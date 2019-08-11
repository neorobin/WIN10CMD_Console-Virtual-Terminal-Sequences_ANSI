@echo off & setlocal enabledelayedexpansion

mode 500,500
set "SIN=(t-t*t/1875*t/320000+t*t/1875*t/15625*t/16000*t/2560000-t*t/1875*t/15360*t/15625*t/15625*t/16000*t/44800000)"
set "COS=(10000-t*t/20000+t*t/1875*t/15625*t/819200-t*t/1875*t/15360*t/15625*t/15625*t/10240000+t*t/1875*t/15360*t/15625*t/15625*t/16000*t/15625*t/229376000)"


set "_SIN=(#-#*#/1875*#/320000+#*#/1875*#/15625*#/16000*#/2560000-#*#/1875*#/15360*#/15625*#/15625*#/16000*#/44800000)"
set "_COS=(10000-#*#/20000+#*#/1875*#/15625*#/819200-#*#/1875*#/15360*#/15625*#/15625*#/10240000+#*#/1875*#/15360*#/15625*#/15625*#/16000*#/15625*#/229376000)"

REM 必要常量, 不直接用字面数值, 让 宏代码 部分更易读; 宏代码中直接用数值代替这些符号常量一样运行
set /a "_PI=31416, _2PI=2*_PI, _PI#2=_PI/2, _3PI#2=3*_PI/2, _3PI#2_1=_3PI#2-1"

set "_SIN(t)=(#=(t) %% %_2PI%, #+=#>>31&%_2PI%, #1=(#-%_PI#2%^#-%_3PI#2%)>>31, #3=%_3PI#2_1%-#>>31, #=(-#&#1)+(#&~#1)+(%_PI%&#1)+(-%_2PI%&#3), %_SIN%)"

set "_COS(t)=(#=(t) %% %_2PI%, #+=#>>31&%_2PI%, #1=(#-%_PI#2%^#-%_3PI#2%)>>31, #3=%_3PI#2_1%-#>>31, #=(-#&#1)+(#&~#1)+(%_PI%&#1)+(-%_2PI%&#3), #=%_COS%, (-#&#1)+(#&~#1))"

set "_SIN(t),_COS(t)=(#=(t) %% %_2PI%, #+=#>>31&%_2PI%, #1=(#-%_PI#2%^#-%_3PI#2%)>>31, #3=%_3PI#2_1%-#>>31, #=(-#&#1)+(#&~#1)+(%_PI%&#1)+(-%_2PI%&#3), #S=%_SIN%, #=%_COS%, #C=(-#&#1)+(#&~#1))"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::	角度映射原理
::
::  map rule: [0,2pi) to [-pi/2, pi/2]
::  
::  angle t in [0,2pi)
::  
::  0 <= t < pi/2       t -> t          in [0, pi/2)
::  
::  not need map
::  
::  
::  pi/2 <= t < 3pi/2   t -> pi-t       in (-pi/2, pi/2]
::  
::  sin(t) = sin(pi-t),    cos(t) = -cos(pi-t)
::  
::  
::  3pi/2 <= t < 2pi    t -> -2pi+t     in [-pi/2, 0)
::  
::  sin(t) = sin(-2pi+t),  cos(t) = cos(-2pi+t)
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



REM 16 test angles in [0, 2Pi) step by Pi/8
set "List=0,3927,7854,11781,15708,19635,23562,27489,31416,35343,39270,43197,47124,51051,54978,58905"
set /a "p=31416, p2=62832, pn2=-62832, p#2=15708, p3#2=47124, p3#2_=p3#2-1"
set R_Sin=
set R_Cos=

