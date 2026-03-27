// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// integration_test optional

import 'package:flutter_application_1/main.dart';

void main() {
// Async main handled by pumpWidget

  testWidgets('PetVerse Pro smoke test', (WidgetTester tester) async {
    // Build our app - main() now async with init, pump widget
    await tester.pumpWidget(MyApp());

    // Verify splash screen shows during loading
    expect(find.text('Pet Care Tracker'), findsOneWidget);

    // Wait for splash delay and pump to home page
    await tester.pump(const Duration(seconds: 3));

    // Verify home page loaded
    expect(find.text('Pet Care Tracker'), findsNothing);
    expect(find.text('Pets'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Tap theme toggle (light mode initially - dark_mode icon)
    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();

    // Verify dark mode toggled (now light_mode icon)
    expect(find.byIcon(Icons.light_mode), findsOneWidget);

    // Add first pet: tap FAB, enter dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Fill dialog fields
    await tester.enterText(find.byType(TextField).first, 'Fluffy');
    await tester.enterText(find.byType(TextField).at(1), 'Cat');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify pet added
    expect(find.text('Fluffy'), findsOneWidget);
    expect(find.text('Cat'), findsOneWidget);

    // Test search
    await tester.enterText(find.byType(TextField).first, 'Fluffy');
    await tester.pump();
    expect(find.text('Fluffy'), findsOneWidget);

    // Toggle back and settle
    await tester.tap(find.byIcon(Icons.light_mode));
    await tester.pumpAndSettle();
  });
}
