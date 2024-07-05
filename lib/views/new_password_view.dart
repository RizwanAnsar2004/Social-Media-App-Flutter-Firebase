import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moneyup/constants/routes.dart';

class NewPasswordView extends StatefulWidget {
  const NewPasswordView({super.key});

  @override
  State<NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends State<NewPasswordView> {
  String password = "mike123";
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;

  @override
  void initState() {
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Set the desired background color
        elevation: 0.0,
        automaticallyImplyLeading: true,
        // Other app bar properties
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(
                top: 50.0,
              ),
              child: FaIcon(
                FontAwesomeIcons.lockOpen, // Set the desired Font Awesome icon
                size: 60,
                color: Colors.black,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                top: 20.0,
              ),
              child: Text(
                "New Password",
                style: TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontFamily: 'SF Pro Display',
                  fontSize: 30.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                top: 10.0,
                left: 30.0,
                right: 30.0,
                bottom: 20.0,
              ),
              child: Text(
                "Your identity has been verified!\nSet your new password",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontFamily: 'SF Pro Display',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 30.0,
                right: 30.0,
                bottom: 12.0,
              ),
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
                      20.0, 20.0, 20.0, 20.0), // Set the content padding
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color(0xFFD4D4D8),
                        width: 1.0), // Set the border color and width
                    borderRadius:
                        BorderRadius.circular(12.0), // Set the border radius
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w400,
                  fontSize: 18.0,
                  height: 1.0,
                  color: Color(0xFF18181B), // Set the hint text color
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 30.0,
                right: 30.0,
                bottom: 12.0,
              ),
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
                      20.0, 20.0, 20.0, 20.0), // Set the content padding
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color(0xFFD4D4D8),
                        width: 1.0), // Set the border color and width
                    borderRadius:
                        BorderRadius.circular(12.0), // Set the border radius
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w400,
                  fontSize: 18.0,
                  height: 1.0,
                  color: Color(0xFF18181B), // Set the hint text color
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 30.0,
                right: 30.0,
                bottom: 12.0,
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (_password.text == password) {
                    final snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
                      content: AwesomeSnackbarContent(
                        title: 'Oh Snap!',
                        message:
                            'You entered a password that matches your current password!',
                        contentType: ContentType.failure,
                      ),
                    );

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(snackBar);
                  } else if (_password.text != _confirmPassword.text) {
                    final snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
                      content: AwesomeSnackbarContent(
                        title: 'Oh Snap!',
                        message:
                            'Password and Confirm Password should be same.',
                        contentType: ContentType.failure,
                      ),
                    );

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(snackBar);
                  } else {
                    final snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
                      content: AwesomeSnackbarContent(
                        title: 'Success!',
                        message: 'Your password has been successfully reset.',

                        /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                        contentType: ContentType.success,
                      ),
                    );

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(snackBar);

                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (route) => false,
                    );
                  }
                },
                style: TextButton.styleFrom(
                  fixedSize: const Size(398.0, 60.0),
                  backgroundColor: const Color(0xFF79F959),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'Update',
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
          ],
        ),
      ),
    );
  }
}
