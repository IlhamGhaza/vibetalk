import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc/theme_cubit.dart';
import '../../../core/theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../nav_bar.dart';
import 'register_page.dart';

import '../widget/auth_button.dart';
import '../widget/auth_text_field.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        SnackbarUtils(
          text: context.tr('auth.snackbar_login_success'),
          backgroundColor: Colors.green,
        ).showSuccessSnackBar(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavBar()),
        );
      } catch (e) {
        SnackbarUtils(
          text: context.tr('auth.snackbar_login_failed'),
          backgroundColor: Colors.red,
        ).showErrorSnackBar(context);
        debugPrint(e.toString());
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 28),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: DefaultColors.primaryColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        context.tr('auth.login'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? DefaultColors.whiteText
                              : DefaultColors.lightTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('auth.login_subtitle'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: DefaultColors.greyText,
                        ),
                      ),
                      const SizedBox(height: 32),
                      AuthTextField(
                        textInputAction: TextInputAction.next,
                        suffixIcon: const Icon(Icons.email),
                        label: context.tr('auth.email'),
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.tr('auth.validation_email_empty');
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return context.tr('auth.validation_email_invalid');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        textInputAction: TextInputAction.done,
                        label: context.tr('auth.password'),
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.tr('auth.validation_password_empty');
                          }
                          if (value.length < 8) {
                            return context.tr(
                              'auth.validation_password_min_length',
                            );
                          }
                          return null;
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: Text(
                            context.tr('auth.forgot_password_prompt'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: DefaultColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AuthButton(
                        text: context.tr('auth.login'),
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.tr('auth.dont_have_account_prompt'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDarkMode
                                  ? DefaultColors.whiteText
                                  : DefaultColors.lightTextColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: Text(
                              context.tr('auth.register'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: DefaultColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
                          height: 24.0,
                          width: 24.0,
                        ),
                        label: Text(
                          context.tr('auth.login_with_google_button'),
                          style: TextStyle(
                            color: isDarkMode
                                ? DefaultColors.whiteText
                                : DefaultColors.lightTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? DefaultColors.textInputBackground
                              : DefaultColors.lightInputBackground,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                              color: isDarkMode
                                  ? Colors.transparent
                                  : DefaultColors.greyText.withOpacity(0.3),
                            ),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          SnackbarUtils(
                            text: 'auth.feature_not_available'.tr(),
                            backgroundColor: Colors.red,
                          ).showErrorSnackBar(context);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
