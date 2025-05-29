import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/bloc/language_cubit.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageCubit = context.watch<LanguageCubit>();
    final currentLocale = languageCubit.state;

    return Scaffold(
      appBar: AppBar(title: Text('app.select_language'.tr())),
      body: BlocBuilder<LanguageCubit, Locale>(
        builder: (context, currentLocale) {
          return ListView(
            children: [
              RadioListTile<String>(
                title: Text('english'.tr()),
                value: 'en',
                groupValue: currentLocale.languageCode,
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
                title: Text('indonesian'.tr()),
                value: 'id',
                groupValue: currentLocale.languageCode,
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
                title: Text('korean'.tr()),
                value: 'ko',
                groupValue: currentLocale.languageCode,
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
  }
}
