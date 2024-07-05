import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String name;
  final String message;
  final DateTime timestamp;
  final String uid;
  final String pfp;

  Notification({
    required this.uid,
    required this.name,
    required this.message,
    required this.timestamp,
    required this.pfp,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "uid": uid,
        "message": message,
        "pfp": pfp,
        "timestamp": timestamp,
      };

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      message: json['message'],
      uid: json['uid'],
      name: json['name'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      pfp: json['pfp'],
    );
  }
  static Notification fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Notification(
      name: snapshot['name'],
      uid: snapshot['uid'],
      message: snapshot['message'],
      timestamp: snapshot['timestamp'],
      pfp: snapshot['pfp'],
    );
  }
}
