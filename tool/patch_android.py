#!/usr/bin/env python3
"""Install widget resources into a Flutter Android tree; safe to re-run."""
from pathlib import Path
import argparse, shutil

def patch_manifest(path):
    if not path.is_file(): return False
    text = path.read_text(encoding='utf-8'); changed = False
    permissions = ['android.permission.RECEIVE_BOOT_COMPLETED','android.permission.POST_NOTIFICATIONS','android.permission.SCHEDULE_EXACT_ALARM']
    for permission in permissions:
        if permission not in text:
            pos = text.find('<application')
            if pos >= 0:
                text = text[:pos] + '    <uses-permission android:name="' + permission + '" />\n' + text[pos:]
                changed = True
    if 'BarnamevarWidgetProvider' not in text:
        lines = ['        <receiver','            android:name="com.barnamevar.app.BarnamevarWidgetProvider"','            android:label="برنامه‌ور"','            android:exported="true">','            <intent-filter>','                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />','            </intent-filter>','            <meta-data android:name="android.appwidget.provider" android:resource="@xml/barnamevar_widget_info" />','        </receiver>']
        receiver = '\n'.join(lines)
        pos = text.rfind('</application>')
        if pos >= 0: text = text[:pos] + receiver + '\n    ' + text[pos:]; changed = True
    if changed: path.write_text(text, encoding='utf-8')
    return changed

def main():
    parser=argparse.ArgumentParser(description=__doc__); parser.add_argument('root',nargs='?',type=Path,default=Path(__file__).resolve().parents[1]); root=parser.parse_args().root.resolve()
    pairs=[(root/'lib/widget/BarnamevarWidgetProvider.kt',root/'android/app/src/main/kotlin/com/barnamevar/app/BarnamevarWidgetProvider.kt'),(root/'lib/widget/barnamevar_widget.xml',root/'android/app/src/main/res/layout/barnamevar_widget.xml'),(root/'lib/widget/barnamevar_widget_info.xml',root/'android/app/src/main/res/xml/barnamevar_widget_info.xml')]
    copied=0
    for src,dst in pairs:
        if src.is_file():
            dst.parent.mkdir(parents=True,exist_ok=True)
            if not dst.exists() or src.read_bytes()!=dst.read_bytes(): shutil.copyfile(src,dst);copied+=1
    updated=patch_manifest(root/'android/app/src/main/AndroidManifest.xml')
    print(f'Android patch complete (root={root}; copied={copied}; manifest_updated={str(updated).lower()}).')
    return 0
if __name__=='__main__': raise SystemExit(main())
