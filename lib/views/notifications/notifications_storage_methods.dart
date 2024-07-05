import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneyup/views/notifications/notification_model.dart';
import 'package:uuid/uuid.dart';

class NotificationStorageMethods {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> storeNotification(
      String type, String uid, String username, String pfp) async {
    String res = "some error";
    String message = "";
    if (type == "like") {
      message = " has liked your post";
    } else if (type == "follow") {
      message = " has started to follow you";
    } else if (type == "retweet") {
      message = " has reup/requoted your post";
    }

    try {
      if (message != null) {
        String notid = const Uuid().v1();
        Notification not = Notification(
          message: message,
          uid: uid,
          name: username,
          timestamp: DateTime.now(),
          pfp: pfp,
        );
        _firestore.collection('notifications').doc(notid).set(not.toJson());
        res = 'success';
      } else {
        print("notifications has failed due to missing message");
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteNotification(String uid) async {
    String res = "some error occurred";
    try {
      // Fetch notifications with the given uid
      QuerySnapshot snapshot = await _firestore
          .collection("notifications")
          .where('uid', isEqualTo: uid)
          .get();

      // Delete each document matching the uid
      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
      res = "successfully cleared notifications";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
