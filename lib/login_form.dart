import 'package:bookworm_cpsc5250/book_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _userControllerSignUp = TextEditingController();
  final TextEditingController _passwordControllerSignUp = TextEditingController();
  final TextEditingController _userControllerLogIn = TextEditingController();
  final TextEditingController _passwordControllerLogIn = TextEditingController();

  void _onSignUp() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _userControllerSignUp.text,
          password: _passwordControllerSignUp.text
      );
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference ref = firestore.collection('users').doc(_userControllerSignUp.text);
      Map<String, Map<String, dynamic>> newData = {
        'unread': {},
        'in_progress': {},
        'finished': {}
      };
      await ref.set(newData, SetOptions(merge: true));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BookManager()));
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('Email already in use');
      }
      else {
        print(e.code);
      }
    }
  }

  void _onLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _userControllerLogIn.text,
          password: _passwordControllerLogIn.text
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BookManager()));
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('User not found');
      }
      else if (e.code == 'wrong-password') {
        print('Wrong password');
      }
      else {
        print(e.code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Center(
                child: Text(
                  'Welcome to Bookworm!',
                  style: TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                key: const Key('signupEmailInput'),
                controller: _userControllerSignUp,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'user@email.com'),
              ),
              TextField(
                key: const Key('signupPasswordInput'),
                controller: _passwordControllerSignUp,
                decoration: const InputDecoration(hintText: 'password'),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                key: const Key('signupButton'),
                onPressed: _onSignUp,
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 100),
              const Center(
                child: Text(
                  'Or Welcome Back!',
                  style: TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                key: const Key('logInEmailInput'),
                controller: _userControllerLogIn,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'user@email.com'),
              ),
              TextField(
                key: const Key('logInEPasswordInput'),
                controller: _passwordControllerLogIn,
                decoration: const InputDecoration(hintText: 'password'),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                key: const Key('logInButton'),
                onPressed: _onLogin,
                child: const Text('Log In'),
              )
            ]
          )
        )
      )
    );
  }
}