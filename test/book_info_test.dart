import 'package:bookworm_cpsc5250/book.dart';
import 'package:bookworm_cpsc5250/book_info.dart';
import 'package:bookworm_cpsc5250/timer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:bookworm_cpsc5250/book_lists.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bookworm_cpsc5250/firebase_options.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

const String noImage = 'https://firebasestorage.googleapis.com/v0/b/bookworm-317ec.appspot.com/o/no-image-icon.png?alt=media&token=bdb8c352-2246-42aa-a727-fe423db7ad18';

void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
}
class MockTimerProvider extends Mock implements TimerProvider {}
@GenerateMocks([Unread, InProgress, Finished, TimerProvider])

main() {
  late MockTimerProvider mockTimerProvider;
  late Book testBook;
  late List<Book> testBooks;

  setUp(() {
    mockTimerProvider = MockTimerProvider();
    testBook = Book('Test Book', 'Test Author', noImage, Duration(minutes: 30));
    testBooks = [testBook];
  });

  setupFirebaseAuthMocks();
  setUpAll(() async {
    HttpOverrides.global = null;
    await Firebase.initializeApp(
        name: 'test',
        options: DefaultFirebaseOptions.currentPlatform
    );
  });

  testWidgets('Book info page contains all display widgets', (widgetTester) async {
    final book = Book("Between the World and Me", "Ta-Nehisi Coates", noImage, const Duration(minutes: 30));

    await widgetTester.runAsync(() async {
      await http.get(Uri.parse(noImage));
    });

    await widgetTester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TimerProvider()),
          ChangeNotifierProvider<Unread>(create: (_) => Unread()),
          ChangeNotifierProvider<InProgress>(create: (_) => InProgress()),
          ChangeNotifierProvider<Finished>(create: (_) => Finished())
        ],
        child: MaterialApp(
          home: Scaffold(
            body: BookInfo(book, 'Unread'),
          ),
        )
    ));
    await widgetTester.pumpAndSettle();

    expect(find.text('Book Information'), findsOneWidget);
    expect(find.text('Between the World and Me'), findsOneWidget);
    expect(find.text('Ta-Nehisi Coates'), findsOneWidget);
    expect(find.text('Reading Time: 0:30:00.000000'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });


  testWidgets('play button triggers start to count reading time', (tester) async {
    final book = Book("Title", "Author", noImage, Duration.zero);

    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<TimerProvider>(create: (_) => mockTimerProvider),
          ChangeNotifierProvider<Unread>(create: (_) => Unread()),
          ChangeNotifierProvider<InProgress>(create: (_) => InProgress()),
          ChangeNotifierProvider<Finished>(create: (_) => Finished())
        ],
        child: MaterialApp(
          home: BookInfo(testBook, 'Unread'),
        )
    ));

    await tester.pumpAndSettle();
    final Offset targetOffset = tester.getCenter(find.byIcon(Icons.play_arrow));
    await tester.tapAt(targetOffset);
    await tester.pumpAndSettle();
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Reading Time: 0:00:00.000000'), findsNothing);
  });



  testWidgets('Reset button resets reading time to zero', (WidgetTester tester) async {
    final book = Book("Title", "Author", noImage, Duration.zero);

    List<Book> books = [book];
    // Wrap your BookInfo with a ChangeNotifierProvider for TimerProvider
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<TimerProvider>(create: (_) => mockTimerProvider),
        ChangeNotifierProvider<Unread>(create: (_) => Unread()),
        ChangeNotifierProvider<InProgress>(create: (_) => InProgress()),
        ChangeNotifierProvider<Finished>(create: (_) => Finished())
      ],
      child: MaterialApp(
        home: Scaffold(
          body: BookInfo(book, 'In Progress'), // Your widget that has the reset button
        ),
      ),
    ),
    );

    final Offset targetOffset = tester.getCenter(find.byIcon(Icons.refresh));
    await tester.tapAt(targetOffset);
    await tester.pumpAndSettle();

    expect(book.readingTime, Duration.zero);

  });

  testWidgets('change from unread to in progress status after starting timer', (tester) async {
    final book = Book("Between the World and Me", "Ta-Nehisi Coates", noImage, const Duration(minutes: 30));

    final TimerProvider mockTimerProvider = MockTimerProvider();

    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<TimerProvider>(create: (_) => mockTimerProvider),
          ChangeNotifierProvider<Unread>(create: (_) => Unread()),
          ChangeNotifierProvider<InProgress>(create: (_) => InProgress()),
          ChangeNotifierProvider<Finished>(create: (_) => Finished())
        ],
        child: MaterialApp(
          home: BookInfo(book, 'Unread'),
        )
    ));

    final Offset targetOffset = tester.getCenter(find.byIcon(Icons.play_arrow));
    await tester.tapAt(targetOffset);
    await tester.pumpAndSettle();

    expect(find.text('Unread'), findsNothing);

  });

}