for %%a in (%List%) do (

		REM 紧凑版, 未使用完全宏, 角度预处理部分为 sin,cos 共用
        set /a "t=%%a"
        set /a "t%%=p2,s1=(t-p#2^t-p3#2)>>31, s3=p3#2_-t>>31, t=(-t&s1)+(t&~s1)+(p&s1)+(pn2&s3), r1=%SIN%"
        set /a "t=%COS%, r2=(-t&s1)+(t&~s1)"
        set R_Sin=!R_Sin!!r1!,
        set R_Cos=!R_Cos!!r2!,

		REM 完全宏版, 正弦, 余弦独立使用, 各自内含了角度预处理部分
        set /a "th=%%a"
        set /a "r1_new=%_SIN(t):t=th%"
        set /a "r2_new=%_COS(t):t=th%"
        set R_Sin_new=!R_Sin_new!!r1_new!,
        set R_Cos_new=!R_Cos_new!!r2_new!,

		REM 完全宏版, 正弦, 余弦 共用角度预处理部分, 由 #S 返回正弦结果, #C 返回余弦结果
        set /a "%_SIN(t),_COS(t):t=th%"
        set /a "r3=#S"
        set /a "r4=#C"
        set R_Sin_new_1=!R_Sin_new_1!!r3!,
        set R_Cos_new_1=!R_Cos_new_1!!r4!,

)
set R_
pause


exit
R_Cos=10000,9238,7071,3826,0,-3826,-7071,-9238,-10000,-9238,-7071,-3826,0,3826,7071,9238,
R_Sin=0,3827,7071,9239,9999,9239,7071,3827,0,-3827,-7071,-9239,-9999,-9239,-7071,-3827,

R_Cos=10000,9238,7071,3826,0,-3826,-7071,-9238,-10000,-9238,-7071,-3826,0,3826,7071,9238,
R_Sin=0,3827,7071,9239,9999,9239,7071,3827,0,-3827,-7071,-9239,-9999,-9239,-7071,-3827,
Press any key to continue . . .




R_Cos=    10000,9238,7071,3826,0,-3826,-7071,-9238,-10000,-9238,-7071,-3826,0,3826,7071,9238,
R_Cos_new=10000,9238,7071,3826,0,-3826,-7071,-9238,-10000,-9238,-7071,-3826,0,3826,7071,9238,

R_Sin=    0,3827,7071,9239,9999,9239,7071,3827,0,-3827,-7071,-9239,-9999,-9239,-7071,-3827,
R_Sin_new=0,3827,7071,9239,9999,9239,7071,3827,0,-3827,-7071,-9239,-9999,-9239,-7071,-3827,
Press any key to continue . . .


R_Cos=      10000,9238,7071,3826,0,-3826,-7071,-9238,-10000,-9238,-7071,-3826,0,3826,7071,9238,
R_Cos_new=  10000,9238,7071,3826,0,-3826,-7071,-9238,-10000,-9238,-7071,-3826,0,3826,7071,9238,
R_Cos_new_1=10000,9238,7071,3826,0,-3826,-7071,-9238,-10000,-9238,-7071,-3826,0,3826,7071,9238,

R_Sin=      0,3827,7071,9239,9999,9239,7071,3827,0,-3827,-7071,-9239,-9999,-9239,-7071,-3827,
R_Sin_new=  0,3827,7071,9239,9999,9239,7071,3827,0,-3827,-7071,-9239,-9999,-9239,-7071,-3827,
R_Sin_new_1=0,3827,7071,9239,9999,9239,7071,3827,0,-3827,-7071,-9239,-9999,-9239,-7071,-3827,

R_Cos=10000,9238,7071,3826,0,-3826,-7071,-9238,-10000,-9238,-7071,-3826,0,3826,7071,9238,
R_Cos_new=10000,9238,7071,3826,0,-3826,-7071,-9238,-10000,-9238,-7071,-3826,0,3826,7071,9238,
R_Cos_new_1=10000,9238,7071,3826,0,-3826,-7071,-9238,-10000,-9238,-7071,-3826,0,3826,7071,9238,
R_Sin=0,3827,7071,9239,9999,9239,7071,3827,0,-3827,-7071,-9239,-9999,-9239,-7071,-3827,
R_Sin_new=0,3827,7071,9239,9999,9239,7071,3827,0,-3827,-7071,-9239,-9999,-9239,-7071,-3827,
R_Sin_new_1=0,3827,7071,9239,9999,9239,7071,3827,0,-3827,-7071,-9239,-9999,-9239,-7071,-3827,
Press any key to continue . . .






