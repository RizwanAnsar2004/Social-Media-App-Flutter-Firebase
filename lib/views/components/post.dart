import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:moneyup/constants/colors.dart';
import 'package:moneyup/constants/routes.dart';
import 'package:moneyup/models/post.dart' as model;
import 'package:moneyup/views/ApiService.dart';
import 'package:moneyup/views/Requote.dart';
import 'package:moneyup/views/addpost.dart';
import 'package:moneyup/views/firestore_methods.dart';
import 'package:moneyup/models/user.dart' as model;
import 'package:moneyup/providers/user_provider.dart';
import 'package:moneyup/views/notifications/notifications_storage_methods.dart';
import 'package:moneyup/views/post_view.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class PostWidget extends StatefulWidget {
  final Map<String, dynamic> snap;

  const PostWidget({Key? key, required this.snap}) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isFavorite = false;
  bool isUpvote = false;
  late int upvoteCount = 0;
  late int retweetcount = 0;
  late int view = 0;
  late int comment = 0;
  late String username;
  late String uid;
  late String pfp;
  final ApiService _apiService = ApiService();

  void _addComment() async {
    final prefs = await SharedPreferences.getInstance();
    final userId =
        prefs.getString('userId'); // Replace with your logic to get userId

    final response = await _apiService.addComment(widget.snap['uid']);
    if (response.statusCode == 200) {
      // Handle success
      print('Comment added successfully');
      // Refresh comments after adding
    } else {
      // Handle error
      print('Failed to add comment');
    }
  }

  void _fetchComments() async {
    try {
      final comments = await _apiService.getComments(widget.snap['uid']);
      setState(() {});
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    view = generateRandomNumber();
    // Set the initial upvote count
    fetchPostData();
  }

  int generateRandomNumber() {
    final random = Random();
    view = random.nextInt(10) +
        1; // nextInt(5) generates a number between 0 and 4, so we add 1
    return view; // Print the generated number to the console (optional)
  }

  void fetchPostData() async {
    try {
      // Fetch user data and update state
      // Use widget.snap to access data from the widget
      setState(() {
        getUpvotes();
        getcomments();
        getUsername();
        getRetweet();
      });
    } catch (error) {
      print('Error fetching post data: $error');
    }
  }

  Future<int> fetchUpvotes() async {
    try {
      // Reference to the post document
      DocumentReference postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postid']);

      // Fetch the document snapshot
      DocumentSnapshot postSnapshot = await postRef.get();

      // Check if the document exists
      if (postSnapshot.exists) {
        // Get the data from the document
        Map<String, dynamic> postData =
            postSnapshot.data() as Map<String, dynamic>;

        // Check if likes field exists and is an array
        if (postData.containsKey('likes') && postData['likes'] is List) {
          // Return the length of the likes array as the upvotes count
          List<dynamic> likes = postData['likes'];
          return likes.length;
        } else {
          // If upvotes field doesn't exist, return 0
          return 0;
        }
      } else {
        // If the post document doesn't exist, return null or throw an error
        return 0;
      }
    } catch (error) {
      print('Error fetching upvotes: $error');
      throw error;
    }
  }

  Future<int> fetchretweet() async {
    try {
      // Reference to the post document
      DocumentReference postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postid']);

      // Fetch the document snapshot
      DocumentSnapshot postSnapshot = await postRef.get();

      // Check if the document exists
      if (postSnapshot.exists) {
        // Get the data from the document
        Map<String, dynamic> postData =
            postSnapshot.data() as Map<String, dynamic>;

        // Check if likes field exists and is an array
        if (postData.containsKey('retweet') && postData['retweet'] is List) {
          // Return the length of the likes array as the upvotes count
          List<dynamic> likes = postData['retweet'];
          return likes.length;
        } else {
          // If upvotes field doesn't exist, return 0
          return 0;
        }
      } else {
        // If the post document doesn't exist, return null or throw an error
        return 0;
      }
    } catch (error) {
      print('Error fetching upvotes: $error');
      throw error;
    }
  }

  Future<int> fetchcomments() async {
    try {
      // Reference to the post document
      DocumentReference postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postid']);

      // Fetch the document snapshot
      DocumentSnapshot postSnapshot = await postRef.get();

      // Check if the document exists
      if (postSnapshot.exists) {
        // Get the data from the document
        Map<String, dynamic> postData =
            postSnapshot.data() as Map<String, dynamic>;

        // Check if likes field exists and is an array
        if (postData.containsKey('likes') && postData['likes'] is List) {
          // Return the length of the likes array as the upvotes count
          List<dynamic> likes = postData['likes'];
          return likes.length;
        } else {
          // If upvotes field doesn't exist, return 0
          return 0;
        }
      } else {
        // If the post document doesn't exist, return null or throw an error
        return 0;
      }
    } catch (error) {
      print('Error fetching upvotes: $error');
      throw error;
    }
  }

  Future<int> fetchComments() async {
    try {
      // Reference to the comments collection for the post
      CollectionReference commentsRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postid'])
          .collection('comments');

      // Fetch the comments snapshot
      QuerySnapshot commentsSnapshot = await commentsRef.get();

      // Return the number of comments in the snapshot
      return commentsSnapshot.size;
    } catch (error) {
      print('Error fetching comments: $error');
      throw error;
    }
  }

  void getcomments() async {
    try {
      // Call the fetchUpvotes function
      int count = await fetchcomments();

      // Assign the result to upvoteCount
      comment = count;
    } catch (error) {
      print('Error getting upvotes: $error');
      // Handle error if necessary
    }
  }

  Widget _buildPanelRow(
      String svgPath, String title, String description, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        onTap;
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            SvgPicture.asset(
              svgPath,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: AppColors.lightTextColor,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Color(0xFF71717A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // void _onRetweetButtonPressed() {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (BuildContext context) {
  //       return Container(
  //         decoration: const BoxDecoration(
  //           color: AppColors.backgroundColor,
  //           borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(30),
  //             topRight: Radius.circular(30),
  //           ),
  //         ),
  //         height: 200,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             Align(
  //               alignment: Alignment.center,
  //               child: Container(
  //                 width: 100,
  //                 height: 6,
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(3),
  //                 ),
  //               ),
  //             ),
  //             _buildPanelRow('assets/reup.svg', 'ReUp', 'Retweet the post',
  //                 () async {
  //               try {
  //                 User? user = FirebaseAuth.instance.currentUser;
  //                 String? username =
  //                     FirebaseAuth.instance.currentUser?.displayName;
  //                 String? Photourl =
  //                     FirebaseAuth.instance.currentUser!.photoURL;
  //                 String res = await FirestoreMethods().uploadPost(
  //                   widget.snap['description'],
  //                   widget.snap['image'],
  //                   user!.uid,
  //                   username!,
  //                   Photourl!,
  //                 );
  //                 if (res == "success") {
  //                   print(res);
  //                 }
  //               } catch (err) {
  //                 // Handle error
  //                 print("Error: $err");
  //               }
  //             }),
  //             const Divider(),
  //             _buildPanelRow('assets/requote.svg', 'ReQuote',
  //                 'Add Quote to your retweet', () {}),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  void getUsername() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    setState(() {
      username = (snap.data() as Map<String, dynamic>)['username'];
      uid = (snap.data() as Map<String, dynamic>)['uid'];
      pfp = (snap.data() as Map<String, dynamic>)['photoUrl'];
    });
  }

  void postImage(String uid, String username, String pfp) async {
    try {
      String res = await FirestoreMethods().Reup(
        widget.snap['description'],
        widget.snap['postUrl'],
        uid,
        username,
        pfp,
      );
      if (res == "success") {
        await NotificationStorageMethods()
            .storeNotification("retweet", widget.snap['uid'], username, pfp);
        print(res);
        await FirestoreMethods()
            .retweet(widget.snap['postid'], widget.snap['retweet']);

        getRetweet();
        // Redirect back to home view
        Navigator.pop(context);
      }
    } catch (err) {
      // Handle error
      print("Error: $err");
    }
  }

  // void _onRetweetButtonPressed() {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Container(
  //         color: const Color(0xFF3F3F46),
  //         padding: EdgeInsets.all(16.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[
  //             ListTile(
  //               leading: SvgPicture.asset(
  //                 'assets/reup.svg',
  //                 height: 50,
  //               ),
  //               title: Text(
  //                 'ReUp',
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //               onTap: () {
  //                 setState(() {
  //                   uid = FirebaseAuth.instance.currentUser!.uid;
  //                   username = FirebaseAuth.instance.currentUser!.displayName!;
  //                   pfp = FirebaseAuth.instance.currentUser!.photoURL!;
  //                 });
  //                 postImage(uid, username, pfp);
  //               },
  //             ),
  //             ListTile(
  //               leading: SvgPicture.asset(
  //                 'assets/requote.svg',
  //                 height: 50,
  //               ),
  //               title: Text(
  //                 'Requote',
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //               onTap: () {
  //                 Navigator.of(context).push(
  //                   MaterialPageRoute(
  //                       builder: (context) => Requote(snap: widget.snap)),
  //                 );
  //                 getRetweet();
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  void _onRetweetButtonPressed() {
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
                  'assets/reup.svg',
                  height: 50,
                ),
                title: Text(
                  'ReUp',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  final currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    setState(() {
                      uid = currentUser.uid;
                      username = username;
                      pfp = pfp;
                    });
                    postImage(uid, username, pfp);
                  } else {
                    // Handle the case when the user is not authenticated
                    print('User is not logged in');
                  }
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'assets/requote.svg',
                  height: 50,
                ),
                title: Text(
                  'Requote',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Requote(snap: widget.snap),
                    ),
                  );
                  getRetweet();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void bucks() {
    print("bucks");
  }

  void getRetweet() async {
    try {
      // Call the fetchUpvotes function
      int count = await fetchretweet();
      print(count);
      // Assign the result to upvoteCount
      setState(() {
        retweetcount = count;
      });
    } catch (error) {
      print('Error getting upvotes: $error');
      // Handle error if necessary
    }
  }

  void getUpvotes() async {
    try {
      // Call the fetchUpvotes function
      int count = await fetchUpvotes();
      // Assign the result to upvoteCount
      setState(() {
        upvoteCount = count;
      });
    } catch (error) {
      print('Error getting upvotes: $error');
      // Handle error if necessary
    }
  }

  void _onPostWidgetTapped() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PostView(postSnap: widget.snap),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final model.User user = Provider.of<UserProvider>(context).getUser;
    return GestureDetector(
      onTap: _onPostWidgetTapped,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(widget.snap['pfp']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        widget.snap['username'],
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      widget.snap['datePublished'] != null
                          ? DateFormat.yMMMd()
                              .format(widget.snap['datePublished'].toDate())
                          : '',
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                  icon: SvgPicture.asset(
                    'assets/favorite.svg',
                    height: 24,
                    color: isFavorite ? const Color(0xFF79F959) : Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    'assets/three-dots-vertical.svg',
                    height: 21,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.snap['description'],
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(11.0),
                      image: DecorationImage(
                        image: NetworkImage(widget.snap['postUrl']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: IconButton(
                        onPressed: () async {
                          String res = await FirestoreMethods().likePost(
                              widget.snap['postid'], widget.snap['upvote']);
                          if (res == "success") {
                            await NotificationStorageMethods()
                                .storeNotification(
                                    "like", widget.snap['uid'], username, pfp);
                          }
                          setState(() {
                            isUpvote = !isUpvote;
                            getUpvotes();
                          });
                        },
                        icon: SvgPicture.asset(
                          'assets/upvote.svg',
                          color:
                              isUpvote ? const Color(0xFF79F959) : Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '$upvoteCount',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'SF Pro Display',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: IconButton(
                        onPressed: () {
                          _onPostWidgetTapped();
                        },
                        icon: SvgPicture.asset(
                          'assets/comment.svg',
                        ),
                      ),
                    ),
                    Text(
                      '$comment',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'SF Pro Display',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: IconButton(
                        onPressed: () {
                          _onRetweetButtonPressed();
                          setState(() {
                            getRetweet();
                          });
                        },
                        icon: SvgPicture.asset(
                          'assets/retweet.svg',
                        ),
                      ),
                    ),
                    Text(
                      '$retweetcount',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'SF Pro Display',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: IconButton(
                        onPressed: () {
                          // setState(() {
                          //   view = view + 1;
                          // });
                        },
                        icon: SvgPicture.asset(
                          'assets/views.svg',
                        ),
                      ),
                    ),
                    Text(
                      '$view',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'SF Pro Display',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: IconButton(
                        onPressed: () {
                          // Perform action for the upload button
                        },
                        icon: SvgPicture.asset(
                          'assets/upload.svg',
                        ),
                      ),
                    ),
                  ],
                ),
              ), // Add more action buttons here if needed
            ],
          ),
        ],
      ),
    );
  }
}
