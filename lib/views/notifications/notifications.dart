import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneyup/views/components/bottom_navigation_bar.dart';
import 'package:moneyup/views/notifications/notification_widget.dart';
import 'package:moneyup/views/notifications/notifications_storage_methods.dart';
import 'package:moneyup/views/notifications/notification_model.dart' as custom;

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = fetchNotifications();
  }

  Future<void> checkupload() async {
    String result = await NotificationStorageMethods()
        .storeNotification("like", "uid", "username", "pfp");
    print(result);
    // Handle the result if needed
    setState(() {
      _notificationsFuture = fetchNotifications();
    });
  }

  Future<void> checkdelete() async {
    setState(() {
      _isLoading = true; // Set loading to true
    });
    String userid = FirebaseAuth.instance.currentUser!.uid;
    String result =
        await NotificationStorageMethods().deleteNotification(userid);
    print(result);
    // Re-fetch notifications after deletion
    setState(() {
      _notificationsFuture = fetchNotifications();
      _isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    String userid = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .where('uid', isEqualTo: userid)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Alerts',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _isLoading
                ? CircularProgressIndicator(
                    color: Colors.white,
                  )
                : TextButton(
                    onPressed: () {
                      checkdelete();
                      // Implement your action when the button is pressed
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.white)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text('No new notifications',
                      style: TextStyle(fontSize: 25, color: Colors.white)));
            } else {
              List<Map<String, dynamic>> notifications = snapshot.data!;
              return ListView(
                children: [
                  _buildSectionTitle('Today'),
                  _buildNotificationList(notifications
                      .where((notif) => (notif['timestamp'] as Timestamp)
                          .toDate()
                          .isAfter(DateTime.now().subtract(Duration(days: 1))))
                      .map((notif) => NotificationCard(
                            pfp: notif['pfp'],
                            message: notif['name'] + notif['message'],
                            timestamp:
                                (notif['timestamp'] as Timestamp).toDate(),
                          ))
                      .toList()),
                  _buildSectionTitle('Older'),
                  _buildNotificationList(notifications
                      .where((notif) => (notif['timestamp'] as Timestamp)
                          .toDate()
                          .isBefore(DateTime.now().subtract(Duration(days: 1))))
                      .map((notif) => NotificationCard(
                            pfp: notif['pfp'],
                            message: notif['name'] + notif['message'],
                            timestamp:
                                (notif['timestamp'] as Timestamp).toDate(),
                          ))
                      .toList()),
                ],
              );
            }
          },
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<Widget> notifications) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return notifications[index];
      },
    );
  }
}
