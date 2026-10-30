# برنامه‌ور | Barnamevar

برنامه‌ریز فارسی با تقویم جلالی، مدیریت کارها، یادآور، تکرار، خروجی ICS و پشتیبان رمزگذاری‌شده.

## پیش‌نیاز و اجرا
Flutter stable و Dart 3.3+ لازم است:
```sh
flutter pub get
flutter run
```
برای APK: `python3 tool/patch_android.py .` و سپس `flutter build apk --release`.
اگر پوشهٔ Android در checkout شما scaffold نشده، ابتدا `flutter create --platforms=android .` را اجرا کنید. ابزار پچ، منابع ویجت را در ساختار استاندارد Android نصب می‌کند و مجوزها و receiver را به manifest موجود اضافه می‌کند؛ اجرای مجدد امن است.

## آزمون
```sh
flutter analyze
flutter test
python3 tool/patch_android.py /path/to/flutter/project
```
کارها به صورت محلی در SharedPreferences نگهداری می‌شوند. فایل پشتیبان `.bvb` با AES-GCM و کلید مشتق‌شده از گذرواژه رمزگذاری می‌شود. مجوزهای اعلان و آلارم دقیق ممکن است برحسب Android و تنظیمات دستگاه متفاوت باشند.
