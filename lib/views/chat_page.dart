// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:moneyup/models/user.dart' as model;
// import 'package:moneyup/views/database_service.dart';
// import 'package:moneyup/views/components/message_tile.dart';

// class ChatPage extends StatefulWidget {
//   final String groupId;
//   final String userName;
//   final String groupName;

//   ChatPage(
//       {required this.groupId, required this.userName, required this.groupName});

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   late model.User user = model.User(
//       email: '',
//       name: '',
//       uid: '',
//       photoUrl: '',
//       title: '',
//       password: '',
//       address: '',
//       contact: '',
//       followers: [],
//       following: []);
//   bool _isJoined = false;
//   _joinValueInGroup(String userName, String groupId, String groupName) async {
//     final value = await DatabaseService(uid: user.uid)
//         .isUserJoined(groupId, groupName, userName);
//     setState(() {
//       _isJoined = value;
//     });
//   }

//   Stream<QuerySnapshot>? _chats;
//   TextEditingController messageEditingController = TextEditingController();

//   Future<void> _initializeUserDetails() async {
//     try {
//       // Fetch user details asynchronously
//       model.User? userDetails = await getUserDetails();
//       if (userDetails != null) {
//         // Ensure userDetails is not null
//         // Update user state with fetched details
//         setState(() {
//           user = userDetails;
//         });
//         // Proceed with other operations that depend on user details
//       } else {
//         print('User details are null');
//       }
//     } catch (e) {
//       print('Error initializing user details: $e');
//       // Handle error fetching user details
//     }
//   }

//   Future<model.User?> getUserDetails() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       DocumentSnapshot snap = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .get();
//       return model.User.fromSnap(snap);
//     } else {
//       throw Exception("User not authenticated");
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initializeUserDetails();
//     DatabaseService(uid: user.uid).getChats(widget.groupId).then((val) {
//       setState(() {
//         _chats = val;
//       });
//     });
//     _joinValueInGroup(user.name, widget.groupId, widget.groupName);
//   }

//   Widget _chatMessages() {
//     return StreamBuilder(
//       stream: _chats,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               final data =
//                   snapshot.data!.docs[index].data() as Map<String, dynamic>?;
//               final message = data?["message"] ?? "";
//               final sender = data?["sender"] ?? "";
//               final sentByMe = widget.userName == data?["sender"];
//               return MessageTile(
//                 message: message,
//                 sender: sender,
//                 sentByMe: sentByMe,
//               );
//             },
//           );
//         } else {
//           return Container();
//         }
//       },
//     );
//   }

//   _sendMessage() {
//     if (messageEditingController.text.isNotEmpty) {
//       Map<String, dynamic> chatMessageMap = {
//         "message": messageEditingController.text,
//         "sender": widget.userName,
//         'time': DateTime.now().millisecondsSinceEpoch,
//       };
//       final currentUser = FirebaseAuth.instance.currentUser;
//       DatabaseService(uid: currentUser!.uid)
//           .sendMessage(widget.groupId, chatMessageMap);

//       setState(() {
//         messageEditingController.text = "";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.groupName, style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         backgroundColor: Colors.black87,
//         elevation: 0.0,
//         iconTheme: IconThemeData(color: Colors.white),
//       ),
//       body: _chats != null
//           ? Container(
//               child: Stack(
//                 children: <Widget>[
//                   _chatMessages(),
//                   Container(
//                     alignment: Alignment.bottomCenter,
//                     width: MediaQuery.of(context).size.width,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: 15.0, vertical: 10.0),
//                       color: Colors.grey[700],
//                       child: Row(
//                         children: <Widget>[
//                           Expanded(
//                             child: TextField(
//                               controller: messageEditingController,
//                               style: TextStyle(color: Colors.white),
//                               decoration: InputDecoration(
//                                 hintText: "Send a message ...",
//                                 hintStyle: TextStyle(
//                                     color: Colors.white38, fontSize: 16),
//                                 border: InputBorder.none,
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 12.0),
//                           GestureDetector(
//                             onTap: () {
//                               _sendMessage();
//                             },
//                             child: Container(
//                               height: 50.0,
//                               width: 50.0,
//                               decoration: BoxDecoration(
//                                 color: Colors.blueAccent,
//                                 borderRadius: BorderRadius.circular(50),
//                               ),
//                               child: Center(
//                                   child: Icon(Icons.send, color: Colors.white)),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : Center(
//               child: CircularProgressIndicator(),
//             ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:moneyup/models/user.dart' as model;
// import 'package:moneyup/views/chat_home_page.dart';
// import 'package:moneyup/views/database_service.dart';
// import 'package:moneyup/views/components/message_tile.dart';

