import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibetalk/presentation/auth/page/login_page.dart';

import '../../../core/bloc/theme_cubit.dart';
import '../../../nav_bar.dart';
import '../../../core/theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _hasNavigated = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await _controller.forward();
        log('User is already logged in. Navigating to home.');
        _navigateToHome();
      } else {
        _auth.authStateChanges().listen((User? user) {
          if (!_hasNavigated && mounted) {
            if (user != null) {
              log('User is logged in. Navigating to home.');
              _navigateToHome();
            } else {
              log('User is not logged in. Navigating to login.');
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (!_hasNavigated && mounted) {
                  _navigateToLogin();
                }
              });
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');

      await _controller.forward();
      _navigateToLogin();
    }
  }

  void _navigateToHome() {
    if (_hasNavigated || !mounted) return;

    _hasNavigated = true;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => const NavBar()));
  }

  void _navigateToLogin() {
    if (_hasNavigated || !mounted) return;

    _hasNavigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        return Scaffold(
          body: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.message,
                            size: 150,
                            color: isDarkMode
                                ? AppTheme.lightTheme.primaryColor
                                : AppTheme.darkTheme.primaryColor,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Vibetalk',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDarkMode
                                    ? AppTheme.lightTheme.primaryColor
                                    : AppTheme.darkTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
