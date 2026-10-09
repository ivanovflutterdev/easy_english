// Generated from the Firebase project configuration files supplied for
// easyenglish-f1b2a. Keep this file under version control; platform-specific
// secret files (google-services.json and GoogleService-Info.plist) stay local.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase Web is not configured for this app yet.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Firebase is not configured for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDOKM0Esaow1sASuvHt4jWRggtQTKuTpAk',
    appId: '1:156060136060:android:effce3925ce2c83dad0ff9',
    messagingSenderId: '156060136060',
    projectId: 'easyenglish-f1b2a',
    storageBucket: 'easyenglish-f1b2a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDAloJYUtNvzsOPcTn--oDwe-tpPXlfk3s',
    appId: '1:156060136060:ios:af8328c03adecf74ad0ff9',
    messagingSenderId: '156060136060',
    projectId: 'easyenglish-f1b2a',
    storageBucket: 'easyenglish-f1b2a.firebasestorage.app',
    iosBundleId: 'ivanovoleksandr',
  );
}
