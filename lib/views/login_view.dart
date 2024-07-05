import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moneyup/constants/colors.dart';
import 'package:moneyup/constants/routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moneyup/views/ApiService.dart';
import 'package:toastification/toastification.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginView extends StatefulWidget {
  // const LoginView({super.key});
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String email = "mike@gmail.com";
  String password = "mike123";
  final ApiService _apiService = ApiService();
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final FirebaseAuth _auth;
  late final GoogleSignIn _googleSignIn;
  void _login() async {
    Map<String, dynamic> loginData = {
      'email': _email.text,
      'password': _password.text,
    };

    final response = await _apiService.login(loginData);
    if (response.statusCode == 200) {
      // Handle success, navigate to the main screen, etc.
      print('User logged in successfully');
    } else {
      // Handle error
      print('Failed to log in user');
    }
  }

  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "some error occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
      } else {
        res = "PLEASE ENTER ALL FIELDS";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = "User Not Found";
      } else if (e.code == 'user-not-found') {
        res = "Invalid Cridentials";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _auth = FirebaseAuth.instance;
    _googleSignIn = GoogleSignIn();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        // Get the user details
        final User? user = userCredential.user;

        if (user != null) {
          // Navigate to your home screen or do something else
          Navigator.of(context).pushNamedAndRemoveUntil(
            homeRoute,
            (route) => false,
          );
        }
      } else {
        // Handle if Google sign-in is cancelled
        print("Google sign-in cancelled.");
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          autoCloseDuration: const Duration(seconds: 2),
          title: Text('INVALID CRIDENTIALS!!'),
          // // you can also use RichText widget for title and description parameters
          // description: RichText(
          //     text: const TextSpan(
          //         text:
          //             'This is a sample toast message. ')),
          alignment: Alignment.topCenter,
          direction: TextDirection.ltr,
          animationDuration: const Duration(milliseconds: 200),

          icon: const Icon(Icons.error_outline_outlined),
          primaryColor: Colors.red,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x07000000),
              blurRadius: 16,
              offset: Offset(0, 16),
              spreadRadius: 0,
            )
          ],
          showProgressBar: true,
          closeButtonShowType: CloseButtonShowType.onHover,
          closeOnClick: false,
          pauseOnHover: true,
          dragToClose: true,
          applyBlurEffect: true,
          callbacks: ToastificationCallbacks(
            onTap: (toastItem) => print('Toast ${toastItem.id} tapped'),
            onCloseButtonTap: (toastItem) =>
                print('Toast ${toastItem.id} close button tapped'),
            onAutoCompleteCompleted: (toastItem) =>
                print('Toast ${toastItem.id} auto complete completed'),
            onDismissed: (toastItem) =>
                print('Toast ${toastItem.id} dismissed'),
          ),
        );
      }
    } catch (e) {
      // Handle sign-in errors
      print("Error signing in with Google: $e");
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 2),
        title: Text('INVALID CRIDENTIALS!!'),
        // // you can also use RichText widget for title and description parameters
        // description: RichText(
        //     text: const TextSpan(
        //         text:
        //             'This is a sample toast message. ')),
        alignment: Alignment.topCenter,
        direction: TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 200),

        icon: const Icon(Icons.error_outline_outlined),
        primaryColor: Colors.red,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 16,
            offset: Offset(0, 16),
            spreadRadius: 0,
          )
        ],
        showProgressBar: true,
        closeButtonShowType: CloseButtonShowType.onHover,
        closeOnClick: false,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: true,
        callbacks: ToastificationCallbacks(
          onTap: (toastItem) => print('Toast ${toastItem.id} tapped'),
          onCloseButtonTap: (toastItem) =>
              print('Toast ${toastItem.id} close button tapped'),
          onAutoCompleteCompleted: (toastItem) =>
              print('Toast ${toastItem.id} auto complete completed'),
          onDismissed: (toastItem) => print('Toast ${toastItem.id} dismissed'),
        ),
      );
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      // Log in with Facebook
      final LoginResult result = await FacebookAuth.instance.login();

      // Check if the login was successful
      if (result.status == LoginStatus.success) {
        // Get the access token
        final AccessToken accessToken = result.accessToken!;

        // Use the access token to get user data
        final userData = await FacebookAuth.instance.getUserData();

        // Access user data
        print('User ID: ${userData['id']}');
        print('User Name: ${userData['name']}');
        print('User Email: ${userData['email']}');
        print('User Picture URL: ${userData['picture']['data']['url']}');

        // Navigate to your home screen or do something else
        Navigator.of(context).pushNamedAndRemoveUntil(
          homeRoute,
          (route) => false,
        );
      } else {
        // Handle if Facebook sign-in is cancelled or fails
        print("Facebook sign-in failed or cancelled.");
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          autoCloseDuration: const Duration(seconds: 2),
          title: Text('INVALID CRIDENTIALS!!'),
          // // you can also use RichText widget for title and description parameters
          // description: RichText(
          //     text: const TextSpan(
          //         text:
          //             'This is a sample toast message. ')),
          alignment: Alignment.topCenter,
          direction: TextDirection.ltr,
          animationDuration: const Duration(milliseconds: 200),

          icon: const Icon(Icons.error_outline_outlined),
          primaryColor: Colors.red,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x07000000),
              blurRadius: 16,
              offset: Offset(0, 16),
              spreadRadius: 0,
            )
          ],
          showProgressBar: true,
          closeButtonShowType: CloseButtonShowType.onHover,
          closeOnClick: false,
          pauseOnHover: true,
          dragToClose: true,
          applyBlurEffect: true,
          callbacks: ToastificationCallbacks(
            onTap: (toastItem) => print('Toast ${toastItem.id} tapped'),
            onCloseButtonTap: (toastItem) =>
                print('Toast ${toastItem.id} close button tapped'),
            onAutoCompleteCompleted: (toastItem) =>
                print('Toast ${toastItem.id} auto complete completed'),
            onDismissed: (toastItem) =>
                print('Toast ${toastItem.id} dismissed'),
          ),
        );
      }
    } catch (e) {
      // Handle sign-in errors
      print("Error signing in with Facebook: $e");
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 2),
        title: Text('INVALID CRIDENTIALS!!'),
        // // you can also use RichText widget for title and description parameters
        // description: RichText(
        //     text: const TextSpan(
        //         text:
        //             'This is a sample toast message. ')),
        alignment: Alignment.topCenter,
        direction: TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 200),

        icon: const Icon(Icons.error_outline_outlined),
        primaryColor: Colors.red,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 16,
            offset: Offset(0, 16),
            spreadRadius: 0,
          )
        ],
        showProgressBar: true,
        closeButtonShowType: CloseButtonShowType.onHover,
        closeOnClick: false,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: true,
        callbacks: ToastificationCallbacks(
          onTap: (toastItem) => print('Toast ${toastItem.id} tapped'),
          onCloseButtonTap: (toastItem) =>
              print('Toast ${toastItem.id} close button tapped'),
          onAutoCompleteCompleted: (toastItem) =>
              print('Toast ${toastItem.id} auto complete completed'),
          onDismissed: (toastItem) => print('Toast ${toastItem.id} dismissed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              color: AppColors.backgroundColor,
              child: const Padding(
                padding: EdgeInsets.only(top: 80.0, bottom: 30),
                child: Column(
                  children: [
                    Text(
                      "Welcome back",
                      style: TextStyle(
                        color: Color(0xFFE4E4E7),
                        fontFamily: 'SF Pro Display',
                        fontSize: 18.0,
                      ),
                    ),
                    Text(
                      "Please login",
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
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 14.0, left: 7.0, right: 7.0, bottom: 0.0),
                      child: TextField(
                        controller: _email,
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: const TextStyle(
                            color: AppColors.placeholderColor,
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFD4D4D8), width: 1.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w400,
                          fontSize: 18.0,
                          height: 1.0,
                          color: AppColors.darkTextColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 14.0, left: 7.0, right: 7.0, bottom: 0.0),
                      child: TextField(
                        controller: _password,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: const TextStyle(
                            color: AppColors.placeholderColor,
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFD4D4D8), width: 1.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w400,
                          fontSize: 18.0,
                          height: 1.0,
                          color: AppColors.darkTextColor,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15.0, right: 15.0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              forgotPasswordRoute,
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            foregroundColor: const Color(0xFFFFFFFF),
                          ),
                          child: const Text(
                            "Forgot password?",
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w400,
                              fontSize: 16.0,
                              decoration: TextDecoration.underline,
                              color: Color(0xFF2A2A2A),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0, left: 8.0, right: 8.0, bottom: 12.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          String login = await loginUser(
                              email: _email.text, password: _password.text);
                          if (login == 'success') {
                            print(login);
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              homeRoute,
                              (route) => false,
                            );
                          } else {
                            toastification.show(
                              context: context,
                              type: ToastificationType.error,
                              style: ToastificationStyle.fillColored,
                              autoCloseDuration: const Duration(seconds: 2),
                              title: Text(login),
                              // // you can also use RichText widget for title and description parameters
                              // description: RichText(
                              //     text: const TextSpan(
                              //         text:
                              //             'This is a sample toast message. ')),
                              alignment: Alignment.topCenter,
                              direction: TextDirection.ltr,
                              animationDuration:
                                  const Duration(milliseconds: 200),

                              icon: const Icon(Icons.error_outline_outlined),
                              primaryColor: Colors.red,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x07000000),
                                  blurRadius: 16,
                                  offset: Offset(0, 16),
                                  spreadRadius: 0,
                                )
                              ],
                              showProgressBar: true,
                              closeButtonShowType: CloseButtonShowType.onHover,
                              closeOnClick: false,
                              pauseOnHover: true,
                              dragToClose: true,
                              applyBlurEffect: true,
                              callbacks: ToastificationCallbacks(
                                onTap: (toastItem) =>
                                    print('Toast ${toastItem.id} tapped'),
                                onCloseButtonTap: (toastItem) => print(
                                    'Toast ${toastItem.id} close button tapped'),
                                onAutoCompleteCompleted: (toastItem) => print(
                                    'Toast ${toastItem.id} auto complete completed'),
                                onDismissed: (toastItem) =>
                                    print('Toast ${toastItem.id} dismissed'),
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          fixedSize: const Size(398.0, 60.0),
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w700,
                            fontSize: 18.0,
                            color: AppColors.darkTextColor,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 5.0,
                            left: 20.0,
                            right: 12.0,
                            bottom: 5.0,
                          ),
                          child: Container(
                            width: 147,
                            height: 1,
                            color: const Color(0xFFD4D4D8),
                          ),
                        ),
                        const Text(
                          "or",
                          style: TextStyle(
                            color: Color(0xFF71717A),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 5.0,
                            left: 12.0,
                            right: 12.0,
                            bottom: 5.0,
                          ),
                          child: Container(
                            width: 147,
                            height: 1,
                            color: const Color(0xFFD4D4D8),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton.icon(
                        onPressed: _signInWithFacebook,
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(340.0, 60.0),
                          backgroundColor: const Color(0xFF1877F2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10), // Set horizontal padding
                        ),
                        icon: const Padding(
                          padding: EdgeInsets.only(),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FaIcon(
                              FontAwesomeIcons.facebookF,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        label: const Padding(
                          padding: EdgeInsets.only(left: 45, right: 70),
                          child: Text(
                            'Continue with Facebook',
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Handle button press
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(340.0, 60.0),
                          backgroundColor: AppColors.darkTextColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Padding(
                          padding: EdgeInsets.only(),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FaIcon(
                              FontAwesomeIcons.apple,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        label: const Padding(
                          padding: EdgeInsets.only(left: 55, right: 85),
                          child: Text(
                            'Continue with Apple',
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: ElevatedButton.icon(
                        onPressed: _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(340.0, 60.0),
                          backgroundColor: const Color(0xFFD4D4D8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Padding(
                          padding: EdgeInsets.only(),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FaIcon(
                              FontAwesomeIcons.google,
                              size: 20,
                            ),
                          ),
                        ),
                        label: const Padding(
                          padding: EdgeInsets.only(left: 47, right: 80),
                          child: Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: AppColors.darkTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 70.0, bottom: 14.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            registerRoute,
                            (route) => false,
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          foregroundColor: const Color(0xFFFFFFFF),
                        ),
                        child: const Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                                color: AppColors.darkTextColor,
                                fontWeight: FontWeight.w400),
                            children: [
                              TextSpan(
                                text: "Sign up!",
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
    );
  }
}
