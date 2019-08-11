@echo off & setlocal DISABLEDELAYEDEXPANSION & >nul chcp 437

(for /f "delims==" %%a in ('set') do set "%%a=") & set "Path=%SystemRoot%\system32"

:: for Fifteen-segment display logic
:: The following pattern code is not necessary, just to illustrate the logical principle of the show
::
::  ###   # ### ### # # ### ### ### ### ### ABC
::  # #   #   #   # # # #   #     # # # # # DEF
::  # #   # ### ### ### ### ###   # ### ### GHI
::  # #   # #     #   #   # # #   # # #   # JKL
::  ###   # ### ###   # ### ###   # ### ### MNO

	set "$_A="#A=!!(#-1)""
	set "$_B="#B=(!!(#-1)^&!!(#-4))""
	set "$_C="#C=1""
	set "$_D="#D=(!(#^&3)^|!!(#^&~3))^&!!(#-7)""
REM set "$_E="#E=0""                                    & rem never display
	set "$_F="#F=!!(#-5)^&!!(#-6)""
	set "$_G="#G=!!(#-1)^&!!(#-7)""
	set "$_H="#H=!(!#^|!(#-1)^|!(#-7))""
REM set "$_I="#I=1""									& rem Replaced by C
	set "$_J="#J=~#^&1^&!!(#-4)""
REM set "$_K="#K=0""                                    & rem never display
	set "$_L="#L=!!(#-2)""
	set "$_M="#M=(!!(#-1)^&!!(#-4)^&!!(#-7))""
REM set "$_N="#N=(!!(#-1)^&!!(#-4)^&!!(#-7))""          & rem Replaced by M
REM set "$_O="#O=1""									& rem Replaced by C

@echo off & setlocal enabledelayedexpansion

for /F %%a in ('echo prompt $E^| cmd') do set "_ESC=%%a"

set "_PEN=#"
set "_PEN_SCALE=*"

set /a "_SIZE=51" & REM Set the size of the clock, recommended from 37 to 100

set /a "_WID_FIFTEEN_SEGMENT_DISPLAY_LOW_LIMIT=37"

set /a "_s=(_SIZE-15)>>31, _SIZE=(_WID_FIFTEEN_SEGMENT_DISPLAY_LOW_LIMIT&_s)+(_SIZE&~_s)" & REM size lower limit: 37

set /a "_WID=_HEI=_SIZE|1,_R_FACE=_WID/2-1, _R_FACE_SQ=_R_FACE*_R_FACE, _R_FACE_1=_R_FACE-1,_R_FACE_2=_R_FACE-2"

set /a "_LEFT_FIFTEEN_SEGMENT_DISPLAY=(_WID-_WID_FIFTEEN_SEGMENT_DISPLAY_LOW_LIMIT)/2+1, _TOP_FIFTEEN_SEGMENT_DISPLAY=_WID/2+_R_FACE/4"

color 0F & mode !_WID!,!_HEI!

REM The work that needs "Path" is done, now you can clean it up.
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

set "$erase_last_pin="
set /a "_DENSITY=150,  _SPEED=%_2PI%/_DENSITY, _SPEED=3*%_DEG%, th=_TH0+%_2PI%, _DTH=-_SPEED"

set /a "_DDS_OF_A_DAY=24*60*60*100"

set "_LEFT37DOWN1=%_ESC%[37D%_ESC%[1B"

title pointer_digital_dual_display_clock_WIN10


REM 每 _GAP 帧计算一次 FPS, ! _GAP 必须是不小于 2 的 2的幂
set /a "_GAP=2<<5"

