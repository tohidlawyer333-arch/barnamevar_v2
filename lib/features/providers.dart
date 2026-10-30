import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/jalali.dart';
import '../data/task_repository.dart';
import '../domain/task.dart';
final taskRepositoryProvider=Provider<TaskRepository>((ref)=>TaskRepository());
final tasksProvider=AsyncNotifierProvider<TasksController,List<Task>>(TasksController.new);
class TasksController extends AsyncNotifier<List<Task>> {
 @override Future<List<Task>> build()=>ref.read(taskRepositoryProvider).load();
 Future<void> replace(List<Task> tasks) async {state=AsyncData(tasks);await ref.read(taskRepositoryProvider).save(tasks);}
 Future<void> upsert(Task task) async {final list=[...state.valueOrNull??<Task>[]];final i=list.indexWhere((x)=>x.id==task.id);if(i<0){list.add(task);}else{list[i]=task;}await replace(list);}
 Future<void> remove(String id) async=>replace((state.valueOrNull??[]).where((t)=>t.id!=id).toList());
}
final jalaliHeaderProvider=StreamProvider<Jalali>((ref) async* {while(true){yield Jalali.fromGregorian(DateTime.now());await Future<void>.delayed(const Duration(seconds:30));}});
final themeSeedProvider=StateProvider<int>((ref)=>0xff1769aa);
final darkModeProvider=StateProvider<String>((ref)=>'خودکار');
final occasionReminderDaysProvider=StateProvider<int>((ref)=>1);
