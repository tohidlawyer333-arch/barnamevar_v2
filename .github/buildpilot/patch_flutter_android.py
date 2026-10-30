from pathlib import Path
import re

pubspec = Path("pubspec.yaml").read_text(encoding="utf-8")
if "flutter_local_notifications" not in pubspec:
    print("BuildPilot: no flutter_local_notifications dependency; desugaring patch skipped")
    raise SystemExit(0)

app = Path("android/app")
kts = app / "build.gradle.kts"
groovy = app / "build.gradle"
if kts.exists():
    path = kts
    text = path.read_text(encoding="utf-8")
    if "isCoreLibraryDesugaringEnabled" not in text:
        text, count = re.subn(r"compileOptions\s*\{", "compileOptions {\n        isCoreLibraryDesugaringEnabled = true", text, count=1)
        if not count:
            raise SystemExit("BuildPilot: compileOptions block not found in build.gradle.kts")
    if "desugar_jdk_libs" not in text:
        text += '\n\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n}\n'
else:
    path = groovy
    if not path.exists():
        raise SystemExit("BuildPilot: android/app/build.gradle(.kts) not found")
    text = path.read_text(encoding="utf-8")
    if "coreLibraryDesugaringEnabled" not in text:
        text, count = re.subn(r"compileOptions\s*\{", "compileOptions {\n        coreLibraryDesugaringEnabled true", text, count=1)
        if not count:
            raise SystemExit("BuildPilot: compileOptions block not found in build.gradle")
    if "desugar_jdk_libs" not in text:
        text += "\n\ndependencies {\n    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'\n}\n"

path.write_text(text, encoding="utf-8")
print("BuildPilot: core library desugaring configured")