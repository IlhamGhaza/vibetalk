import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/bloc/theme_cubit.dart';
import '../../../core/theme.dart';
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
    analyticsLogEvent();
    super.initState();
  }

  void analyticsLogEvent() async {
    await FirebaseAnalytics.instance.logBeginCheckout(
      value: 10.0,
      currency: 'USD',
      items: [
        AnalyticsEventItem(itemName: 'Socks', itemId: 'xjw73ndnw', price: 10.0),
      ],
      coupon: '10PERCENTOFF',
    );
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
    final XFile? image = await ImagePicker().pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (image != null) {
      // Create a Reference to the file

      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef
          .child('images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await imageRef.putFile(File(image.path));

      // Dapatkan URL gambar yang telah diupload
      final imageUrl = await imageRef.getDownloadURL();
      final channel = Channel(
        id: channelId(currentUser!.uid, widget.partnerUser.id),
        memberIds: [currentUser!.uid, widget.partnerUser.id],
        members: [UserModel.fromFirebaseUser(currentUser!), widget.partnerUser],
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
      FirebaseDatasource.instance.updateChannel(channel.id, channelUpdateData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
        return Scaffold(
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
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const Text(
                            "Active now",
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
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
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final List<Message> messages = snapshot.data ?? [];
                        //if message is null
                        if (messages.isEmpty) {
                          return const Center(child: Text('No message found'));
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
                              color: const Color(0xffF3F6F6),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Row(
                              children: [
                                const SpaceWidth(16),
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: const InputDecoration(
                                      hintText: "Type a message",
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
                          child: const Icon(Icons.camera_alt),
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
