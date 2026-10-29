/// Pure-Dart Jalali <-> Gregorian conversion (33-year arithmetic algorithm,
/// valid for Jalali years -61 .. 3177).
class Jalali {
  const Jalali(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  static const _breaks = <int>[
    -61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181, 1210, //
    1635, 2060, 2097, 2192, 2262, 2324, 2394, 2456, 3178,
  ];

  static const monthNames = <String>[
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور', //
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
  ];

  /// Saturday-first week names (index 0 = Saturday).
  static const weekdayNames = <String>[
    'شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه',
  ];

  factory Jalali.fromDateTime(DateTime d) =>
      Jalali.fromJdn(_g2d(d.year, d.month, d.day));

  factory Jalali.fromJdn(int jdn) {
    var gy = _d2gYear(jdn);
    var jy = gy - 621;
    final r = _jalCal(jy);
    final jdn1f = _g2d(gy, 3, r.march);
    var k = jdn - jdn1f;
    if (k >= 0) {
      if (k <= 185) {
        return Jalali(jy, 1 + k ~/ 31, k % 31 + 1);
      }
      k -= 186;
    } else {
      jy -= 1;
      k += 179;
      if (r.leap == 1) k += 1;
    }
    return Jalali(jy, 7 + k ~/ 30, k % 30 + 1);
  }

  static bool isLeap(int jy) => _jalCal(jy).leap == 0;

  static int daysInMonth(int jy, int jm) {
    if (jm <= 6) return 31;
    if (jm <= 11) return 30;
    return isLeap(jy) ? 30 : 29;
  }

  int get jdn {
    final r = _jalCal(year);
    return _g2d(r.gy, 3, r.march) + (month - 1) * 31 - (month ~/ 7) * (month - 7) + day - 1;
  }

  /// Gregorian date at local midnight.
  DateTime toDateTime() {
    final g = _d2g(jdn);
    return DateTime(g[0], g[1], g[2]);
  }

  /// 0 = Saturday ... 6 = Friday.
  int get weekdayIndex => (jdn + 2) % 7;

  Jalali addDays(int n) => Jalali.fromJdn(jdn + n);

  @override
  bool operator ==(Object other) =>
      other is Jalali && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => '$year/$month/$day';

  static ({int leap, int gy, int march}) _jalCal(int jy) {
    if (jy < _breaks.first || jy >= _breaks.last) {
      throw ArgumentError('Jalali year out of range: $jy');
    }
    final gy = jy + 621;
    var leapJ = -14;
    var jp = _breaks[0];
    var jump = 0;
    for (var i = 1; i < _breaks.length; i++) {
      final jm = _breaks[i];
      jump = jm - jp;
      if (jy < jm) break;
      leapJ += (jump ~/ 33) * 8 + (jump % 33) ~/ 4;
      jp = jm;
    }
    var n = jy - jp;
    leapJ += (n ~/ 33) * 8 + ((n % 33) + 3) ~/ 4;
    if (jump % 33 == 4 && jump - n == 4) leapJ += 1;
    final leapG = gy ~/ 4 - ((gy ~/ 100 + 1) * 3) ~/ 4 - 150;
    final march = 20 + leapJ - leapG;
    if (jump - n < 6) n = n - jump + ((jump + 4) ~/ 33) * 33;
    var leap = ((n + 1) % 33 - 1) % 4;
    if (leap == -1) leap = 4;
    return (leap: leap, gy: gy, march: march);
  }

  static int _g2d(int gy, int gm, int gd) {
    final a = (gm - 8) ~/ 6;
    var d = ((gy + a + 100100) * 1461) ~/ 4 + (153 * ((gm + 9) % 12) + 2) ~/ 5 + gd - 34840408;
    d = d - (((gy + 100100 + a) ~/ 100) * 3) ~/ 4 + 752;
    return d;
  }

  static List<int> _d2g(int jdn) {
    var j = 4 * jdn + 139361631;
    j = j + (((4 * jdn + 183187720) ~/ 146097) * 3) ~/ 4 * 4 - 3908;
    final i = (j % 1461) ~/ 4 * 5 + 308;
    final gd = (i % 153) ~/ 5 + 1;
    final gm = (i ~/ 153) % 12 + 1;
    final gy = j ~/ 1461 - 100100 + (8 - gm) ~/ 6;
    return [gy, gm, gd];
  }

  static int _d2gYear(int jdn) => _d2g(jdn)[0];
}
