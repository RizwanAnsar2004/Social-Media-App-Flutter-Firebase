import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moneyup/providers/user_provider.dart';
import 'package:moneyup/utils/utils.dart';
import 'package:moneyup/views/notifications/notifications_storage_methods.dart';
import 'package:provider/provider.dart';
import 'package:moneyup/views/firestore_methods.dart';

// Custom page widget
class Requote extends StatefulWidget {
  final Map<String, dynamic> snap;

  const Requote({super.key, required this.snap});

  @override
  RequoteState createState() => RequoteState();
}

class RequoteState extends State<Requote> {
  late final TextEditingController _description;
  Uint8List? _image;
  String username = "";
  String uid = "";
  String pfp = "";
  bool isLoading = false;

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

  Future<Uint8List?> fetchImageFromUrl() async {
    final url = widget.snap['postUrl'];
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        // Handle the error or return null
        print('Failed to load image. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Handle the exception or return null
      print('Error occurred while fetching image: $e');
      return null;
    }
  }

  void initState() {
    super.initState();
    _description = TextEditingController();
    getUsername();

    fetchImageFromUrl().then((imageData) {
      setState(() {
        _image = imageData;
      });
    });
  }

  // void selectImage() async {
  //   Uint8List im = await pickImage(ImageSource.gallery);
  //   setState(() {
  //     _image = im;
  //   });
  // }

  // void postImage(String uid, String username, String pfp) async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   try {
  //     String res = await FirestoreMethods().uploadPost(
  //       _description.text,
  //       _image!,
  //       uid,
  //       username,
  //       pfp,
  //     );
  //     if (res == "success") {
  //       setState(() {
  //         isLoading = false;
  //       });

  //       clearImage();
  //     }
  //   } catch (err) {
  //     setState(() {
  //       var isLoading = false;
  //     });
  //   }
  // }

  void postImage(String uid, String username, String pfp) async {
    setState(() {
      isLoading = true;
    });
    try {
      String res = await FirestoreMethods().uploadPost(
        _description.text,
        _image!,
        uid,
        username,
        pfp,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        await FirestoreMethods()
            .retweet(widget.snap['postid'], widget.snap['retweet']);
        // clearImage();
        if (res == "success") {
          await NotificationStorageMethods()
              .storeNotification("retweet", widget.snap['uid'], username, pfp);
          print(res);
        }
        // Redirect back to home view
        Navigator.pop(context);
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      // Handle error
      print("Error: $err");
    }
  }

  // void clearImage() {
  //   setState(() {
  //     _image = null;
  //   });
  // }

  // void selectImageCamera() async {
  //   Uint8List im = await pickImage(ImageSource.camera);
  //   setState(() {
  //     _image = im;
  //   });
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _description.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider user = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black, // Set background color here
      // Custom app bar
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.0, top: 15.0),
              child: Text(
                'Add post',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, right: 16.0),
              child: isLoading
                  ? CircularProgressIndicator() // Show loading indicator
                  : TextButton(
                      onPressed: () => postImage(uid, username, pfp),
                      child: Text(
                        'Post',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Color(0xFF79F959)),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        ),
                      ),
                    ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Align(
          alignment:
              Alignment.topLeft, // Align the content to the top-left corner
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Add padding to the image
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 50.0, // Set the radius of the circular image
                      backgroundImage: NetworkImage(
                          '$pfp'), // Replace 'assets/images/profile_image.jpg' with your image asset
                    ),
                    SizedBox(
                        width: 20.0), // Add some spacing between image and text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$username',
                            style: TextStyle(
                              fontSize: 24.0,
                              color: Colors.white, // White color for text
                              fontWeight: FontWeight.bold, // Bold text
                            ),
                          ),
                          SizedBox(
                              height:
                                  8.0), // Add some spacing between text and text field
                          Container(
                            width: double.infinity, // Take up remaining space
                            child: TextField(
                              controller: _description,
                              decoration: InputDecoration(
                                hintText: 'Write something...',
                                hintStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none, // Remove the border
                              ),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Network Image below the text field
                _image != null
                    ? Image.memory(
                        _image!,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
