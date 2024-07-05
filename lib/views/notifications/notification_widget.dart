// import 'package:flutter/material.dart';

// class NotificationCard extends StatelessWidget {
//   final String message;
//   final DateTime timestamp;

//   NotificationCard({required this.message, required this.timestamp});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: Colors.grey[900], // Custom color for the card
//       margin: EdgeInsets.all(8.0),
//       child: InkWell(
//         onTap: () {
//           // Handle notification click
//           // Implement navigation or other action based on the notification
//         },
//         child:
//         // Padding(
//           // padding: EdgeInsets.all(16.0),
//           child: ListTile(
//             leading: CircleAvatar(
//               radius: 35.0,
//               backgroundColor: Colors.white,
//               backgroundImage: NetworkImage(
//                   'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg'), // Replace with your image URL
//             ),
//             title: Text(
//               message,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             subtitle: Text(
//               timestamp.toString(),
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 14.0,
//               ),
//             ),
//           ),
//         ),
//       );
//       // ,
//     // );
//   }
// }

import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String message;
  final DateTime timestamp;
  final String pfp;
  NotificationCard(
      {required this.pfp, required this.message, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900], // Custom color for the card
      // margin: EdgeInsets.all(8.0),
      child: InkWell(
        // onTap: () {
        //   // Handle notification click
        //   // Implement navigation or other action based on the notification
        // },
        child: ListTile(
          contentPadding:
              EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          leading: CircleAvatar(
            radius: 35.0,
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(
                '${pfp}'),
          ),
          title: Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            timestamp.toString(),
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.0,
            ),
          ),
        ),
      ),
    );
  }
}
