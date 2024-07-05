import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moneyup/models/user.dart' as model;
import 'package:moneyup/views/components/bottom_navigation_bar.dart';
import 'package:moneyup/views/profile_view.dart';
import 'package:moneyup/views/search_page.dart';
import 'package:moneyup/views/database_service.dart';
import 'package:moneyup/views/components/group_tile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  String _groupName = '';
  String _userName = '';
  String _email = '';
  String _uid = '';

  Stream<QuerySnapshot>? _groups;

  @override
  void initState() {
    super.initState();
    _initializeUserDetails();

    // _getUserAuthAndJoinedGroups();
  }

  Future<void> _initializeUserDetails() async {
    try {
      model.User? userDetails = await getUserDetails();
      if (userDetails != null) {
        setState(() {
          user = userDetails;
          _userName = userDetails.name ?? ''; // Handle potential null value
          _email = userDetails.email ?? ''; // Handle potential null value
          _uid = userDetails.uid;
        });
        _getUserAuthAndJoinedGroups();

        print('User details set: $_userName');
      } else {
        print('User details are null');
        // Handle case where userDetails is null
      }
    } catch (e) {
      print('Error initializing user details: $e');
      // Handle error fetching user details
    }
  }

  Future<model.User?> getUserDetails() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        print('User document snapshot: ${snap.data()}');
        if (snap.data() != null) {
          return model.User(
            email: snap['email'] ?? '',
            name: snap['username'] ?? '',
            uid: snap['uid'] ?? '',
            photoUrl: snap['photoUrl'] ?? '',
            title: snap['title'] ?? '',
            password: snap['password'] ?? '',
            // address: snap['address'] ?? '',
            contact: snap['contact'] ?? '',
            followers: List<String>.from(snap['followers'] ?? []),
            following: List<String>.from(snap['following'] ?? []),
          );
        } else {
          throw Exception("User document is null");
        }
      } else {
        throw Exception("User not authenticated");
      }
    } catch (e) {
      print('Error fetching user details: $e');
      throw e; // Rethrow the error to propagate it upwards
    }
  }

  Widget noGroupWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _popupDialog(context);
            },
            child: Icon(Icons.add_circle, color: Colors.grey[700], size: 75.0),
          ),
          SizedBox(height: 20.0),
          Text(
            "You've not joined any group, tap on the 'add' icon to create a group or search for groups by tapping on the search button below.",
          ),
        ],
      ),
    );
  }

  Widget groupsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _groups,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return noGroupWidget();
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              String groupId = doc.id;
              String groupName = doc['groupName'];
              return GroupTile(
                userName: _userName,
                groupId: groupId,
                groupName: groupName,
              );
            },
          );
        }
      },
    );
  }

  void _getUserAuthAndJoinedGroups() async {
    try {
      // Ensure _userName and _uid are not empty
      if (_userName.isNotEmpty && _uid.isNotEmpty) {
        // Use DatabaseService to fetch user-specific groups
        Stream<QuerySnapshot>? groupsStream =
            DatabaseService(uid: _uid).getUserGroups();
        setState(() {
          _groups = groupsStream;
        });
        print("Groups found");
      } else {
        print("User name or uid is empty");
      }
    } catch (e) {
      print('Error fetching user groups: $e');
      // Handle error fetching groups
    }
  }

  void _popupDialog(BuildContext context) {
    if (_userName.isEmpty) {
      print('User name is empty, cannot create group.');
      return;
    }

    AlertDialog alert = AlertDialog(
      title: Text("Create a group"),
      content: TextField(
        onChanged: (val) {
          setState(() {
            _groupName = val;
          });
          print(_groupName);
        },
        style: TextStyle(fontSize: 15.0, height: 2.0, color: Colors.black),
      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Create"),
          onPressed: () async {
            if (_groupName.isNotEmpty) {
              if (_userName.isNotEmpty) {
                print("Creating group with name: $_groupName");
                DatabaseService(uid: user.uid)
                    .createGroup(_userName, _groupName, _uid);
                Navigator.of(context).pop();
              } else {
                print("User name is empty");
              }
            }
          },
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Groups',
          style: TextStyle(
            color: Colors.white,
            fontSize: 27.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black87,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            icon: Icon(Icons.search, color: Colors.white, size: 25.0),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 50.0),
          children: <Widget>[
            Icon(Icons.account_circle, size: 150.0, color: Colors.grey[700]),
            SizedBox(height: 15.0),
            Text(
              _userName,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 7.0),
            ListTile(
              onTap: () {},
              selected: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.group),
              title: Text('Groups'),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
            ),
          ],
        ),
      ),
      body: groupsList(),
      backgroundColor: Colors.black87,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _popupDialog(context);
        },
        child: Icon(Icons.add, color: Colors.white, size: 30.0),
        backgroundColor: Colors.grey,
        elevation: 0.0,
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}


// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
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

//   String _groupName = '';
//   String _userName = '';
//   String _email = '';
//   Stream<QuerySnapshot>? _groups;

