/// Rule-based occasions. Solar rules are exact for every year.
/// Lunar rules (isLunar) need a per-year date table; other years are approximate.
enum OccasionKind { personal, professional, family, spiritual, national }

class OccasionRule {
  const OccasionRule({
    required this.id,
    required this.title,
    required this.month,
    required this.day,
    required this.kind,
    required this.leadDays,
    required this.suggestion,
    this.isLunar = false,
    this.isHoliday = false,
    this.enabled = true,
  });

  final String id;
  final String title;
  final int month;
  final int day;
  final OccasionKind kind;
  final List<int> leadDays;
  final String suggestion;
  final bool isLunar;
  final bool isHoliday;
  final bool enabled;
}

/// Default reminder time is 09:00 (user adjustable).
const defaultOccasionRules = <OccasionRule>[
  OccasionRule(
    id: 'birthday_wife', title: 'تولد همسر', month: 9, day: 18,
    kind: OccasionKind.personal, leadDays: [10, 0],
    suggestion: 'برای تولد همسرت کادو و برنامه‌ی مناسب تدارک ببین.',
  ),
  OccasionRule(
    id: 'birthday_daughter', title: 'تولد دخترم', month: 10, day: 23,
    kind: OccasionKind.personal, leadDays: [10, 0],
    suggestion: 'برای تولد دخترت کادو و برنامه‌ی مناسب تدارک ببین.',
  ),
  OccasionRule(
    id: 'fathers_day', title: 'روز پدر', month: 10, day: 2,
    kind: OccasionKind.family, leadDays: [10],
    suggestion: 'برای پدر کادو بخر یا به دیدنش برو.',
    isLunar: true,
  ),
  OccasionRule(
    id: 'mothers_day', title: 'روز مادر و زن', month: 9, day: 9,
    kind: OccasionKind.family, leadDays: [10],
    suggestion: 'برای مادر و همسرت کادو بخر یا به دیدنشان برو.',
    isLunar: true,
  ),
  OccasionRule(
    id: 'teachers_day', title: 'روز معلم', month: 2, day: 12,
    kind: OccasionKind.professional, leadDays: [2],
    suggestion: 'از معلم‌هایت تشکر کن.',
  ),
  OccasionRule(
    id: 'lawyers_day', title: 'روز وکیل', month: 12, day: 7,
    kind: OccasionKind.professional, leadDays: [2],
    suggestion: 'به وکیل‌های اطرافت تبریک بگو.',
  ),
  OccasionRule(
    id: 'engineers_day', title: 'روز مهندس', month: 12, day: 5,
    kind: OccasionKind.professional, leadDays: [2],
    suggestion: 'به مهندس‌های اطرافت تبریک بگو.',
  ),
  OccasionRule(
    id: 'doctors_day', title: 'روز پزشک', month: 6, day: 1,
    kind: OccasionKind.professional, leadDays: [2],
    suggestion: 'به پزشک‌های اطرافت تبریک بگو.',
  ),
  OccasionRule(
    id: 'dentists_day', title: 'روز دندان‌پزشک', month: 1, day: 23,
    kind: OccasionKind.professional, leadDays: [2],
    suggestion: 'به دندان‌پزشک‌ها تبریک بگو.',
  ),
];
