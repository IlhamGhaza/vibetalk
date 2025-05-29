import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/theme_cubit.dart';
import '../../../core/theme.dart';

class AuthTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    this.enabled = true,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label == null
                ? const SizedBox.shrink()
                : Text(
                    label ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? DefaultColors.whiteText
                          : DefaultColors.lightTextColor,
                    ),
                  ),
            const SizedBox(height: 8),
            TextFormField(
              textInputAction: textInputAction,
              enabled: enabled,
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              validator: validator,
              style: TextStyle(
                color: isDarkMode
                    ? DefaultColors.whiteText
                    : DefaultColors.lightTextColor,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: DefaultColors.greyText),
                prefixIcon: prefixIcon != null
                    ? IconTheme(
                        data: IconThemeData(
                          color: isDarkMode
                              ? DefaultColors.textInputIcon
                              : DefaultColors.greyText,
                        ),
                        child: prefixIcon!,
                      )
                    : null,
                suffixIcon: suffixIcon != null
                    ? IconTheme(
                        data: IconThemeData(
                          color: isDarkMode
                              ? DefaultColors.textInputIcon
                              : DefaultColors.greyText,
                        ),
                        child: suffixIcon!,
                      )
                    : null,
                filled: true,
                fillColor: enabled
                    ? (isDarkMode
                          ? DefaultColors.textInputBackground
                          : DefaultColors.lightInputBackground)
                    : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode
                        ? Colors.transparent
                        : DefaultColors.greyText.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode
                        ? Colors.transparent
                        : DefaultColors.greyText.withOpacity(0.3),
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: DefaultColors.greyText.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: DefaultColors.primaryColor,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.error,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.error,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
