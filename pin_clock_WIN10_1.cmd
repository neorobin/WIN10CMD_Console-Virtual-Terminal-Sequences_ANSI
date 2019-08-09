@echo off & setlocal enabledelayedexpansion
chcp 437

(for /f "delims==" %%a in ('set') do set "%%a=") & set "Path=%SystemRoot%\system32"

for /F %%a in ('echo prompt $E^| cmd') do set "_ESC=%%a"

set /a "_WID=75, _HEI=75, _PINLEN_S = _WID / 2 - 3, _PINLEN_M = _WID / 2 - 9, _PINLEN_H = _PINLEN_S / 2 + 3,  _PINLEN_D = _PINLEN_S / 2 - 0"
color f0 & mode !_WID!,!_HEI!
set "Path="


set "_SIN=(t-t*t/1875*t/320000+t*t/1875*t/15625*t/16000*t/2560000-t*t/1875*t/15360*t/15625*t/15625*t/16000*t/44800000)"
set "_COS=(10000-t*t/20000+t*t/1875*t/15625*t/819200-t*t/1875*t/15360*t/15625*t/15625*t/10240000+t*t/1875*t/15360*t/15625*t/15625*t/16000*t/15625*t/229376000)"

set /a "_PI=31416, _2PI=2*_PI, _PI#2=_PI/2, _3PI#2=3*_PI/2, _3PI#2_1=_3PI#2-1, _DEG=_PI/180, _6DEG=6*_PI/180, _30DEG=30*_PI/180, _3.6DEG=36*_PI/(180*10)"


set /a "_XC = 10000 * _WID/2, _YC = 10000 * _HEI/2, _TH0=!random! %% 360 * %_DEG%"


REM <nul set /p "=%_ESC%[!p"

<nul set /p "=%_ESC%[?25l" & REM _ESC [ ? 25 l	DECTCEM	Text Cursor Enable Mode Hide	Hide the cursor

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: angle of HOUR PIN: 		HH * 30deg + MM * 30deg / 60 + SS * 30deg / 3600
:: 							 = ((HH * 60 + MM) * 60 + SS) * 30deg / 3600
:: 							 = ((HH * 60 + MM) * 60 + SS) * deg / 120
::
:: angle of MINUTE PIN: 	MM * 6deg + SS * 6deg / 60
:: 							 = (MM * 60 + SS) * 6deg / 60
:: 							 = (MM * 60 + SS) * deg / 10
::
:: angle of SECOND PIN: 	SS * 6deg
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


REM PAUSE

set "$erase_last_pin="
set /a "_SPEED=3*%_DEG%, th=_TH0+%_2PI%, _DTH=-_SPEED"

(
	for /f "delims==" %%a in ('set _') do set "%%a="

	set /a "_PINLEN_S = %_WID% / 2 - 3, _PINLEN_M = %_WID% / 2 - 6, _PINLEN_H = _PINLEN_S / 2 + 3, _PINLEN_D = _PINLEN_S / 4"
	set /a "_HUE_H=0xFF, _HUE_M=0xBB, _HUE_S=0x55, _HUE_D=0x88, "
	set "_RGB_D=0;255;0"
	set "_RGB_S=255;0;0"
	set "_RGB_M=0;0;0"
	set "_RGB_H=0;0;0"

	for /L %%i in () do (

		REM set /a "t=!time:~7,1!" & set /a "t ^= z, z ^= t"
		set /a "t=!time:~-1!" & set /a "t ^= z, z ^= t"
		if !t! neq 0 (

			set "tm=!time: =0!" & set /a "SS=1!tm:~6,2!-100, MM=1!tm:~3,2!-100, HH=1!tm:~0,2!-100, DD=1!tm:~-2!-100"



			set /a "th_S=%_PI% - SS*%_6DEG% + %_2PI%, th_M=%_PI% + %_2PI% - (MM * 60 + SS) * %_DEG% / 10, th_H=%_PI% + %_2PI% - ((HH * 60 + MM) * 60 + SS) * %_DEG% / 120, th_D=%_PI% - DD*%_3.6DEG% + %_2PI%"

			set /a "th=th_H, th%%=%_2PI%, t=th+=th>>31&%_2PI%, s1=(t-%_PI#2%^t-%_3PI#2%)>>31, s3=%_3PI#2_1%-t>>31, t=(-t&s1)+(t&~s1)+(%_PI%&s1)+(-%_2PI%&s3), #S=%_SIN%, t=%_COS%, #C=(-t&s1)+(t&~s1), $x=%_XC%-#C, $y=%_YC%-#S"

			for /l %%a in (0 1 %_PINLEN_H%) do (
				set /a "#x=($x+=#C)/10000+1, #y=($y+=#S)/10000+1"
				set "$pin=%_ESC%[!#x!;!#y!H@!$pin!"
			)
			set "$pin=%_ESC%[38;2;!_RGB_H!m!$pin!"


			set /a "th=th_M, th%%=%_2PI%, t=th+=th>>31&%_2PI%, s1=(t-%_PI#2%^t-%_3PI#2%)>>31, s3=%_3PI#2_1%-t>>31, t=(-t&s1)+(t&~s1)+(%_PI%&s1)+(-%_2PI%&s3), #S=%_SIN%, t=%_COS%, #C=(-t&s1)+(t&~s1), $x=%_XC%-#C, $y=%_YC%-#S"

			for /l %%a in (0 1 %_PINLEN_M%) do (
				set /a "#x=($x+=#C)/10000+1, #y=($y+=#S)/10000+1"
				set "$pin=%_ESC%[!#x!;!#y!H@!$pin!"
			)
			set "$pin=%_ESC%[38;2;!_RGB_M!m!$pin!"


			set /a "th=th_S, th%%=%_2PI%, t=th+=th>>31&%_2PI%, s1=(t-%_PI#2%^t-%_3PI#2%)>>31, s3=%_3PI#2_1%-t>>31, t=(-t&s1)+(t&~s1)+(%_PI%&s1)+(-%_2PI%&s3), #S=%_SIN%, t=%_COS%, #C=(-t&s1)+(t&~s1), $x=%_XC%-#C, $y=%_YC%-#S"

			for /l %%a in (0 1 %_PINLEN_S%) do (
				set /a "#x=($x+=#C)/10000+1, #y=($y+=#S)/10000+1"
				set "$pin=%_ESC%[!#x!;!#y!H@!$pin!"
			)
			set "$pin=%_ESC%[38;2;!_RGB_S!m!$pin!"


			set /a "th=th_D, th%%=%_2PI%, t=th+=th>>31&%_2PI%, s1=(t-%_PI#2%^t-%_3PI#2%)>>31, s3=%_3PI#2_1%-t>>31, t=(-t&s1)+(t&~s1)+(%_PI%&s1)+(-%_2PI%&s3), #S=%_SIN%, t=%_COS%, #C=(-t&s1)+(t&~s1), $x=%_XC%-#C, $y=%_YC%-#S"

			for /l %%a in (0 1 %_PINLEN_D%) do (
				set /a "#x=($x+=#C)/10000+1, #y=($y+=#S)/10000+1"
				set "$pin=%_ESC%[!#x!;!#y!H@!$pin!"
			)
			set "$pin=%_ESC%[38;2;!_RGB_D!m!$pin!"






			<nul set /p "=!$erase_last_pin!!$pin!"

			set "$erase_last_pin=!$pin:@= !"
			set "$pin="

			title !tm!: th=!th!; _DTH=%_DTH%;  {_HUE_S=!_HUE_S!}
		)
	)
)

>nul pause
exit

