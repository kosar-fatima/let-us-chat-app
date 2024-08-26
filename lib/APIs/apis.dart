import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken() async {
    await messaging.requestPermission();

    await messaging.getToken().then((value) {
      if (value != null) {
        me.pushToken = value;
        log('Push token: ${value}');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  //for sending push notificatons
  static Future<void> sendPushNotification(
      ChatUser chatuser, String msg) async {
    try {
      final body = {
        "to": chatuser.pushToken,
        "notification": {
          "title": chatuser.name,
          "body": msg,
          "android_channel_id": "chatting",
        },
        "data": {
          "DATA": "User ID: ${me.id}",
        },
      };

      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      var response = await post(url, body: json.encode(body), headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader:
            'key=AAAAjfNcww8:APA91bEKyU9HTATtzOzVWBmp16SBA-qoVqFgdRHFG_dPv9PRwEWIjBMeRJRQIm0CxHHHXhzYaNSIc2JTypUUlDSCmLucYxW11UzOxyoHSXnMTS_1Av-bAn7Z96vJHKp2kKDTp48qsttr',
      });
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
    } catch (e) {
      log('\nSend Push Notifications: $e');
    }
  }

  static Future<bool> userExist() async {
    return (await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

// for adding chat user for our conversation
  static Future<bool> addChatContact(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (data.docs.isNotEmpty && data.docs.first.id != auth.currentUser!.uid) {
      firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('my_contacts')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }

// for adding a user to my contacts when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_contacts')
        .doc(auth.currentUser!.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

// for updating user information
  static Future<void> updateser() async {
    return (await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update(
      {'name': me.name, 'about': me.about},
    ));
  }

  static late ChatUser me;

  //static User get user => auth.currentUser!;

  static Future<void> getSelfInfo() async {
    return await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        // For setting user status to active
        APIs.updateActiveStatus(true);

        log('Data of mine: ${user.data()}');
      } else {
        createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<void> createUser() async {
    final chatuser = ChatUser(
        id: auth.currentUser!.uid,
        name: auth.currentUser!.displayName.toString(),
        email: auth.currentUser!.email.toString(),
        about: 'Hey I am using whatsapp!',
        image: auth.currentUser!.photoURL.toString(),
        created_at: DateTime.now().millisecondsSinceEpoch.toString(),
        isOnline: false,
        last_active: '',
        pushToken: '');
    return (await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .set(chatuser.toJson()));
  }

// for getting all users from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    if (userIds.isEmpty) {
      // Return an empty stream or handle it in a way that makes sense for your application.
      return const Stream.empty();
    }
    return firestore
        .collection('users')
        .where('id', whereIn: userIds)
        .snapshots();
  }

// for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('my_contacts')
        .snapshots()
        .handleError((error) {
      // Handle the error, e.g., print an error message
      print("Error in getMyUsersId: $error");
      // Return an empty stream or handle it in a way that makes sense for your application
      return Stream.empty();
    });
  }

  static Future<void> updateProfilePicture(File file) async {
    // getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref =
        storage.ref().child('profile_pictures/${auth.currentUser!.uid}');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(auth.currentUser!.uid).update(
      {'image': me.image},
    );
  }

  //      Chat Screen related APIs

  static String getConversationID(String id) {
    return auth.currentUser!.uid.hashCode <= id.hashCode
        ? '${auth.currentUser!.uid}_$id'
        : '${id}_${auth.currentUser!.uid}';
  }

  // for receiving messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Message message = Message(
        told: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        formId: auth.currentUser!.uid,
        sent: time);
    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'Image'));
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.formId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.told)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image)
      await storage.refFromURL(message.msg).delete();
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.told)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});

    if (message.type == Type.image)
      await storage.refFromURL(message.msg).delete();
  }

  // get Last message
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // send chat Image
  static Future<void> sendChatImage(ChatUser chatuser, File file) async {
    // getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatuser.id)}/${DateTime.now().microsecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatuser, imageUrl, Type.image);
  }

// get last message time for read and sent
  static String getMessageTime(
      {required BuildContext context,
      required String time,
      bool shower = false}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    final formattedTime = TimeOfDay.fromDateTime(sent).format(context);
    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == now.year) {
      return formattedTime;
    }
    return now.year == sent.year
        ? '$formattedTime - ${sent.day} ${_getMonth(sent)}'
        : '$formattedTime - ${sent.day} ${_getMonth(sent)}  ${sent.year}';
  }

  // get last message time
  static String getLastMessageTime(
      {required BuildContext context,
      required String time,
      bool shower = false}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == now.year) {
      return TimeOfDay.fromDateTime(sent).format(context);
    }
    return shower
        ? '${sent.day} ${_getMonth(sent)} ${sent.year}'
        : '${sent.day} ${_getMonth(sent)}';
  }

  // for getting specofic user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatuser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatuser.id)
        .snapshots();
  }

  // get formatted last active time of user in chat
  static String getLastActiveTime(
      {required BuildContext context, required String lastActiveTime}) {
    final int i = int.tryParse(lastActiveTime) ?? -1;

    //if time is not available then return below statement
    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String formattedTime = TimeOfDay.fromDateTime(time).format(context);
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      return 'Last seen today at $formattedTime';
    }
    if ((now.difference(time).inHours / 24).round() == 1) {
      return 'Last seen yesterday at $formattedTime';
    }

    String month = _getMonth(time);
    return 'Last seen on ${time.day} $month on $formattedTime';
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(auth.currentUser!.uid).update({
      'is_online': isOnline,
      'last active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  // get month name for last converstation
  static String _getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return '';
  }
}
