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
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  DocumentSnapshot? _lastDocument;
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreMessages();
    }
  }

  Future<void> _initializeLastDocument() async {
    if (_messages.isNotEmpty && _lastDocument == null) {
      try {
        _lastDocument = await _firestore
            .collection('messages')
            .doc(_messages.last.id)
            .get();
      } catch (e) {
        debugPrint('Error initializing last document: $e');
      }
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || _lastDocument == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final moreMessages = await FirebaseDatasource.instance.loadMoreMessages(
        channelId(widget.partnerUser.id, currentUser!.uid),
        _lastDocument!,
      );

      if (moreMessages.isNotEmpty) {
        // Fix: Await the Future and get the actual DocumentSnapshot
        final lastDocSnapshot = await _firestore
            .collection('messages')
            .doc(moreMessages.last.id)
            .get();

        setState(() {
          _messages.addAll(moreMessages);
          _lastDocument = lastDocSnapshot;
        });
      }
    } catch (e) {
      debugPrint('Error loading more messages: $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
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
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

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

                        if (snapshot.hasData) {
                          _messages = snapshot.data!;
                          if (_messages.isNotEmpty && _lastDocument == null) {
                            _initializeLastDocument();
                          }
                        }

                        final List<Message> messages = _messages;
                        if (messages.isEmpty) {
                          return Center(
                            child: Text(
                              context.tr('home.no_message'),
                              style: theme.textTheme.bodyMedium,
                            ),
                          );
                        }

                        return Stack(
                          children: [
                            ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              reverse: true,
                              padding: const EdgeInsets.all(10),
                              itemCount:
                                  messages.length + (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == messages.length) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        color: DefaultColors.primaryColor,
                                      ),
                                    ),
                                  );
                                }

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
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? DefaultColors.darkInputBackground
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(24.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    style: TextStyle(
                                      color: Colors.white
                                    ),
                                    cursorColor: DefaultColors.primaryColor,
                                    decoration: InputDecoration(
                                      hintText: "chat.type_message".tr(),
                                      // hintStyle: theme.textTheme.labelSmall,
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      log(_messageController.text);
                                      sendMessage();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: DefaultColors.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(
                                        Icons.send,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildIconButton(
                          Icons.camera_alt,
                          () => _sendMessageImage(true),
                          theme,
                        ),
                        const SizedBox(width: 12),
                        _buildIconButton(
                          Icons.photo_library,
                          () => _sendMessageImage(false),
                          theme,
                        ),
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

  Widget _buildIconButton(IconData icon, VoidCallback onTap, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.iconTheme.color!.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: theme.iconTheme.color, size: 20),
      ),
    );
  }
}
