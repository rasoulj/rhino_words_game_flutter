// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pishgaman/main.dart';
import 'package:pishgaman/models/match_enum.dart';

void main() {

  test("PPPPN", () {
    List<MatchEnum> m1 = match("12345", "12346");
    List<MatchEnum> t1 = listMatchEnum("PPPPN").toList();

    expect(m1, equals(t1));
  });

  test("PPPNE", () {
    List<MatchEnum> m1 = match("12312", "12341");
    List<MatchEnum> t1 = listMatchEnum("PPPNE").toList();
    expect(m1, equals(t1));
  });

  test("NEENN", () {
    List<MatchEnum> m1 = match("12351", "61114");
    List<MatchEnum> t1 = listMatchEnum("NEENN").toList();

    expect(m1, equals(t1));
  });

  test("EEENE", () {
    List<MatchEnum> m1 = match("12251", "51112");
    List<MatchEnum> t1 = listMatchEnum("EEENE").toList();

    expect(m1, equals(t1));
  });

  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(const MyApp());
  //
  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);
  //
  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();
  //
  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });
}
