// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:vibetalk/core/theme.dart';

import '../../../core/widgets/spaces.dart';
import '../../../data/models/user_model.dart';
import '../../../core/widgets/avatar.dart';

enum BubbleType { top, middle, bottom, alone }

enum Direction { left, right }

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    Key? key,
    required this.direction,
    required this.message,
    this.photoUrl,
    required this.type,
    required this.partnerUser,
  }) : super(key: key);
  final Direction direction;
  final String message;
  final String? photoUrl;
  final BubbleType type;
  final UserModel partnerUser;

  @override
  Widget build(BuildContext context) {
    final isOnLeft = direction == Direction.left;
    return Column(
      crossAxisAlignment: isOnLeft
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        // if (isOnLeft) _buildLeading(type, partnerUser.username),
        Row(
          mainAxisAlignment: isOnLeft
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // SizedBox(width: isOnLeft ? 40 : 0),
            Row(
              children: [
                isOnLeft
                    ? const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.person, color: Colors.grey, size: 20),
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
                        ? const Color(0xffF2F7FB)
                        : DefaultColors.primaryColor,
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isOnLeft ? Colors.black : Colors.white,
                      // overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                !isOnLeft
                    ? const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.person, color: Colors.grey, size: 20),
                      )
                    : const SizedBox(),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeading(BubbleType type, String name) {
    if (type == BubbleType.alone || type == BubbleType.bottom) {
      if (photoUrl != null) {
        return Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(photoUrl!)),
            const SpaceWidth(12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
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
