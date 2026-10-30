import 'task.dart';
import '../occasions/occasion_rule.dart';
class PlannedReminder {final int id;final DateTime at;final String title,body;const PlannedReminder(this.id,this.at,this.title,this.body);}
class ReminderPlanner {
 static int taskId(Task t)=>1000000+(t.reminderId??t.id.hashCode.abs()%899999);
 static int occasionId(String key)=>5000000+(key.hashCode.abs()%899999);
 List<PlannedReminder> task(Task t)=>t.reminder&&!t.isArchived&&!t.isDone?[PlannedReminder(taskId(t),t.due,t.title,t.note)]:[];
 List<PlannedReminder> occasion(OccasionRule r,DateTime date)=>r.defaultReminder?[PlannedReminder(occasionId(r.key),date.subtract(Duration(days:r.preReminderDays)),r.title,'یادآوری مناسبت ${r.title}')]:[];
}
