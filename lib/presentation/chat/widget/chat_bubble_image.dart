// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../../core/widgets/spaces.dart';
import 'chat_bubble.dart';


class ChatBubbleImage extends StatelessWidget {
  final String url;
  final Direction direction;
  const ChatBubbleImage({Key? key, required this.url, required this.direction})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOnLeft = direction == Direction.left;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isOnLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(left: isOnLeft ? 40 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                url.isEmpty
                    ? const SizedBox()
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          url,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                const SpaceHeight(8),
                // const Text(
                //   "09:26 AM",
                //   style: TextStyle(
                //     fontSize: 14.0,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.grey,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
