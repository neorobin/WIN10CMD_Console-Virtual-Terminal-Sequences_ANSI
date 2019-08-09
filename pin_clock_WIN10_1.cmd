@echo off & setlocal enabledelayedexpansion

chcp 437

set "Path=%SystemRoot%\system32" & for /f "delims==" %%a in ('set') do if /i "%%a" neq "Path" set "%%a="

for /F %%a in ('echo prompt $E^| cmd') do set "_ESC=%%a"

set /a "_PI=31416, _2PI=2*_PI, _PI#2=_PI/2, _3PI#2=3*_PI/2, _3PI#2_1=_3PI#2-1, _DEG=_PI/180"
set "_SIN=(t-t*t/1875*t/320000+t*t/1875*t/15625*t/16000*t/2560000-t*t/1875*t/15360*t/15625*t/15625*t/16000*t/44800000)"
set "_COS=(10000-t*t/20000+t*t/1875*t/15625*t/819200-t*t/1875*t/15360*t/15625*t/15625*t/10240000+t*t/1875*t/15360*t/15625*t/15625*t/16000*t/15625*t/229376000)"

set /a "_WID=75, _HEI=75, _iMax=_WID*_HEI, _HALF_WID = _WID / 2 - 3"
color 0c & mode !_WID!,!_HEI!

REM (for /l %%i in (1 1 !_iMax!) do set "scr= !scr!") & set "emp=!scr!"

REM set /a "buffwid = _WID, linesWantBackAbove = _HEI - 1, cntBS = 2 + (buffwid + 7) / 8 * linesWantBackAbove"

REM set "BSs=" & for /L %%a in (1 1 !cntBS!) do set "BSs=!BSs!%BS%"
REM set "aLineBS=" & for /L %%a in (1 1 !_WID!) do set "aLineBS=!aLineBS!%BS%"

set /a "_XC =10000* _WID/2, _YC =10000* _HEI/2, _TH0=!random! %% 360 * %_DEG%"


<nul set /p "=%_ESC%[!p"
<nul set /p "=%_ESC%[?25l"

REM _ESC [ ? 25 l	DECTCEM	Text Cursor Enable Mode Hide	Hide the cursor

set "_erase_last_pin="

set /a "th=_TH0+%_2PI%, _DTH=-%_DEG%"



REM set /a "hue=88"

(
	for /f "delims==" %%a in ('set _') do set "%%a="
	SET "PATH="
	SET
	
	for /L %%i in (0 1 500000) do (
		set "_pin="

		set /a "th+=-%_DEG%+%_2PI%, th %%= %_2PI%, th += th>>31&%_2PI%, t=th, s1=(t-%_PI#2%^t-%_3PI#2%)>>31, s3=%_3PI#2_1%-t>>31, t=(-t&s1)+(t&~s1)+(%_PI%&s1)+(-%_2PI%&s3), #S=%_SIN%, t=%_COS%, #C=(-t&s1)+(t&~s1), $x=%_XC%-#C, $y=%_YC%-#S"

		set /a "hue=!random! %% 256"

		for /l %%a in (0 1 %_HALF_WID%) do (
			set /a "#x=($x+=#C)/10000+1, #y=($y+=#S)/10000+1"
			set "_pin=!_pin!%_ESC%[!#x!;!#y!H%_ESC%[38;5;!hue!m@"
		)

		<nul set /p "=!_erase_last_pin!!_pin!"

		set "_erase_last_pin=!_pin:@= !"

		title %%i / 500000; th=!th!; _DTH=%_DTH%;  {hue=!hue!}

		REM SET
		REM PAUSE
	)
)

>nul pause
exit

