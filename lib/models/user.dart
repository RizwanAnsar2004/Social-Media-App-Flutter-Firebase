import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String name;
  final String uid;
  final String title;
  final String password;
  // final String address;
  final String contact;
  final List followers;
  final List following;
  final String photoUrl;

  const User({
    required this.email,
    required this.name,
    required this.uid,
    required this.photoUrl,
    required this.title,
    required this.password,
    // required this.address,
    required this.contact,
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toJson() => {
        "username": name,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "title": title,
        "password": password,
        "contact": contact,
        "followers": followers,
        "following": following,
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return User(
      name: snapshot['username'],
      uid: snapshot['uid'],
      title: snapshot['title'],
      photoUrl: snapshot['photoUrl'],
      password: snapshot['password'],
      following: snapshot['following'],
      followers: snapshot['followers'],
      email: snapshot['email'],
      contact: snapshot['contact'],
      // address: snapshot['address'],
    );
  }
}
