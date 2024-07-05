import 'dart:typed_data';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:moneyup/models/post.dart';
import 'package:moneyup/views/notifications/notifications_storage_methods.dart';
import 'package:moneyup/views/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(String des, Uint8List file, String uid,
      String username, String pfp) async {
    String res = "some error";
    try {
      String photoUrl =
          await StorageMethods().uploadimagetoStorage('posts', file, true);

      String postid = const Uuid().v1();

      Post post = Post(
        description: des,
        uid: uid,
        username: username,
        postid: postid,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        pfp: pfp,
        upvote: [],
        retweet: [],
        viewed: [],
      );
      _firestore.collection('posts').doc(postid).set(post.toJson());
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> Reup(String des, String filelink, String uid, String username,
      String pfp) async {
    String res = "some error";
    try {
      String photoUrl = filelink;

      String postid = const Uuid().v1();

      Post post = Post(
        description: des,
        uid: uid,
        username: username,
        postid: postid,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        pfp: pfp,
        upvote: [],
        retweet: [],
        viewed: [],
      );
      _firestore.collection('posts').doc(postid).set(post.toJson());
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likePost(String postId, List likes) async {
    int randomInt = Random().nextInt(100000);
    String res = "Some error occurred";
    try {
      _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([randomInt])
      });


      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
Future<String> retweet(String postId, List retweet) async {
    int randomInt = Random().nextInt(100000);
    String res = "Some error occurred";
    try {
      _firestore.collection('posts').doc(postId).update({
        'retweet': FieldValue.arrayUnion([randomInt])
      });


      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];
      String pfp = (snap.data()! as dynamic)['photoUrl'];
      String username = (snap.data()! as dynamic)['username'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
        DocumentSnapshot followsnap =
            await _firestore.collection('users').doc(uid).get();

        ///to add follow notifications
        String result = await NotificationStorageMethods()
            .storeNotification("follow", followId, username, pfp);
        print(result);
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }
}
