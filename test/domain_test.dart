import 'package:flutter_test/flutter_test.dart';
import 'package:barnamevar/domain/recurrence.dart';
import 'package:barnamevar/domain/task.dart';
void main() {
  final due=DateTime(2024,3,20,9,15);
  Task sample({Recurrence recurrence=Recurrence.none})=>Task(id:'task-1',title:'کار نمونه',due:due,recurrence:recurrence);
  test('task JSON round-trip preserves fields',(){
    final task=sample(recurrence:Recurrence.weekly).copyWith(note:'یادداشت',category:Category.work,weekdays:[1,3]);
    final restored=Task.fromJson(task.toJson()); expect(restored.id,task.id); expect(restored.title,task.title);
    expect(restored.due,task.due); expect(restored.recurrence,Recurrence.weekly); expect(restored.weekdays,[1,3]); expect(restored.category,Category.work);
  });
  test('daily and monthly recurrence preserve date and time',(){
    expect(RecurrenceCalculator.next(sample(recurrence:Recurrence.daily)),DateTime(2024,3,21,9,15));
    final monthEnd=Task(id:'end',title:'پایان ماه',due:DateTime(2024,4,19),recurrence:Recurrence.monthly);
    expect(RecurrenceCalculator.next(monthEnd),DateTime(2024,5,19));
  });
  test('completing a repeating task archives and creates next instance',(){
    final result=RecurrenceCalculator.complete(sample(recurrence:Recurrence.daily)); expect(result,hasLength(2));
    expect(result.first.isDone,isTrue); expect(result.first.isArchived,isTrue); expect(result.last.isDone,isFalse);
    expect(result.last.due,DateTime(2024,3,21,9,15));
  });
}
