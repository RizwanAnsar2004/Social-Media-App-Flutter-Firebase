import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moneyup/constants/routes.dart';
import 'package:moneyup/providers/user_provider.dart';
import 'package:moneyup/views/components/bottom_navigation_bar.dart';
import 'package:moneyup/views/components/post.dart';
import 'package:provider/provider.dart';
import 'package:moneyup/views/edit_profile.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic> userData = {};

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<DocumentSnapshot> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    return userSnapshot;
  }

  User? get user => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  void initState() {
    super.initState();
    someFunction();
  }

  Future<void> someFunction() async {
    var userSnapshot = await getUserDetails();
    setState(() {
      userData = userSnapshot.data() as Map<String, dynamic>;
    }); // Assign the user data to userData
  }

  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (_) => ProfilePage(),
      );

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
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  AppBar _appBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      forceMaterialTransparency: true,
      automaticallyImplyLeading: false, // This line removes the back button
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Removed IconButton for back button
              const SizedBox(),
              IconButton(
                onPressed: () {
                  // Show the popup menu when the icon is pressed
                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                        48, 50, 0, 0), // Adjust the position as needed
                    items: <PopupMenuEntry>[
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.create_outlined),
                          title: Text('Edit Profile'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      UserProfileEditScreen()),
                            );
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.logout),
                          title: Text('Logout'),
                          onTap: () {
                            signOut;
                            Navigator.pushReplacementNamed(context, loginRoute);
                          },
                        ),
                      ),
                    ],
                  );
                },
                icon: Icon(Icons.settings),
                color: Colors.white,
              ),
            ],
          ),
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
                    "${userData['followers'] != null ? userData['followers'].length.toString() : '0'}",
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(width: 125),
                  Text(
                    "${userData['following'] != null ? userData['following'].length.toString() : '0'}",
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
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Container();
    }
    return Container(
      color: Colors.black, // Set background color to black
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: currentUser.uid)
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
