@echo off & setlocal enabledelayedexpansion
>nul chcp 437

(for /f "delims==" %%a in ('set') do set "%%a=") & set "Path=%SystemRoot%\system32"

for /F %%a in ('echo prompt $E^| cmd') do set "_ESC=%%a"
REM cd /d "%~dp0"
REM call :getASCII219 & rem get ASCII 219 to var _ASCII219
if defined _ASCII219 (
	set "_PEN=%_ASCII219%"
) else (
	set "_PEN=#"
)
set "_PEN_SCALE=*"

set /a "_SIZE=50" & REM Set the size of the clock, recommended from 29 to 100
set /a "_s=(_SIZE-15)>>31, _SIZE=(15&_s)+(_SIZE&~_s)" & REM size lower limit: 15
set /a "_WID=_HEI=_SIZE|1,_R_FACE=_WID/2-1, _R_FACE_SQ=_R_FACE*_R_FACE, _R_FACE_1=_R_FACE-1,_R_FACE_2=_R_FACE-2,_PINLEN_S=_R_FACE-3,_PINLEN_M=_PINLEN_S-1,_PINLEN_H=_PINLEN_S/2+1,_PINLEN_D=_PINLEN_S/2-0"
color 0F & mode !_WID!,!_HEI!
REM color 0F & mode !_WID!,200
set "Path="


set "_SIN=(t-t*t/1875*t/320000+t*t/1875*t/15625*t/16000*t/2560000-t*t/1875*t/15360*t/15625*t/15625*t/16000*t/44800000)"
set "_COS=(10000-t*t/20000+t*t/1875*t/15625*t/819200-t*t/1875*t/15360*t/15625*t/15625*t/10240000+t*t/1875*t/15360*t/15625*t/15625*t/16000*t/15625*t/229376000)"

set /a "_PI=31416, _2PI=2*_PI, _PI#2=_PI/2, _3PI#2=3*_PI/2, _3PI#2_1=_3PI#2-1, _DEG=_PI/180, _6DEG=6*_PI/180, _30DEG=30*_PI/180, _3.6DEG=36*_PI/(180*10)"


set /a "_XCZOOM = 10000 * _WID/2, _XC=_WID/2+1, _YCZOOM = 10000 * _HEI/2, _YC=_HEI/2+1, _TH0=!random! %% 360 * %_DEG%, _TH0=0"
REM set /a "_2XC=(%_XCZOOM%/10000+1)*2, _2YC=(%_YCZOOM%/10000+1)*2"
set /a "_2XC=2*_XC, _2YC=2*_YC"


REM <nul set /p "=%_ESC%[!p"