_2PI=62832
_3PI#2=47124
_3PI#2_1=47123
_PI=31416
_PI#2=15708
_SIN=(#-#*#/1875*#/320000+#*#/1875*#/15625*#/16000*#/2560000-#*#/1875*#/15360*#/15625*#/15625*#/16000*#/44800000)
_COS=(10000-#*#/20000+#*#/1875*#/15625*#/819200-#*#/1875*#/15360*#/15625*#/15625*#/10240000+#*#/1875*#/15360*#/15625*#/15625*#/16000*#/15625*#/229376000)





set "
_SIN(t)=(#=(t) %% %_2PI%, #+=#>>31&%_2PI%, #1=(#-%_PI#2%^#-%_3PI#2%)>>31, #3=%_3PI#2_1%-#>>31, #=(-#&#1)+(#&~#1)+(%_PI%&#1)+(-%_2PI%&#3), %_SIN%)"
_SIN(t)=(#=(t) % 62832,   #+=#>>31&62832,  #1=(#-15708^#-47124)>>31,      #3=47123-#>>31,      #=(-#&#1)+(#&~#1)+(31416&#1)+(-62832&#3), (#-#*#/1875*#/320000+#*#/1875*#/15625*#/16000*#/2560000-#*#/1875*#/15360*#/15625*#/15625*#/16000*#/44800000))


set "
_COS(t)=(#=(t) %% %_2PI%, #+=#>>31&%_2PI%, #1=(#-%_PI#2%^#-%_3PI#2%)>>31, #3=%_3PI#2_1%-#>>31, #=(-#&#1)+(#&~#1)+(%_PI%&#1)+(-%_2PI%&#3), #=%_COS%, (-#&#1)+(#&~#1))"
_COS(t)=(#=(t) % 62832,   #+=#>>31&62832,  #1=(#-15708^#-47124)>>31,      #3=47123-#>>31,      #=(-#&#1)+(#&~#1)+(31416&#1)+(-62832&#3),  #=(10000-#*#/20000+#*#/1875*#/15625*#/819200-#*#/1875*#/15360*#/15625*#/15625*#/10240000+#*#/1875*#/15360*#/15625*#/15625*#/16000*#/15625*#/229376000), (-#&#1)+(#&~#1))

        (#=(t) % 62832,   #+=#>>31&62832,  #1=(#-15708^#-47124)>>31,      #3=47123-#>>31,      #=(-#&#1)+(#&~#1)+(31416&#1)+(-62832&#3), #S=(#-#*#/1875*#/320000+#*#/1875*#/15625*#/16000*#/2560000-#*#/1875*#/15360*#/15625*#/15625*#/16000*#/44800000),                          #=(10000-#*#/20000+#*#/1875*#/15625*#/819200-#*#/1875*#/15360*#/15625*#/15625*#/10240000+#*#/1875*#/15360*#/15625*#/15625*#/16000*#/15625*#/229376000), #C=(-#&#1)+(#&~#1))

_SIN(t),_COS(t)=(#=(t) % 62832, #+=#>>31&62832, #1=(#-15708^#-47124)>>31, #3=47123-#>>31, #=(-#&#1)+(#&~#1)+(31416&#1)+(-62832&#3), #S=(#-#*#/1875*#/320000+#*#/1875*#/15625*#/16000*#/2560000-#*#/1875*#/15360*#/15625*#/15625*#/16000*#/44800000),                                 #=(10000-#*#/20000+#*#/1875*#/15625*#/819200-#*#/1875*#/15360*#/15625*#/15625*#/10240000+#*#/1875*#/15360*#/15625*#/15625*#/16000*#/15625*#/229376000), #C=(-#&#1)+(#&~#1))
Press any key to continue . . .





















@echo off & setlocal enabledelayedexpansion
>nul chcp 437
mode 132,300

for /F %%a in ('echo prompt $E^| cmd') do set "_ESC=%%a"

REM ESC [ <y> ; <x> H	CUP	Cursor Position	*Cursor moves to <x>; <y> coordinate within the viewport, where <x> is the column of the <y> line

set /a "x=3,y=7"
set "_PEN=!x!,!y!"

echo;%_ESC%[!y!;!x!H%_PEN%

echo;123456789
pause

exit

set "$=73"

echo;"%~dp0"

for %%$ in (1 5 12) do (

	set /a "tt=3*%%$"
	set tt

)
set

pause