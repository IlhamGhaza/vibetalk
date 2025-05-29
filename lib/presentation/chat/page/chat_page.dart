import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibetalk/core/utils/snackbar_utils.dart';
import '../../../core/bloc/theme_cubit.dart';
import '../../../core/theme.dart';
import '../../../core/utils/permission.dart';
import '../widget/chat_bubble.dart';
import '../widget/chat_bubble_image.dart';
import '../../../core/widgets/spaces.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../../data/models/channel_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/user_model.dart';

class ChatPage extends StatefulWidget {
  final UserModel partnerUser;
  const ChatPage({super.key, required this.partnerUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? imageFile;

  @override
  void initState() {
    super.initState();
  }

  void sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    final channel = Channel(
      id: channelId(currentUser!.uid, widget.partnerUser.id),
      memberIds: [currentUser!.uid, widget.partnerUser.id],
      members: [UserModel.fromFirebaseUser(currentUser!), widget.partnerUser],
      lastMessage: _messageController.text.trim(),
      sendBy: currentUser!.uid,
      lastTime: Timestamp.now(),
      unRead: {currentUser!.uid: false, widget.partnerUser.id: true},
    );
    await FirebaseDatasource.instance.updateChannel(
      channel.id,
      channel.toMap(),
    );

    var docRef = FirebaseFirestore.instance.collection('messages').doc();
    var message = Message(
      id: docRef.id,
      textMessage: _messageController.text.trim(),
      senderId: currentUser!.uid,
      sendAt: Timestamp.now(),
      channelId: channel.id,
      type: 'text',
    );
    FirebaseDatasource.instance.addMessage(message);

    var channelUpdateData = {
      'lastMessage': message.textMessage,
      'sendBy': currentUser!.uid,
      'lastTime': message.sendAt,
      'unRead': {currentUser!.uid: false, widget.partnerUser.id: true},
    };
    FirebaseDatasource.instance.updateChannel(channel.id, channelUpdateData);

    _messageController.clear();
  }

  void _sendMessageImage(bool isCamera) async {
    try {
      XFile? image;

      if (isCamera) {
        try {
          bool cameraPermissionGranted = await checkCameraPermission();
          if (cameraPermissionGranted) {
            image = await ImagePicker().pickImage(
              source: ImageSource.camera,
              imageQuality: 80,
            );
          } else {
            if (mounted) {
              SnackbarUtils(
                text: 'Camera permission is required to take photos',
                backgroundColor: Colors.red,
              );
            }
            return;
          }
        } catch (e) {
          debugPrint('Camera permission error: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Camera not available, switching to gallery',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }

          isCamera = false;
        }
      }

      if (!isCamera) {
        try {
          bool storagePermissionGranted =
              await checkAndroidExternalStoragePermission();
          if (storagePermissionGranted) {
            image = await ImagePicker().pickImage(
              source: ImageSource.gallery,
              imageQuality: 80,
            );
          } else {
            if (mounted) {
              SnackbarUtils(
                text: 'Storage permission is required to access gallery',
                backgroundColor: Colors.red,
              ).showErrorSnackBar(context);
            }
            return;
          }
        } catch (e) {
          debugPrint('Storage permission error: $e');
          if (mounted) {
            SnackbarUtils(
              text: 'Unable to access gallery: ${e.toString()}',
              backgroundColor: Colors.red,
            ).showErrorSnackBar(context);
          }
          return;
        }
      }

      if (image != null) {
        final String fileExtension = image.path.toLowerCase();
        if (!fileExtension.endsWith('.jpg') &&
            !fileExtension.endsWith('.jpeg') &&
            !fileExtension.endsWith('.png') &&
            !fileExtension.endsWith('.gif') &&
            !fileExtension.endsWith('.webp')) {
          if (mounted) {
            SnackbarUtils(
              text: 'Please select a valid image file (JPG, PNG, GIF, WEBP)',
              backgroundColor: Colors.red,
            ).showErrorSnackBar(context);
          }
          return;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text('Uploading image...'),
                ],
              ),
              duration: Duration(seconds: 10),
            ),
          );
        }