<nul set /p "=%_ESC%[?25l" & REM _ESC [ ? 25 l	DECTCEM	Text Cursor Enable Mode Hide	Hide the cursor

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: angle of HOUR PIN: 				HH * 30deg + MM * 30deg / 60 + SS * 30deg / 3600
:: 									 = ((HH * 60 + MM) * 60 + SS) * 30deg / 3600
:: 									 = ((HH * 60 + MM) * 60 + SS) * deg / 120
::
:: angle of MINUTE PIN: 			MM * 6deg + SS * 6deg / 60
:: 									 = (MM * 60 + SS) * 6deg / 60
:: 									 = (MM * 60 + SS) * deg / 10
::
:: angle of SECOND PIN: 			SS * 6deg
::     								OR
::									(SS * 100 + DD)	/ 100 * 6deg
::									 = (SS * 100 + DD) * 6deg / 100
::
:: angle of Percentile second PIN: 	DD * 360deg / 100 = DD * 36deg / 10
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

	set "_RGB_SCALE=0;0;255"
	set "_RGB_FACE=255;255;255"
	set "_RGB_D=0;255;0"
	set "_RGB_S=255;0;0"
	set "_RGB_M=100;100;100"
	set "_RGB_H=0;0;0"


set "$erase_last_pin="
set /a "_DENSITY=150,  _SPEED=%_2PI%/_DENSITY, _SPEED=3*%_DEG%, th=_TH0+%_2PI%, _DTH=-_SPEED"

(
	for /f "delims==" %%a in ('set _') do set "%%a="


	set /a "_PINLEN_S=%_R_FACE%-3,_PINLEN_M=_PINLEN_S-1,_PINLEN_H=_PINLEN_S/2+3,_PINLEN_D=_PINLEN_S/4"
	set /a "_HUE_H=0xFF, _HUE_M=0xBB, _HUE_S=0x55, _HUE_D=0x88"
	set "_RGB_D=0;255;0"
	set "_RGB_S=255;0;0"
	set "_RGB_M=100;100;100"
	set "_RGB_H=0;0;0"





	<nul set /p "=%_ESC%[48;2;%_RGB_FACE%m"

	REM gen clock dial: Distance method, quick but not meticulous
	title gen clock dial: Distance method, quick but not meticulous
	for /L %%y in (%_YC% -1 1) do (
		for /L %%x in (1 1 %_XC%) do (
			set /a "_dx=%%x-%_XC%, _dy=%%y-%_YC%, t=_dx*_dx+_dy*_dy-%_R_FACE_SQ%-1"
			if !t! lss 0 (
				set /a "#x_=%_2XC%-%%x, #y_=%_2YC%-%%y"
				set "$pin=%_ESC%[!#x_!;%%yH%_PEN%%_ESC%[%%x;!#y_!H%_PEN%%_ESC%[!#x_!;!#y_!H%_PEN%%_ESC%[%%x;%%yH%_PEN%!$pin!"
			)
		)
		set "$pin=%_ESC%[38;2;%_RGB_FACE%m!$pin!"
		<nul set /p "=!$pin!"
		set "$pin="
	)

	REM gen clock dial: rotary scanning polishing edge
	for /L %%i in (0 1 %_DENSITY%) do (
			set /a "th+=-%_SPEED%, th%%=%_2PI%, t=th+=th>>31&%_2PI%, s1=(t-%_PI#2%^t-%_3PI#2%)>>31, s3=%_3PI#2_1%-t>>31, t=(-t&s1)+(t&~s1)+(%_PI%&s1)+(-%_2PI%&s3), #S=%_SIN%, t=%_COS%, #C=(-t&s1)+(t&~s1),  #x=(%_XCZOOM%+%_R_FACE%*#C)/10000+1, #y=(%_YCZOOM%+%_R_FACE%*#S)/10000+1, #x_=%_2XC%-#x, #y_=%_2YC%-#y"

			set "$pin=%_ESC%[!#x_!;!#y!H%_PEN%%_ESC%[!#x!;!#y_!H%_PEN%%_ESC%[!#x_!;!#y_!H%_PEN%%_ESC%[!#x!;!#y!H%_PEN%!$pin!"

			set "$pin=%_ESC%[38;2;%_RGB_FACE%m!$pin!"
			<nul set /p "=!$pin!"
			set "$pin="
			title gen clock dial: rotary scanning polishing edge %%i / %_DENSITY%
	)
	REM title B !time!
	REM >nul pause


	REM nail up scale
	<nul set /p "=%_ESC%[48;2;%_RGB_FACE%m"
	for /L %%i in (0 1 3) do (
			set /a "r3=%%i %% 3"
			set /a "th=%_PI% - %%i*%_2PI%/12, th%%=%_2PI%, t=th+=th>>31&%_2PI%, s1=(t-%_PI#2%^t-%_3PI#2%)>>31, s3=%_3PI#2_1%-t>>31, t=(-t&s1)+(t&~s1)+(%_PI%&s1)+(-%_2PI%&s3), #S=%_SIN%, t=%_COS%, #C=(-t&s1)+(t&~s1), $x=%_XCZOOM%-#C, $y=%_YCZOOM%-#S"

			for /l %%a in (0 1 %_R_FACE%) do (
				set /a "#x=($x+=#C)/10000+1, #y=($y+=#S)/10000+1, #x_=%_2XC%-#x, #y_=%_2YC%-#y"
				if !r3!==0 (
					if %%a geq %_R_FACE_2% if %%a lss %_R_FACE% (
						set "$pin=%_ESC%[!#x!;!#y!H%_PEN_SCALE%%_ESC%[!#x_!;!#y_!H%_PEN_SCALE%%_ESC%[!#x_!;!#y!H%_PEN_SCALE%%_ESC%[!#x!;!#y_!H%_PEN_SCALE%!$pin!"
					)
				) else (
					if %%a equ %_R_FACE_1% (
						set "$pin=%_ESC%[!#x!;!#y!H%_PEN_SCALE%%_ESC%[!#x_!;!#y_!H%_PEN_SCALE%%_ESC%[!#x_!;!#y!H%_PEN_SCALE%%_ESC%[!#x!;!#y_!H%_PEN_SCALE%!$pin!"				
					)
				)
			)
			set "$pin=%_ESC%[38;2;%_RGB_SCALE%m!$pin!"
			<nul set /p "=!$erase_last_pin!!$pin!"
			set "$pin="
			title nail up scale %%i / 2
	)

	<nul set /p "=%_ESC%[48;2;%_RGB_FACE%m"





	for /L %%i in () do (

		set /a "t=!time:~-1!" & set /a "t ^= z, z ^= t"
		if !t! neq 0 (

			set "tm=!time: =0!" & set /a "SS=1!tm:~6,2!-100, MM=1!tm:~3,2!-100, HH=1!tm:~0,2!-100, DD=1!tm:~-2!-100"

			set /a "th_S=%_PI% - (SS * 100 + DD) * %_6DEG% / 100, th_M=%_PI% - (MM * 60 + SS) * %_DEG% / 10, th_H=%_PI% - ((HH * 60 + MM) * 60 + SS) * %_DEG% / 120, th_D=%_PI% - DD*%_3.6DEG%"

			set /a "th=th_H, th%%=%_2PI%, t=th+=th>>31&%_2PI%, s1=(t-%_PI#2%^t-%_3PI#2%)>>31, s3=%_3PI#2_1%-t>>31, t=(-t&s1)+(t&~s1)+(%_PI%&s1)+(-%_2PI%&s3), #S=%_SIN%, t=%_COS%, #C=(-t&s1)+(t&~s1), $x=%_XCZOOM%-#C, $y=%_YCZOOM%-#S"

			for /l %%a in (0 1 %_PINLEN_H%) do (
				set /a "#x=($x+=#C)/10000+1, #y=($y+=#S)/10000+1"
				set "$pin=%_ESC%[!#x!;!#y!H%_PEN%!$pin!"
			)
			set "$pin=%_ESC%[38;2;!_RGB_H!m!$pin!"


			set /a "th=th_M, th%%=%_2PI%, t=th+=th>>31&%_2PI%, s1=(t-%_PI#2%^t-%_3PI#2%)>>31, s3=%_3PI#2_1%-t>>31, t=(-t&s1)+(t&~s1)+(%_PI%&s1)+(-%_2PI%&s3), #S=%_SIN%, t=%_COS%, #C=(-t&s1)+(t&~s1), $x=%_XCZOOM%-#C, $y=%_YCZOOM%-#S"

			for /l %%a in (0 1 %_PINLEN_M%) do (
				set /a "#x=($x+=#C)/10000+1, #y=($y+=#S)/10000+1"
				set "$pin=%_ESC%[!#x!;!#y!H%_PEN%!$pin!"
			)
			set "$pin=%_ESC%[38;2;!_RGB_M!m!$pin!"


			set /a "th=th_S, th%%=%_2PI%, t=th+=th>>31&%_2PI%, s1=(t-%_PI#2%^t-%_3PI#2%)>>31, s3=%_3PI#2_1%-t>>31, t=(-t&s1)+(t&~s1)+(%_PI%&s1)+(-%_2PI%&s3), #S=%_SIN%, t=%_COS%, #C=(-t&s1)+(t&~s1), $x=%_XCZOOM%-#C, $y=%_YCZOOM%-#S"

			for /l %%a in (0 1 %_PINLEN_S%) do (
				set /a "#x=($x+=#C)/10000+1, #y=($y+=#S)/10000+1"
				set "$pin=%_ESC%[!#x!;!#y!H%_PEN%!$pin!"
			)
			set "$pin=%_ESC%[38;2;!_RGB_S!m!$pin!"


			set /a "th=th_D, th%%=%_2PI%, t=th+=th>>31&%_2PI%, s1=(t-%_PI#2%^t-%_3PI#2%)>>31, s3=%_3PI#2_1%-t>>31, t=(-t&s1)+(t&~s1)+(%_PI%&s1)+(-%_2PI%&s3), #S=%_SIN%, t=%_COS%, #C=(-t&s1)+(t&~s1), $x=%_XCZOOM%-#C, $y=%_YCZOOM%-#S"

			for /l %%a in (0 1 %_PINLEN_D%) do (
				set /a "#x=($x+=#C)/10000+1, #y=($y+=#S)/10000+1"
				set "$pin=%_ESC%[!#x!;!#y!H%_PEN%!$pin!"
			)
			set "$pin=%_ESC%[38;2;!_RGB_D!m!$pin!"


			<nul set /p "=!$erase_last_pin!!$pin!"

			set "$erase_last_pin=!$pin:%_PEN%= !"
			set "$pin="

			title !tm!
		)
	)
)

>nul pause
exit


:getASCII219
call :getASCII219_
>nul copy 219.chr /b + 13.chr /b 219_CR.chr /b
<219_CR.chr set /p "_ASCII219="
REM for %%N in (13 219 219_CR) do del %%N.chr
exit /b
REM end of :getBackSpaceAndASCII219


REM ***
:getASCII219_
setlocal
set ^"genchr=(^
  for %%N in (13 219) do if not exist %%N.chr (^
  makecab /d compress=off /d reserveperdatablocksize=26 /d reserveperfoldersize=%%N 0.tmp %%N.chr ^>nul^&^
  type %%N.chr ^| ((for /l %%n in (1 1 38) do pause)^>nul^&findstr "^^" ^>%%N.temp)^&^
  ^>nul copy /y %%N.temp /a %%N.chr /b^&^
  del %%N.temp^
  )^
)^&^
del 0.tmp^"
for %%N in (13 219) do (del /f /q /a %%N.chr >nul 2>&1)
type nul >0.tmp
cmd /q /v:on /c "%genchr%"
endlocal
exit /b
REM end of :getASCII219_