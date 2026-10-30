import 'package:flutter_test/flutter_test.dart';
import 'package:barnamevar/core/jalali.dart';
void main() {
  group('Jalali calendar', () {
    test('converts Nowruz 2024 and round-trips', () {
      final date=Jalali.fromGregorian(DateTime(2024,3,20));
      expect(date,const Jalali(1403,1,1)); expect(date.toGregorian(),DateTime(2024,3,20));
    });
    test('month lengths and arithmetic respect leap Esfand', () {
      expect(Jalali.daysInMonth(1399,12),30); expect(Jalali.daysInMonth(1400,12),29);
      expect(Jalali(1402,12,29).addDays(1),const Jalali(1403,1,1));
    });
    test('formats Persian digits',()=>expect(Jalali(1403,1,1).toString(),'۱۴۰۳/۰۱/۰۱'));
  });
}
