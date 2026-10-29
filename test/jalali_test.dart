import 'package:flutter_test/flutter_test.dart';
import 'package:barnamevar/core/jalali.dart';

void main() {
  test('1 Farvardin 1405 is 2026-03-21', () {
    expect(Jalali(1405, 1, 1).toDateTime(), DateTime(2026, 3, 21));
    expect(Jalali.fromDateTime(DateTime(2026, 3, 21)), const Jalali(1405, 1, 1));
  });

  test('6 Aban 1405 is 2026-10-28 and a Wednesday', () {
    final j = Jalali.fromDateTime(DateTime(2026, 10, 28));
    expect(j, const Jalali(1405, 8, 6));
    expect(j.weekdayIndex, 4); // Saturday=0 -> Wednesday=4
  });

  test('leap years', () {
    expect(Jalali.isLeap(1403), isTrue);
    expect(Jalali.isLeap(1404), isFalse);
    expect(Jalali.isLeap(1408), isTrue);
    expect(Jalali.daysInMonth(1403, 12), 30);
    expect(Jalali.daysInMonth(1404, 12), 29);
  });

  test('round trip over 60 years', () {
    var d = Jalali(1380, 1, 1);
    for (var i = 0; i < 22000; i++) {
      final back = Jalali.fromDateTime(d.toDateTime());
      expect(back, d);
      d = d.addDays(1);
    }
  });
}
