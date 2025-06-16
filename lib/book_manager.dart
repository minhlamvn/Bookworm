import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'book.dart';
import 'book_page.dart';
import 'statistics_page.dart';
import 'add_book_form.dart';
import 'firebase_functions.dart';
import 'book_lists.dart';

class BookManager extends StatefulWidget {
  const BookManager({super.key});

  @override
  State<BookManager> createState() => _BookManagerState();
}

class _BookManagerState extends State<BookManager> {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAll(context);
  }

  void _loadAll(BuildContext context) {
    _loadBooks(context, 'unread');
    _loadBooks(context, 'in_progress');
    _loadBooks(context, 'finished');
  }

  void _loadBooks(BuildContext context, String bookStatus) async {
    List<Book> books = await FirebaseFunctions.loadBooks(bookStatus);
    if (bookStatus == 'unread') {
      context.read<Unread>().setUnreadBooks(books);
    }
    else if (bookStatus == 'in_progress') {
      context.read<InProgress>().setInProgressBooks(books);
    }
    else {
      context.read<Finished>().setFinishedBooks(books);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const SizedBox.expand(child: Center(child: BookPage('Unread'))),
      const SizedBox.expand(child: Center(child: BookPage('In Progress'))),
      const SizedBox.expand(child: Center(child: BookPage('Finished'))),
    ];

    return Scaffold(
      bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              key: Key('unread-nav'),
              selectedIcon: Icon(Icons.menu_book),
              icon: Icon(Icons.menu_book_outlined),
              label: 'Unread',
            ),
            NavigationDestination(
              key: Key('in-progress-nav'),
              selectedIcon: Icon(Icons.align_vertical_bottom),
              icon: Icon(Icons.align_vertical_bottom_outlined),
              label: 'In Progress',
            ),
            NavigationDestination(
              key: Key('finished-nav'),
              selectedIcon: Icon(Icons.done_all),
              icon: Icon(Icons.done_all_outlined),
              label: 'Finished',
            ),
          ]
      ),
      body: pages[currentPageIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: 'statistics_button',
            key: const Key('statistics_button'),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Statistics())
              );
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.bar_chart_rounded,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            heroTag: 'add_book_button',
            key: const Key('add_book_button'),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddBookForm()));
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.add,
              size: 24,
            ),
          ),
        ]
      ),
    );
  }
}