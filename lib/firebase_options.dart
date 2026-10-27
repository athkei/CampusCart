// TEMPORARY STUB so the project compiles without red errors.
// Overwrite this file by running, in the project folder:
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=campuscart-dc95f
// That generates the real keys for Android/iOS/web and replaces this file.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Run flutterfire configure for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_flutterfire_configure',
    appId: 'REPLACE',
    messagingSenderId: 'REPLACE',
    projectId: 'campuscart-dc95f',
    storageBucket: 'campuscart-dc95f.firebasestorage.app',
  );
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_flutterfire_configure',
    appId: 'REPLACE',
    messagingSenderId: 'REPLACE',
    projectId: 'campuscart-dc95f',
    storageBucket: 'campuscart-dc95f.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_flutterfire_configure',
    appId: 'REPLACE',
    messagingSenderId: 'REPLACE',
    projectId: 'campuscart-dc95f',
    storageBucket: 'campuscart-dc95f.firebasestorage.app',
  );
}
