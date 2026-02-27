import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mood_tracker_app/main.dart';

void main() {
  testWidgets('Splash Screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MoodTrackerApp());

    // Verify that the splash screen shows 'Mood Tracker'.
    expect(find.text('Mood Tracker'), findsOneWidget);
    
    // Clear pending timers (Future.delayed in SplashScreen)
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
