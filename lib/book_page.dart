import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'book.dart';
import 'book_icon.dart';
import 'book_lists.dart';

class BookPage extends StatefulWidget {
  final String status;
  const BookPage(this.status, {super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  List<Book> books = [];

  @override
  Widget build(BuildContext context) {
    if (widget.status == 'Unread') {
      books = context.watch<Unread>().unread;
    }
    else if (widget.status == 'In Progress') {
      books = context.watch<InProgress>().inProgress;
    }
    else {
      books = context.watch<Finished>().finished;
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Center(
            child: Text(widget.status,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 24)
            ),
          ),
        ),
        body: SafeArea(
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.77,
                ),
                itemCount: books.length,
                itemBuilder: (BuildContext context, int index) {
                  return BookIcon(books[index], widget.status);
                }
            )
        )
    );
  }
}
