import 'package:flutter/material.dart';

enum AppLanguage { english, indonesian }

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  AppLanguage _selectedLanguage = AppLanguage.indonesian;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Bahasa')),
      body: ListView(
        children: [
          RadioListTile<AppLanguage>(
            title: const Text('English'),
            value: AppLanguage.english,
            groupValue: _selectedLanguage,
            onChanged: (AppLanguage? value) {
              if (value != null) {
                setState(() {
                  _selectedLanguage = value;
                });

                print('Bahasa diubah menjadi: ${value.toString()}');
              }
            },
          ),

          RadioListTile<AppLanguage>(
            title: const Text('Bahasa Indonesia'),
            value: AppLanguage.indonesian,
            groupValue: _selectedLanguage,
            onChanged: (AppLanguage? value) {
              if (value != null) {
                setState(() {
                  _selectedLanguage = value;
                });

                print('Bahasa diubah menjadi: ${value.toString()}');
              }
            },
          ),
        ],
      ),
    );
  }
}
