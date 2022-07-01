// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        return macos;
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
    apiKey: 'AIzaSyD2yFNBYXOtnDi1vQkB8QfDoGMB6evIUnk',
    appId: '1:470611045203:web:a2a9c8093bfe20b30a8fa6',
    messagingSenderId: '470611045203',
    projectId: 'flutter-firebase-test-1-eda40',
    authDomain: 'flutter-firebase-test-1-eda40.firebaseapp.com',
    storageBucket: 'flutter-firebase-test-1-eda40.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDUooM2WVcK2XWxYmxJpvsBql0i6FM_jow',
    appId: '1:470611045203:android:c8975d065ac4fa2e0a8fa6',
    messagingSenderId: '470611045203',
    projectId: 'flutter-firebase-test-1-eda40',
    storageBucket: 'flutter-firebase-test-1-eda40.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC2PK6zfDIJH9PsdRsOLdJzFKc31vdsWnQ',
    appId: '1:470611045203:ios:6a11fd891eb711460a8fa6',
    messagingSenderId: '470611045203',
    projectId: 'flutter-firebase-test-1-eda40',
    storageBucket: 'flutter-firebase-test-1-eda40.appspot.com',
    androidClientId: '470611045203-h5il3qo8gj7jh6ldb24v5s8qc3071b66.apps.googleusercontent.com',
    iosClientId: '470611045203-lr1n0u2sm6fed7t2j9agkmocb07qbq4k.apps.googleusercontent.com',
    iosBundleId: 'com.example.firebaseFlutter1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC2PK6zfDIJH9PsdRsOLdJzFKc31vdsWnQ',
    appId: '1:470611045203:ios:6a11fd891eb711460a8fa6',
    messagingSenderId: '470611045203',
    projectId: 'flutter-firebase-test-1-eda40',
    storageBucket: 'flutter-firebase-test-1-eda40.appspot.com',
    androidClientId: '470611045203-h5il3qo8gj7jh6ldb24v5s8qc3071b66.apps.googleusercontent.com',
    iosClientId: '470611045203-lr1n0u2sm6fed7t2j9agkmocb07qbq4k.apps.googleusercontent.com',
    iosBundleId: 'com.example.firebaseFlutter1',
  );
}