(
	for /f "delims==" %%a in ('set _') do set "%%a="

	set /a "_PIN_LEN_S=%_R_FACE%-3,_PIN_LEN_M=_PIN_LEN_S-1,_PIN_LEN_H=_PIN_LEN_S/2+%_SIZE%/15,_PIN_LEN_D=_PIN_LEN_S/2-0"
	set "_RGB_D=0;255;0"
	set "_RGB_S=255;0;0"
	set "_RGB_M=100;100;100"
	set "_RGB_H=0;0;0"


	<nul set /p "=%_ESC%[48;2;%_RGB_FACE%m"

	REM gen clock dial: Distance method, quick but not meticulous
	REM title gen clock dial: Distance method, quick but not meticulous
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
		REM title gen clock dial: rotary scanning polishing edge %%i / %_DENSITY%
	)

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
			REM title nail up scale %%i / 2
	)

	<nul set /p "=%_ESC%[48;2;%_RGB_FACE%m"


	REM $__=0 用于 在 E 和 K 位 不报错
	REM "#_= " 用于 在 E 和 K 位 让运算式 "S=!S!#!#%%$!" 有值可取
	set "$__=0" & set "#_=0"


	set /a "_cnt=0, $v=0"
	for /L %%i in () do (

		set "tm=!time: =0!" & set /a "SS=1!tm:~6,2!-100, MM=1!tm:~3,2!-100, HH=1!tm:~0,2!-100, DD=1!tm:~-2!-100"

		set /a "th_S=%_PI% - (SS * 100 + DD) * %_6DEG% / 100, th_M=%_PI% - (MM * 60 + SS) * %_DEG% / 10, th_H=%_PI% - ((HH * 60 + MM) * 60 + SS) * %_DEG% / 120, th_D=%_PI% - DD*%_3.6DEG%"

		REM Draw 4 pointers
		for %%K in (D S M H) do (
			set /a "th=th_%%K, th%%=%_2PI%, t=th+=th>>31&%_2PI%, s1=(t-%_PI#2%^t-%_3PI#2%)>>31, s3=%_3PI#2_1%-t>>31, t=(-t&s1)+(t&~s1)+(%_PI%&s1)+(-%_2PI%&s3), #S=%_SIN%, t=%_COS%, #C=(-t&s1)+(t&~s1), $x=%_XCZOOM%-#C, $y=%_YCZOOM%-#S"
			for /l %%a in (0 1 !_PIN_LEN_%%K!) do (
				set /a "#x=($x+=#C)/10000+1, #y=($y+=#S)/10000+1"
				set "$pin=%_ESC%[!#x!;!#y!H%_PEN%!$pin!"
			)
			set "$pin=%_ESC%[38;2;!_RGB_%%K!m!$pin!"
		)

		<nul set /p "=!$erase_last_pin!!$pin!"
		set "$erase_last_pin=!$pin:%_PEN%= !"
		set "$pin="

		REM Fifteen segment display

		set "S=" & set "_0or1=0"
		REM 从上到下 逐次 生成 1~5 行图形

		REM "A B C" "D _ F" "G H I" "J _ L" "M N O"
		REM I 和 O 的逻辑与 C 完全一致, 由 C 代替
		REM N 的逻辑与 M 完全一致, 由 M 代替

		for %%L in ("A B C" "D _ F" "G H C" "J _ L" "M M C") do (
			REM 每行从左到右依次计算并填充各个位置
			for %%d in (0 _ 1 _ : _ 3 _ 4 _ : _ 6 _ 7 _ : _ 9 _ 10) do (
				if "%%d" geq "0" (
					REM 获取数字准备计算 是否 显示
					set "#=!tm:~%%d,1!"

					REM 一个数字位 点 3 个像素宽, 要逐个像素计算 是否 显示
					REM "S=!S!#!#%%$!" :  !#%%$! 的结果是加入一个 0 或者 1,
					REM 在 0 或者 1 前加一个 _ 号, 这个符号不能用作画笔字符, 否则替换可能出错
					REM 为了在后续将这些 0 或者 1, 便于被替换成 空格 或者 画笔字符
					for %%$ in (%%~L) do (
						set /a !$_%%$!
						set "S=!S!_!#%%$!"
					)
				) else if "!_0or1!%%d"=="1:" (
					REM 第 2, 4 行的分隔位
					set "S=!S!%_PEN%"
				) else (
					REM 恒空白位
					set "S=!S! "
				)
			)

			REM 先左移 37 到图形最左边, 再下移一行
			set "S=!S!%_LEFT37DOWN1%"
			set /a "_0or1^=1"
		)
		set "S=!S:_0= !"
		<nul set /p "=%_ESC%[%_TOP_FIFTEEN_SEGMENT_DISPLAY%;%_LEFT_FIFTEEN_SEGMENT_DISPLAY%H!S:_1=%_PEN%!"

		set /a "t=-((_cnt+=1)&(%_GAP%-1))>>31, $$=($u=((HH*60+MM)*60+SS)*100+DD)-$v, $$+=$$>>31&%_DDS_OF_A_DAY%, $$=(~t&$$)+(t&1), FPS=(~t&(100*%_GAP%/$$))+(t&FPS), $v=(~t&$u)+(t&$v)"
		if !t!==0 (
			<nul set /p "=%_ESC%[48;2;0;0;0m%_ESC%[1;1HFPS:!FPS! %_ESC%[48;2;%_RGB_FACE%m"
		)
		REM title !tm! double display B: _cnt=!_cnt!
	)
)

>nul pause
exit
