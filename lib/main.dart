import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:moneyup/constants/routes.dart';
import 'package:moneyup/providers/user_provider.dart';
import 'package:moneyup/views/Requote.dart';
import 'package:moneyup/views/addpost.dart';
import 'package:moneyup/views/map/pages/maps_v1_page.dart';
import 'package:moneyup/views/new_password_view.dart';
import 'package:moneyup/views/notifications/notification_model.dart';
import 'package:moneyup/views/notifications/notifications.dart';
import 'package:moneyup/views/profile_view.dart';
import 'package:moneyup/views/verification_code_view.dart';
import 'package:moneyup/views/forgot_password_view.dart';
import 'package:moneyup/views/home_view.dart';
import 'package:moneyup/views/login_view.dart';
import 'package:moneyup/views/register_view.dart';
import 'package:moneyup/views/splash.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: const MaterialColor(
            0xFF79F959,
            <int, Color>{
              50: Color(0xFFE1F7D3),
              100: Color(0xFFB8ECA3),
              200: Color(0xFF8CE173),
              300: Color(0xFF60D543),
              400: Color(0xFF36C414),
              500: Color(0xFF0CBF00),
              600: Color(0xFF0AAB00),
              700: Color(0xFF089700),
              800: Color(0xFF068200),
              900: Color(0xFF036E00),
            },
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(),
        routes: {
          splashRoute: (context) => const SplashView(),
          loginRoute: (context) => const LoginView(),
          forgotPasswordRoute: (context) => const passreset(),
          verificationCodeRoute: (context) => const VerificationCodeView(),
          newPasswordRoute: (context) => const NewPasswordView(),
          registerRoute: (context) => const RegisterView(),
          homeRoute: (context) => HomeView(),
          maproute: (context) => const MapsV1Page(),
          alertroute: (context) => Notifications(),
          // ignore: prefer_const_literals_to_create_immutables
          profileRoute: (context) => ProfilePage(),
          // postRoute: (context) => const PostView(
          //       postSnap: },
          //     ),
          addpost: (context) => const CustomPage(),
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          // Check if the user is logged in
          if (snapshot.hasData) {
            // User is logged in, navigate to the home screen
            return HomeView();
          } else {
            // User is not logged in, navigate to the login screen
            return LoginView();
          }
        } else if (snapshot.hasError) {
          // Error handling
          return Center(
            child: Text('${snapshot.error}'),
          );
        } else {
          // Loading state
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
