// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBvYQB-beb72LX1T2Ihk8hUoO_IO3NrD58',
    appId: '1:71914470507:web:3e162dd680fae422ca052e',
    messagingSenderId: '71914470507',
    projectId: 'moneyup-9413e',
    authDomain: 'moneyup-9413e.firebaseapp.com',
    storageBucket: 'moneyup-9413e.appspot.com',
    measurementId: 'G-9SZLNGBYDC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDQGN6Ykj6LVRJtz9hLe0oO68wD2CuzOo4',
    appId: '1:71914470507:android:58a0d137abe40f5fca052e',
    messagingSenderId: '71914470507',
    projectId: 'moneyup-9413e',
    storageBucket: 'moneyup-9413e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBSdjwhLtz86uCElte-pqIuHxFhxq6hJ3s',
    appId: '1:71914470507:ios:9492157e7f3b1b6eca052e',
    messagingSenderId: '71914470507',
    projectId: 'moneyup-9413e',
    storageBucket: 'moneyup-9413e.appspot.com',
    androidClientId: '71914470507-26vt0td1sf6osnogdd9a033f6jsn87cn.apps.googleusercontent.com',
    iosClientId: '71914470507-ge84neiscgssdh0o3nvvagms9kjg3gk8.apps.googleusercontent.com',
    iosBundleId: 'com.example.moneyup',
  );

}