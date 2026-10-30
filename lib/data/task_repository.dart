import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/task.dart';
class TaskRepository {
 static const _key='barnamevar.tasks.v2';
 Future<List<Task>> load() async {final p=await SharedPreferences.getInstance();final s=p.getString(_key);if(s==null)return [];return (jsonDecode(s) as List).map((e)=>Task.fromJson(Map<String,dynamic>.from(e))).toList();}
 Future<void> save(List<Task> tasks) async {final p=await SharedPreferences.getInstance();await p.setString(_key,jsonEncode(tasks.map((e)=>e.toJson()).toList()));}
}
