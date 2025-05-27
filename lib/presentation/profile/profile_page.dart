import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibetalk/core/utils/snackbar_utils.dart';
import 'package:vibetalk/presentation/profile/edit_profile_page.dart';
import '../../core/bloc/language_cubit.dart';
import '../../core/bloc/theme_cubit.dart';
import '../../core/theme.dart';
import '../../data/datasources/firebase_datasource.dart';
import '../../data/models/user_model.dart';
import '../auth/page/splash_page.dart';
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
          appBar: AppBar(title: Text('profile.profile'.tr())),
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
                          // Refresh user data when returning from EditProfilePage
                          _getCurrentUser();
                        });
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).primaryColor,
                        child:
                            _currentUser == null || _currentUser!.photo.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: Theme.of(context).colorScheme.onPrimary,
                              )
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
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
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
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentUser?.email ?? _userEmail,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.labelSmall?.color,
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

                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    context.tr('profile.theme'),
                    style: Theme.of(context).textTheme.titleMedium,
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
                        activeColor: Theme.of(context).colorScheme.primary,
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
                      currentLanguageName = 'profile.indonesian'
                          .tr(); // Default or fallback
                  }
                  return ListTile(
                    leading: Icon(
                      Icons.language,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    title: Text('profile.language'.tr()),
                    trailing: Text(currentLanguageName),
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
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  context.tr('auth.logout'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(context.tr('auth.logout')),
                        content: Text(context.tr('auth.logout_confirmation')),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(context.tr('app.cancel')),
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
