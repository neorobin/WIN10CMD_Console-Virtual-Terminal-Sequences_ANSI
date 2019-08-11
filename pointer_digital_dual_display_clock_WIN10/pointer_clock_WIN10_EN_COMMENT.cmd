::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::  Pointer Clock
::
::  pointer_clock_WIN10.cmd
::
::  author: neorobin ver: 20190811_222058
::
::  https://github.com/neorobin/WIN10CMD_Console-Virtual-Terminal-Sequences_ANSI/blob/master/pointer_digital_dual_display_clock_WIN10/pointer_clock_WIN10.cmd
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off & setlocal enabledelayedexpansion
>nul chcp 437

(for /f "delims==" %%a in ('set') do set "%%a=") & set "Path=%SystemRoot%\system32"

for /F %%a in ('echo prompt $E^| cmd') do set "_ESC=%%a"

set "_PEN=#"
set "_PEN_SCALE=*"

set /a "_SIZE=51" & REM Set the size of the clock, recommended from 37 to 100

set /a "_LOW_LIMIT_OF_WIDTH_OF_FIFTEEN_SEGMENT_DISPLAY=37"

set /a "_s=(_SIZE-15)>>31, _SIZE=(_LOW_LIMIT_OF_WIDTH_OF_FIFTEEN_SEGMENT_DISPLAY&_s)+(_SIZE&~_s)" & REM size lower limit: 37

set /a "_WID=_HEI=_SIZE|1,_R_FACE=_WID/2-1, _R_FACE_SQ=_R_FACE*_R_FACE, _R_FACE_1=_R_FACE-1,_R_FACE_2=_R_FACE-2"

set /a "_LEFT_FIFTEEN_SEGMENT_DISPLAY=(_WID-_LOW_LIMIT_OF_WIDTH_OF_FIFTEEN_SEGMENT_DISPLAY)/2+1, _TOP_FIFTEEN_SEGMENT_DISPLAY=_WID/2+_R_FACE/4"

color 0F & mode %_WID%,%_HEI%

REM The work that needs "Path" is done, now you can clean it up.
set "Path="

set "_SIN=(#-#*#/1875*#/320000+#*#/1875*#/15625*#/16000*#/2560000-#*#/1875*#/15360*#/15625*#/15625*#/16000*#/44800000)"
set "_COS=(10000-#*#/20000+#*#/1875*#/15625*#/819200-#*#/1875*#/15360*#/15625*#/15625*#/10240000+#*#/1875*#/15360*#/15625*#/15625*#/16000*#/15625*#/229376000)"

REM Angle constants, not directly using literal values, making macro code definitions more readable
set /a "_PI=31416, _2PI=2*_PI, _PI#2=_PI/2, _3PI#2=3*_PI/2, _3PI#2_1=_3PI#2-1"

set "_SIN(t)=(#=(t) %% %_2PI%, #+=#>>31&%_2PI%, #1=(#-%_PI#2%^#-%_3PI#2%)>>31, #3=%_3PI#2_1%-#>>31, #=(-#&#1)+(#&~#1)+(%_PI%&#1)+(-%_2PI%&#3), %_SIN%)"

set "_COS(t)=(#=(t) %% %_2PI%, #+=#>>31&%_2PI%, #1=(#-%_PI#2%^#-%_3PI#2%)>>31, #3=%_3PI#2_1%-#>>31, #=(-#&#1)+(#&~#1)+(%_PI%&#1)+(-%_2PI%&#3), #=%_COS%, (-#&#1)+(#&~#1))"

set "_SIN(t),_COS(t)=(#=(t) %% %_2PI%, #+=#>>31&%_2PI%, #1=(#-%_PI#2%^#-%_3PI#2%)>>31, #3=%_3PI#2_1%-#>>31, #=(-#&#1)+(#&~#1)+(%_PI%&#1)+(-%_2PI%&#3), #S=%_SIN%, #=%_COS%, #C=(-#&#1)+(#&~#1))"

