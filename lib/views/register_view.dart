import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moneyup/constants/routes.dart';
import 'package:moneyup/models/user.dart' as model;
import 'package:moneyup/utils/utils.dart';
import 'package:moneyup/views/ApiService.dart';
import 'package:moneyup/views/storage_methods.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();

  Future<model.User> getUserDetails() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    return model.User.fromSnap(snap);
  }
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _title;
  late final TextEditingController _contact;
  late final TextEditingController _address;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  Uint8List? _image;
  bool _isLoading = false;

  FirebaseAuth _auth = FirebaseAuth.instance;
    final ApiService _apiService = ApiService();

void _signUp() async {
    Map<String, dynamic> userData = {
      'name': _name.text,
      'email': _email.text,
      'password': _password.text,
    };

    final response = await _apiService.signUp(userData);
    if (response.statusCode == 200) {
      // Handle success
      print('User signed up successfully');
    } else {
      // Handle error
      print('Failed to sign up user');
    }
  }
  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    _contact = TextEditingController();
    _title = TextEditingController();
    _address = TextEditingController();
  }

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    return model.User.fromSnap(snap);
  }

  Future<String> signUpUser(
      {required String email,
      required String name,
      required String title,
      required String password,
      required String address,
      required String contact,
      required Uint8List file}) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    String res = 'Some Error Occurred';
    try {
      if (email.isNotEmpty &&
          name.isNotEmpty &&
          title.isNotEmpty &&
          password.isNotEmpty &&
          address.isNotEmpty &&
          contact.isNotEmpty &&
          file != null) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String photoUrl =
            await StorageMethods().uploadimagetoStorage('pfp', file, false);
        print('${cred.user!.uid}');
        model.User user = model.User(
          name: name,
          uid: cred.user!.uid,
          email: email,
          title: title,
          password: password,
          // address: address,
          contact: contact,
          followers: [],
          following: [],
          photoUrl: photoUrl,
        );
        await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());
        res = 'success';
      } else {
        throw 'One or more required fields are empty';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _address.dispose();
    _title.dispose();
    _contact.dispose();
    super.dispose();
  }

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                width: screenWidth,
                color: const Color(0xFF1E1E1E),
                child: const Padding(
                  padding: EdgeInsets.only(top: 80.0, bottom: 30),
                  child: Column(
                    children: [
                      Text(
                        "Welcome to Money Up",
                        style: TextStyle(
                          color: Color(0xFFE4E4E7),
                          fontFamily: 'SF Pro Display',
                          fontSize: 18.0,
                        ),
                      ),
                      Text(
                        "Please signup",
                        style: TextStyle(
                          color: Color(0xFFE4E4E7),
                          fontFamily: 'SF Pro Display',
                          fontSize: 30.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  border: Border.all(
                    color: const Color(0xFFE1EFFE),
                    width: 1,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(35.0),
                    topRight: Radius.circular(35.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: _image != null
                                ? GestureDetector(
                                    onTap: () {
                                      selectImage();
                                    },
                                    child: CircleAvatar(
                                      radius: 64,
                                      backgroundImage: MemoryImage(_image!),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      selectImage();
                                    },
                                    child: const CircleAvatar(
                                      radius: 64,
                                      backgroundImage: NetworkImage(
                                          'https://i.stack.imgur.com/l60Hf.png'),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _name,
                          decoration: InputDecoration(
                            hintText: 'Name',
                            hintStyle: const TextStyle(
                              color: Color(0xFFA1A1AA),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                                20.0, 20.0, 20.0, 20.0),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFD4D4D8),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _title,
                          decoration: InputDecoration(
                            hintText: 'Title',
                            hintStyle: const TextStyle(
                              color: Color(0xFFA1A1AA),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                                20.0, 20.0, 20.0, 20.0),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFD4D4D8),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _address,
                          decoration: InputDecoration(
                            hintText: 'Address',
                            hintStyle: const TextStyle(
                              color: Color(0xFFA1A1AA),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                                20.0, 20.0, 20.0, 20.0),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFD4D4D8),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _contact,
                          decoration: InputDecoration(
                            hintText: 'Contact',
                            hintStyle: const TextStyle(
                              color: Color(0xFFA1A1AA),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                                20.0, 20.0, 20.0, 20.0),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFD4D4D8),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _email,
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: const TextStyle(
                              color: Color(0xFFA1A1AA),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                                20.0, 20.0, 20.0, 20.0),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFD4D4D8),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _password,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: const TextStyle(
                              color: Color(0xFFA1A1AA),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                                20.0, 20.0, 20.0, 20.0),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFD4D4D8),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _confirmPassword,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            hintStyle: const TextStyle(
                              color: Color(0xFFA1A1AA),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                                20.0, 20.0, 20.0, 20.0),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFD4D4D8),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 8.0, right: 8.0, bottom: 12.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            String signUpResult = await signUpUser(
                              email: _email.text,
                              name: _name.text,
                              title: _title.text,
                              password: _password.text,
                              address: _address.text,
                              contact: _contact.text,
                              file: _image!,
                            );
                            if (signUpResult == 'success') {
                              print('REGISTRATION SUCCESSFUL');
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                loginRoute,
                                (route) => false,
                              );
                            } else {
                              print(signUpResult);
                              print('REGISTRATION FAILED');
                              // Registration failed, handle the error or display a message to the user
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(398.0, 60.0),
                            backgroundColor: const Color(0xFF79F959),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  // Wrap the text in SizedBox
                                  width: 24.0,
                                  height: 24.0,
                                  child:
                                      CircularProgressIndicator(), // Show loading indicator
                                )
                              : const Text(
                                  'Signup',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.0,
                                    color: Color(0xFF18181B),
                                  ),
                                ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 30.0, bottom: 210.0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              loginRoute,
                              (route) => false,
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFFFFFF),
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                          ),
                          child: const Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                  color: Color(0xFF18181B),
                                  fontWeight: FontWeight.w400),
                              children: [
                                TextSpan(
                                  text: "Login!",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
