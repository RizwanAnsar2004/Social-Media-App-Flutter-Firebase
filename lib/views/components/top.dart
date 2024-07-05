import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneyup/views/components/search_screen.dart'; // Import the search screen file

class Top extends StatefulWidget {
  const Top({Key? key}) : super(key: key);

  @override
  State<Top> createState() => _TopState();
}

class _TopState extends State<Top> {
  late final TextEditingController _searchtext;
  bool isShowUsers = false;
  late QuerySnapshot<Map<String, dynamic>> _searchResult;

  @override
  void initState() {
    super.initState();
    _searchtext = TextEditingController();
  }

  @override
  void dispose() {
    _searchtext.dispose();
    super.dispose();
  }

  void _searchUser(String searchText) async {
    if (searchText.isNotEmpty) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: searchText)
          .get();
      setState(() {
        isShowUsers = true;
        _searchResult = querySnapshot;
      });
    } else {
      setState(() {
        isShowUsers = false;
      });
    }
  }

  // Function to navigate to the search screen
  void _navigateToSearchScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 50.0), // Reduced bottom padding
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Money ",
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                          letterSpacing: -1,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Up",
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                          letterSpacing: -1,
                          color: Color(0xFF79F959),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GestureDetector(
                      onTap: () {
                        _navigateToSearchScreen(
                            context); // Navigate to search screen
                      },
                      child: SvgPicture.asset('assets/search.svg'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () {
                    String searchText = _searchtext.text;
                    _searchUser(searchText);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F3F46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(52.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: _searchtext,
                        decoration: InputDecoration(
                          hintText: 'Cash in...',
                        ),
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Color(0xFFA1A1AA),
                        ),
                        // Call _searchUser when submitted
                        onSubmitted: _searchUser,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (isShowUsers)
              ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResult.docs.length,
                itemBuilder: (context, index) {
                  final userData = _searchResult.docs[index].data();
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(userData['photoUrl']),
                      radius: 16,
                    ),
                    title: Text(userData['username']),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
