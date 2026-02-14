// File generated from Firebase Console config (Android + iOS).
// Android: android/app/google-services.json
// iOS: ios/Runner/GoogleService-Info.plist

import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) return android;
    if (Platform.isIOS) return ios;
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static FirebaseOptions get android => const FirebaseOptions(
        apiKey: 'AIzaSyCEYYDjuayEXRU0-Btwc0JwQdAnIVM3qv4',
        appId: '1:840735247188:android:f0265ebe16258ef38f96c1',
        messagingSenderId: '840735247188',
        projectId: 'prsapp-90270',
        storageBucket: 'prsapp-90270.appspot.com',
      );

  static FirebaseOptions get ios => const FirebaseOptions(
        apiKey: 'AIzaSyDqktEIQqNO1cL04cZOf8zPJ9X9hc0O6mA',
        appId: '1:840735247188:ios:2cdcf76dd77ee6468f96c1',
        messagingSenderId: '840735247188',
        projectId: 'prsapp-90270',
        storageBucket: 'prsapp-90270.appspot.com',
        iosBundleId: 'com.propertyrent',
        iosClientId:
            '840735247188-ji4qp0vckubq7ks2j0tpvllvvu15bgl4.apps.googleusercontent.com',
      );
}
