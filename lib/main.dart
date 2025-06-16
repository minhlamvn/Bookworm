import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'firebase_initializer.dart';
import 'timer_provider.dart';
import 'book_lists.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => Unread()),
        ChangeNotifierProvider(create: (_) => InProgress()),
        ChangeNotifierProvider(create: (_) => Finished()),
      ],
      child: MaterialApp(
        title: 'Bookworm',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        home: const Scaffold(body: FirebaseInitializer()),
      ),
    );
  }
}
