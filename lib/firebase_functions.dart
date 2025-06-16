import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book.dart';

class FirebaseFunctions {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<Book>> loadBooks(String bookStatus) async {
    User? user = _auth.currentUser;
    if (user != null) {
      String email = user.email!;
      DocumentSnapshot<Map<String,dynamic>> snapshot =
      await _firestore.collection('users').doc(email).get();
      if (snapshot.exists) {
        List<Book> books = [];
        Map<String, dynamic>? userData = snapshot.data();
        if (userData != null) {
          var data = userData[bookStatus];
          if (data != null) {
            if (data is Map<String, dynamic>) {
              Map<String, dynamic> bookData = data;
              if (bookData['name'] != null &&
                  bookData['author'] != null &&
                  bookData['image'] != null &&
                  bookData['readingTime'] != null) {
                books.add(
                    Book(bookData['name'],
                        bookData['author'],
                        bookData['image'] ,
                        Duration(seconds: bookData['readingTime'])
                    )
                );
              }
            }
            else if (data is List<dynamic>) {
              for (var item in data) {
                Map<String, dynamic> bookData = item;
                if (bookData['name'] != null &&
                    bookData['author'] != null &&
                    bookData['image'] != null &&
                    bookData['readingTime'] != null)  {
                  books.add(
                      Book(bookData['name'],
                          bookData['author'],
                          bookData['image'] ,
                          Duration(seconds: bookData['readingTime'])
                      )
                  );
                }
              }
            }
          }
        }
        return books;
      }
    }
    return [];
  }

  static void saveBooks(List<Book> newBooks, String bookStatus) async {
    User? user = _auth.currentUser;
    if (user != null) {
      String email = user.email!;
      List<Map<String, dynamic>> books = newBooks
          .map((book) => {'name': book.name,
        'author': book.author,
        'image': book.image,
        'readingTime' : book.readingTime.inSeconds
          }).toList();
      await _firestore.collection('users').doc(email).set(
          {bookStatus: books}, SetOptions(merge: true));
    }
  }

  static void deleteBook(int index, List<Book> books, String bookStatus) {
    books.removeAt(index);
    saveBooks(books, bookStatus);
  }
}