import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'core/jalali.dart';
import 'occasions/holidays.dart';
import 'occasions/occasion_rule.dart';

const _digits = '۰۱۲۳۴۵۶۷۸۹';
String fa(Object v) => v
    .toString()
    .replaceAllMapped(RegExp(r'\d'), (m) => _digits[int.parse(m[0]!)]);
String two(int n) => n.toString().padLeft(2, '0');

class Task {
  Task(this.id, this.title, this.when, {this.done = false});
  final int id;
  final String title;
  final DateTime when;
  final bool done;
  Task copy({bool? done, DateTime? when}) =>
      Task(id, title, when ?? this.when, done: done ?? this.done);
  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'when': when.toIso8601String(), 'done': done};
  static Task fromJson(Map<String, dynamic> j) => Task(
      j['id'] as int, j['title'] as String, DateTime.parse(j['when'] as String),
      done: j['done'] as bool);
}

final notifier = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  tzdata.initializeTimeZones();
  final name = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(name));
  await notifier.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher')));
  final a = notifier.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await a?.requestNotificationsPermission();
}

Future<void> schedule(int id, String title, DateTime when) async {
  if (when.isBefore(DateTime.now())) return;
  const d = NotificationDetails(
      android: AndroidNotificationDetails('tasks', 'یادآوری کارها',
          importance: Importance.high, priority: Priority.high));
  try {
    await notifier.zonedSchedule(
        id, title, null, tz.TZDateTime.from(when, tz.local), d,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle);
  } catch (_) {}
}

class TaskList extends Notifier<List<Task>> {
  late SharedPreferences _p;
  @override
  List<Task> build() {
    _p = ref.watch(prefsProvider);
    final raw = _p.getString('tasks');
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void _save(List<Task> l) {
    state = l;
    _p.setString('tasks', jsonEncode(l.map((e) => e.toJson()).toList()));
  }

  void add(String title, DateTime when) {
    final id = DateTime.now().microsecondsSinceEpoch % 900000000;
    _save([...state, Task(id, title, when)]);
    schedule(id, title, when);
  }

  void toggle(int id) {
    _save([for (final t in state) t.id == id ? t.copy(done: !t.done) : t]);
    notifier.cancel(id);
  }

  void remove(int id) {
    _save(state.where((t) => t.id != id).toList());
    notifier.cancel(id);
  }

  void snooze(int id) {
    final w = DateTime.now().add(const Duration(minutes: 30));
    final t = state.firstWhere((t) => t.id == id);
    _save([for (final x in state) x.id == id ? x.copy(when: w) : x]);
    schedule(id, t.title, w);
  }

  String exportJson() => jsonEncode(state.map((e) => e.toJson()).toList());
}

final prefsProvider = Provider<SharedPreferences>((_) => throw UnimplementedError());
final tasksProvider = NotifierProvider<TaskList, List<Task>>(TaskList.new);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  try {
    await initNotifications();
  } catch (_) {}
  runApp(ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: const BarnamevarApp()));
}

class BarnamevarApp extends StatelessWidget {
  const BarnamevarApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'برنامه‌یار',
        debugShowCheckedModeBanner: false,
        locale: const Locale('fa'),
        supportedLocales: const [Locale('fa'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (c, w) => Directionality(textDirection: TextDirection.rtl, child: w!),
        theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Vazirmatn',
            colorSchemeSeed: const Color(0xFF00695C)),
        home: const HomePage(),
      );
}

String jalaliLabel(Jalali j) =>
    '${Jalali.weekdayNames[j.weekdayIndex]} ${fa(j.day)} ${Jalali.monthNames[j.month - 1]} ${fa(j.year)}';

