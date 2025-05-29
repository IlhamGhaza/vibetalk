import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/bloc/language_cubit.dart';
import '../../../core/bloc/theme_cubit.dart';
import '../../../core/theme.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

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
            'app.select_language'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          iconTheme: theme.iconTheme,
        ),
        body: BlocBuilder<LanguageCubit, Locale>(
          builder: (context, currentLocale) {
            return ListView(
              children: [
                RadioListTile<String>(
                                    title: Text(
                      'english'.tr(),
                      style: theme.textTheme.bodyMedium,
                    ),
                    value: 'en',
                    groupValue: currentLocale.languageCode,
                    activeColor: DefaultColors.primaryColor,
                    onChanged: (String? value) {
                      if (value != null) {
                        context.read<LanguageCubit>().changeLanguage(
                          context,
                          value,
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(
                      'indonesian'.tr(),
                      style: theme.textTheme.bodyMedium,
                    ),
                    value: 'id',
                    groupValue: currentLocale.languageCode,
                    activeColor: DefaultColors.primaryColor,
                    onChanged: (String? value) {
                      if (value != null) {
                        context.read<LanguageCubit>().changeLanguage(
                          context,
                          value,
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(
                      'korean'.tr(),
                      style: theme.textTheme.bodyMedium,
                    ),
                    value: 'ko',
                    groupValue: currentLocale.languageCode,
                    activeColor: DefaultColors.primaryColor,
                    onChanged: (String? value) {
                      if (value != null) {
                        context.read<LanguageCubit>().changeLanguage(
                          context,
                          value,
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }


}
