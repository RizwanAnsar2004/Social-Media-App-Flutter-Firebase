// import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:moneyup/constants/routes.dart';

// class ForgotPasswordView extends StatefulWidget {
//   const ForgotPasswordView({super.key});

//   @override
//   State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
// }

// class _ForgotPasswordViewState extends State<ForgotPasswordView> {
//   String email = "mike@gmail.com";
//   late final TextEditingController _email;

//   @override
//   void initState() {
//     _email = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _email.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent, // Set the desired background color
//         elevation: 0.0,
//         automaticallyImplyLeading: true,
//         // Other app bar properties
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const Padding(
//               padding: EdgeInsets.only(top: 80.0),
//               child: FaIcon(
//                 FontAwesomeIcons.lock, // Set the desired Font Awesome icon
//                 size: 60,
//                 color: Colors.black,
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.only(top: 30.0),
//               child: Text(
//                 "Forget Password",
//                 style: TextStyle(
//                   color: Color(0xFF1E1E1E),
//                   fontFamily: 'SF Pro Display',
//                   fontSize: 30.0,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.only(
//                   top: 10.0, left: 30.0, right: 30.0, bottom: 30.0),
//               child: Text(
//                 "Provide your account's email for which you want to reset your password!",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Color(0xFF1E1E1E),
//                   fontFamily: 'SF Pro Display',
//                   fontSize: 16.0,
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(
//                 top: 20.0,
//                 left: 30.0,
//                 right: 30.0,
//                 bottom: 12.0,
//               ),
//               child: TextField(
//                 controller: _email,
//                 autocorrect: false,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                   hintText: 'Email',
//                   hintStyle: const TextStyle(
//                     color: Color(0xFFA1A1AA),
//                   ),
//                   contentPadding: const EdgeInsets.fromLTRB(
//                       20.0, 20.0, 20.0, 20.0), // Set the content padding
//                   border: OutlineInputBorder(
//                     borderSide: const BorderSide(
//                         color: Color(0xFFD4D4D8),
//                         width: 1.0), // Set the border color and width
//                     borderRadius:
//                         BorderRadius.circular(12.0), // Set the border radius
//                   ),
//                 ),
//                 style: const TextStyle(
//                   fontFamily: 'SF Pro Display',
//                   fontStyle: FontStyle.normal,
//                   fontWeight: FontWeight.w400,
//                   fontSize: 18.0,
//                   height: 1.0,
//                   color: Color(0xFF18181B), // Set the hint text color
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(
//                 left: 30.0,
//                 right: 30.0,
//                 bottom: 12.0,
//               ),
//               child: ElevatedButton(
//                 onPressed: () async {
//                   if (email == _email.text) {
//                     Navigator.of(context).pushNamed(
//                       verificationCodeRoute,
//                     );
//                   } else {
//                     final snackBar = SnackBar(
//                       elevation: 0,
//                       behavior: SnackBarBehavior.floating,
//                       backgroundColor: Colors.transparent,
//                       content: AwesomeSnackbarContent(
//                         title: 'Oh Snap!',
//                         message: 'You entered an incorrect email!',

//                         /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
//                         contentType: ContentType.failure,
//                       ),
//                     );

//                     ScaffoldMessenger.of(context)
//                       ..hideCurrentSnackBar()
//                       ..showSnackBar(snackBar);
//                   }
//                 },
//                 style: TextButton.styleFrom(
//                   fixedSize: const Size(398.0, 60.0),
//                   backgroundColor: const Color(0xFF79F959),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.0),
//                   ),
//                 ),
//                 child: const Text(
//                   'Next',
//                   style: TextStyle(
//                     fontFamily: 'SF Pro Display',
//                     fontStyle: FontStyle.normal,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 18.0,
//                     color: Color(0xFF18181B),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class passreset extends StatefulWidget {
  const passreset({Key? key}) : super(key: key);

  @override
  State<passreset> createState() => _passresetState();
}

class _passresetState extends State<passreset> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Password reset link sent ! Check Your Email'),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(e.message.toString()),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF79F959),
          elevation: 0,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Text(
                'Enter Your Email and we will send you the link to reset password',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color(0xFF79F959)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Email',
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
              ),
            ),
            MaterialButton(
              onPressed: passwordReset,
              child: Text('Reset Password'),
              color: const Color(0xFF79F959),
            )
          ],
        ));
  }
}
