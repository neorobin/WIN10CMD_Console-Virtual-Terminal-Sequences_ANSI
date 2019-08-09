@echo off & setlocal enabledelayedexpansion
chcp 437

(for /f "delims==" %%a in ('set') do set "%%a=") & set "Path=%SystemRoot%\system32"

for /F %%a in ('echo prompt $E^| cmd') do set "_ESC=%%a"

set /a "_WID=75, _HEI=75, _HALF_WID = _WID / 2 - 3"
color 0c & mode !_WID!,!_HEI!
set "Path="


set "_SIN=(t-t*t/1875*t/320000+t*t/1875*t/15625*t/16000*t/2560000-t*t/1875*t/15360*t/15625*t/15625*t/16000*t/44800000)"
set "_COS=(10000-t*t/20000+t*t/1875*t/15625*t/819200-t*t/1875*t/15360*t/15625*t/15625*t/10240000+t*t/1875*t/15360*t/15625*t/15625*t/16000*t/15625*t/229376000)"

set /a "_PI=31416, _2PI=2*_PI, _PI#2=_PI/2, _3PI#2=3*_PI/2, _3PI#2_1=_3PI#2-1, _DEG=_PI/180"


set /a "_XC = 10000 * _WID/2, _YC = 10000 * _HEI/2, _TH0=!random! %% 360 * %_DEG%"


REM <nul set /p "=%_ESC%[!p"

<nul set /p "=%_ESC%[?25l" & REM _ESC [ ? 25 l	DECTCEM	Text Cursor Enable Mode Hide	Hide the cursor


set "$erase_last_pin="
set /a "_SPEED=3*%_DEG%, th=_TH0+%_2PI%, hue=88, _DTH=-_SPEED"

(
	for /f "delims==" %%a in ('set _') do set "%%a="

	for /L %%i in (0 1 500000) do (

		REM set /a "t=!time:~-1!" & set /a "t ^= z, z ^= t"
		REM if !t! neq 0 (

			REM set "tm=!time: =0!" & set "se=1!tm:~6,2!-100"


			set /a "th+=-%_SPEED%+%_2PI%, th%%=%_2PI%, t=th+=th>>31&%_2PI%, s1=(t-%_PI#2%^t-%_3PI#2%)>>31, s3=%_3PI#2_1%-t>>31, t=(-t&s1)+(t&~s1)+(%_PI%&s1)+(-%_2PI%&s3), #S=%_SIN%, t=%_COS%, #C=(-t&s1)+(t&~s1), $x=%_XC%-#C, $y=%_YC%-#S"

			REM set /a "hue=!random! %% 256"

			for /l %%a in (0 1 %_HALF_WID%) do (
				set /a "#x=($x+=#C)/10000+1, #y=($y+=#S)/10000+1"
				set "$pin=%_ESC%[!#x!;!#y!H@!$pin!"
			)
			set "$pin=%_ESC%[38;5;!hue!m!$pin!"

			<nul set /p "=!$erase_last_pin!!$pin!"

			set "$erase_last_pin=!$pin:@= !"
			set "$pin="

			title !tm:~6,2!: %%i / 500000; th=!th!; _DTH=%_DTH%;  {hue=!hue!}
		REM )
	)
)

>nul pause
exit

