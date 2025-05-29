import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibetalk/core/extensions/build_context_ext.dart';
import '../../../core/bloc/theme_cubit.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/spaces.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../../data/models/user_model.dart';
import '../../chat/page/chat_page.dart';
import '../widget/card_contact.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
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
                  isDarkMode
                      ? DefaultColors.darkScaffoldBackground
                      : DefaultColors.lightScaffoldBackground,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SpaceHeight(24),
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
                            context.tr('contact.all_members'),
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            width: 44.0,
                            height: 44.0,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(22.0),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(top: context.deviceHeight * 0.15),
                  height: context.deviceHeight * 0.85,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(44),
                      topRight: Radius.circular(44),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            height: 4,
                            width: 30,
                            decoration: const BoxDecoration(
                              color: Color(0xffE6E6E6),
                              borderRadius: BorderRadius.all(
                                Radius.circular(16.0),
                              ),
                            ),
                          ),
                        ),
                        const SpaceHeight(20),
                        Text(
                          context.tr('contact.users_section_title'),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        StreamBuilder<List<UserModel>>(
                          stream: FirebaseDatasource.instance.allUser(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: DefaultColors.primaryColor,
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  context.tr(
                                    'contact.error_something_went_wrong',
                                  ),
                                  style: theme.textTheme.bodyMedium,
                                ),
                              );
                            }
                            return ListView.separated(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                    return const SpaceHeight(16);
                                  },
                              itemBuilder: (BuildContext context, int index) {
                                if (snapshot.data![index].id !=
                                    FirebaseAuth.instance.currentUser!.uid) {
                                  return InkWell(
                                    onTap: () {
                                      context.push(
                                        ChatPage(
                                          partnerUser: snapshot.data![index],
                                        ),
                                      );
                                    },
                                    child: CardContact(
                                      user: snapshot.data![index],
                                    ),
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
