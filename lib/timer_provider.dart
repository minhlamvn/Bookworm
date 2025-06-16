import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'book.dart';

class TimerProvider with ChangeNotifier {
  final Map<String, Timer> _timers = {};

  void startTimer(Book book, List<Book> books, String status) {
    _timers[book.name]?.cancel(); // Cancel any existing timer for this book
    _timers[book.name] = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newDuration = book.readingTime + const Duration(seconds: 1);
      book.readingTime = newDuration;
      updateReadingTimeForBook(book, books, status);
      notifyListeners();
    });
  }

  void stopTimer(Book book) {
    _timers[book.name]?.cancel();
    notifyListeners();
  }

  void resetTimer(Book book, List<Book> books, String status) {
    _timers[book.name]?.cancel();
    book.readingTime = Duration.zero;
    updateReadingTimeForBook(book, books, status);
    notifyListeners();
  }

  void updateReadingTimeForBook(Book book, List<Book> books, String status) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      List<Map<String, dynamic>> newBooks = books
          .map((oldBook) => {'name': oldBook.name,
        'author': oldBook.author,
        'image': oldBook.image,
        'readingTime' : oldBook.readingTime.inSeconds
      }).toList();
      String fireBaseStatus;
      if (status == 'Unread') {fireBaseStatus = 'unread';}
      else if (status == 'In Progress') {fireBaseStatus = 'in_progress';}
      else {fireBaseStatus = 'finished';}
      for (var oldBook in newBooks) {
        if (oldBook['name'] == book.name && oldBook['author'] == book.author && oldBook['image'] == book.image){
          oldBook['readingTime'] = book.readingTime.inSeconds;
        }
      }
      await FirebaseFirestore.instance.collection('users').doc(user.email).set(
          {fireBaseStatus: newBooks}, SetOptions(merge: true));
    }
  }
}