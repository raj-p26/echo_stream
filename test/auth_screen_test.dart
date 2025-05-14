import 'package:echo_stream/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth Screen tests', () {
    testWidgets('Initial Auth screen state', (tester) async {
      await tester.pumpWidget(const App());

      final loginButtonFinder = find.text('Login');

      expect(loginButtonFinder, findsOneWidget);
    });

    testWidgets('Updating state to be signup page', (tester) async {
      await tester.pumpWidget(const App());
      final toggleButtonFinder = find.text('Create new account');

      await tester.tap(toggleButtonFinder);
      await tester.pump();

      expect(toggleButtonFinder, findsNothing);
    });

    testWidgets('Entering empty text and validating inputs', (tester) async {
      await tester.pumpWidget(const App());

      final loginButtonFinder = find.text('Login');
      expect(loginButtonFinder, findsOneWidget);

      final emailFieldFinder = find.byKey(Key('emailField'));
      expect(emailFieldFinder, findsOne);

      await tester.enterText(emailFieldFinder, '');
      await tester.pump();

      await tester.tap(loginButtonFinder);
      await tester.pump();

      expect(find.text('Please enter valid email address'), findsOneWidget);
    });
  });
}
