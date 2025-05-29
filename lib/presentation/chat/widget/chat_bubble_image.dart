import 'package:flutter/material.dart';

import '../../../core/widgets/spaces.dart';
import 'chat_bubble.dart';

class ChatBubbleImage extends StatelessWidget {
  final String url;
  final Direction direction;
  const ChatBubbleImage({super.key, required this.url, required this.direction});

  @override
  Widget build(BuildContext context) {
    final isOnLeft = direction == Direction.left;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isOnLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(
              left: isOnLeft ? 28 : 0,
              right: isOnLeft ? 0 : 28,
            ),
            child: Column(
              crossAxisAlignment: isOnLeft
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                url.isEmpty
                    ? const SizedBox()
                    : Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            url,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Icon(
                                  Icons.broken_image,
                                  color: theme.iconTheme.color?.withOpacity(
                                    0.5,
                                  ),
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                const SpaceHeight(8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
