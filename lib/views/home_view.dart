// Import necessary packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moneyup/constants/colors.dart';
import 'package:moneyup/constants/routes.dart';
import 'package:moneyup/views/ApiService.dart';
import 'package:moneyup/views/components/bottom_navigation_bar.dart';
import 'package:moneyup/views/components/post.dart';
import 'package:moneyup/views/addpost.dart';
import 'package:moneyup/views/components/top.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  HomeView({Key? key}) : super(key: key);

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  final ApiService _apiService = ApiService();

  void _fetchPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId =
          prefs.getString('userId'); // Replace with your logic to get userId
      final posts = await _apiService.getPosts(userId!);
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  void _addPost() async {
    Map<String, dynamic> postData = {
      'user_id': 'example_user_id', // You should get this from the user data
    };

    final response = await _apiService.addPost(postData);
    if (response.statusCode == 200) {
      // Handle success
      print('Post added successfully');
      _fetchPosts(); // Refresh posts after adding
    } else {
      // Handle error
      print('Failed to add post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height:
                  110, // Adjust this value based on the height of your header
              child: Top(),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height -
                  80 -
                  kBottomNavigationBarHeight -
                  kToolbarHeight, // Calculate the available height for the body
              child: _buildBody(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(context),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }

  // Widget _buildBody() {
  //   return StreamBuilder(
  //     stream: FirebaseFirestore.instance.collection('posts').snapshots(),
  //     builder: (context,
  //         AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Center(
  //           child: CircularProgressIndicator(),
  //         );
  //       } else if (snapshot.hasError) {
  //         return Center(
  //           child: Text('Error: ${snapshot.error}'),
  //         );
  //       } else {
  //         return ListView.builder(
  //           itemCount: snapshot.data!.docs.length,
  //           itemBuilder: (context, index) =>
  //               PostWidget(snap: snapshot.data!.docs[index].data()),
  //         );
  //       }
  //     },
  //   );
  // }

  Widget _buildBody() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        String currentUserId = FirebaseAuth.instance.currentUser!.uid;
        List<String> followingIDs = _getFollowingIds(currentUserId);
        if (followingIDs.isNotEmpty) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (userSnapshot.hasError) {
            return Center(
              child: Text('Error: ${userSnapshot.error}'),
            );
          } else if (userSnapshot.data == null) {
            // User not authenticated, handle accordingly
            return Center(
              child: Text('Please sign in to view posts'),
            );
          } else {
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('uid', whereIn: followingIDs
                      // [...followingIDs, currentUserId]
                      )
                  // .orderBy('datePublished', descending: true)
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
                } else if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No posts available'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) =>
                        PostWidget(snap: snapshot.data!.docs[index].data()),
                  );
                }
              },
            );
          }
        } else if (followingIDs.isEmpty) {
          return const Center(
            child: Text(
              'No posts available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          );
        }
        // Add a return statement here as a fallback
        return Container(); // Or any other widget you want to return as a fallback
      },
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<DocumentSnapshot> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    return userSnapshot;
  }

  @override
  void initState() {
    super.initState();
    someFunction();
  }

  late Map<String, dynamic> userData = {};
  Future<void> someFunction() async {
    var userSnapshot = await getUserDetails();
    setState(() {
      userData = userSnapshot.data() as Map<String, dynamic>;
    }); // Assign the user data to userData
  }

  List<String> _getFollowingIds(String currentUserId) {
    List<dynamic> followingData = userData['following'] ?? [];
    List<String> followingIds = followingData.cast<String>();
    print(followingIds);
    return followingIds;
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: const Color(0xFF3F3F46),
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: SvgPicture.asset(
                  'assets/upload.svg',
                  height: 24,
                  color: Colors.white,
                ),
                title: Text(
                  'Post',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(addpost);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                ),
                title: Text(
                  'Bucks',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
