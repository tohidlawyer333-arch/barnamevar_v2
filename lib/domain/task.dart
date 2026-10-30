import '../core/jalali.dart';
enum Category { work, family, finance, health, custom }
enum Recurrence { none, daily, weekly, monthly, yearly }
class Task {
 final String id,title,note; final DateTime due; final Category category; final Recurrence recurrence; final List<int> weekdays; final bool isDone,isArchived; final bool reminder; final int? reminderId;
 const Task({required this.id,required this.title,required this.due,this.note='',this.category=Category.custom,this.recurrence=Recurrence.none,this.weekdays=const[],this.isDone=false,this.isArchived=false,this.reminder=true,this.reminderId});
 Task copyWith({String? id,String? title,String? note,DateTime? due,Category? category,Recurrence? recurrence,List<int>? weekdays,bool? isDone,bool? isArchived,bool? reminder,int? reminderId})=>Task(id:id??this.id,title:title??this.title,note:note??this.note,due:due??this.due,category:category??this.category,recurrence:recurrence??this.recurrence,weekdays:weekdays??this.weekdays,isDone:isDone??this.isDone,isArchived:isArchived??this.isArchived,reminder:reminder??this.reminder,reminderId:reminderId??this.reminderId);
 Map<String,Object?> toJson()=>{'id':id,'title':title,'note':note,'due':due.toIso8601String(),'category':category.name,'recurrence':recurrence.name,'weekdays':weekdays,'done':isDone,'archived':isArchived,'reminder':reminder,'reminderId':reminderId};
 factory Task.fromJson(Map<String,dynamic> j)=>Task(id:j['id'],title:j['title'],note:j['note']??'',due:DateTime.parse(j['due']),category:Category.values.firstWhere((x)=>x.name==j['category'],orElse:()=>Category.custom),recurrence:Recurrence.values.firstWhere((x)=>x.name==j['recurrence'],orElse:()=>Recurrence.none),weekdays:List<int>.from(j['weekdays']??[]),isDone:j['done']??false,isArchived:j['archived']??false,reminder:j['reminder']??true,reminderId:j['reminderId']);
 Jalali get jalaliDue=>Jalali.fromGregorian(due);
}
