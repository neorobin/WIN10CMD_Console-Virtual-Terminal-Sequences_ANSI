@echo off & setlocal enabledelayedexpansion

chcp 437

for /F %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
set "TAB=	" & for /F %%a in ('"prompt $h&for %%b in (1) do rem"')do Set "BS=%%a"

set "moveCursor=<nul set /p "=!ESC![x;yH""

set /a "ZM=10000, p=31416, p2=62832, pn2=-62832, p#2=15708, p3#2=47124, p3#2_=p3#2-1, DEG=31416/180"
set "SIN=(t-t*t/1875*t/320000+t*t/1875*t/15625*t/16000*t/2560000-t*t/1875*t/15360*t/15625*t/15625*t/16000*t/44800000)"
set "COS=(10000-t*t/20000+t*t/1875*t/15625*t/819200-t*t/1875*t/15360*t/15625*t/15625*t/10240000+t*t/1875*t/15360*t/15625*t/15625*t/16000*t/15625*t/229376000)"

set /a "wid=75, hei=75, iMax=wid*hei, wid_div_2 = wid / 2 - 3"
color 0c & mode !wid!,!hei!

(for /l %%i in (1 1 !iMax!) do set "scr= !scr!") & set "emp=!scr!"

set /a "buffwid = wid, linesWantBackAbove = hei - 1, cntBS = 2 + (buffwid + 7) / 8 * linesWantBackAbove"

set "BSs=" & for /L %%a in (1 1 !cntBS!) do set "BSs=!BSs!%BS%"
set "aLineBS=" & for /L %%a in (1 1 !wid!) do set "aLineBS=!aLineBS!%BS%"

set /a "XC =10000* wid/2, YC =10000* hei/2, DEG_unit = 3, ddu=1, th0=!random! %% 360 * DEG"

set /a "r=0, x=(XC + r * COSt)/10000, y=(YC + r * SINt)/10000"
set /a "ind_C=x+y*wid+1, lenL_C=ind_C-1"


<nul set /p "=!ESC![!p"
<nul set /p "=!ESC![?25l"

REM ESC [ ? 25 l	DECTCEM	Text Cursor Enable Mode Hide	Hide the cursor

set "erase_last_pin="

for /L %%i in (0 1 5000) do (

    set /a "th=th0+p2+DEG*%%i, DEG_unit+=ddu, DEG_unit= DEG_unit %% 360"

	set /a " th %%= p2, th += th>>31&p2, t=th, s1=(t-p#2^t-p3#2)>>31, s3=p3#2_-t>>31, t=(-t&s1)+(t&~s1)+(p&s1)+(pn2&s3), SINt=%SIN%, t=%COS%, COSt=(-t&s1)+(t&~s1)"

	for /f "tokens=1,2" %%a in ("!lenL_C! !ind_C!") do (set scr=!scr:~0,%%a!*!scr:~%%b!)

   set /a "hue=!random! %% 256"	
	
	set "pin="
	
    for /l %%a in (1 1 !wid_div_2!) do (

        set /a "r=%%a, x=(XC + r * COSt)/10000, y=(YC + r * SINt)/10000, x1=x+1, y1=y+1"
		REM , inScr=(x-0^x-wid)&(y-0^y-hei)

	   %moveCursor:x;y=!x1!;!y1!%

	   
	   REM <nul set /p "=!ESC![38;5;!hue!m@!ESC![0m"
	   
	   set "pin=!pin!!ESC![!x1!;!y1!H!ESC![38;5;!hue!m@"

	   REM %moveCursor:x;y=!lastx!;!lasty!%

	   REM <nul set /p "=!ESC![1X"



        REM if !inScr! lss 0 (
            REM set /a "ind=x+y*wid+1, lenL=ind-1"
            REM for /f "tokens=1,2" %%a in ("!lenL! !ind!") do (set scr=!scr:~0,%%a!*!scr:~%%b!)
        REM )
    )
	
	<nul set /p "=!erase_last_pin!!pin!"
	
	set "erase_last_pin=!pin:@= !"

    REM <nul set /p "=!aLineBS!" & (2>nul echo;%TAB%!BSs!) & <nul set /p "=%BS%"
    REM <nul set /p "=%BS%!scr:~0,-1!" & set "scr=!emp!" & title %%i / 5000
	
   REM <nul set /p "=!ESC![2J"
   
   title %%i / 5000; th=!th!
	
)
>nul pause
exit



