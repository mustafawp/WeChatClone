import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/models/message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore fstore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  // for storing self information
  static late ChatUser me;

  static User get user => auth.currentUser!;

  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
      }
    });
  }

  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name,
          "body": msg,
          "android_channel_id": "chats",
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
        "priority": "high",
        "content_available": true,
      };

      var res = await http.post(
          Uri.parse("https://fcm.googleapis.com/fcm/send"),
          body: jsonEncode(body),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAQkAymGU:APA91bG_VXsKvENoBri8FJZFKH2UTCpEOSq1etV7knwUCbM39x6e6gxhPvMaQZ2W5hCxM2k02tRjHLafpwufqEOgL9KHMAde4Un99LYP99DPVaqJ9QGrNEWLCXM09fYST4hlZBZzSaum'
          });
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
    } catch (e) {
      print("Error sendPushNotification: $e");
    }
  }

  // for checking if user exists or not ?
  static Future<bool> userExists() async {
    return (await fstore.collection("users").doc(user.uid).get()).exists;
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await fstore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromMap(user.data()!);
        await getFirebaseMessagingToken();

        //for setting user status to active
        APIs.updateActiveStatus(true);
        print('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // create new user
  static Future<void> createUser() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    final newUser = ChatUser(
        about: "Hey! I'm using We Chat!",
        createdAt: timestamp,
        email: user.email.toString(),
        id: user.uid,
        image: user.photoURL.toString(),
        isOnline: false,
        lastActive: timestamp,
        name: user.displayName.toString(),
        pushToken: "");
    return await fstore.collection("users").doc(user.uid).set(newUser.toMap());
  }

  // tüm kullanıcıları çek
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return fstore
        .collection('users')
        .where("id", isNotEqualTo: user.uid)
        .snapshots();
  }

  // kullanıcı bilgilerini güncelle
  static Future<void> updateUserInfo() async {
    await fstore.collection("users").doc(user.uid).update({
      "name": me.name,
      "about": me.about,
    });
  }

  // profil fotosunu güncelle
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split(".").last;
    final ref = storage.ref().child("profile_pictures/${user.uid}.$ext");
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) async {
      print("Data Transferred: ${p0.bytesTransferred / 1000} kb");
      me.image = await ref.getDownloadURL();
      await fstore
          .collection("users")
          .doc(user.uid)
          .update({"image": me.image});
    });
  }

  /*   Chat Screen Related APIs   */

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? "${user.uid}_$id"
      : "${id}_${user.uid}";

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser otherUser) {
    return fstore
        .collection('chats/${getConversationID(otherUser.id)}/messages')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser otherUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Message newMessage = Message(
        msg: msg,
        read: '',
        told: otherUser.id,
        type: type,
        fromId: user.uid,
        sent: time);

    final ref =
        fstore.collection('chats/${getConversationID(otherUser.id)}/messages');
    await ref.doc(time).set(newMessage.toJson()).then((value) =>
        sendPushNotification(otherUser, type == Type.text ? msg : 'image'));
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    fstore
        .collection('chats/${getConversationID(message.fromId)}/messages')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot> getLastMessage(ChatUser user) {
    return fstore
        .collection('chats/${getConversationID(user.id)}/messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split(".").last;
    final ref = storage.ref().child(
        "images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext");
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) async {
      print("Data Transferred: ${p0.bytesTransferred / 1000} kb");
    });

    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return fstore
        .collection('users')
        .where("id", isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    fstore.collection('users').doc(user.uid).update({
      "isOnline": isOnline,
      "lastActive": DateTime.now().millisecondsSinceEpoch.toString(),
      "pushToken": me.pushToken,
    });
  }

  static Future<void> deleteMessage(Message message) async {
    await fstore
        .collection('chats/${getConversationID(message.told)}/messages')
        .doc(message.sent)
        .delete();
    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }
}
