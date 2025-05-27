import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String id;
  final String userName;
  final String email;
  final String photo;

  UserModel(
      {required this.id,
      required this.userName,
      required this.email,
      required this.photo});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': userName,
      'email': email,
      'photo': photo,
    };
  }

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      userName: user.email!,
      email: user.email!,
      photo: user.photoURL ?? '',
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      userName: map['userName'] ?? '',
      email: map['email'] ?? '',
      photo: map['photo'] ?? '',
    );
  }

  factory UserModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    return UserModel(
        id: snapshot.id,
        userName: snapshot['userName'],
        email: snapshot['email'],
        photo: snapshot['photo']);
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}