class Header extends StatefulWidget {
  const Header({super.key});
  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  late Timer _t;
  DateTime _now = DateTime.now();
  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      final n = DateTime.now();
      if (n.minute != _now.minute || n.day != _now.day) setState(() => _now = n);
    });
  }

  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(
      '${jalaliLabel(Jalali.fromDateTime(_now))} — ${fa('${two(_now.hour)}:${two(_now.minute)}')}',
      style: const TextStyle(fontSize: 14));
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = [...ref.watch(tasksProvider)]
      ..sort((a, b) => a.when.compareTo(b.when));
    return Scaffold(
      appBar: AppBar(
        title: const Text('برنامه‌یار'),
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(28), child: Header()),
        actions: [
          IconButton(
              icon: const Icon(Icons.event),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const OccasionsPage()))),
          IconButton(
              icon: const Icon(Icons.ios_share),
              onPressed: () => Share.share(
                  ref.read(tasksProvider.notifier).exportJson(),
                  subject: 'پشتیبان برنامه‌یار')),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('کاری ثبت نشده است'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (c, i) {
                final t = tasks[i];
                final j = Jalali.fromDateTime(t.when);
                return ListTile(
                  leading: Checkbox(
                      value: t.done,
                      onChanged: (_) =>
                          ref.read(tasksProvider.notifier).toggle(t.id)),
                  title: Text(t.title,
                      style: TextStyle(
                          decoration:
                              t.done ? TextDecoration.lineThrough : null)),
                  subtitle: Text(
                      '${fa('${j.year}/${two(j.month)}/${two(j.day)}')}  ${fa('${two(t.when.hour)}:${two(t.when.minute)}')}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                        tooltip: '۳۰ دقیقه بعد',
                        icon: const Icon(Icons.snooze),
                        onPressed: () =>
                            ref.read(tasksProvider.notifier).snooze(t.id)),
                    IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () =>
                            ref.read(tasksProvider.notifier).remove(t.id)),
                  ]),
                );
              }),
      floatingActionButton: FloatingActionButton(
          onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const AddSheet()),
          child: const Icon(Icons.add)),
    );
  }
}

class AddSheet extends ConsumerStatefulWidget {
  const AddSheet({super.key});
  @override
  ConsumerState<AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends ConsumerState<AddSheet> {
  final _c = TextEditingController();
  Jalali _d = Jalali.fromDateTime(DateTime.now());
  int _h = 9, _m = 0;

  Widget _grid(int count, int cur, ValueChanged<int> on, int step) => SizedBox(
        height: 120,
        child: SingleChildScrollView(
          child: Wrap(spacing: 4, children: [
            for (var i = 0; i < count; i += step)
              ChoiceChip(
                  label: Text(fa(two(i))),
                  selected: cur == i,
                  onSelected: (_) => setState(() => on(i))),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: _c,
                maxLines: null,
                decoration: const InputDecoration(labelText: 'عنوان کار')),
            const SizedBox(height: 8),
            Row(children: [
              IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => _d = _d.addDays(-1))),
              Expanded(
                  child: Text(jalaliLabel(_d), textAlign: TextAlign.center)),
              IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _d = _d.addDays(1))),
            ]),
            const Text('ساعت'),
            _grid(24, _h, (v) => _h = v, 1),
            const Text('دقیقه'),
            _grid(60, _m, (v) => _m = v, 5),
            FilledButton(
                onPressed: () {
                  if (_c.text.trim().isEmpty) return;
                  final g = _d.toDateTime();
                  ref.read(tasksProvider.notifier).add(_c.text.trim(),
                      DateTime(g.year, g.month, g.day, _h, _m));
                  Navigator.pop(context);
                },
                child: const Text('ذخیره')),
          ]),
        ),
      );
}

class OccasionsPage extends StatelessWidget {
  const OccasionsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final y = Jalali.fromDateTime(DateTime.now()).year;
    final hol = officialHolidays[y] ?? const <Holiday>[];
    return Scaffold(
      appBar: AppBar(title: Text('مناسبت‌های ${fa(y)}')),
      body: ListView(children: [
        const ListTile(title: Text('تعطیلات رسمی')),
        for (final h in hol)
          ListTile(
              dense: true,
              title: Text(h.title),
              trailing: Text('${fa(h.day)} ${Jalali.monthNames[h.month - 1]}')),
        const Divider(),
        const ListTile(title: Text('مناسبت‌های شخصی و صنفی')),
        for (final r in defaultOccasionRules)
          ListTile(
              dense: true,
              title: Text(r.title),
              subtitle: Text(r.suggestion),
              trailing: Text('${fa(r.day)} ${Jalali.monthNames[r.month - 1]}')),
      ]),
    );
  }
}
