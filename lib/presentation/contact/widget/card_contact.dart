import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibetalk/core/widgets/spaces.dart';

import '../../../core/bloc/theme_cubit.dart';
import '../../../core/theme.dart';
import '../../../data/models/user_model.dart';

class CardContact extends StatelessWidget {
  final UserModel user;
  const CardContact({super.key, required this.user});

 @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

        return Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(26.0),
              child: user.photo.isNotEmpty
                  ? Image.network(
                      user.photo,
                      width: 52.0,
                      height: 52.0,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 52.0,
                      height: 52.0,
                      color: Colors.grey,
                      child: Icon(
                        size: 32,
                        Icons.person,
                        color: isDarkMode ? Colors.white : Colors.grey[600],
                      ),
                    ),
            ),
            const SpaceWidth(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.userName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email,
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 12.0),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
