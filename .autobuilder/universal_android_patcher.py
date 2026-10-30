#!/usr/bin/env python3
import re, subprocess, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parent.parent
ANDROID = ROOT / "android"
def block(text, name, additions):
    match = re.search(r"(?m)^\s*" + re.escape(name) + r"\s*\{", text)
    if not match:
        return text.rstrip() + "\n\n" + name + " {\n" + "".join("    " + line + "\n" for _, line in additions) + "}\n"
    start=text.find("{",match.start()); depth=0; end=None; quote=None; escaped=False
    for i in range(start,len(text)):
        c=text[i]
        if quote:
            if escaped: escaped=False
            elif c=="\\": escaped=True
            elif c==quote: quote=None
        elif c in "\"'": quote=c
        elif c=="{": depth+=1
        elif c=="}":
            depth-=1
            if depth==0: end=i; break
    if end is None: return text
    body=text[start+1:end]; missing=[line for pattern,line in additions if not re.search(pattern,body,re.M)]
    if missing: text=text[:end]+"\n"+"".join("        "+line+"\n" for line in missing)+text[end:]
    return text
def patch_gradle(path):
    text=path.read_text(encoding="utf-8"); kts=path.suffix==".kts"
    text=block(text,"android",[(r"\bcompileSdk(?:Version)?\s*(?:=|\s)\s*\d+","compileSdk = 36" if kts else "compileSdkVersion 36")])
    text=block(text,"defaultConfig",[(r"\bminSdk(?:Version)?\s*(?:=|\s|\()\s*\d+","minSdk = 24" if kts else "minSdkVersion 24"),(r"\btargetSdk(?:Version)?\s*(?:=|\s|\()\s*\d+","targetSdk = 36" if kts else "targetSdkVersion 36"),(r"multiDexEnabled\s*(?:=\s*)?true","multiDexEnabled = true" if kts else "multiDexEnabled true")])
    text=block(text,"compileOptions",[(r"coreLibraryDesugaringEnabled\s*(?:=\s*)?true","isCoreLibraryDesugaringEnabled = true" if kts else "coreLibraryDesugaringEnabled true"),(r"\bsourceCompatibility\b","sourceCompatibility = JavaVersion.VERSION_17" if kts else "sourceCompatibility JavaVersion.VERSION_17"),(r"\btargetCompatibility\b","targetCompatibility = JavaVersion.VERSION_17" if kts else "targetCompatibility JavaVersion.VERSION_17")])
    if not re.search(r"kotlinOptions\s*\{",text): text += "\nkotlinOptions {\n    jvmTarget = \"17\"\n}\n"
    elif not re.search(r"jvmTarget\s*=\s*['\"]17",text): text=re.sub(r"(kotlinOptions\s*\{)",r"\1\n    jvmTarget = \"17\"",text,count=1)
    if not re.search(r"coreLibraryDesugaring\s*\(?['\"]com\.android\.tools:desugar_jdk_libs:",text):
        dep='coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")' if kts else "coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'"
        text += "\ndependencies {\n    "+dep+"\n}\n"
    path.write_text(text,encoding="utf-8")
def main():
    if not ANDROID.exists(): print("No Android directory; skipped."); return
    custom=ROOT/"tool/patch_android.py"
    if custom.is_file(): subprocess.run([sys.executable,str(custom),str(ROOT)],cwd=ROOT,check=True)
    gradle=next((p for p in (ANDROID/"app/build.gradle",ANDROID/"app/build.gradle.kts") if p.exists()),None)
    if gradle: patch_gradle(gradle)
    gp=ANDROID/"gradle.properties"; props=gp.read_text(encoding="utf-8") if gp.exists() else ""
    for setting in ("android.useAndroidX=true","android.enableJetifier=true"):
        key=setting.split("=")[0]
        if not re.search(r"(?m)^\s*"+re.escape(key)+r"\s*=",props): props=props.rstrip()+"\n"+setting+"\n"
    gp.write_text(props.lstrip(),encoding="utf-8")
    manifest=ANDROID/"app/src/main/AndroidManifest.xml"
    if manifest.exists():
        xml=manifest.read_text(encoding="utf-8")
        if "android.permission.INTERNET" not in xml:
            xml=re.sub(r"(<manifest\b[^>]*>)",r'\1\n    <uses-permission android:name="android.permission.INTERNET" />',xml,count=1)
            manifest.write_text(xml,encoding="utf-8")
    print("Android compatibility patch complete.")
if __name__=="__main__": main()
