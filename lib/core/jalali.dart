import 'persian.dart';
class Jalali {
 final int year, month, day;
 const Jalali(this.year,this.month,this.day);
 static const monthNames=['فروردین','اردیبهشت','خرداد','تیر','مرداد','شهریور','مهر','آبان','آذر','دی','بهمن','اسفند'];
 static const weekdayNames=['دوشنبه','سه‌شنبه','چهارشنبه','پنجشنبه','جمعه','شنبه','یکشنبه'];
 static const _breaks=[-61,9,38,199,426,686,756,818,1111,1181,1210,1635,2060,2097,2192,2262,2324,2394,2456,3178];
 static int _div(int a,int b)=>a~/b;
 static int _mod(int a,int b)=>a-(a~/b)*b;
 static List<int> _jalCal(int jy) {
  final gy=jy+621; var leapJ=-14; var jp=_breaks[0]; int jm=0;
  for(final x in _breaks.skip(1)) { jm=x; final jump=jm-jp; if(jy<jm) break; leapJ+=_div(jump,33)*8+_div(_mod(jump,33),4); jp=jm; }
  var n=jy-jp; leapJ+=_div(n,33)*8+_div(_mod(n,33)+3,4);
  if(_mod(jumpFor(jy),33)==4 && jumpFor(jy)-n==4) leapJ++;
  final leapG=_div(gy,4)-_div((_div(gy,100)+1)*3,4)-150;
  final march=20+leapJ-leapG;
  if(jumpFor(jy)-n<6) n=n-jumpFor(jy)+_div(jumpFor(jy)+4,33)*33;
  var leap=_mod(_mod(n+1,33)-1,4); if(leap==-1) leap=4;
  return [gy,march,leap];
 }
 static int jumpFor(int jy) { var jp=_breaks[0]; for(final jm in _breaks.skip(1)){if(jy<jm)return jm-jp;jp=jm;} return 0; }
 static int _g2d(int gy,int gm,int gd) { var d=_div((gy+_div(gm-8,6)+100100)*1461,4)+_div(153*_mod(gm+9,12)+2,5)+gd-34840408; d=d-_div(_div(gy+100100+_div(gm-8,6),100)*3,4)+752; return d; }
 static DateTime _d2g(int jdn) { var j=4*jdn+139361631; j=j+_div(_div(4*jdn+183187720,146097)*3,4)*4-3908; final i=_div(_mod(j,1461),4)*5+308; final gd=_div(_mod(i,153),5)+1; final gm=_mod(_div(i,153),12)+1; final gy=_div(j,1461)-100100+_div(8-gm,6); return DateTime(gy,gm,gd); }
 static int _toJdn(int jy,int jm,int jd){ final r=_jalCal(jy); return _g2d(r[0],3,r[1])+(jm-1)*31-_div(jm,7)*(jm-7)+jd-1; }
 factory Jalali.fromGregorian(DateTime d) { final gy=d.year; final jy=gy-621; final r=_jalCal(jy); final jdn=_g2d(gy,d.month,d.day); final k=jdn-_g2d(gy,3,r[1]); int jm,jd;
  if(k>=0){if(k<=185){jm=1+_div(k,31);jd=_mod(k,31)+1;return Jalali(jy,jm,jd);} final q=k-186;jm=7+_div(q,30);jd=_mod(q,30)+1;return Jalali(jy,jm,jd);}
  final prev=jy-1; final pr=_jalCal(prev); final kk=jdn-_g2d(gy-1,3,pr[1]); final q=kk-186; jm=7+_div(q,30);jd=_mod(q,30)+1; return Jalali(prev,jm,jd);
 }
 DateTime toGregorian(){final n=_d2g(_toJdn(year,month,day));return DateTime(n.year,n.month,n.day);}
 static bool isLeapYear(int y)=>_jalCal(y)[2]==0;
 static int daysInMonth(int y,int m)=>m<=6?31:m<=11?30:(isLeapYear(y)?30:29);
 Jalali addDays(int n)=>Jalali.fromGregorian(toGregorian().add(Duration(days:n)));
 int get weekdayIndex=>(_toJdn(year,month,day)+1)%7;
 String get weekday=>weekdayNames[weekdayIndex];
 String format()=> '${faInt(day)} ${monthNames[month-1]} ${faInt(year)}';
 @override String toString()=> '${faInt(year)}/${faInt(month.toString().padLeft(2,'0'))}/${faInt(day.toString().padLeft(2,'0'))}';
 @override bool operator==(Object o)=>o is Jalali&&o.year==year&&o.month==month&&o.day==day;
 @override int get hashCode=>Object.hash(year,month,day);
}
