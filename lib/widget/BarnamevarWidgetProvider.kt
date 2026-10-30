package com.barnamevar.app
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import org.json.JSONArray
import java.util.Calendar
private object JalaliDate {
 private val breaks=intArrayOf(-61,9,38,199,426,686,756,818,1111,1181,1210,1635,2060,2097,2192,2262,2324,2394,2456,3178)
 private fun div(a:Int,b:Int)=Math.floorDiv(a,b); private fun mod(a:Int,b:Int)=a-Math.floorDiv(a,b)*b
 private fun g2d(gy:Int,gm:Int,gd:Int):Int {var d=div((gy+div(gm-8,6)+100100)*1461,4)+div(153*mod(gm+9,12)+2,5)+gd-34840408;d-=div(div(gy+100100+div(gm-8,6),100)*3,4);return d+752}
 private fun cal(jy:Int):IntArray {val gy=jy+621;var leapJ=-14;var jp=breaks[0];var jump=0;for(jm in breaks.drop(1)){jump=jm-jp;if(jy<jm)break;leapJ+=div(jump,33)*8+div(mod(jump,33),4);jp=jm};var n=jy-jp;leapJ+=div(n,33)*8+div(mod(n,33)+3,4);if(mod(jump,33)==4&&jump-n==4)leapJ++;val leapG=div(gy,4)-div((div(gy,100)+1)*3,4)-150;return intArrayOf(20+leapJ-leapG)}
 fun fromGregorian(gy:Int,gm:Int,gd:Int):IntArray {var jy=gy-621;var k=g2d(gy,gm,gd)-g2d(gy,3,cal(jy)[0]);if(k<0){jy--;k=g2d(gy,gm,gd)-g2d(gy-1,3,cal(jy)[0])+186};if(k<=185)return intArrayOf(jy,1+k/31,k%31+1);k-=186;return intArrayOf(jy,7+k/30,k%30+1)}
}
class BarnamevarWidgetProvider:AppWidgetProvider(){override fun onUpdate(context:Context,manager:AppWidgetManager,ids:IntArray){for(id in ids)update(context,manager,id)}
 private fun update(c:Context,m:AppWidgetManager,id:Int){val views=RemoteViews(c.packageName,R.layout.barnamevar_widget);val cal=Calendar.getInstance();val j=JalaliDate.fromGregorian(cal.get(Calendar.YEAR),cal.get(Calendar.MONTH)+1,cal.get(Calendar.DAY_OF_MONTH));views.setTextViewText(R.id.widget_date,"${j[2]} / ${j[1]} / ${j[0]}");val prefs=c.getSharedPreferences("FlutterSharedPreferences",Context.MODE_PRIVATE);val json=prefs.getString("flutter.barnamevar.tasks.v2",null);val tasks=try{JSONArray(json?:"[]")}catch(_:Exception){JSONArray()};val titles=mutableListOf<String>();for(i in 0 until tasks.length()){val task=tasks.optJSONObject(i)?:continue;if(task.optBoolean("done")||task.optBoolean("archived"))continue;titles.add(task.optString("title"))};for(i in 0..2){views.setTextViewText(listOf(R.id.widget_task1,R.id.widget_task2,R.id.widget_task3)[i],titles.getOrNull(i)?.take(48)?:if(i==0)"کار آینده‌ای نیست" else "")};m.updateAppWidget(id,views)}}
