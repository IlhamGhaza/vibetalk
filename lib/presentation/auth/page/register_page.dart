import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart'; // Contoh import untuk lokalisasi
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibetalk/core/utils/snackbar_utils.dart';
import '../../../core/bloc/theme_cubit.dart';
import '../../../core/theme.dart';
import '../../../nav_bar.dart';
import '../widget/auth_button.dart';
import '../widget/auth_text_field.dart';

import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final authResult = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user?.uid)
            .set({
              'email': _emailController.text,
              'userName': _nameController.text.trim().replaceAll(' ', ''),
              'name': _nameController.text,
              'photo': '',
            });
        debugPrint('Register success, $authResult');
        SnackbarUtils(
          text: context.tr('auth.snackbar_register_success'),
          backgroundColor: Colors.green,
        ).showSuccessSnackBar(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavBar()),
        );
      } catch (e) {
        SnackbarUtils(text: context.tr('auth.snackbar_register_failed'), backgroundColor: Colors.red).showErrorSnackBar(context);
        debugPrint(e.toString()); // Tetap gunakan debugPrint untuk error development
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
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: DefaultColors.primaryColor,
                        child: Icon(
                          Icons.message,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        context.tr('auth.register'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('auth.register_subtitle'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: DefaultColors.greyText,
                        ),
                      ),
                      const SizedBox(height: 32),
                      AuthTextField(
                        suffixIcon: const Icon(Icons.email),
                        label: context.tr('auth.username_label'),
                        textInputAction: TextInputAction.next,
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.tr('auth.validation_username_empty');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        suffixIcon: const Icon(Icons.email),
                        label: context.tr('auth.email'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
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
                        label: context.tr('auth.password'),
                        controller: _passwordController,
                        textInputAction: TextInputAction.next,
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
                            return context.tr('auth.validation_password_min_length');
                          }
                          // if (!RegExp(
                          //   r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$',
                          // ).hasMatch(value)) {
                          //   return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
                          // }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        label: context.tr('auth.confirm_password_label'),
                        textInputAction: TextInputAction.done,
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: _toggleConfirmPasswordVisibility,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.tr('auth.validation_confirm_password_empty');
                          }
                          if (value != _passwordController.text) {
                            return context.tr('auth.validation_password_mismatch');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      AuthButton(
                        text: context.tr('auth.register'),
                        onPressed: _handleRegister,
                        isOutlined: false,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.tr('auth.already_have_account_prompt'),
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
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            child: Text(
                              context.tr('auth.login'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.primaryColor,
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
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? Colors.grey[700]
                              : Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(
                              color: isDarkMode
                                  ? Colors.grey[600]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {},
                      ),
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
