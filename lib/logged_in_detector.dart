import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_form.dart';
import 'book_manager.dart';

class LoggedInDetector extends StatelessWidget {
  const LoggedInDetector({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const LoginForm();
          }
          else if (snapshot.hasData) {
            return const BookManager();
          }
          return const CircularProgressIndicator();
        }
    );
  }
}