import 'package:bookworm_cpsc5250/book_info.dart';
import 'package:flutter/material.dart';
import 'book.dart';

class BookIcon extends StatelessWidget {
  final Book book;
  final String status;
  const BookIcon(this.book, this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => BookInfo(book,status)));
        },
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        ),
        child: Image.network(
          book.image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
