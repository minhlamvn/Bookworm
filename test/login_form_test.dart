import 'package:bookworm_cpsc5250/login_form.dart';
import 'package:bookworm_cpsc5250/timer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:bookworm_cpsc5250/book_lists.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bookworm_cpsc5250/firebase_options.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

main() {
  setupFirebaseAuthMocks();
  setUpAll(() async {
    await Firebase.initializeApp(
        name: 'test',
        options: DefaultFirebaseOptions.currentPlatform
    );
  });

  testWidgets('Shows sign up fields', (widgetTester) async {
    await widgetTester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider<Unread>(create: (_) => Unread()),
        ChangeNotifierProvider<InProgress>(create: (_) => InProgress()),
        ChangeNotifierProvider<Finished>(create: (_) => Finished())
      ],
      child: const MaterialApp(
        home: Scaffold(body: LoginForm()),
      ),
    ));
    await widgetTester.pumpAndSettle();

    final textFieldEmail = find.byKey(const Key("signupEmailInput"));
    expect(textFieldEmail, findsOneWidget);

    final textFieldPassword = find.byKey(const Key("signupPasswordInput"));
    expect(textFieldPassword, findsOneWidget);

    final signupButton = find.byKey(const Key("signupButton"));
    expect(signupButton, findsOneWidget);
  });

  testWidgets('Shows log in fields', (widgetTester) async {
    await widgetTester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider<Unread>(create: (_) => Unread()),
        ChangeNotifierProvider<InProgress>(create: (_) => InProgress()),
        ChangeNotifierProvider<Finished>(create: (_) => Finished())
      ],
      child: const MaterialApp(
        home: Scaffold(body: LoginForm()),
      ),
    ));
    await widgetTester.pumpAndSettle();

    final textFieldEmail = find.byKey(const Key("logInEmailInput"));
    expect(textFieldEmail, findsOneWidget);

    final textFieldPassword = find.byKey(const Key("logInEPasswordInput"));
    expect(textFieldPassword, findsOneWidget);

    final signupButton = find.byKey(const Key("logInButton"));
    expect(signupButton, findsOneWidget);
  });


  testWidgets('Successful Signup', (WidgetTester tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider<Unread>(create: (_) => Unread()),
        ChangeNotifierProvider<InProgress>(create: (_) => InProgress()),
        ChangeNotifierProvider<Finished>(create: (_) => Finished())
      ],
      child: const MaterialApp(
        home: Scaffold(body: LoginForm()),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(Key('signupEmailInput')), 'test@gmail.com');
    await tester.enterText(find.byKey(Key('signupPasswordInput')), 'password12345');
    await tester.tap(find.byKey(Key('signupButton')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginForm), findsOneWidget);
  });
}