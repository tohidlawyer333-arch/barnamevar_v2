import pathlib, re
app = pathlib.Path('android/app')
g = app / 'build.gradle.kts'
if g.exists():
    s = g.read_text()
    if 'isCoreLibraryDesugaringEnabled' not in s:
        s = s.replace('compileOptions {', 'compileOptions {\n        isCoreLibraryDesugaringEnabled = true', 1)
        s += '\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n}\n'
else:
    g = app / 'build.gradle'
    s = g.read_text()
    if 'coreLibraryDesugaringEnabled' not in s:
        s = s.replace('compileOptions {', 'compileOptions {\n        coreLibraryDesugaringEnabled true', 1)
        s += "\ndependencies {\n    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'\n}\n"
assert 'esugaringEnabled' in s, 'compileOptions not found'
g.write_text(s)
m = app / 'src/main/AndroidManifest.xml'
x = m.read_text()
perms = ['POST_NOTIFICATIONS', 'RECEIVE_BOOT_COMPLETED', 'VIBRATE']
add = ''.join(f'    <uses-permission android:name="android.permission.{p}"/>\n' for p in perms if p not in x)
x = re.sub(r'(<application)', add + r'\1', x, count=1)
x = x.replace('android:label="barnamevar"', 'android:label="برنامه‌یار"')
m.write_text(x)
print('android patched')
