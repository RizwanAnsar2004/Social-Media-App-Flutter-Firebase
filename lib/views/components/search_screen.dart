import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:moneyup/constants/colors.dart';
import 'package:moneyup/views/profile_view.dart';
import 'package:moneyup/views/user_profile_view.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.backgroundColor, // Set background color to black
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Form(
          child: TextFormField(
            controller: searchController,
            style: TextStyle(color: Colors.white), // Set text color to white
            decoration: InputDecoration(
              labelText: 'Search for a user...',
              labelStyle:
                  TextStyle(color: Colors.white), // Set label color to white
              suffixIcon: IconButton(
                icon: Icon(Icons.search,
                    color: Colors.white), // Set icon color to white
                onPressed: () {
                  _searchUser(searchController.text);
                },
              ),
            ),
            onFieldSubmitted: (String _) {
              setState(() {
                isShowUsers = true;
              });
            },
          ),
        ),
      ),
      body: isShowUsers
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where(
                    'username',
                    isGreaterThanOrEqualTo: searchController.text,
                  )
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UserProfileView(
                            uid: (snapshot.data! as dynamic).docs[index]['uid'],
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            (snapshot.data! as dynamic).docs[index]['photoUrl'],
                          ),
                          radius: 16,
                        ),
                        title: Text(
                          (snapshot.data! as dynamic).docs[index]['username'],
                          style: TextStyle(
                              color: Colors.white), // Set text color to white
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : Container(), // Return an empty container when isShowUsers is false
    );
  }

  void _searchUser(String searchText) async {
    if (searchText.isNotEmpty) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: searchText)
          .get();
      setState(() {
        isShowUsers = true;
      });
    } else {
      setState(() {
        isShowUsers = false;
      });
    }
  }
}
