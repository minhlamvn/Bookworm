import 'package:flutter/foundation.dart';
import 'firebase_functions.dart';
import 'book.dart';

class Unread with ChangeNotifier {
  List<Book> unread = [];
  Unread();

  String getUnreadNumber() {
    String result = unread.length.toString();
    return result;
  }

  List<Book> getUnreadBooks() {return unread;}

  void setUnreadBooks(List<Book> books) {
    unread = books;
    FirebaseFunctions.saveBooks(unread, 'unread');
    notifyListeners();
  }

  void addUnreadBook(String newName, String newAuthor, String newImg, Duration readingTime) {
    unread.add(Book(newName, newAuthor, newImg, readingTime));
    FirebaseFunctions.saveBooks(unread, 'unread');
    notifyListeners();
  }

  void deleteUnreadBook(int index) {
    FirebaseFunctions.deleteBook(index, unread, 'unread');
    FirebaseFunctions.saveBooks(unread, 'unread');
    notifyListeners();
  }

  Duration getTimeUnread() {
    Duration time = const Duration(seconds: 0);
    for (Book book in unread) {
      time += book.readingTime;
    }
    return time;
  }
}

class InProgress with ChangeNotifier {
  List<Book> inProgress = [];
  InProgress();

  String getInProgressNumber() {
    String result = inProgress.length.toString();
    return result;
  }

  List<Book> getInProgressBooks() {return inProgress;}

  void setInProgressBooks(List<Book> books) {
    inProgress = books;
    FirebaseFunctions.saveBooks(inProgress, 'in_progress');
    notifyListeners();
  }

  void addInProgressBook(String newName, String newAuthor, String newImg, Duration readingTime) {
    inProgress.add(Book(newName, newAuthor, newImg, readingTime));
    FirebaseFunctions.saveBooks(inProgress, 'in_progress');
    notifyListeners();
  }

  void deleteInProgressBook(int index) {
    FirebaseFunctions.deleteBook(index, inProgress, 'in_progress');
    FirebaseFunctions.saveBooks(inProgress, 'in_progress');
    notifyListeners();
  }

  Duration getTimeInProgress() {
    Duration time = const Duration(seconds: 0);
    for (Book book in inProgress) {
      time += book.readingTime;
    }
    return time;
  }
}

class Finished with ChangeNotifier {
  List<Book> finished = [];
  Finished();

  String getFinishedNumber() {
    String result = finished.length.toString();
    return result;
  }

  List<Book> getFinishedBooks() {return finished;}

  void setFinishedBooks(List<Book> books) {
    finished = books;
    FirebaseFunctions.saveBooks(finished, 'finished');
    notifyListeners();
  }

  void addFinishedBook(String newName, String newAuthor, String newImg,Duration readingTime) {
    finished.add(Book(newName, newAuthor, newImg, readingTime));
    FirebaseFunctions.saveBooks(finished, 'finished');
    notifyListeners();
  }

  void deleteFinishedBook(int index) {
    FirebaseFunctions.deleteBook(index, finished, 'finished');
    FirebaseFunctions.saveBooks(finished, 'finished');
    notifyListeners();
  }

  Duration getTimeFinished() {
    Duration time = const Duration(seconds: 0);
    for (Book book in finished) {
      time += book.readingTime;
    }
    return time;
  }
}