set /a "_DEG=_PI/180, _6DEG=6*_PI/180, _30DEG=30*_PI/180, _3.6DEG=36*_PI/(180*10)"

set /a "_XCZOOM = 10000 * _WID/2, _XC=_WID/2+1, _YCZOOM = 10000 * _HEI/2, _YC=_HEI/2+1, _TH0=-_PI#2"

set /a "_2XC=2*_XC, _2YC=2*_YC"

<nul set /p "=%_ESC%[?25l" & REM ESC [ ? 25 l  DECTCEM   Text Cursor Enable Mode Hide  Hide the cursor

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: angle of HOUR PIN:           HH * 30deg + MM * 30deg / 60 + SS * 30deg / 3600
::                              = ((HH * 60 + MM) * 60 + SS) * 30deg / 3600
::                              = ((HH * 60 + MM) * 60 + SS) * deg / 120
::
:: angle of MINUTE PIN:         MM * 6deg + SS * 6deg / 60
::                              = (MM * 60 + SS) * 6deg / 60
::                              = (MM * 60 + SS) * deg / 10
::
:: angle of SECOND PIN:         SS * 6deg
::                              OR
::                              (SS * 100 + CC)    / 100 * 6deg
::                              = (SS * 100 + CC) * 6deg / 100
::
:: angle of CENTISECOND PIN:    CC * 360deg / 100 = CC * 36deg / 10
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set "_RGB_SCALE=0;0;255"
set "_RGB_FACE=255;255;255"

set "$erase_last_pin="
set /a "_DENSITY=150, _SPEED=3*%_DEG%, th=_TH0"

set /a "_CENTISECONDS_OF_A_DAY=24*60*60*100"

set "_LEFT37DOWN1=%_ESC%[37D%_ESC%[1B"

REM Calculate FPS once per _GAP frame, ! _GAP must be a power of 2, and not less than 2
set /a "_GAP=2<<5"

(
    for /f "delims==" %%a in ('set _') do set "%%a="

    set /a "_PIN_LEN_S=%_R_FACE%-3,_PIN_LEN_M=_PIN_LEN_S-1,_PIN_LEN_H=_PIN_LEN_S/2+%_SIZE%/15,_PIN_LEN_C=_PIN_LEN_S/4-0"
    set "_RGB_C=0;255;0"
    set "_RGB_S=255;0;0"
    set "_RGB_M=100;100;100"
    set "_RGB_H=0;0;0"

    <nul set /p "=%_ESC%[48;2;%_RGB_FACE%m"

    REM gen clock dial: Distance method, quick but not meticulous
    for /L %%x in (%_XC% -1 1) do (
        for /L %%y in (%_YC% -1 1) do (
            set /a "_dx=%%x-%_XC%, _dy=%%y-%_YC%, t=_dx*_dx+_dy*_dy-%_R_FACE_SQ%-1"
            if !t! lss 0 (
                set /a "#x_=%_2XC%-%%x, #y_=%_2YC%-%%y"
                set "$pin=%_ESC%[%%y;!#x_!H%_PEN%%_ESC%[!#y_!;%%xH%_PEN%%_ESC%[!#y_!;!#x_!H%_PEN%%_ESC%[%%y;%%xH%_PEN%!$pin!"
            )
        )
        set "$pin=%_ESC%[38;2;%_RGB_FACE%m!$pin!"
        <nul set /p "=!$pin!"
        set "$pin="
    )

    REM gen clock dial: rotary scanning polishing edge
    for /L %%i in (0 1 %_DENSITY%) do (

        set /a "th+=%_SPEED%, %_SIN(t),_COS(t):t=th%, #x=(%_XCZOOM%+%_R_FACE%*#C)/10000+1, #y=(%_YCZOOM%+%_R_FACE%*#S)/10000+1, #x_=%_2XC%-#x, #y_=%_2YC%-#y"

        set "$pin=%_ESC%[!#y!;!#x_!H%_PEN%%_ESC%[!#y_!;!#x!H%_PEN%%_ESC%[!#y_!;!#x_!H%_PEN%%_ESC%[!#y!;!#x!H%_PEN%!$pin!"

        set "$pin=%_ESC%[38;2;%_RGB_FACE%m!$pin!"
        <nul set /p "=!$pin!"
        set "$pin="
    )

    REM nail up scale
    <nul set /p "=%_ESC%[48;2;%_RGB_FACE%m"
    for /L %%i in (0 1 3) do (
        set /a "r3=%%i %% 3"

        set /a "th=-%_PI#2% + %%i*%_2PI%/12, %_SIN(t),_COS(t):t=th%, $x=%_XCZOOM%-#C, $y=%_YCZOOM%-#S"

        for /l %%a in (0 1 %_R_FACE%) do (
            set /a "#x=($x+=#C)/10000+1, #y=($y+=#S)/10000+1, #x_=%_2XC%-#x, #y_=%_2YC%-#y"
            if !r3!==0 (
                if %%a geq %_R_FACE_2% if %%a lss %_R_FACE% (
                    set "$pin=%_ESC%[!#y!;!#x!H%_PEN_SCALE%%_ESC%[!#y_!;!#x_!H%_PEN_SCALE%%_ESC%[!#y!;!#x_!H%_PEN_SCALE%%_ESC%[!#y_!;!#x!H%_PEN_SCALE%!$pin!"
                )
            ) else (
                if %%a equ %_R_FACE_1% (
                    set "$pin=%_ESC%[!#y!;!#x!H%_PEN_SCALE%%_ESC%[!#y_!;!#x_!H%_PEN_SCALE%%_ESC%[!#y!;!#x_!H%_PEN_SCALE%%_ESC%[!#y_!;!#x!H%_PEN_SCALE%!$pin!"
                )
            )
        )
        set "$pin=%_ESC%[38;2;%_RGB_SCALE%m!$pin!"
        <nul set /p "=!$erase_last_pin!!$pin!"
        set "$pin="
    )

    <nul set /p "=%_ESC%[48;2;%_RGB_FACE%m"

    set /a "_cnt=0, $v=0"
    for /L %%i in () do (

        set "tm=!time: =0!" & set /a "SS=1!tm:~6,2!-100, MM=1!tm:~3,2!-100, HH=1!tm:~0,2!-100, CC=1!tm:~-2!-100"

        set /a "th_S=-%_PI#2% + (SS * 100 + CC) * %_6DEG% / 100, th_M=-%_PI#2% + (MM * 60 + SS) * %_DEG% / 10, th_H=-%_PI#2% + ((HH * 60 + MM) * 60 + SS) * %_DEG% / 120, th_C=-%_PI#2% + CC*%_3.6DEG%"

        REM Draw 4 pointers
        for %%K in (C S M H) do (

            set /a "th=th_%%K, %_SIN(t),_COS(t):t=th%, $x=%_XCZOOM%-#C, $y=%_YCZOOM%-#S"

            for /l %%a in (0 1 !_PIN_LEN_%%K!) do (
                set /a "#x=($x+=#C)/10000+1, #y=($y+=#S)/10000+1"
                set "$pin=%_ESC%[!#y!;!#x!H%_PEN%!$pin!"
            )
            set "$pin=%_ESC%[38;2;!_RGB_%%K!m!$pin!"
        )

        <nul set /p "=!$erase_last_pin!!$pin!"
        set "$erase_last_pin=!$pin:%_PEN%= !"
        set "$pin="

        title !tm! pointer_clock_WIN10

        set /a "t=-((_cnt+=1)&(%_GAP%-1))>>31, $$=($u=((HH*60+MM)*60+SS)*100+CC)-$v, $$+=$$>>31&%_CENTISECONDS_OF_A_DAY%, $$=(~t&$$)+(t&1), FPS=(~t&(100*%_GAP%/$$))+(t&FPS), $v=(~t&$u)+(t&$v)"
        if !t!==0 (
            <nul set /p "=%_ESC%[48;2;0;0;0m%_ESC%[1;1HFPS:!FPS! %_ESC%[48;2;%_RGB_FACE%m"
        )
    )
)

>nul pause
exit
