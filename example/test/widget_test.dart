import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:validate_kit_example/main.dart';

void main() {
  /// Uses a tall surface so the whole lazily-built form is laid out and
  /// reachable without scrolling in tests.
  void useTallSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('renders the validate_kit demo form', (
    WidgetTester tester,
  ) async {
    useTallSurface(tester);
    await tester.pumpWidget(const ValidateKitExampleApp());

    expect(find.text('validate_kit'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('shows validation errors for an empty submission', (
    WidgetTester tester,
  ) async {
    useTallSurface(tester);
    await tester.pumpWidget(const ValidateKitExampleApp());

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your full name'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Please confirm your password'), findsOneWidget);
  });

  testWidgets('accepts a fully valid form', (WidgetTester tester) async {
    useTallSurface(tester);
    await tester.pumpWidget(const ValidateKitExampleApp());

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name'),
      'Ada Lovelace',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'ada@example.com',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '36');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'Str0ng#Pass',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm password'),
      'Str0ng#Pass',
    );

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('United States').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Registration form is valid.'), findsOneWidget);
  });
}
