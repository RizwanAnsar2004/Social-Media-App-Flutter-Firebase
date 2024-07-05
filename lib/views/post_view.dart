import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moneyup/views/components/comment.dart';
import 'package:moneyup/views/components/post.dart';
import 'package:moneyup/views/firestore_methods.dart';

class PostView extends StatefulWidget {
  final Map<String, dynamic> postSnap;

  const PostView({Key? key, required this.postSnap}) : super(key: key);

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  final TextEditingController _commentController = TextEditingController();

  void postComment() async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      User currentUser = _auth.currentUser!;

      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      String res = await FirestoreMethods().postComment(
        widget.postSnap['postid'],
        _commentController.text,
        snap['uid'],
        snap['username'],
        snap['photoUrl'],
      );

      if (res != 'success') {
        print(res);
      }
      setState(() {
        _commentController.text = "";
      });
    } catch (err) {
      print(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.1,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Post",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postSnap['postid'])
            .collection('comments')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      PostWidget(snap: widget.postSnap),
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0, left: 15.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Comments",
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xFFFAFAFA),
                            ),
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (ctx, index) => CommentWidget(
                          snap: (snapshot.data! as dynamic).docs[index].data(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 100),
                        child: TextField(
                          controller: _commentController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 4,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: 'Leave a comment',
                            hintStyle: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                            filled: true,
                            fillColor: Colors.black,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        postComment();
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
