import 'package:flutter/material.dart';
import 'package:vibetalk/core/widgets/spaces.dart';

import '../../../data/models/user_model.dart';

class CardContact extends StatelessWidget {
  final UserModel user;
  const CardContact({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
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
                  child: const Icon(
                    size: 32,
                    Icons.person,
                    color: Colors.white,
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
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                user.email,
                style: const TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
