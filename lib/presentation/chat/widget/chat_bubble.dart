import 'package:flutter/material.dart';
import 'package:vibetalk/core/theme.dart';

import '../../../core/widgets/spaces.dart';
import '../../../data/models/user_model.dart';
import '../../../core/widgets/avatar.dart';

enum BubbleType { top, middle, bottom, alone }

enum Direction { left, right }

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.direction,
    required this.message,
    this.photoUrl,
    required this.type,
    required this.partnerUser,
  });
  final Direction direction;
  final String message;
  final String? photoUrl;
  final BubbleType type;
  final UserModel partnerUser;

  @override
  Widget build(BuildContext context) {
    final isOnLeft = direction == Direction.left;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: isOnLeft
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: isOnLeft
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                isOnLeft
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.person,
                          color: theme.iconTheme.color?.withValues(alpha: 0.6),
                          size: 20,
                        ),
                      )
                    : const SizedBox(),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: _borderRadius(direction, type),
                    color: isOnLeft
                        ? (isDarkMode
                              ? DefaultColors.darkReceiverMessage
                              : DefaultColors.lightReceiverMessage)
                        : (isDarkMode
                              ? DefaultColors.darkSenderMessage
                              : DefaultColors.lightSenderMessage),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isOnLeft
                          ? (isDarkMode ? Colors.white : Colors.black87)
                          : Colors.white,
                    ),
                  ),
                ),
                !isOnLeft
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.person,
                          color: theme.iconTheme.color?.withValues(alpha: 0.6),
                          size: 20,
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeading(BubbleType type, String name, ThemeData theme) {
    if (type == BubbleType.alone || type == BubbleType.bottom) {
      if (photoUrl != null) {
        return Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(photoUrl!)),
            const SpaceWidth(12),
            Text(
              name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }
      return Row(
        children: [
          const Avatar(radius: 20),
          const SpaceWidth(12),
          Text(
            name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
    return const SizedBox(width: 24);
  }

  BorderRadius _borderRadius(Direction dir, BubbleType type) {
    const radius1 = Radius.circular(15);
    const radius2 = Radius.circular(5);
    switch (type) {
      case BubbleType.top:
        return dir == Direction.left
            ? const BorderRadius.only(
                topLeft: radius1,
                topRight: radius1,
                bottomLeft: radius2,
                bottomRight: radius1,
              )
            : const BorderRadius.only(
                topLeft: radius1,
                topRight: radius1,
                bottomLeft: radius1,
                bottomRight: radius2,
              );

      case BubbleType.middle:
        return dir == Direction.left
            ? const BorderRadius.only(
                topLeft: radius2,
                topRight: radius1,
                bottomLeft: radius2,
                bottomRight: radius1,
              )
            : const BorderRadius.only(
                topLeft: radius1,
                topRight: radius2,
                bottomLeft: radius1,
                bottomRight: radius2,
              );
      case BubbleType.bottom:
        return dir == Direction.left
            ? const BorderRadius.only(
                topLeft: radius2,
                topRight: radius1,
                bottomLeft: radius1,
                bottomRight: radius1,
              )
            : const BorderRadius.only(
                topLeft: radius1,
                topRight: radius2,
                bottomLeft: radius1,
                bottomRight: radius1,
              );
      case BubbleType.alone:
        return BorderRadius.circular(15);
    }
  }
}
