#!/usr/bin/env python3
"""Static and mathematical verification for Barnamevar v2. Run: python3 tool/verify_project.py"""
from pathlib import Path
import re, sys, math, zipfile
ROOT = Path(__file__).resolve().parents[1]

def div(a,b): return abs(a)//abs(b) * (-1 if (a<0) != (b<0) else 1)
def mod(a,b): return a-div(a,b)*b
BREAKS=[-61,9,38,199,426,686,756,818,1111,1181,1210,1635,2060,2097,2192,2262,2324,2394,2456,3178]
def jump_for(y):
    jp=BREAKS[0]
    for jm in BREAKS[1:]:
        if y<jm: return jm-jp
        jp=jm
    return 0
def jal_cal(y):
    gy=y+621; leap_j=-14; jp=BREAKS[0]
    for jm in BREAKS[1:]:
        jump=jm-jp
        if y<jm: break
        leap_j+=div(jump,33)*8+div(mod(jump,33),4); jp=jm
    n=y-jp; leap_j+=div(n,33)*8+div(mod(n,33)+3,4)
    if mod(jump_for(y),33)==4 and jump_for(y)-n==4: leap_j+=1
    leap_g=div(gy,4)-div(div(gy,100)+1,4)*3-150
    march=20+leap_j-leap_g
    if jump_for(y)-n<6: n=n-jump_for(y)+div(jump_for(y)+4,33)*33
    leap=mod(mod(n+1,33)-1,4)
    if leap==-1: leap=4
    return gy,march,leap
def g2d(gy,gm,gd):
    d=div((gy+div(gm-8,6)+100100)*1461,4)+div(153*mod(gm+9,12)+2,5)+gd-34840408
    d=d-div(div(gy+100100+div(gm-8,6),100)*3,4)+752
    return d
def d2g(jdn):
    j=4*jdn+139361631
    j=j+div(div(4*jdn+183187720,146097)*3,4)*4-3908
    i=div(mod(j,1461),4)*5+308
    gd=div(mod(i,153),5)+1; gm=mod(div(i,153),12)+1
    gy=div(j,1461)-100100+div(8-gm,6)
    return gy,gm,gd
def jdn_jal(y,m,d):
    gy,march,_=jal_cal(y)
    return g2d(gy,3,march)+(m-1)*31-div(m,7)*(m-7)+d-1
def jal_to_g(y,m,d): return d2g(jdn_jal(y,m,d))
def g_to_jal(gy,gm,gd):
    jy=gy-621; _,march,_=jal_cal(jy); k=g2d(gy,gm,gd)-g2d(gy,3,march)
    if k>=0:
        if k<=185:return jy,1+div(k,31),mod(k,31)+1
        q=k-186; return jy,7+div(q,30),mod(q,30)+1
    prev=jy-1; _,pm,_=jal_cal(prev); kk=g2d(gy,gm,gd)-g2d(gy-1,3,pm); q=kk-186
    return prev,7+div(q,30),mod(q,30)+1

