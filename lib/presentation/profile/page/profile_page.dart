import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibetalk/core/utils/snackbar_utils.dart';
import 'package:vibetalk/presentation/profile/page/edit_profile_page.dart';
import '../../../core/bloc/language_cubit.dart';
import '../../../core/bloc/theme_cubit.dart';
import '../../../core/theme.dart';
import '../../../data/datasources/firebase_datasource.dart';
import '../../../data/models/user_model.dart';
import '../../auth/page/splash_page.dart';
import 'language_selection_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _currentUser;

  void _getCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      if (mounted) {
        setState(() {
          _currentUser = null;
        });
      }
      return;
    }

    try {
      final UserModel? fetchedUser = await FirebaseDatasource.instance.getUser(
        firebaseUser.uid,
      );
      if (mounted) {
        setState(() {
          _currentUser = fetchedUser;
        });
      }
    } catch (e) {
      if (mounted) {
        log(e.toString());
        SnackbarUtils(
          text: 'Gagal memuat data profil: $e',
          backgroundColor: Colors.red,
        ).showErrorSnackBar(context);
        setState(() {
          _currentUser = null;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _username = 'Nama Pengguna';
  final String _userEmail = 'email.pengguna@example.com';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'profile.profile'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
            iconTheme: theme.iconTheme,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        ).then((_) {
                          _getCurrentUser();
                        });
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: DefaultColors.primaryColor,
                        child:
                            _currentUser == null || _currentUser!.photo.isEmpty
                            ? Icon(Icons.person, size: 60, color: Colors.white)
                            : ClipOval(
                                child: Image.network(
                                  _currentUser!.photo,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            color: DefaultColors.primaryColor,
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentUser?.userName ?? _username,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentUser?.email ?? _userEmail,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.labelSmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  context.tr('app.setting'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      key: ValueKey(themeMode),
                      color: DefaultColors.primaryColor,
                    ),
                  ),
                  title: Text(
                    context.tr('profile.theme'),
                    style: theme.textTheme.titleMedium,
                  ),
                  trailing: BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, themeMode) {
                      return Switch(
                        value: themeMode == ThemeMode.dark,
                        onChanged: (value) {
                          context.read<ThemeCubit>().updateTheme(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                        activeColor: DefaultColors.primaryColor,
                      );
                    },
                  ),
                ),
              ),

              BlocBuilder<LanguageCubit, Locale>(
                builder: (context, currentLocale) {
                  String currentLanguageName;
                  switch (currentLocale.languageCode) {
                    case 'en':
                      currentLanguageName = 'profile.english'.tr();
                      break;
                    case 'id':
                      currentLanguageName = 'profile.indonesian'.tr();
                      break;
                    case 'ko':
                      currentLanguageName = 'profile.korean'.tr();
                      break;
                    default:
                      currentLanguageName = 'profile.indonesian'.tr();
                  }
                  return ListTile(
                    leading: Icon(Icons.language, color: theme.iconTheme.color),
                    title: Text(
                      'profile.language'.tr(),
                      style: theme.textTheme.bodyMedium,
                    ),
                    trailing: Text(
                      currentLanguageName,
                      style: theme.textTheme.bodyMedium,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguageSelectionPage(),
                        ),
                      );
                    },
                  );
                },
              ),

              const Divider(height: 32),

              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text(
                  context.tr('auth.logout'),
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: theme.scaffoldBackgroundColor,
                        title: Text(
                          context.tr('auth.logout'),
                          style: theme.textTheme.titleMedium,
                        ),
                        content: Text(
                          context.tr('auth.logout_confirmation'),
                          style: theme.textTheme.bodyMedium,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              context.tr('app.cancel'),
                              style: TextStyle(
                                color: DefaultColors.primaryColor,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              _auth.signOut();
                              SnackbarUtils(
                                text: 'auth.snackbar_logout_success'.tr(),
                                backgroundColor: Colors.green,
                              ).showSuccessSnackBar(context);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SplashPage(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                context.tr('auth.logout'),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
