import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barnamevar/features/calendar_screen.dart';
void main() {
  testWidgets('calendar renders weekday headings and empty state',(tester) async {
    await tester.pumpWidget(MaterialApp(home:Scaffold(body:CalendarScreen(tasks:const [],onReminder:(_){}) )));
    expect(find.text('ش'),findsOneWidget); expect(find.text('ی'),findsOneWidget);
    expect(find.text('موردی برای این روز ثبت نشده'),findsOneWidget);
  });
}