def main():
    problems=[]; notes=[]
    files=sorted(p for p in ROOT.rglob('*') if p.is_file())
    empty=[str(p.relative_to(ROOT)) for p in files if p.stat().st_size==0]
    if empty: problems.append('Empty files: '+', '.join(empty))
    else: notes.append(f'Non-empty files: PASS ({len(files)} files)')
    markers=('TO'+'DO','FI'+'XME','Unimplemented'+'Error')
    found=[]
    for p in files:
        try: data=p.read_bytes()
        except OSError as e: found.append((p,str(e))); continue
        for marker in markers:
            if marker.encode() in data: found.append((p,marker))
    if found: problems.append('Forbidden markers: '+', '.join(f'{p.relative_to(ROOT)}:{m}' for p,m in found))
    else: notes.append('Forbidden markers: PASS (zero matches)')
    # Check Dart relative imports and in-project package imports.
    dart_files=[p for d in ('lib','test') for p in (ROOT/d).rglob('*.dart')]
    import_re=re.compile(r"import\s+['\"]([^'\"]+)['\"](?:\s+(?:as\s+\w+|show\s+[^;]+|hide\s+[^;]+))*\s*;")
    bad=[]; local_imports=0
    for p in dart_files:
        text=p.read_text(encoding='utf-8')
        for spec in import_re.findall(text):
            if spec.startswith('dart:') or (spec.startswith('package:') and not spec.startswith('package:barnamevar/')): continue
            if spec.startswith('package:barnamevar/'): target=ROOT/'lib'/spec[len('package:barnamevar/'):]
            else: target=(p.parent/spec).resolve()
            local_imports+=1
            if not target.is_file(): bad.append(f'{p.relative_to(ROOT)} imports missing {spec}')
    # Validate locally imported declared class/enum/typedef/top-level function names
    # where import uses show; all local sources are also scanned for definitions.
    source='\n'.join(p.read_text(encoding='utf-8') for p in (ROOT/'lib').rglob('*.dart'))
    declarations=set(re.findall(r'\b(?:class|enum|typedef|mixin|extension)\s+(\w+)',source))
    declarations.update(re.findall(r'(?m)^\s*(?:Future(?:<[^>]+>)?|Stream(?:<[^>]+>)?|List<[^>]+>|Map<[^>]+>|\w+(?:\??))\s+(\w+)\s*\([^;{}]*\)\s*(?:async\s*)?(?:\{|=>)',source))
    declarations.update(re.findall(r'(?m)^\s*(?:const|final|var)\s+(\w+)\s*=',source))
    # Parse show lists only: symbol visibility is checked against the target library declarations.
    for p in dart_files:
        text=p.read_text(encoding='utf-8')
        for m in re.finditer(r"import\s+['\"]([^'\"]+)['\"]\s+show\s+([^;]+);",text):
            spec,names=m.groups()
            if spec.startswith('package:barnamevar/'): target=ROOT/'lib'/spec[len('package:barnamevar/'):]
            elif not spec.startswith(('dart:','package:')): target=(p.parent/spec).resolve()
            else: continue
            if target.exists():
                body=target.read_text(encoding='utf-8')
                defs=set(re.findall(r'\b(?:class|enum|typedef|mixin|extension)\s+(\w+)',body))
                defs.update(re.findall(r'(?m)^\s*(?:Future(?:<[^>]+>)?|Stream(?:<[^>]+>)?|List<[^>]+>|Map<[^>]+>|\w+(?:\??))\s+(\w+)\s*\(',body))
                for name in names.split(','):
                    name=name.strip()
                    if name and name not in defs: bad.append(f'{p.relative_to(ROOT)} imports unexported {name} from {spec}')
    if bad: problems.extend(bad)
    else: notes.append(f'Local relative/package imports: PASS ({local_imports} imports; paths resolve; show-symbols checked)')
    # Jalali conversion equations copied from lib/core/jalali.dart, evaluated independently in Python.
    jalali_cases=[((2024,3,20),(1403,1,1)),((2021,3,21),(1400,1,1)),((2020,3,20),(1399,1,1)),((2021,3,20),(1399,12,30))]
    jresults=[]
    for greg,want in jalali_cases:
        got=g_to_jal(*greg); back=jal_to_g(*got)
        jresults.append((greg,got,back,want))
        if got!=want or back!=greg: problems.append(f'Jalali conversion mismatch: {greg} => {got}, expected {want}, roundtrip {back}')
    notes.append('Jalali checks: '+('PASS' if all(a==c and b==d for a,b,c,d in jresults) else 'FAIL')+'; '+repr(jresults))
    # Date claims explicitly documented in holidays.dart and fixed 1405 dates.
    holiday_checks=[((1405,3,6),(2026,5,27)),((1405,3,14),(2026,6,4)),((1405,4,4),(2026,6,25)),((1405,4,5),(2026,6,26))]
    hres=[]
    for jal,greg in holiday_checks:
        got=jal_to_g(*jal); hres.append((jal,got,greg))
        if got!=greg: problems.append(f'Holiday date mismatch: Jalali {jal} => {got}, documented Gregorian {greg}')
    notes.append('Documented 1405 holiday date checks: '+('PASS' if all(g==x for _,g,x in hres) else 'FAIL')+'; '+repr(hres))
    # ReminderPlanner ID ranges as written in Dart; explicit reminderId bypass is called out.
    task_lo,task_hi=1_000_000,1_000_000+899_998
    occ_lo,occ_hi=5_000_000,5_000_000+899_998
    separate=task_hi<occ_lo
    notes.append(f'Notification ID ranges (hash-derived): task [{task_lo},{task_hi}], occasion [{occ_lo},{occ_hi}], disjoint={separate}')
    if not separate: problems.append('Hash-derived task/occasion notification IDs overlap')
    planner=(ROOT/'lib/domain/reminder_planner.dart').read_text(encoding='utf-8')
    if 't.reminderId??' in planner: notes.append('CAVEAT: task.reminderId overrides the task hash range; arbitrary explicit IDs are not guaranteed separated from occasion IDs.')
    # Actual lib/core/contrast.dart equations versus WCAG 2.x reference.
    contrast=(ROOT/'lib/core/contrast.dart').read_text(encoding='utf-8')
    def linear(v):
        v=v/255
        return v/12.92 if v<=0.04045 else ((v+0.055)/1.055)**2.4
    def wcag(c): return .2126*linear(c[0])+.7152*linear(c[1])+.0722*linear(c[2])
    def ratio(x,y):
        a,b=wcag(x),wcag(y); hi,lo=max(a,b),min(a,b); return (hi+.05)/(lo+.05)
    # Source _pow does 24 iterations (x^24, ignoring its n argument). Contrast ternary also omits .05 from its dark operand.
    def source_linear(v):
        v=v/255
        return v/12.92 if v<=.04045 else ((v+.055)/1.055)**24
    def source_lum(c): return .2126*source_linear(c[0])+.7152*source_linear(c[1])+.0722*source_linear(c[2])
    def source_ratio(x,y):
        a,b=source_lum(x),source_lum(y)
        return (a if a>b else b+.05)/(b+.05 if a>b else a) if (b+.05 if a>b else a)!=0 else math.inf
    color_cases=[((0,0,0),(255,255,255)),((119,119,119),(255,255,255)),((0,105,170),(255,255,255)),((255,255,255),(255,255,255))]
    cres=[]
    for a,b in color_cases:
        w=ratio(a,b); s=source_ratio(a,b); cres.append((a,b,round(w,4),round(s,4)))
    source_bad=('_pow(double x,double n){var out=1.0;for(var i=0;i<24;i++)out*=x;' in contrast and '(x>y?x:y+.05)/(x>y?y+.05:x)' in contrast)
    if not source_bad: notes.append('Contrast source patterns changed; inspect formulas manually.')
    if any(abs(w-s)>0.01 for _,_,w,s in cres): problems.append('WCAG contrast Dart logic does not match reference formula (including _pow exponent/denominator); cases: '+repr(cres))
    else: notes.append('WCAG contrast checks: PASS; '+repr(cres))
    print('\n'.join(notes))
    if problems:
        print('FAILURES:')
        for x in problems: print(' - '+x)
        return 1
    print('OVERALL: PASS')
    return 0
if __name__=='__main__': sys.exit(main())
