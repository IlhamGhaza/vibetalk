import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibetalk/core/extensions/build_context_ext.dart';
import 'package:vibetalk/core/widgets/spaces.dart';

import '../../core/bloc/theme_cubit.dart';
import '../../core/theme.dart';
import '../../data/datasources/firebase_datasource.dart';
import '../../data/models/channel_model.dart';
import '../../data/models/user_model.dart';
import '../chat/widget/card_message.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
        return Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DefaultColors.primaryColor.withValues(alpha: 0.9),
                  DefaultColors.primaryColor.withValues(alpha: 0.7),
                  DefaultColors.darkScaffoldBackground,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const SpaceHeight(16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 44.0,
                              height: 44.0,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(22.0),
                              ),
                              child: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              context.tr('app.title'),
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Hero(
                              tag: 'profile_picture',
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 21,
                                  backgroundImage:
                                      auth.currentUser?.photoURL != null &&
                                          auth.currentUser!.photoURL!.isNotEmpty
                                      ? NetworkImage(
                                          auth.currentUser!.photoURL!,
                                        )
                                      : null,
                                  child:
                                      auth.currentUser?.photoURL == null ||
                                          auth.currentUser!.photoURL!.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SpaceHeight(32),
                        SizedBox(
                          height: 110,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            separatorBuilder:
                                (BuildContext context, int index) {
                                  return const SpaceWidth(16);
                                },
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                return Column(
                                  children: [
                                    Container(
                                      width: 64.0,
                                      height: 64.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.2),
                                            Colors.white.withOpacity(0.1),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          32.0,
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white.withOpacity(0.9),
                                        size: 28,
                                      ),
                                    ),
                                    const SpaceHeight(8),
                                    Text(
                                      context.tr('home.add_story'),
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return _itemProfile(index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: EdgeInsets.only(top: context.deviceHeight * 0.28),
                  width: MediaQuery.of(context).size.width,
                  height: context.deviceHeight * 0.73,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(44),
                      topRight: Radius.circular(44),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(16.0),
                          ),
                        ),
                      ),
                      const SpaceHeight(16),
                      Expanded(
                        child: StreamBuilder<List<Channel>>(
                          stream: auth.currentUser != null
                              ? FirebaseDatasource.instance.channelStream(
                                  auth.currentUser!.uid,
                                )
                              : null,
                          builder: (context, snapshot) {
                            if (auth.currentUser == null) {
                              return Center(
                                child: Text(
                                  context.tr('auth.user_not_found'),
                                ),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }

                            final List<Channel> channels = snapshot.data ?? [];

                            if (channels.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 64,
                                      color: Colors.grey.withOpacity(0.5),
                                    ),
                                    const SpaceHeight(16),
                                   Text(context.tr('home.no_conversation'),
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.withOpacity(0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SpaceHeight(8),
                                   Text(context.tr('home.new_conversation'),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.separated(
                              itemCount: channels.length,
                              itemBuilder: (context, index) {
                                final channel = channels[index];

                                final otherMembers = channel.memberIds
                                    .where((id) => id != auth.currentUser!.uid)
                                    .toList();

                                if (otherMembers.isEmpty) {
                                  return const ListTile(
                                    title: Text('Invalid channel'),
                                  );
                                }

                                final String partnerId = otherMembers.first;

                                return FutureBuilder<UserModel?>(
                                  future: FirebaseDatasource.instance.getUser(
                                    partnerId,
                                  ),
                                  builder: (context, userSnapshot) {
                                    if (userSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    if (userSnapshot.hasError) {
                                      return ListTile(
                                        title: Text(
                                          'Error loading user: ${userSnapshot.error}',
                                        ),
                                      );
                                    }

                                    final UserModel? user = userSnapshot.data;
                                    if (user == null) {
                                      return ListTile(
                                        title: Text(
                                          context.tr('auth.user_not'),
                                        ),
                                      );
                                    }

                                    return CardMessage(
                                      user: user,
                                      index: index,
                                    );
                                  },
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const SpaceHeight(12);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _itemProfile(int index) {
    return Column(
      children: [
        Container(
          width: 64.0,
          height: 64.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32.0),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: Image.network(
              'https://media.istockphoto.com/id/2158693457/id/foto/pasfoto-tampak-samping-potret-pebisnis-yang-percaya-diri.jpg?s=2048x2048&w=is&k=20&c=nci_shC5prENxjvAo0EgsLN5lQlgCiL5zOBZiGGYys4=',
              width: 60.0,
              height: 60.0,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: const Icon(Icons.person, color: Colors.grey),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: const CircularProgressIndicator(),
                );
              },
            ),
          ),
        ),
        const SpaceHeight(8),
        Text(
          'User $index',
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