// import '../constants/routes.dart';

// class ChatPage extends StatefulWidget {
//   final String groupId;
//   final String userName;
//   final String groupName;

//   ChatPage({
//     required this.groupId,
//     required this.userName,
//     required this.groupName,
//   });

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   late model.User user = model.User(
//     email: '',
//     name: '',
//     uid: '',
//     photoUrl: '',
//     title: '',
//     password: '',
//     address: '',
//     contact: '',
//     followers: [],
//     following: [],
//   );
//   bool _isJoined = false;
//   Stream<QuerySnapshot>? _chats;
//   TextEditingController messageEditingController = TextEditingController();

//   Future<void> _initializeUserDetails() async {
//     try {
//       // Fetch user details asynchronously
//       model.User? userDetails = await getUserDetails();
//       if (userDetails != null) {
//         // Update user state with fetched details
//         setState(() {
//           user = userDetails!;
//         });
//         // Check if user is joined in the group
//         _joinValueInGroup(user.name, widget.groupId, widget.groupName);
//       } else {
//         print('User details are null');
//       }
//     } catch (e) {
//       print('Error initializing user details: $e');
//       // Handle error fetching user details
//     }
//   }

//   Future<model.User?> getUserDetails() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       DocumentSnapshot snap = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .get();
//       return model.User.fromSnap(snap);
//     } else {
//       throw Exception("User not authenticated");
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initializeUserDetails();
//     DatabaseService(uid: user.uid).getChats(widget.groupId).then((val) {
//       setState(() {
//         _chats = val;
//       });
//     });
//   }

//   void _joinValueInGroup(
//       String userName, String groupId, String groupName) async {
//     final value = await DatabaseService(uid: user.uid)
//         .isUserJoined(groupId, groupName, userName);
//     setState(() {
//       _isJoined = value;
//     });
//   }

//   Widget _chatMessages() {
//     return StreamBuilder(
//       stream: _chats,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               final data =
//                   snapshot.data!.docs[index].data() as Map<String, dynamic>?;
//               final message = data?["message"] ?? "";
//               final sender = data?["sender"] ?? "";
//               final sentByMe = widget.userName == data?["sender"];
//               return MessageTile(
//                 message: message,
//                 sender: sender,
//                 sentByMe: sentByMe,
//               );
//             },
//           );
//         } else {
//           return Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }

//   _sendMessage() {
//     if (messageEditingController.text.isNotEmpty) {
//       Map<String, dynamic> chatMessageMap = {
//         "message": messageEditingController.text,
//         "sender": widget.userName,
//         'time': DateTime.now().millisecondsSinceEpoch,
//       };
//       final currentUser = FirebaseAuth.instance.currentUser;
//       DatabaseService(uid: currentUser!.uid)
//           .sendMessage(widget.groupId, chatMessageMap);

//       setState(() {
//         messageEditingController.text = "";
//       });
//     }
//   }

//   void _leaveGroup() {
//     // Implement leave group functionality here
//     // For example, call a method in your DatabaseService to remove the user from the group
//     // Update UI as needed, e.g., navigate back or refresh state
//     setState(() {
//       _isJoined = false;
//     });
//     _showScaffold('Left the group "${widget.groupName}"');
//     // Example implementation if using DatabaseService
//     DatabaseService(uid: user.uid)
//         .toggleGroupJoin(widget.groupId, widget.groupName, user.name);
//     Navigator.of(context)
//         .pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
//   }

//   void _showScaffold(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.groupName, style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         backgroundColor: Colors.black87,
//         elevation: 0.0,
//         iconTheme: IconThemeData(color: Colors.white),
//         actions: <Widget>[
//           _isJoined
//               ? IconButton(
//                   icon: Icon(Icons.exit_to_app),
//                   onPressed: () {
//                     _leaveGroup(); // Leave group
//                   },
//                 )
//               : Container(), // No action if not joined
//         ],
//       ),
//       body: _chats != null
//           ? Container(
//               child: Stack(
//                 children: <Widget>[
//                   _chatMessages(),
//                   Container(
//                     alignment: Alignment.bottomCenter,
//                     width: MediaQuery.of(context).size.width,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: 15.0, vertical: 10.0),
//                       color: Colors.grey[700],
//                       child: Row(
//                         children: <Widget>[
//                           Expanded(
//                             child: TextField(
//                               controller: messageEditingController,
//                               style: TextStyle(color: Colors.white),
//                               decoration: InputDecoration(
//                                 hintText: "Send a message ...",
//                                 hintStyle: TextStyle(
//                                     color: Colors.white38, fontSize: 16),
//                                 border: InputBorder.none,
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 12.0),
//                           GestureDetector(
//                             onTap: () {
//                               _sendMessage();
//                             },
//                             child: Container(
//                               height: 50.0,
//                               width: 50.0,
//                               decoration: BoxDecoration(
//                                 color: Colors.blueAccent,
//                                 borderRadius: BorderRadius.circular(50),
//                               ),
//                               child: Center(
//                                 child: Icon(Icons.send, color: Colors.white),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : Center(
//               child: CircularProgressIndicator(),
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneyup/models/user.dart' as model;
import 'package:moneyup/views/chat_home_page.dart';
import 'package:moneyup/views/database_service.dart';
import 'package:moneyup/views/components/message_tile.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String userName;
  final String groupName;

  ChatPage({
    required this.groupId,
    required this.userName,
    required this.groupName,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late model.User user = model.User(
    email: '',
    name: '',
    uid: '',
    photoUrl: '',
    title: '',
    password: '',
    // address: '',
    contact: '',
    followers: [],
    following: [],
  );
  bool _isJoined = false;
  Stream<QuerySnapshot>? _chats;
  TextEditingController messageEditingController = TextEditingController();

  Future<void> _initializeUserDetails() async {
    try {
      model.User? userDetails = await getUserDetails();
      if (userDetails != null) {
        setState(() {
          user = userDetails!;
        });
        _joinValueInGroup(user.name, widget.groupId, widget.groupName);
      } else {
        print('User details are null');
      }
    } catch (e) {
      print('Error initializing user details: $e');
    }
  }

  Future<model.User?> getUserDetails() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      return model.User.fromSnap(snap);
    } else {
      throw Exception("User not authenticated");
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeUserDetails();
    DatabaseService(uid: user.uid).getChats(widget.groupId).then((val) {
      setState(() {
        _chats = val;
      });
    });
  }

  void _joinValueInGroup(
      String userName, String groupId, String groupName) async {
    final value = await DatabaseService(uid: user.uid)
        .isUserJoined(groupId, groupName, userName);
    setState(() {
      _isJoined = value;
    });

    if (!_isJoined) {
      _showJoinGroupDialog();
    }
  }

  Widget _chatMessages() {
    return StreamBuilder(
      stream: _chats,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>?;
              final message = data?["message"] ?? "";
              final sender = data?["sender"] ?? "";
              final sentByMe = widget.userName == data?["sender"];
              return MessageTile(
                message: message,
                sender: sender,
                sentByMe: sentByMe,
              );
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  _sendMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageEditingController.text,
        "sender": widget.userName,
        'time': DateTime.now().millisecondsSinceEpoch,
      };
      final currentUser = FirebaseAuth.instance.currentUser;
      DatabaseService(uid: currentUser!.uid)
          .sendMessage(widget.groupId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  void _joinGroup() {
    setState(() {
      _isJoined = true;
    });
    _showScaffold('Joined the group "${widget.groupName}"');
    DatabaseService(uid: user.uid)
        .toggleGroupJoin(widget.groupId, widget.groupName, user.name);
    Navigator.of(context).pop();
  }

  void _leaveGroup() {
    setState(() {
      _isJoined = false;
    });
    _showScaffold('Left the group "${widget.groupName}"');
    DatabaseService(uid: user.uid)
        .toggleGroupJoin(widget.groupId, widget.groupName, user.name);
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
  }

  void _showScaffold(String message) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar(); // Hide any existing snack bar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating, // Set behavior to floating
      ),
    );
  }

  void _showJoinGroupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Join Group"),
          content: Text("Do you want to join the group '${widget.groupName}'?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Join"),
              onPressed: () {
                _joinGroup(); // Join the group
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black87,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          _isJoined
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    _leaveGroup(); // Leave group
                  },
                )
              : IconButton(
                  icon: Icon(Icons.group_add),
                  onPressed: () {
                    _showJoinGroupDialog(); // Show join group dialog
                  },
                ),
        ],
      ),
      body: _chats != null
          ? Container(
              child: Stack(
                children: <Widget>[
                  _chatMessages(),
                  Container(
                    alignment: Alignment.bottomCenter,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10.0),
                      color: Colors.grey[700],
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: messageEditingController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Send a message ...",
                                hintStyle: TextStyle(
                                    color: Colors.white38, fontSize: 16),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.0),
                          GestureDetector(
                            onTap: () {
                              _sendMessage();
                            },
                            child: Container(
                              height: 50.0,
                              width: 50.0,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Icon(Icons.send, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
