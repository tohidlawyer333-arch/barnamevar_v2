#!/usr/bin/env python3
"""Idempotent best-effort Android/Flutter compatibility patcher."""
import re, shutil, subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parent.parent
ANDROID=ROOT/"android"
def block(text,name,lines):
    m=re.search(r"(?m)^\\s*"+re.escape(name)+r"\\s*\\{",text)
    if not m:
        return text.rstrip()+"\\n\\n"+name+" {\\n"+"".join("    "+line+"\\n" for _,line in lines)+"}\\n"
    start=text.find("{",m.start()); depth=0; end=-1; quote=None; esc=False
    for i in range(start,len(text)):
        c=text[i]
        if quote:
            if esc: esc=False
            elif c=="\\\\": esc=True
            elif c==quote: quote=None
            continue
        if c in "\\\"'": quote=c
        elif c=="{": depth+=1
        elif c=="}":
            depth-=1
            if depth==0: end=i; break
    if end<0: return text
    body=text[start+1:end]; missing=[line for pattern,line in lines if not re.search(pattern,body,re.M)]
    if missing: text=text[:end]+"\\n"+"".join("        "+line+"\\n" for line in missing)+text[end:]
    return text
def patch_gradle(path):
    text=path.read_text(encoding="utf-8"); kts=path.suffix==".kts"
    text=block(text,"android",[(r"\\bcompileSdk(?:Version)?\\s*(?:=|\\s)\\s*36\\b","compileSdk = 36" if kts else "compileSdkVersion 36")])
    text=block(text,"defaultConfig",[(r"\\bminSdk(?:Version)?\\s*(?:=|\\s|\\()\\s*24\\b","minSdk = 24" if kts else "minSdkVersion 24"),(r"\\btargetSdk(?:Version)?\\s*(?:=|\\s|\\()\\s*36\\b","targetSdk = 36" if kts else "targetSdkVersion 36"),(r"multiDexEnabled\\s*(?:=\\s*)?true","multiDexEnabled = true" if kts else "multiDexEnabled true")])
    text=block(text,"compileOptions",[(r"coreLibraryDesugaringEnabled\\s*(?:=\\s*)?true","isCoreLibraryDesugaringEnabled = true" if kts else "coreLibraryDesugaringEnabled true"),(r"\\bsourceCompatibility\\b","sourceCompatibility = JavaVersion.VERSION_17" if kts else "sourceCompatibility JavaVersion.VERSION_17"),(r"\\btargetCompatibility\\b","targetCompatibility = JavaVersion.VERSION_17" if kts else "targetCompatibility JavaVersion.VERSION_17")])
    if not re.search(r"kotlinOptions\\s*\\{",text): text += "\\nkotlinOptions {\\n    jvmTarget = \\\"17\\\"\\n}\\n"
    elif not re.search(r"jvmTarget\\s*=\\s*['\\\"]17",text): text=re.sub(r"(kotlinOptions\\s*\\{)",r"\\1\\n    jvmTarget = \\\"17\\\"",text,count=1)
    if not re.search(r"coreLibraryDesugaring\\s*\\(?['\\\"]com\\.android\\.tools:desugar_jdk_libs:2\\.1\\.4",text):
        dep='coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")' if kts else "coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'"
        text += "\\ndependencies {\\n    "+dep+"\\n}\\n"
    path.write_text(text,encoding="utf-8")
def main():
    if not ANDROID.exists(): print("No android directory; skipped."); return
    gradle=next((p for p in (ANDROID/"app/build.gradle",ANDROID/"app/build.gradle.kts") if p.exists()),None)
    if gradle: patch_gradle(gradle)
    gp=ANDROID/"gradle.properties"; props=gp.read_text(encoding="utf-8") if gp.exists() else ""
    for key in ("android.useAndroidX=true","android.enableJetifier=true"):
        if not re.search(r"(?m)^\\s*"+key.split("=")[0]+r"\\s*=",props): props+="\\n"+key
    gp.write_text(props.lstrip()+"\\n",encoding="utf-8")
    # Copy custom Kotlin/Java widgets and retain project-specific patcher behavior.
    source=ROOT/"lib/widget"; dest=ANDROID/"app/src/main/kotlin"
    if source.exists():
        for item in source.rglob("*"):
            if item.is_file() and item.suffix in (".kt",".java"):
                content=item.read_text(encoding="utf-8",errors="replace"); match=re.search(r"(?m)^\\s*package\\s+([\\w.]+)",content)
                target=dest/Path(*match.group(1).split("."))/item.name if match else dest/item.name
                target.parent.mkdir(parents=True,exist_ok=True); shutil.copy2(item,target)
    custom=ROOT/"tool/patch_android.py"
    if custom.exists(): subprocess.run(["python",str(custom)],cwd=ROOT,check=True)
    manifest=ANDROID/"app/src/main/AndroidManifest.xml"
    if manifest.exists():
        xml=manifest.read_text(encoding="utf-8")
        if "android.permission.INTERNET" not in xml: xml=re.sub(r"(<manifest\\b[^>]*>)",r"\\1\\n    <uses-permission android:name=\\\"android.permission.INTERNET\\\" />",xml,count=1)
        manifest.write_text(xml,encoding="utf-8")
    print("Android compatibility patch complete.")
if __name__=="__main__": main()
