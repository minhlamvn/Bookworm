import 'dart:io';

import 'package:flutter/material.dart';
import 'book.dart';
import 'book_manager.dart';
import 'package:provider/provider.dart';
import 'book_lists.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';

class AddBookInfoForm extends StatefulWidget {
  final Book _book;
  const AddBookInfoForm(this._book, {super.key});

  @override
  State<AddBookInfoForm> createState() => _AddBookInfoFormState();
}

class _AddBookInfoFormState extends State<AddBookInfoForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _author = TextEditingController();
  String _status = 'Unread';
  Duration _readingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Set initial values based on the book passed to the widget
    _name.text = widget._book.name;
    _author.text = widget._book.author;
    _status = 'Unread';
    _readingTime = Duration.zero;
  }

  void onSavedPress(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      String img = widget._book.image;
      if (_status == 'Unread') {
        context.read<Unread>().addUnreadBook(_name.text, _author.text, img, _readingTime);
      }
      else if (_status == 'In Progress') {
        context.read<InProgress>().addInProgressBook(_name.text, _author.text, img, _readingTime);
      }
      else {
        context.read<Finished>().addFinishedBook(_name.text, _author.text, img, _readingTime);
      }
      _formKey.currentState!.reset();
      Navigator.pop(context, MaterialPageRoute(builder: (context) => const BookManager()));
    }
  }

  Future<String?> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = basename(file.path);
      final destination = 'images/$fileName';
      final storageRef = firebase_storage.FirebaseStorage.instance.ref().child(destination);
      await storageRef.putFile(file);
      return await storageRef.getDownloadURL();
    }
    return null;
  }

  Future<String?> _takePhoto() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = basename(file.path);
      final destination = 'images/$fileName';
      final storageRef = firebase_storage.FirebaseStorage.instance.ref().child(destination);
      await storageRef.putFile(file);
      return await storageRef.getDownloadURL();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text('Adding Book Info',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 24)
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 5),
                Image.network(
                  widget._book.image,
                  width: 120,
                  height: 120,
                ),
                ElevatedButton(
                  key: const Key('pick_image'),
                  onPressed: () async {
                    final imageUrl = await _pickImage();
                    if (imageUrl != null) {
                      setState(() {
                        widget._book.image = imageUrl;
                      });
                    }
                  },
                  child: const Text('Pick Image'),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  key: const Key('take_photo'),
                  onPressed: () async {
                    final imageUrl = await _takePhoto();
                    if (imageUrl != null) {
                      setState(() {
                        widget._book.image = imageUrl;
                      });
                    }
                  },
                  child: const Text('Take a Photo'),
                ),
                TextFormField(
                  key: const Key('name'),
                  decoration: const InputDecoration(
                      labelText: 'Name'
                  ),
                  controller: _name,
                ),
                TextFormField(
                  key: const Key('author'),
                  decoration: const InputDecoration(
                      labelText: 'Author'
                  ),
                  controller: _author,
                ),
                const SizedBox(height: 5),
                Row(
                    children: [
                      const Text('Status'),
                      const SizedBox(width: 80),
                      DropdownButton(
                          key: const Key('status'),
                          value: _status,
                          items: const [
                            DropdownMenuItem<String>(value: 'Unread', child: Text('Unread')),
                            DropdownMenuItem<String>(value: 'In Progress', child: Text('In Progress')),
                            DropdownMenuItem<String>(value: 'Finished', child: Text('Finished')),
                          ],
                          onChanged: (String? status) {
                            setState(() {
                              _status = status!;
                            });
                          }
                      ),
                    ]
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                    key: const Key('save_book'),
                    onPressed: () {onSavedPress(context);},
                    child: const Text('Save'))
              ],
            ),
          )
      )
    );
  }
}