import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String postid;
  final String uid;
  final datePublished;
  final String postUrl;
  final String username;
  final String pfp;
  final upvote;
  final retweet;
  final viewed;

  const Post({
    required this.description,
    required this.postid,
    required this.uid,
    required this.datePublished,
    required this.postUrl,
    required this.username,
    required this.pfp,
    required this.upvote,
    required this.retweet,
    required this.viewed,
  });

  Map<String, dynamic> toJson() => {
        "description": description,
        "postid": postid,
        "uid": uid,
        "datePublished": datePublished,
        "postUrl": postUrl,
        "username": username,
        "pfp": pfp,
        "upvote": upvote,
        "retweet": retweet,
        "viewed": viewed,
      };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Post(
      username: snapshot['username'],
      uid: snapshot['uid'],
      description: snapshot['description'],
      postid: snapshot['postid'],
      datePublished: snapshot['datePublished'],
      postUrl: snapshot['postUrl'],
      pfp: snapshot['pfp'],
      upvote: snapshot['upvote'],
      retweet: snapshot['retweet'],
      viewed: snapshot['viewed'],
    );
  }
}
