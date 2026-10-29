# برنامه‌یار

اپ اندروید (Flutter) برای مدیریت کارها با تقویم شمسی، یادآوری و مناسبت‌های ۱۴۰۵.

## ساخت
نیازمند Flutter stable و JDK 17.
```
flutter create --platforms=android --org ir.barnamevar --project-name barnamevar .
rm -f test/widget_test.dart
python3 tool/patch_android.py
flutter pub get
flutter analyze --no-fatal-infos && flutter test
flutter build apk --release
```
(پوشه‌ی android عمداً در زیپ نیست؛ دستور اول می‌سازد. در GitHub همین کار را `.github/workflows/build.yml` می‌کند.)
`tool/patch_android.py` مجوزهای اعلان و desugaring را خودکار اضافه می‌کند.

## وضعیت
- بررسی نشده: هیچ‌کدام از مراحل بالا در این محیط اجرا نشد (Flutter در دسترس نبود)؛ فقط CI تعیین‌کننده است.
- منطق شمسی و فهرست تعطیلات ۱۴۰۳–۱۴۰۵ آماده است.
- ناقص نسبت به طرح اولیه: Drift، go_router، ویجت خانه، پشتیبان رمزنگاری‌شده، ۷ تم، یادآوری مبتنی بر قانون مناسبت‌ها (قوانین هست، زمان‌بندی نیست). ذخیره‌سازی با shared_preferences است.