        try {
          final storageRef = FirebaseStorage.instance.ref();
          final imageRef = storageRef
              .child('images')
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

          await imageRef.putFile(File(image.path));

          final imageUrl = await imageRef.getDownloadURL();

          final channel = Channel(
            id: channelId(currentUser!.uid, widget.partnerUser.id),
            memberIds: [currentUser!.uid, widget.partnerUser.id],
            members: [
              UserModel.fromFirebaseUser(currentUser!),
              widget.partnerUser,
            ],
            lastMessage: 'Send an image',
            sendBy: currentUser!.uid,
            lastTime: Timestamp.now(),
            unRead: {currentUser!.uid: false, widget.partnerUser.id: true},
          );

          await FirebaseDatasource.instance.updateChannel(
            channel.id,
            channel.toMap(),
          );

          var docRef = FirebaseFirestore.instance.collection('messages').doc();
          var message = Message(
            id: docRef.id,
            textMessage: imageUrl,
            senderId: currentUser!.uid,
            sendAt: Timestamp.now(),
            channelId: channel.id,
            type: 'image',
          );

          FirebaseDatasource.instance.addMessage(message);

          var channelUpdateData = {
            'lastMessage': 'Send an image',
            'sendBy': currentUser!.uid,
            'lastTime': message.sendAt,
            'unRead': {currentUser!.uid: false, widget.partnerUser.id: true},
          };

          FirebaseDatasource.instance.updateChannel(
            channel.id,
            channelUpdateData,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Image sent successfully',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          debugPrint('Error uploading image: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            SnackbarUtils(
              text: 'Failed to upload image: ${e.toString()}',
              backgroundColor: Colors.red,
            ).showErrorSnackBar(context);
          }
        }
      }
    } catch (e) {
      debugPrint('Error in _sendMessageImage: $e');
      if (mounted) {
        SnackbarUtils(
          text: 'An error occurred: ${e.toString()}',
          backgroundColor: Colors.red,
        ).showErrorSnackBar(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: theme.iconTheme.color,
                        ),
                      ),
                      const SpaceWidth(16),
                      widget.partnerUser.photo.isEmpty
                          ? CircleAvatar(
                              backgroundColor: Colors.blueGrey,
                              radius: 22,
                              child: Text(
                                widget.partnerUser.userName[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                          : CircleAvatar(
                              radius: 22,
                              backgroundImage: NetworkImage(
                                widget.partnerUser.photo,
                              ),
                            ),
                      const SpaceWidth(16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.partnerUser.userName,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Active now",
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: StreamBuilder<List<Message>>(
                      stream: FirebaseDatasource.instance.messageStream(
                        channelId(widget.partnerUser.id, currentUser!.uid),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: DefaultColors.primaryColor,
                            ),
                          );
                        }
                        final List<Message> messages = snapshot.data ?? [];
                        if (messages.isEmpty) {
                          return Center(
                            child: Text(
                              context.tr('home.no_message'),
                              style: theme.textTheme.bodyMedium,
                            ),
                          );
                        }
                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          reverse: true,
                          padding: const EdgeInsets.all(10),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return message.type == 'image'
                                ? ChatBubbleImage(
                                    url: message.textMessage,
                                    direction:
                                        message.senderId == currentUser!.uid
                                        ? Direction.right
                                        : Direction.left,
                                  )
                                : ChatBubble(
                                    partnerUser: widget.partnerUser,
                                    direction:
                                        message.senderId == currentUser!.uid
                                        ? Direction.right
                                        : Direction.left,
                                    message: message.textMessage,
                                    type: BubbleType.alone,
                                  );
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 80.0,
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? DefaultColors.darkInputBackground
                                  : DefaultColors.lightInputBackground,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Row(
                              children: [
                                const SpaceWidth(16),
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    style: theme.textTheme.bodyMedium,
                                    decoration: InputDecoration(
                                      hintText: "chat.type_message".tr(),
                                      hintStyle: theme.textTheme.labelSmall,
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    log(_messageController.text);
                                    sendMessage();
                                  },
                                  child: const Icon(
                                    Icons.send,
                                    color: DefaultColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SpaceWidth(16),
                        GestureDetector(
                          onTap: () {
                            _sendMessageImage(true);
                          },
                          child: Icon(
                            Icons.camera_alt,
                            color: theme.iconTheme.color,
                          ),
                        ),
                        const SpaceWidth(16),
                        GestureDetector(
                          onTap: () {
                            _sendMessageImage(false);
                          },
                          child: Icon(
                            Icons.photo_library,
                            color: theme.iconTheme.color,
                          ),
                        ),
                        const SpaceWidth(16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
