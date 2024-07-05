import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyup/views/storage_methods.dart';
import 'package:moneyup/views/users_view_model.dart';
import 'package:moneyup/views/user_repo.dart';

class UserProfileEditScreen extends StatefulWidget {
  // Receive circle avatar image data
  const UserProfileEditScreen({Key? key}) : super(key: key);

  @override
  _UserProfileEditScreenState createState() => _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends State<UserProfileEditScreen> {
  late TextEditingController _nameController;
  // late TextEditingController _titleController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;
  late String _pfpUrl = '';
  bool isLoading = false;

  Uint8List? _image;
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

  Future<void> someFunction() async {
    var userSnapshot = await getUserDetails();
    setState(() {
      userData = userSnapshot.data() as Map<String, dynamic>;
      _nameController.text = userData['username'];
      // _titleController.text = userData['title'];
      _addressController.text = userData['address'];
      _contactController.text = userData['contact'];
      _emailController.text = userData['email'];
      _pfpUrl = userData['photoUrl'];
    }); // Assign the user data to userData
  }

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    someFunction();
    _nameController = TextEditingController();
    // _titleController = TextEditingController();
    _addressController = TextEditingController();
    _contactController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    // _titleController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  pickImage(ImageSource source) async {
    final ImagePicker _imagepicker = ImagePicker();
    XFile? _file = await _imagepicker.pickImage(source: source);
    if (_file != null) {
      return await _file.readAsBytes();
    }
    print("NO IMAGE SELECTED");
  }

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  Future<String> Store(Uint8List file) async {
    String photoUrl =
        await StorageMethods().uploadimagetoStorage('pfp', file, false);
    return photoUrl;
  }

  Future<String> updateUserData({
    required String uid,
    required String name,
    required String address,
    required String contact,
    required String email,
    Uint8List? file,
  }) async {
    setState(() {
      isLoading = true;
    });
    FirebaseAuth _auth = FirebaseAuth.instance;
    String res = 'Some Error Occurred';

    try {
      if (email.isNotEmpty &&
          name.isNotEmpty &&
          address.isNotEmpty &&
          contact.isNotEmpty) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(uid).get();

        String? photoUrl;
        if (file != null) {
          photoUrl =
              await StorageMethods().uploadimagetoStorage('pfp', file, false);
        } else {
          // If file is null, do not update photoUrl
          photoUrl = userSnapshot.get('photoUrl'); // Retrieve existing photoUrl
        }

        Map<String, dynamic> updatedData = {
          'username': name,
          'email': email,
          'address': address,
          'contact': contact,
        };

        // Only add photoUrl to updatedData if it's not null
        if (photoUrl != null) {
          updatedData['photoUrl'] = photoUrl;
        }

        await _firestore.collection('users').doc(uid).set(
              updatedData,
              SetOptions(merge: true),
            );

        res = 'success';
      } else {
        throw 'One or more required fields are empty';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              Visibility(
                visible: !isLoading, // Hide the icon when isLoading is true
                child: IconButton(
                  onPressed: () async {
                    setState(() {
                      isLoading =
                          true; // Set isLoading to true when the button is clicked
                    });
                    String signUpResult = await updateUserData(
                      uid: FirebaseAuth.instance.currentUser!.uid,
                      name: _nameController.text,
                      // title: _titleController.text,
                      address: _addressController.text,
                      contact: _contactController.text,
                      email: _emailController.text,
                      file: _image,
                    );
                    if (signUpResult == 'success') {
                      Navigator.pop(context);

                      print('REGISTRATION SUCCESSFUL');
                    } else {
                      print(signUpResult);
                      print('REGISTRATION FAILED');
                      // Registration failed, handle the error or display a message to the user
                    }
                    setState(() {
                      isLoading =
                          false; // Set isLoading back to false when the operation is complete
                    });
                  },
                  icon: const Icon(Icons.save),
                ),
              ),
              if (isLoading)
                CircularProgressIndicator(), // Circular progress indicator
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display circle avatar if image data is available
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
                            child: CircleAvatar(
                              radius: 64,
                              backgroundImage: NetworkImage(_pfpUrl),
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Name'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
              ),
              // const SizedBox(height: 16),
              // const Text('Title'),
              // const SizedBox(height: 8),
              // TextField(
              //   controller: _titleController,
              //   decoration: const InputDecoration(
              //     hintText: 'Enter your title',
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              const SizedBox(height: 16),
              const Text('Address'),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Enter your address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Contact'),
              const SizedBox(height: 8),
              TextField(
                controller: _contactController,
                decoration: const InputDecoration(
                  hintText: 'Enter your contact',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Email'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
