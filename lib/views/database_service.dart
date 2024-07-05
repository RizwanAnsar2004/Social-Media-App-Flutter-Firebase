import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  // Collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  // update userdata
  Future updateUserData(String fullName, String email, String password) async {
    return await userCollection.doc(uid).set({
      'fullName': fullName,
      'email': email,
      'password': password,
      'groups': [],
      'profilePic': ''
    });
  }

  // create group
  // Future<void> createGroup(
  //     String userName, String groupName, String uid) async {
  //   try {
  //     final groupCollection = FirebaseFirestore.instance.collection('groups');

  //     final groupDocRef = await groupCollection.add({
  //       'groupName': groupName,
  //       'groupIcon': '',
  //       'admin': userName,
  //       'members': [uid],
  //       'recentMessage': '',
  //       'recentMessageSender': '',
  //     });

  //     final groupId = groupDocRef.id;
  //     final userDocRef =
  //         FirebaseFirestore.instance.collection('users').doc(uid);
  //     await userDocRef.update({
  //       'groups': FieldValue.arrayUnion([groupId])
  //     });
  //     print('Group created with ID: $groupId');
  //   } catch (e) {
  //     if (e is FirebaseException && e.code == 'not-found') {
  //       // Collection does not exist, create it here
  //       await FirebaseFirestore.instance.collection('groups').doc().set({});
  //       // Retry creating the group
  //       await createGroup(userName, groupName, uid);
  //     } else {
  //       print('Error creating group: $e');
  //       // Handle other errors accordingly
  //     }
  //   }
  // }
  Future<void> createGroup(
      String userName, String groupName, String uid) async {
    try {
      final groupCollection = FirebaseFirestore.instance.collection('groups');

      final groupDocRef = await groupCollection.add({
        'groupName': groupName,
        'groupIcon': '',
        'admin': userName,
        'members': [uid],
        'recentMessage': '',
        'recentMessageSender': '',
      });

      final groupId = groupDocRef.id;
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(uid);
      await userDocRef.update({
        'groups': FieldValue.arrayUnion([groupId])
      });

      print('Group created with ID: $groupId');
    } catch (e) {
      print('Error creating group: $e');

      if (e is FirebaseException && e.code == 'not-found') {
        // Collection does not exist, create it here
        await FirebaseFirestore.instance.collection('groups').doc().set({});

        // Retry creating the group
        await createGroup(userName, groupName, uid);
      } else {
        // Handle other errors accordingly
        // For example, show a snackbar or dialog to inform the user about the error
      }
    }
  }

  // toggling the user group join
  Future<void> toggleGroupJoin(
      String groupId, String groupName, String userName) async {
    DocumentReference userDocRef = userCollection.doc(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    // Retrieve user's groups
    Map<String, dynamic>? userData =
        userDocSnapshot.data() as Map<String, dynamic>?;

    if (userData != null) {
      List<dynamic> groups = userData['groups'] ?? [];

      // Check if the user is already a member of the group
      bool isMember = groups.contains(uid);

      // Update user's groups based on membership status
      if (isMember) {
        // Remove user from the group
        await userDocRef.update({
          'groups': FieldValue.arrayRemove([uid])
        });

        // Remove user from the group's member list
        await groupCollection.doc(groupId).update({
          'members': FieldValue.arrayRemove([uid])
        });
      } else {
        // Add user to the group
        await userDocRef.update({
          'groups': FieldValue.arrayUnion([uid])
        });

        // Add user to the group's member list
        await groupCollection.doc(groupId).update({
          'members': FieldValue.arrayUnion([uid])
        });
      }
    }
  }

  // has user joined the group
  Future<bool> isUserJoined(
      String groupId, String groupName, String userName) async {
    DocumentReference userDocRef = userCollection.doc(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    // Retrieve user's groups
    Map<String, dynamic>? userData =
        userDocSnapshot.data() as Map<String, dynamic>?;

    if (userData != null && userData.containsKey('groups')) {
      List<dynamic> groups = userData['groups'] ?? [];

      if (groups.contains(groupId + '_' + groupName)) {
        //print('he');
        return true;
      }
    }
    //print('ne');
    return false;
  }

  // get user data
  Future getUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where('email', isEqualTo: email).get();
    print(snapshot.docs[0].data);
    return snapshot;
  }

  // get user groups
  // getUserGroups() async {
  //   // return await Firestore.instance.collection("users").where('email', isEqualTo: email).snapshots();
  //   return FirebaseFirestore.instance.collection("users").doc(uid).snapshots();
  // }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserGroups() {
    return FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: uid)
        .snapshots();
  }

  // send message
  sendMessage(String groupId, chatMessageData) {
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add(chatMessageData);
    FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'recentMessage': chatMessageData['message'],
      'recentMessageSender': chatMessageData['sender'],
      'recentMessageTime': chatMessageData['time'].toString(),
    });
  }

  // get chats of a particular group
  getChats(String groupId) async {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  // search groups
  searchByName(String groupName) {
    return FirebaseFirestore.instance
        .collection("groups")
        .where('groupName', isGreaterThanOrEqualTo: groupName)
        .get();
  }
}
