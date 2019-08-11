@echo off & setlocal enableDelayedExpansion

mode 160,300

echo;hello world

for /F %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

set /a "hei=50", "wid=50", "heiXwid=hei * wid"
set /a "hue=50"

<nul set /p "=!ESC![38;5;!hue!mhello world!ESC![0m"

<nul set /p "=!ESC![?9h"



<1 set /p "=wait:"

REM <nul set /p "=!ESC![1001;1;1;1;50T"
echo;
echo;hahaha


pause

exit /b



set "moveCursor=<nul set /p "=!ESC![x;yH""
mode con: cols=%wid% lines=%hei%

set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "SIN(x)=(a=(x * 31416 / 180)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%) / 10000"
set "COS(x)=(a=(15708 - x * 31416 / 180)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%) / 10000"

set /a "lastx=1,lasty=1"
for /l %%e in () do (

   set /a "angle+=1", "x=20 * !cos(x):x=5 * angle! * !sin(x):x=angle! + wid / 2", "y=20 * !cos(x):x=5 * angle! * !cos(x):x=angle! + hei / 2"

   %moveCursor:x;y=!x!;!y!%
   set /a "hue=angle / 15 %% 256"
   <nul set /p "=!ESC![38;5;!hue!m@!ESC![0m"

   %moveCursor:x;y=!lastx!;!lasty!%

   REM <nul set /p "=!ESC![1X"


   set /a "lastx=x,lasty=y"
)