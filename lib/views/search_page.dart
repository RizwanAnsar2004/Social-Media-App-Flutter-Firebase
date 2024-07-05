import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneyup/models/user.dart' as model;
import 'package:moneyup/views/chat_page.dart';
import 'package:moneyup/views/database_service.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchEditingController = TextEditingController();
  QuerySnapshot? searchResultSnapshot;

  bool isLoading = false;
  bool hasUserSearched = false;
  bool _isJoined = false;
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
      following: []);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializeUserDetails();
  }

  Future<void> _initializeUserDetails() async {
    try {
      // Fetch user details asynchronously
      model.User? userDetails = await getUserDetails();
      if (userDetails != null) {
        // Ensure userDetails is not null
        // Update user state with fetched details
        setState(() {
          user = userDetails;
        });
        // Proceed with other operations that depend on user details
      } else {
        print('User details are null');
      }
    } catch (e) {
      print('Error initializing user details: $e');
      // Handle error fetching user details
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

  _initiateSearch() async {
    if (searchEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      try {
        final snapshot = await DatabaseService(uid: user.uid)
            .searchByName(searchEditingController.text);
        print('Search Results: ${snapshot.docs}');

        snapshot.docs.forEach((doc) {
          print(doc['groupName']);
        });
        setState(() {
          searchResultSnapshot = snapshot;
          isLoading = false;
          hasUserSearched = true;
        });
      } catch (e) {
        print('Error: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showScaffold(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.blueAccent,
      duration: Duration(milliseconds: 1500),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 17.0),
      ),
    ));
  }

  _joinValueInGroup(
      String userName, String groupId, String groupName, String admin) async {
    final value = await DatabaseService(uid: user.uid)
        .isUserJoined(groupId, groupName, userName);
    setState(() {
      _isJoined = value;
    });
  }

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  // Future<void> toggleGroupJoin(
  //     String groupId, String groupName, String userName) async {
  //   DocumentReference userDocRef = userCollection.doc(user.uid);
  //   DocumentSnapshot userDocSnapshot = await userDocRef.get();

  //   // Retrieve user's groups
  //   Map<String, dynamic>? userData =
  //       userDocSnapshot.data() as Map<String, dynamic>?;

  //   if (userData != null) {
  //     List<dynamic> groups = userData['groups'] ?? [];

  //     // Check if the user is already a member of the group
  //     bool isMember = groups.contains(uid);

  //     // Update user's groups based on membership status
  //     if (isMember) {
  //       // Remove user from the group

  //       // Remove user from the group's member list

  //     } else {
  //       // Add user to the group

  //     }
  //   }
  // }

  Widget groupList() {
    print('Search Results Length: ${searchResultSnapshot?.docs.length}');
    return hasUserSearched
        ? SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: searchResultSnapshot?.docs.length ?? 0,
              itemBuilder: (context, index) {
                final doc = searchResultSnapshot!.docs[index];
                final data = doc.data() as Map<String, dynamic>;

                String groupId = doc.id; // Access the document ID directly
                final groupName = data["groupName"] as String?;
                final admin = data["admin"] as String?;
                // print(groupId);
                // print(groupName);
                // print(admin);
                if (groupId.isNotEmpty && groupName != null && admin != null) {
                  return groupTile(
                    user.name,
                    groupId,
                    groupName,
                    admin,
                  );
                } else {
                  // Return a placeholder widget or null if any of the required fields is null
                  print("Some value is null");
                  return Container();
                }
              },
            ),
          )
        : Container();
  }

  // Widget groupTile(
  //     String userName, String groupId, String groupName, String admin) {
  //   _joinValueInGroup(user.name, groupId, groupName, admin);
  //   return ListTile(
  //     tileColor: Colors.black,
  //     contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
  //     leading: CircleAvatar(
  //       radius: 30.0,
  //       backgroundColor: Colors.blueAccent,
  //       child: Text(
  //         groupName.isNotEmpty ? groupName.substring(0, 1).toUpperCase() : '',
  //         style: TextStyle(color: Colors.white),
  //       ),
  //     ),
  //     title: Text(groupName,
  //         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
  //     subtitle: Text(
  //       "Admin: $admin",
  //       style: TextStyle(color: Colors.white),
  //     ),
  //     trailing: InkWell(
  //       onTap: () async {
  //         // await DatabaseService(uid: user.uid)
  //         //     .toggleGroupJoin(groupId, groupName, user.name);
  //         // _showScaffold('Successfully joined the group "$groupName"');

  //         if (_isJoined) {
  //           setState(() {
  //             _isJoined = !_isJoined;
  //           });
  //           Future.delayed(Duration(milliseconds: 0), () {
  //             Navigator.of(context).push(MaterialPageRoute(
  //               builder: (context) => ChatPage(
  //                 groupId: groupId,
  //                 userName: user.name,
  //                 groupName: groupName,
  //               ),
  //             ));
  //           });
  //         } else {
  //           _showScaffold('Left the group "$groupName"');

  //           setState(() {
  //             _isJoined = !_isJoined;
  //           });
  //         }
  //       },
  //       child: _isJoined
  //           ? Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(10.0),
  //                 color: Colors.black87,
  //                 border: Border.all(color: Colors.white, width: 1.0),
  //               ),
  //               padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
  //               child: Text('Joined', style: TextStyle(color: Colors.white)),
  //             )
  //           : Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(10.0),
  //                 color: Colors.blueAccent,
  //               ),
  //               padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
  //               child: Text('Join', style: TextStyle(color: Colors.white)),
  //             ),
  //     ),
  //   );
  // }
  Widget groupTile(
    String userName,
    String groupId,
    String groupName,
    String admin,
  ) {
    bool _isChatOpen = false; // Track if the chat is open

    // Function to handle joining/leaving group
    void _handleJoinLeaveGroup() {
      // Perform join/leave logic here
      // For demonstration, I'll toggle _isJoined state
      // setState(() {
      //   _isJoined = !_isJoined;
      // });

      // Simulate opening chat page
      Future.delayed(Duration(milliseconds: 0), () {
        _isChatOpen = true; // Mark chat as open
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ChatPage(
            groupId: groupId,
            userName: userName,
            groupName: groupName,
          ),
        ));
      });
    }

    return ListTile(
      tileColor: Colors.black,
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      leading: CircleAvatar(
        radius: 30.0,
        backgroundColor: Colors.blueAccent,
        child: Text(
          groupName.isNotEmpty ? groupName.substring(0, 1).toUpperCase() : '',
          style: TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        groupName,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      subtitle: Text(
        "Admin: $admin",
        style: TextStyle(color: Colors.white),
      ),
      trailing: _isChatOpen
          ? null // Hide the button when chat is open
          : InkWell(
              onTap: () {
                _handleJoinLeaveGroup();
              },
              child: _isJoined
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.black87,
                        border: Border.all(color: Colors.white, width: 1.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child:
                          Text('Open', style: TextStyle(color: Colors.white)),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.blueAccent,
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child:
                          Text('Open', style: TextStyle(color: Colors.white)),
                    ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.black87,
        title: Text(
          'Search',
          style: TextStyle(
            fontSize: 27.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            color: Colors.grey[700],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchEditingController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search groups...",
                      hintStyle: TextStyle(
                        color: Colors.white38,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _initiateSearch,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(Icons.search, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          isLoading
              ? Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : Expanded(
                  child: groupList(),
                ),
        ],
      ),
    );
  }
}
