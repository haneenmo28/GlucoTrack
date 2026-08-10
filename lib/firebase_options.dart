import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDKCPXRpS9ej4R6L14F6HzONGnCMD8d3_Q',
    appId: '1:116290014601:android:b34ba793e62966136d6558',
    messagingSenderId: '116290014601',
    projectId: 'gluco-tracker-pro-eg',
    storageBucket: 'gluco-tracker-pro-eg.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAIHhngwCdAIV_OuhR8Xu_OhH_H7bL9oz8',
    appId: '1:116290014601:ios:433217d056fc66516d6558',
    messagingSenderId: '116290014601',
    projectId: 'gluco-tracker-pro-eg',
    storageBucket: 'gluco-tracker-pro-eg.firebasestorage.app',
    iosBundleId: 'gluco.tracker.pro.app',
  );
}
