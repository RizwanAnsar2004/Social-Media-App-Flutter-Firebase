import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moneyup/views/components/followbutton.dart';
import 'package:moneyup/views/components/post.dart';
import 'package:moneyup/views/firestore_methods.dart';
import 'package:moneyup/views/login_view.dart';

class UserProfileView extends StatefulWidget {
  final String uid;
  UserProfileView({Key? key, required this.uid}) : super(key: key);

  @override
  UserProfileViewState createState() => UserProfileViewState();
}

class UserProfileViewState extends State<UserProfileView> {
  late Map<String, dynamic> userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;
  Future<void> _fetchUserData() async {
    try {} catch (e) {
      // Handle any errors that occurred during the HTTP request
      print('Error fetching user data: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch user data. Please try again later.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
    if (userData['following'] != null) {
      following = userData['following'].length;
    } else {
      following = 0; // or any default value you prefer
    }
    if (userData['followers'] != null) {
      followers = userData['followers'].length;
    } else {
      followers = 0; // or any default value you prefer
    }
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // get post lENGTH
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {});
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBar(context),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Container(
                color: Colors.black, // Set background color to black
                child: Column(
                  children: [
                    _bannerAndProfilePicture(context),
                    _userBio(context),
                  ],
                ),
              ),
            ),
          ];
        },
        body: _buildBody(),
      ),
      // bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  AppBar _appBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      forceMaterialTransparency: true,
      automaticallyImplyLeading: true, // This line removes the back button
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }

  Widget _bannerAndProfilePicture(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('${userData['photoUrl']}'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10, left: 30), // Add padding to the top
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage('${userData['photoUrl']}'),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _userBio(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // User Bio
            Text(
              '${userData['username']}',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 30,
              ),
            ),
            Text(
              '${userData['title']}',
              style: textTheme.bodyMedium
                  ?.copyWith(color: Colors.white, fontSize: 20),
            ),
            Row(
              children: [
                Icon(Icons.assignment_ind_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "'${userData['contact']}'",
                  style: textTheme.bodySmall
                      ?.copyWith(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.email_outlined, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  '${userData['email']}',
                  style: textTheme.bodySmall
                      ?.copyWith(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            Text(
              'Biography: ${userData['bio']}', // Add this line to display the biography
              style: textTheme.bodySmall
                  ?.copyWith(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.start,
            ),
            // Follow/Unfollow Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FirebaseAuth.instance.currentUser!.uid == widget.uid
                    ? FollowButton(
                        text: 'Sign Out',
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        borderColor: Colors.white,
                        function: () async {
                          await signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const LoginView(),
                              ),
                            );
                          }
                        },
                      )
                    : isFollowing
                        ? FollowButton(
                            text: 'Unfollow',
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            borderColor: Colors.grey,
                            function: () async {
                              await FirestoreMethods().followUser(
                                FirebaseAuth.instance.currentUser!.uid,
                                userData['uid'],
                              );

                              setState(() {
                                isFollowing = false;
                                followers--;
                              });
                            },
                          )
                        : FollowButton(
                            text: 'Follow',
                            backgroundColor: Colors.green,
                            textColor: Colors.black,
                            borderColor: Colors.green,
                            function: () async {
                              await FirestoreMethods().followUser(
                                FirebaseAuth.instance.currentUser!.uid,
                                userData['uid'],
                              );

                              setState(() {
                                isFollowing = true;
                                followers++;
                              });
                            },
                          ),
                // Add spacing between buttons and user bio
                const SizedBox(width: 8),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 30),
              child: Row(
                children: [
                  Text(
                    "Followers:",
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(width: 40),
                  Text(
                    "Following:",
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 65),
              child: Row(
                children: [
                  Text(
                    "${userData['followers'] != null ? followers.toString() : '0'}",
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(width: 125),
                  Text(
                    "${userData['following'] != null ? following.toString() : '0'}",
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      color: Colors.black, // Set background color to black
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: widget.uid)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) =>
                  PostWidget(snap: snapshot.data!.docs[index].data()),
            );
          }
        },
      ),
    );
  }
}