//   @override
//   void initState() {
//     super.initState();
//     _initializeUserDetails();
//   }

//   Future<void> _initializeUserDetails() async {
//     try {
//       model.User? _user = await getUserDetails();
//       if (_user != null) {
//         setState(() {
//           user = user;
//           _userName = user.name;
//           _email = user.email;
//         });_getUserAuthAndJoinedGroups
//         print('User details set: ${user.name}');
//         _getUserAuthAndJoinedGroups();
//       } else {
//         print('User details are null');
//       }
//     } catch (e) {
//       print('Error initializing user details: $e');
//     }
//   }

//   Future<model.User?> getUserDetails() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       DocumentSnapshot snap = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .get();
//       print('User document snapshot: ${snap.data()}');
//       return model.User.fromSnap(snap);
//     } else {
//       throw Exception("User not authenticated");
//     }
//   }

//   Widget noGroupWidget() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 25.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: <Widget>[
//           GestureDetector(
//             onTap: () {
//               _popupDialog(context);
//             },
//             child: Icon(Icons.add_circle, color: Colors.grey[700], size: 75.0),
//           ),
//           SizedBox(height: 20.0),
//           Text(
//             "You've not joined any group, tap on the 'add' icon to create a group or search for groups by tapping on the search button below.",
//           ),
//         ],
//       ),
//     );
//   }

//   Widget groupsList() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _groups,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           if (snapshot.data!.docs.isNotEmpty) {
//             return ListView.builder(
//               itemCount: snapshot.data!.docs.length,
//               shrinkWrap: true,
//               itemBuilder: (context, index) {
//                 var doc = snapshot.data!.docs[index];
//                 String groupId = doc.id;
//                 String groupName = doc['groupName'];
//                 return GroupTile(
//                   userName: _userName,
//                   groupId: groupId,
//                   groupName: groupName,
//                 );
//               },
//             );
//           } else {
//             return noGroupWidget();
//           }
//         } else {
//           return Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }

//   void _getUserAuthAndJoinedGroups() async {
//     print('Fetching user groups for: ${user.name}');
//     if (user.name.isNotEmpty) {
//       setState(() {
//         _userName = user.name;
//       });
//     }

//     Stream<QuerySnapshot>? groupsStream =
//         await DatabaseService(uid: user.uid).getUserGroups();
//     setState(() {
//       _groups = groupsStream;
//     });
//   }

//   void _popupDialog(BuildContext context) {
//     if (_userName.isEmpty) {
//       print('User name is empty, cannot create group.');
//       return;
//     }

//     AlertDialog alert = AlertDialog(
//       title: Text("Create a group"),
//       content: TextField(
//         onChanged: (val) {
//           setState(() {
//             _groupName = val;
//           });
//           print(_groupName);
//         },
//         style: TextStyle(fontSize: 15.0, height: 2.0, color: Colors.black),
//       ),
//       actions: [
//         TextButton(
//           child: Text("Cancel"),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         TextButton(
//           child: Text("Create"),
//           onPressed: () async {
//             if (_groupName.isNotEmpty) {
//               print('Creating group with name: $_groupName');
//               DatabaseService(uid: user.uid)
//                   .createGroup(_userName, _groupName, user.uid);
//               Navigator.of(context).pop();
//             }
//           },
//         ),
//       ],
//     );

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Groups',
//           style: TextStyle(
//               color: Colors.white, fontSize: 27.0, fontWeight: FontWeight.bold),
//         ),
//         iconTheme: IconThemeData(color: Colors.white),
//         backgroundColor: Colors.black87,
//         elevation: 0.0,
//         actions: <Widget>[
//           IconButton(
//             padding: EdgeInsets.symmetric(horizontal: 20.0),
//             icon: Icon(Icons.search, color: Colors.white, size: 25.0),
//             onPressed: () {
//               Navigator.of(context)
//                   .push(MaterialPageRoute(builder: (context) => SearchPage()));
//             },
//           )
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.symmetric(vertical: 50.0),
//           children: <Widget>[
//             Icon(Icons.account_circle, size: 150.0, color: Colors.grey[700]),
//             SizedBox(height: 15.0),
//             Text(_userName,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             SizedBox(height: 7.0),
//             ListTile(
//               onTap: () {},
//               selected: true,
//               contentPadding:
//                   EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
//               leading: Icon(Icons.group),
//               title: Text('Groups'),
//             ),
//             ListTile(
//               onTap: () {
//                 Navigator.of(context).pushReplacement(
//                     MaterialPageRoute(builder: (context) => ProfilePage()));
//               },
//               contentPadding:
//                   EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
//               leading: Icon(Icons.account_circle),
//               title: Text('Profile'),
//             ),
//           ],
//         ),
//       ),
//       body: groupsList(),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _popupDialog(context);
//         },
//         child: Icon(Icons.add, color: Colors.white, size: 30.0),
//         backgroundColor: Colors.grey[700],
//         elevation: 0.0,
//       ),
//       bottomNavigationBar: const CustomBottomNavigationBar(),
//     );
//   }
// }
