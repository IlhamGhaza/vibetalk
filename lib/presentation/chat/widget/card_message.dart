// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/spaces.dart';
import '../../../data/models/user_model.dart';
import '../page/chat_page.dart';

class CardMessage extends StatelessWidget {
  // final UserModel user;
  final UserModel user;
  final int index;
  const CardMessage({super.key, required this.user, required this.index});

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: DefaultColors.primaryColor,
            radius: 26,
            child: user.photo.isEmpty
                ? Icon(Icons.person, size: 30, color: Colors.white)
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
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Last message",
                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SpaceWidth(16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                //random time
                '${(DateTime.now().hour - (1 + index)).toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              // Container(
              //   height: 22,
              //   width: 22,
              //   decoration: const BoxDecoration(
              //       color: Colors.red, shape: BoxShape.circle),
              //   child: const Center(
              //     child: Text(
              //       "2",
              //       style: TextStyle(
              //           fontSize: 12.0,
              //           fontWeight: FontWeight.bold,
              //           color: Colors.white),
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
