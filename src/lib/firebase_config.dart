import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseConfig {
  // Web
  static FirebaseOptions get platformOptions {
    if (kIsWeb) {
      return const FirebaseOptions(
          apiKey: 'AIzaSyDp_6-wlzPltYUru2COwC0mSnnukefwJ0U',
          authDomain: 'msd19-study-buddy.firebaseapp.com',
          projectId: 'msd19-study-buddy',
          storageBucket: 'msd19-study-buddy.appspot.com',
          messagingSenderId: '854406702706',
          appId: '1:854406702706:web:a8c8b1ae9105bca91a44eb');
    } else {
      // Android
      return const FirebaseOptions(
          apiKey: 'AIzaSyDp_6-wlzPltYUru2COwC0mSnnukefwJ0U',
          authDomain: 'msd19-study-buddy.firebaseapp.com',
          projectId: 'msd19-study-buddy',
          storageBucket: 'msd19-study-buddy.appspot.com',
          messagingSenderId: '854406702706',
          appId: '1:854406702706:web:a8c8b1ae9105bca91a44eb');
    }
  }
}
