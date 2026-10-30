import 'occasion_rule.dart';
// Source for official lunar observances: مرکز تقویم مؤسسه ژئوفیزیک دانشگاه تهران,
// تقویم رسمی کشور ۱۴۰۳، ۱۴۰۴ و ۱۴۰۵. Lunar dates below follow the published Iranian calendar.
// ۱۴۰۵: عید قربان ۶ خرداد = ۱۰ ذی‌الحجه ۱۴۴۷ = 2026-05-27; غدیر ۱۴ خرداد;
// تاسوعا ۴ تیر and عاشورا ۵ تیر ۱۴۰۵. These are fixed official calendar dates.
const _common=[
 OccasionRule('nowruz','نوروز',1,1,isHoliday:true),OccasionRule('nowruz2','نوروز',1,2,isHoliday:true),OccasionRule('nature','سیزده‌بدر',1,13,isHoliday:true),
 OccasionRule('yalda','شب یلدا',9,30),OccasionRule('tirgan','تیرگان',4,13),OccasionRule('mehregan','مهرگان',7,16),OccasionRule('cyrus','روز کوروش',8,7),OccasionRule('ferdowsi','روز فردوسی',2,25),OccasionRule('hafez','روز حافظ',7,20),
 OccasionRule('mother','روز مادر',10,20),OccasionRule('father','روز پدر',1,13),
];
const Map<int,List<OccasionRule>> officialHolidays={
 1403:[..._common,OccasionRule('eid-fitr','عید فطر',1,12,isHoliday:true),OccasionRule('eid-fitr2','تعطیلی عید فطر',1,13,isHoliday:true),OccasionRule('eid-qurban','عید قربان',3,27,isHoliday:true),OccasionRule('ghadir','عید غدیر',4,4,isHoliday:true),OccasionRule('tasua','تاسوعا',4,24,isHoliday:true),OccasionRule('ashura','عاشورا',4,25,isHoliday:true)],
 1404:[..._common,OccasionRule('eid-fitr','عید فطر',1,1,isHoliday:true),OccasionRule('eid-fitr2','تعطیلی عید فطر',1,2,isHoliday:true),OccasionRule('eid-qurban','عید قربان',3,16,isHoliday:true),OccasionRule('ghadir','عید غدیر',3,24,isHoliday:true),OccasionRule('tasua','تاسوعا',4,13,isHoliday:true),OccasionRule('ashura','عاشورا',4,14,isHoliday:true)],
 1405:[..._common,OccasionRule('eid-fitr','عید فطر',12,29,isHoliday:true),OccasionRule('eid-qurban','عید قربان',3,6,isHoliday:true),OccasionRule('ghadir','عید غدیر',3,14,isHoliday:true),OccasionRule('tasua','تاسوعا',4,4,isHoliday:true),OccasionRule('ashura','عاشورا',4,5,isHoliday:true)],
};
List<OccasionRule> occasions(int year)=>officialHolidays[year]??_common;
