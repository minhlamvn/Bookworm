import 'dart:convert';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:bookworm_cpsc5250/add_book_info_form.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'book.dart';

const String noImage = 'https://firebasestorage.googleapis.com/v0/b/bookworm-317ec.appspot.com/o/no-image-icon.png?alt=media&token=bdb8c352-2246-42aa-a727-fe423db7ad18';

class AddBookForm extends StatefulWidget {
  const AddBookForm({super.key});

  @override
  State<AddBookForm> createState() => _AddBookFormState();
}

class _AddBookFormState extends State<AddBookForm> {
  final TextEditingController _controller = TextEditingController();
  List<Book> _books = [];
  bool _isLoading = false;

  void _searchBooks(String query) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$query'));

    if (response.statusCode == 200) {
      setState(() {
        _books.clear();
        final jsonData = jsonDecode(response.body);
        if (jsonData['items'] != null) {
          _books = List<Book>.from(jsonData['items'].map((item) => Book.fromJson(item)));
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load books');
    }
  }

  Future<void> _scanBarcode() async {
    try {
      ScanResult result = await BarcodeScanner.scan();
      if (result.type == ResultType.Barcode) {
        _searchBooks('isbn:${result.rawContent}');
      }
    } catch (ex) {
      print('Error scanning barcode: $ex');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
       title: TextField(
         controller: _controller,
         decoration: const InputDecoration(
           hintText: 'Search books...',
         ),
         onSubmitted: (value) {
           _searchBooks(value);
         },
       ),
       actions: [
         ElevatedButton(
             onPressed: _scanBarcode,
             child: const Icon(Icons.camera_alt)
         ),
         ElevatedButton(
             key: const Key('add_manually'),
             onPressed: () {
               Navigator.push(context,
                   MaterialPageRoute(builder: (context) =>
                       AddBookInfoForm(Book('','',noImage,Duration.zero))
                   )
               );
             },
             child: const Text('Manually')
         )
       ],
     ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _books.isEmpty
          ? const Center()
          : ListView.builder(
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          return ListTile(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddBookInfoForm(book))
              );
            },
            leading: Image.network(book.image),
            title: Text(book.name),
            subtitle: Text(book.author),
          );
        },
      ),
    );
  }
}