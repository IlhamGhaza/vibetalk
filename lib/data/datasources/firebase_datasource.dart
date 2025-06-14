import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/channel_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

String channelId(String id1, String id2) {
  if (id1.hashCode < id2.hashCode) {
    log('channelid: $id1-$id2');
    return '$id1-$id2';
  }
  log('channelid: $id1-$id2');
  return '$id2-$id1';
}

class FirebaseDatasource {
  FirebaseDatasource._init();

  static final FirebaseDatasource instance = FirebaseDatasource._init();

  Future<bool> isUserExist(String id) async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .get();
    return snap.exists;
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    if (doc.exists) {
      return UserModel.fromDocumentSnapshot(doc);
    }
    return null;
  }

  Future<void> setUserToFirestore(UserModel user) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .set(user.toMap());
  }

  Stream<List<UserModel>> allUser() {
    return FirebaseFirestore.instance.collection('users').snapshots().map((
      snapShot,
    ) {
      List<UserModel> rs = [];
      for (var element in snapShot.docs) {
        rs.add(UserModel.fromDocumentSnapshot(element));
      }
      return rs;
    });
  }

  Stream<List<UserModel>> allUserByUsername(String username) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('userName', isEqualTo: username)
        .snapshots()
        .map((snapShot) {
          List<UserModel> rs = [];
          for (var element in snapShot.docs) {
            rs.add(UserModel.fromDocumentSnapshot(element));
          }
          return rs;
        });
  }

  // Future<Channel?> getChannel(String channelId) async {
  //   return FirebaseFirestore.instance
  //       .collection('channels')
  //       .doc(channelId)
  //       .get()
  //       .then((chanel) {
  //     if (chanel.exists) {
  //       return Channel.fromDocumentSnapshot(chanel);
  //     }
  //     return null;
  //   });
  // }

  Future<void> updateChannel(
    String channelId,
    Map<String, dynamic> data,
  ) async {
    await FirebaseFirestore.instance
        .collection('channels')
        .doc(channelId)
        .set(data, SetOptions(merge: true));
  }

  Future<void> addMessage(Message message) async {
    await FirebaseFirestore.instance
        .collection('messages')
        .add(message.toMap());
  }

  Stream<List<Message>> messageStream(String channelId) {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('channelId', isEqualTo: channelId)
        .orderBy('sendAt', descending: true)
        .limit(20)
        .snapshots()
        .map((querySnapshot) {
          List<Message> rs = [];
          for (var element in querySnapshot.docs) {
            rs.add(Message.fromDocumentSnapshot(element));
          }
          return rs;
        });
  }

  Future<List<Message>> loadMoreMessages(
    String channelId,
    DocumentSnapshot lastDocument,
  ) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('messages')
        .where('channelId', isEqualTo: channelId)
        .orderBy('sendAt', descending: true)
        .startAfterDocument(lastDocument)
        .limit(20)
        .get();

    return querySnapshot.docs
        .map((doc) => Message.fromDocumentSnapshot(doc))
        .toList();
  }

  Stream<List<Channel>> channelStream(String userId) {
    return FirebaseFirestore.instance
        .collection('channels')
        .where('memberIds', arrayContains: userId)
        .orderBy('lastTime', descending: true)
        .snapshots()
        .map((querySnapshot) {
          List<Channel> rs = [];
          for (var element in querySnapshot.docs) {
            rs.add(Channel.fromDocumentSnapshot(element));
          }
          return rs;
        });
  }

  Future<Channel?> getChannel(String channelId) async {
    return FirebaseFirestore.instance
        .collection('channels')
        .doc(channelId)
        .get()
        .then((chanel) {
          if (chanel.exists) {
            return Channel.fromDocumentSnapshot(chanel);
          }
          return null;
        });
  }

  Stream<List<Channel>> getAllChannels() {
    return FirebaseFirestore.instance.collection('channels').snapshots().map((
      querySnapshot,
    ) {
      return querySnapshot.docs.map((doc) {
        return Channel.fromDocumentSnapshot(doc);
      }).toList();
    });
  }

  // Future<void> addMessage(Message message) async {
  //   await FirebaseFirestore.instance
  //       .collection('messages')
  //       .add(message.toMap());
  // }

  // Stream<List<Message>> messageStream(String channelId) {
  //   return FirebaseFirestore.instance
  //       .collection('messages')
  //       .where('channelId', isEqualTo: channelId)
  //       .orderBy('sendAt', descending: true)
  //       .snapshots()
  //       .map((querySnapshot) {
  //     List<Message> rs = [];
  //     for (var element in querySnapshot.docs) {
  //       rs.add(Message.fromDocumentSnapshot(element));
  //     }
  //     return rs;
  //   });
}

Stream<List<Channel>> channelStream(String userId) {
  return FirebaseFirestore.instance
      .collection('channels')
      .where('memberIds', arrayContains: userId)
      .orderBy('lastTime', descending: true)
      .snapshots()
      .map((querySnapshot) {
        List<Channel> rs = [];
        for (var element in querySnapshot.docs) {
          rs.add(Channel.fromDocumentSnapshot(element));
        }
        return rs;
      });
}
