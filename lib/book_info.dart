import 'package:bookworm_cpsc5250/book.dart';
import 'package:bookworm_cpsc5250/timer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'book_lists.dart';
import 'firebase_functions.dart';

class BookInfo extends StatefulWidget {
  final Book book;
  final String status;
  const BookInfo(this.book, this.status, {super.key});

  @override
  State<BookInfo> createState() => _BookInfoState();
}

class _BookInfoState extends State<BookInfo> {
  String currentStatus = '';

  @override
  Widget build(BuildContext context) {
    if (currentStatus == '') {
      currentStatus = widget.status;
    }
    final timerProvider = Provider.of<TimerProvider>(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text('Book Information',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24
              )
          ),
          actions: [
            PopupMenuButton<String>(
              key: const Key('change_status'),
              initialValue:  currentStatus,
              onSelected: (String status) {
                if (currentStatus == 'Unread') {
                  int index = Provider.of<Unread>(context, listen: false).unread.indexWhere((book) =>
                  book.name == widget.book.name && book.author == widget.book.author && book.image == widget.book.image && book.readingTime == widget.book.readingTime
                  );
                  Provider.of<Unread>(context, listen: false).deleteUnreadBook(index);
                }
                else if (currentStatus == 'In Progress') {
                  int index = Provider.of<InProgress>(context, listen: false).inProgress.indexWhere((book) =>
                  book.name == widget.book.name && book.author == widget.book.author && book.image == widget.book.image && book.readingTime == widget.book.readingTime
                  );
                  Provider.of<InProgress>(context, listen: false).deleteInProgressBook(index);
                }
                else {
                  int index = Provider.of<Finished>(context, listen: false).finished.indexWhere((book) =>
                  book.name == widget.book.name && book.author == widget.book.author && book.image == widget.book.image && book.readingTime == widget.book.readingTime
                  );
                  Provider.of<Finished>(context, listen: false).deleteFinishedBook(index);
                }
                if (status == 'Unread') {
                  Provider.of<Unread>(context, listen: false).addUnreadBook(widget.book.name, widget.book.author, widget.book.image, widget.book.readingTime);
                }
                else if (status == 'In Progress') {
                  Provider.of<InProgress>(context, listen: false).addInProgressBook(widget.book.name, widget.book.author, widget.book.image , widget.book.readingTime);
                }
                else {
                  Provider.of<Finished>(context, listen: false).addFinishedBook(widget.book.name, widget.book.author, widget.book.image , widget.book.readingTime);
                }
                setState(() {
                  currentStatus = status;
                });
              },
              icon: Icon(
                Icons.change_circle,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 30,
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Unread',
                  child: Text('Unread'),
                ),
                const PopupMenuItem<String>(
                  value: 'In Progress',
                  child: Text('In Progress'),
                ),
                const PopupMenuItem<String>(
                  value: 'Finished',
                  child: Text('Finished'),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: SizedBox(
                            width: 340,
                            height: 460,
                            child: Image.network(
                              widget.book.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        widget.book.name,
                        style: const TextStyle(fontSize: 26),
                      ),
                      Text(
                        widget.book.author,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 30),
                      Text(
                          'Reading Time: ${widget.book.readingTime}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () async {
                              if (currentStatus == 'Unread') {
                                int index = Provider.of<Unread>(context, listen: false).unread.indexWhere((book) =>
                                book.name == widget.book.name && book.author == widget.book.author && book.image == widget.book.image);
                                Provider.of<Unread>(context, listen: false).deleteUnreadBook(index);
                              }
                              else if (currentStatus == 'In Progress') {
                                int index = Provider.of<InProgress>(context, listen: false).inProgress.indexWhere((book) =>
                                book.name == widget.book.name && book.author == widget.book.author && book.image == widget.book.image);
                                Provider.of<InProgress>(context, listen: false).deleteInProgressBook(index);
                              }
                              else {
                                int index = Provider.of<Finished>(context, listen: false).finished.indexWhere((book) =>
                                book.name == widget.book.name && book.author == widget.book.author && book.image == widget.book.image);
                                Provider.of<Finished>(context, listen: false).deleteFinishedBook(index);
                              }
                              Provider.of<InProgress>(context, listen: false).addInProgressBook(widget.book.name, widget.book.author, widget.book.image, widget.book.readingTime);
                              setState(() {
                                currentStatus = 'In Progress';
                              });
                              timerProvider.startTimer(widget.book, Provider.of<InProgress>(context, listen: false).getInProgressBooks(), currentStatus);
                              List<Book> books = await FirebaseFunctions.loadBooks('in_progress');
                              Provider.of<InProgress>(context, listen: false).setInProgressBooks(books);
                              },
                            icon: const Icon(Icons.play_arrow),
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: const Icon(Icons.stop),
                            onPressed: () async {
                              timerProvider.stopTimer(widget.book);
                              List<Book> books = await FirebaseFunctions.loadBooks('in_progress');
                              Provider.of<InProgress>(context, listen: false).setInProgressBooks(books);
                              },
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              List<Book> books;
                              if (currentStatus == 'Unread') {
                                books = Provider.of<Unread>(context, listen: false).getUnreadBooks();
                              }
                              else if (currentStatus == "In Progress") {
                                books = Provider.of<InProgress>(context, listen: false).getInProgressBooks();
                              }
                              else {
                                books = Provider.of<Finished>(context, listen: false).getFinishedBooks();
                              }
                              timerProvider.resetTimer(widget.book, books, currentStatus);
                              },
                          ),
                        ],
                      )
                    ]
                )
            )
        )
    );
  }
}