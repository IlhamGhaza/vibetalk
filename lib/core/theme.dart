import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontSize {
  static const small = 12.0;
  static const standard = 14.0;
  static const standardUp = 16.0;
  static const medium = 13.0;
  static const large = 26.0;
}

class DefaultColors {
  static const greyText = Color(0xffb3b9c9);
  static const whiteText = Color(0xffFFFFFF);
  static const senderMessage = Color(0xff7a8194);
  static const receiverMessage = Color(0xff3d4354);
  static const sentMessage = Color(0xffF5F5F5);
  static const messageListPage = Color(0xff292f3f);
  static const buttonColor = Color(0xff7a8194);
  static const textInputText = Color(0xff13162f);

  static const primaryColor = Color(0xff5d9cec);
  static const textInputBackground = Color(0xff2e3440);
  static const textInputShadow = Color(0x4d000000);
  static const textInputLabel = Color(0xffd8dee9);
  static const textInputIcon = Color(0xffeceff4);
  static const textInputCursor = Color(0xff88c0d0);
  static const darkScaffoldBackground = Color(0xff1b202d);
  static const lightScaffoldBackground = Color(0xffffffff);
  static const lightTextColor = Color(0xff000000);

   static const Color lightReceiverMessage = Color(0xFFE8E8E8);
  static const Color darkReceiverMessage = Color(0xFF303030);
  static const Color lightSenderMessage = Color(0xFF007AFF);
  static const Color darkSenderMessage = Color(0xFF0A84FF);
  static const Color lightInputBackground = Color(0xFFF2F2F7);
  static const Color darkInputBackground = Color(0xFF1C1C1E);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: DefaultColors.primaryColor,
      scaffoldBackgroundColor: DefaultColors.darkScaffoldBackground,
      textTheme: TextTheme(
        titleMedium: GoogleFonts.alegreyaSans(
          fontSize: FontSize.medium,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.alegreyaSans(
          fontSize: FontSize.large,
          color: Colors.white,
        ),
        bodySmall: GoogleFonts.alegreyaSans(
          fontSize: FontSize.standardUp,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.alegreyaSans(
          fontSize: FontSize.standard,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.alegreyaSans(
          fontSize: FontSize.standardUp,
          color: Colors.white,
        ),
        labelSmall: GoogleFonts.alegreyaSans(
          fontSize: FontSize.small,
          color: DefaultColors.greyText,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DefaultColors.textInputBackground,
        labelStyle: TextStyle(color: DefaultColors.textInputLabel),
        hintStyle: TextStyle(color: DefaultColors.greyText),
        iconColor: DefaultColors.textInputIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: DefaultColors.primaryColor),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: DefaultColors.textInputCursor,
      ),
      buttonTheme:
          const ButtonThemeData(buttonColor: DefaultColors.buttonColor),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: DefaultColors.primaryColor,
      scaffoldBackgroundColor: DefaultColors.lightScaffoldBackground,
      textTheme: TextTheme(
        titleMedium: GoogleFonts.alegreyaSans(
          fontSize: FontSize.medium,
          color: DefaultColors.lightTextColor,
        ),
        titleLarge: GoogleFonts.alegreyaSans(
          fontSize: FontSize.large,
          color: DefaultColors.lightTextColor,
        ),
        bodySmall: GoogleFonts.alegreyaSans(
          fontSize: FontSize.standardUp,
          color: DefaultColors.lightTextColor,
        ),
        bodyMedium: GoogleFonts.alegreyaSans(
          fontSize: FontSize.standard,
          color: DefaultColors.lightTextColor,
        ),
        bodyLarge: GoogleFonts.alegreyaSans(
          fontSize: FontSize.standardUp,
          color: DefaultColors.lightTextColor,
        ),
        labelSmall: GoogleFonts.alegreyaSans(
          fontSize: FontSize.small,
          color: DefaultColors.greyText,
        ),
      ),
      iconTheme: IconThemeData(color: DefaultColors.lightTextColor),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DefaultColors
            .textInputBackground, // Menggunakan warna latar belakang input yang lebih sesuai
        labelStyle: TextStyle(color: DefaultColors.lightTextColor),
        hintStyle: TextStyle(color: DefaultColors.greyText),
        iconColor: DefaultColors.lightTextColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: DefaultColors.greyText),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: DefaultColors.greyText),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: DefaultColors.primaryColor),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: DefaultColors.primaryColor,
      ),
      buttonTheme: ButtonThemeData(buttonColor: DefaultColors.primaryColor),
    );
  }
}
