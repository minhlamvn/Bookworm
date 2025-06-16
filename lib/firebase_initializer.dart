import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'logged_in_detector.dart';

class FirebaseInitializer extends StatelessWidget {
  const FirebaseInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const LoggedInDetector();
          }
          else if (snapshot.hasError) {
            return const SafeArea(child: Text('Can\'t connect to Firebase'));
          }
          return const CircularProgressIndicator();
        }
    );
  }
}