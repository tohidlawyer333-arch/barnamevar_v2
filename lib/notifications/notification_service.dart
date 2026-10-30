import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
class NotificationService {
 final plugin=FlutterLocalNotificationsPlugin();
 Future<void> initialize() async {tzdata.initializeTimeZones();try{final name=await FlutterTimezone.getLocalTimezone();tz.setLocalLocation(tz.getLocation(name));}catch(_){tz.setLocalLocation(tz.UTC);} const android=AndroidInitializationSettings('@mipmap/ic_launcher');const settings=InitializationSettings(android:android);await plugin.initialize(settings,onDidReceiveNotificationResponse:(r){});}
 Future<void> schedule(int id,String title,String body,DateTime at) async {if(at.isBefore(DateTime.now()))return;await plugin.zonedSchedule(id,title,body,tz.TZDateTime.from(at,tz.local),const NotificationDetails(android:AndroidNotificationDetails('barnamevar','یادآوری‌ها',channelDescription:'یادآوری کارها',importance:Importance.max,priority:Priority.high,actions:[AndroidNotificationAction('MARK_DONE','انجام شد'),AndroidNotificationAction('SNOOZE_30','۳۰ دقیقه بعد')])),androidScheduleMode:AndroidScheduleMode.exactAllowWhileIdle,matchDateTimeComponents:null);}
}
