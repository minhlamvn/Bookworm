import 'package:bookworm_cpsc5250/book_icon.dart';
import 'package:bookworm_cpsc5250/book_manager.dart';
import 'package:bookworm_cpsc5250/timer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
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

@GenerateMocks([Unread, InProgress, Finished])
main() {
  setupFirebaseAuthMocks();
  setUpAll(() async {
    HttpOverrides.global = null;
    await Firebase.initializeApp(
        name: 'test',
        options: DefaultFirebaseOptions.currentPlatform
    );
  });

  testWidgets('Displays a book in a new page in the status is manually changed', (widgetTester) async {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
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
          home: const BookManager(),
          navigatorKey: navigatorKey,
        )
    ));
    await widgetTester.pumpAndSettle();
    expect(find.text('Unread'), findsAtLeastNWidgets(2));

    Finder addBookFinder = find.byKey(const Key('add_book_button'));
    await widgetTester.tap(addBookFinder);
    await widgetTester.pumpAndSettle();
    expect(find.text('Manually'), findsOneWidget);

    Finder addBookNewFinder = find.byKey(const Key('add_manually'));
    await widgetTester.tap(addBookNewFinder);
    await widgetTester.pumpAndSettle();
    expect(find.text('Adding Book Info'), findsOneWidget);

    Finder nameFinder = find.byKey(const Key('name'));
    await widgetTester.tap(nameFinder);
    await widgetTester.pumpAndSettle();
    await widgetTester.enterText(nameFinder, 'Between the World and Me');
    expect(find.text('Between the World and Me'), findsOneWidget);

    Finder authorFinder = find.byKey(const Key('author'));
    await widgetTester.tap(authorFinder);
    await widgetTester.pumpAndSettle();
    await widgetTester.enterText(nameFinder, 'Ta-Nehisi Coates');
    expect(find.text('Ta-Nehisi Coates'), findsOneWidget);

    Finder saveFinder = find.byKey(const Key('save_book'));
    await widgetTester.tap(saveFinder);
    await widgetTester.pumpAndSettle();
    expect(find.text('Manually'), findsOneWidget);

    navigatorKey.currentState!.pop();
    await widgetTester.pumpAndSettle();
    expect(find.text('Unread'), findsAtLeastNWidgets(2));

    Finder newBookFinder = find.byType(BookIcon);
    expect(newBookFinder, findsOneWidget);

    await widgetTester.tap(newBookFinder);
    await widgetTester.pumpAndSettle();
    expect(find.text('Book Information'), findsOneWidget);

    Finder changeStatusFinder = find.byKey(const Key('change_status'));
    await widgetTester.tap(changeStatusFinder);
    await widgetTester.pumpAndSettle();
    expect(find.text('Unread'), findsOneWidget);

    Finder popUpItemFinder = find.byWidgetPredicate((Widget widget) {
      if (widget is PopupMenuItem<String>) {
        return (widget.child as Text).data == 'Finished';
      }
      return false;
    });
    await widgetTester.tap(popUpItemFinder, warnIfMissed: false);
    await widgetTester.pumpAndSettle();

    navigatorKey.currentState!.pop();
    await widgetTester.pumpAndSettle();
    expect(find.text('Unread'), findsAtLeastNWidgets(2));

    newBookFinder = find.byType(BookIcon);
    expect(newBookFinder, findsNothing);

    await widgetTester.tap(find.byKey(const Key('finished-nav')));
    await widgetTester.pumpAndSettle();
    expect(find.text('Finished'), findsAtLeastNWidgets(2));

    newBookFinder = find.byType(BookIcon);
    expect(newBookFinder, findsOneWidget);

    await widgetTester.tap(newBookFinder);
    await widgetTester.pumpAndSettle();
    expect(find.text('Book Information'), findsOneWidget);

    changeStatusFinder = find.byKey(const Key('change_status'));
    await widgetTester.tap(changeStatusFinder);
    await widgetTester.pumpAndSettle();
    expect(find.text('Finished'), findsOneWidget);

    popUpItemFinder = find.byWidgetPredicate((Widget widget) {
      if (widget is PopupMenuItem<String>) {
        return (widget.child as Text).data == 'In Progress';
      }
      return false;
    });
    await widgetTester.tap(popUpItemFinder, warnIfMissed: false);
    await widgetTester.pumpAndSettle();

    navigatorKey.currentState!.pop();
    await widgetTester.pumpAndSettle();
    expect(find.text('Finished'), findsAtLeastNWidgets(2));

    newBookFinder = find.byType(BookIcon);
    expect(newBookFinder, findsNothing);

    await widgetTester.tap(find.byKey(const Key('in-progress-nav')));
    await widgetTester.pumpAndSettle();
    expect(find.text('In Progress'), findsAtLeastNWidgets(2));

    newBookFinder = find.byType(BookIcon);
    expect(newBookFinder, findsOneWidget);
  });
}