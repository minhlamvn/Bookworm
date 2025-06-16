import 'package:bookworm_cpsc5250/book.dart';
import 'package:bookworm_cpsc5250/book_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookworm_cpsc5250/statistics_page.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:bookworm_cpsc5250/book_lists.dart';
import 'package:provider/provider.dart';
import 'package:bookworm_cpsc5250/timer_provider.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:bookworm_cpsc5250/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'login_form_test.dart';

const String noImage = 'https://firebasestorage.googleapis.com/v0/b/bookworm-317ec.appspot.com/o/no-image-icon.png?alt=media&token=bdb8c352-2246-42aa-a727-fe423db7ad18';

void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
}

class MockUnread extends Unread{
  @override
  List<Book> getUnreadBooks() => [
    Book('Unread Book 1', 'Author 1', noImage, Duration(minutes: 10)),
    Book('Unread Book 2', 'Author 2', noImage, Duration(minutes: 20)),
  ];

  @override
  Duration getTimeUnread() => Duration(minutes: 30);

  @override
  String getUnreadNumber() => getUnreadBooks().length.toString();
}

class MockInProgress extends InProgress{
  @override
  List<Book> getInProgressBooks() => [
    Book('InProgress Book 1', 'Author 3', noImage, Duration(minutes: 40)),
    Book('InProgress Book 2', 'Author 4', noImage, Duration(minutes: 50)),
  ];

  @override
  Duration getTimeInProgress() => Duration(minutes: 90);

  @override
  String getInProgressNumber() => getInProgressBooks().length.toString();
}

class MockFinished extends Finished{
  @override
  List<Book> getFinishedBooks() => [
    Book('Finished Book 1', 'Author 5', noImage, Duration(minutes: 60)),
    Book('Finished Book 2', 'Author 6', noImage, Duration(minutes: 70)),
  ];

  @override
  Duration getTimeFinished() => Duration(minutes: 130);

  @override
  String getFinishedNumber() => getFinishedBooks().length.toString();
}

@GenerateMocks([Unread, InProgress, Finished])
void main() {
  setupFirebaseAuthMocks();
  setUpAll(() async {
    await Firebase.initializeApp(
        name: 'test',
        options: DefaultFirebaseOptions.currentPlatform
    );
  });

  testWidgets('Displays correct count for each category', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<Unread>(create: (_) => MockUnread()),
            ChangeNotifierProvider<InProgress>(create: (_) => MockInProgress()),
            ChangeNotifierProvider<Finished>(create: (_) => MockFinished()),
          ],
          child: Statistics(),
        ),
      ),
    );

    // Assuming you have some widgets identified by keys or specific texts that display these counts
    expect(find.byKey(Key('unread_number')), findsOneWidget);
    expect(find.text('2'), findsWidgets); // Assuming the text '2' is unique to the count display
    expect(find.byKey(Key('in_progress_number')), findsOneWidget);
    expect(find.text('2'), findsWidgets); // This might need to be adjusted based on unique identifiers
    expect(find.byKey(Key('finished_number')), findsOneWidget);
    expect(find.text('2'), findsWidgets);
  });

  testWidgets('Displays top 3 longest reads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<Unread>(create: (_) => MockUnread()),
            ChangeNotifierProvider<InProgress>(create: (_) => MockInProgress()),
            ChangeNotifierProvider<Finished>(create: (_) => MockFinished()),
          ],
          child: Statistics(),
        ),
      ),
    );

    // Verify that the titles of the top 3 books are displayed
    expect(find.text('Finished Book 2'), findsOneWidget);
    expect(find.text('Finished Book 1'), findsOneWidget);
    expect(find.text('InProgress Book 2'), findsOneWidget);
  });

  testWidgets('Displays correct total reading time', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<Unread>(create: (_) => MockUnread()),
            ChangeNotifierProvider<InProgress>(create: (_) => MockInProgress()),
            ChangeNotifierProvider<Finished>(create: (_) => MockFinished()),
          ],
          child: Statistics(),
        ),
      ),
    );

    // Adjust the expected text based on how you format the duration in the widget
    expect(find.text('You\'ve read a total of 250 Minutes!'), findsOneWidget);
  });

  testWidgets('Displays correct total books count', (WidgetTester tester) async {

    await tester.pumpWidget(
      MultiProvider(
          providers: [
            ChangeNotifierProvider<Unread>(create: (_) => MockUnread()),
            ChangeNotifierProvider<InProgress>(create: (_) => MockInProgress()),
            ChangeNotifierProvider<Finished>(create: (_) => MockFinished()),
          ],
          child: MaterialApp(
            home: const Statistics(),
          )
      ),
    );

    // Act: Pump the widget
    await tester.pumpAndSettle();

    // Assert: Verify the total books count is displayed correctly
    expect(find.text('6 Book(s) in your Library!'), findsOneWidget);
  });

  testWidgets('Test button triggers nav to statistics page', (tester) async{
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TimerProvider()),
          ChangeNotifierProvider<Unread>(create: (_) => Unread()),
          ChangeNotifierProvider<InProgress>(create: (_) => InProgress()),
          ChangeNotifierProvider<Finished>(create: (_) => Finished()),
        ],
        child: MaterialApp(
          home: const BookManager(),
          navigatorKey: navigatorKey,
        )
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('statistics_button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('statistics_button')));
    await tester.pumpAndSettle();
    expect(find.text('Statistics'), findsOneWidget);
  });

  testWidgets('Statistics displays categories titleBox', (WidgetTester tester) async{
    final mockObserver = MockNavigatorObserver();
    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TimerProvider()),
          ChangeNotifierProvider<Unread>(create: (_) => Unread()),
          ChangeNotifierProvider<InProgress>(create: (_) => InProgress()),
          ChangeNotifierProvider<Finished>(create: (_) => Finished())
        ],
        child: MaterialApp(
          home: const BookManager(),
          navigatorObservers: [mockObserver],
        )
    ));
    await tester.pumpAndSettle();

    final Finder statsFinder = find.byKey(const Key('statistics_button'));

    await tester.tap(statsFinder);
    await tester.pumpAndSettle();

    expect(find.text('Unread'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Finished'), findsOneWidget);
  });

  testWidgets('Statistics titleBox displays mock data', (WidgetTester tester) async{
    final mockObserver = MockNavigatorObserver();
    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TimerProvider()),
          ChangeNotifierProvider<Unread>(create: (_) => Unread()),
          ChangeNotifierProvider<InProgress>(create: (_) => InProgress()),
          ChangeNotifierProvider<Finished>(create: (_) => Finished())
        ],
        child: MaterialApp(
          home: const BookManager(),
          navigatorObservers: [mockObserver],
        )
    ));
    await tester.pumpAndSettle();

    final Finder statsFinder = find.byKey(const Key('statistics_button'));

    await tester.tap(statsFinder);
    await tester.pumpAndSettle();

    final Finder unreadFinder = find.byKey(const Key('unread_number'));
    final Finder inProgressFinder = find.byKey(const Key('in_progress_number'));
    final Finder finishedFinder = find.byKey(const Key('finished_number'));

    final Finder unreadNumFinder = find.descendant(
      of: unreadFinder,
      matching: find.text('0'),
    );
    final Finder inProgressNumFinder = find.descendant(
      of: inProgressFinder,
      matching: find.text('0'),
    );
    final Finder finishedNumFinder = find.descendant(
      of: finishedFinder,
      matching: find.text('0'),
    );

    expect(unreadNumFinder, findsWidgets);
    expect(inProgressNumFinder, findsWidgets);
    expect(finishedNumFinder, findsWidgets);
  });
}