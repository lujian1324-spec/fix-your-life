// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sierro_app/main.dart';
import 'package:sierro_app/screens/smart_schedule_screen.dart';
import 'package:sierro_app/state/app_state.dart';
import 'package:sierro_app/theme/app_theme.dart';

void main() {
  testWidgets('Sierro app boots into the device tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SierroApp());

    expect(find.text('Device'), findsOneWidget);
    expect(find.text('Fridge'), findsOneWidget);
  });

  testWidgets('Smart schedule renders its main content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      AppStateScope(
        state: AppState(),
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const SmartScheduleScreen(),
        ),
      ),
    );

    expect(find.text('Smart Schedule'), findsWidgets);
    expect(find.text('Save'), findsOneWidget);
  });
}
