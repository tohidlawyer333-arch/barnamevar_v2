const persianDigits = ['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'];
String fa(String s) => s.replaceAllMapped(RegExp(r'\d'), (m) => persianDigits[int.parse(m[0]!)]);
String faInt(int n) => fa(n.toString());
String two(int n) => n.toString().padLeft(2,'0');
