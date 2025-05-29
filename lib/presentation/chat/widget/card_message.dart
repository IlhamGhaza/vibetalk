import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/bloc/theme_cubit.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/spaces.dart';
import '../../../data/models/user_model.dart';
import '../page/chat_page.dart';

class CardMessage extends StatelessWidget {
  final UserModel user;
  final int index;
  const CardMessage({super.key, required this.user, required this.index});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ChatPage(partnerUser: user);
                },
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: DefaultColors.primaryColor,
                  radius: 26,
                  child: user.photo.isEmpty
                      ? const Icon(Icons.person, size: 30, color: Colors.white)
                      : CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(user.photo),
                        ),
                ),
                const SpaceWidth(8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.userName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Last message",
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SpaceWidth(16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(DateTime.now().hour - (1 + index)).toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
