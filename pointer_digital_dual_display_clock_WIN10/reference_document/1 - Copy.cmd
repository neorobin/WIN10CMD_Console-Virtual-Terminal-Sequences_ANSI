@echo off
setlocal EnableDelayedExpansion

if "%~1" neq "" goto %1

rem Original code written by neorobin
rem http://www.dostips.com/forum/viewtopic.php?f=3&t=7153&p=49643#p49643

rem This "Lines in color" version created by Antonio Perez Ayala, aka Aacini
rem Use PowerShell to move cursor and show text in color as described at:
rem http://www.dostips.com/forum/viewtopic.php?f=3&t=6936&p=46206#p46206

rem Screen size
set /a "wid=75, hei=75"
mode %wid%,%hei%
cls

echo/
echo   ?   ?   ?????   ???   ?????
echo   ?   ?   ?   ?    ?      ?
echo   ? ? ?   ?????    ?      ?
echo   ?? ??   ?   ?    ?      ?
echo   ?   ?   ?   ?   ???     ?    ?   ?   ?


"%~F0" Main  |  "%~F0" Output
goto :EOF


:Main

(
for /f "delims==" %%a in ('set') do set "%%a="
set /A "wid=%wid%, hei=%hei%"
)

REM APA Define the number of branches (colors) in the spiral as function of the angle in degrees:
REM APA Center:   60       72       90        120       (180)       240        270        288        300        330
REM APA 0-29=1, 30-65=6, 66-80=5, 81-104=4, 105-149=3, 150-210=2, 211-255=3, 256-279=4, 280-294=5, 295-330=6, 331-360=1
set n=0
for %%a in (30:6 66:5 81:4 105:3 150:2 211:3 256:4 280:5 295:6 331:1) do for /F "tokens=1,2 delims=:" %%x in ("%%a") do (
   set "deg!n!=%%x"
   set "cols!n!=%%y"
   set /A n+=1
)
set /A "c=0, cols=1"

REM APA mod                                    Original: DEG=174, Modified: DEG=17453 (DEG * 100)
set /a "p=31416, p2=62832, pn2=-62832, p#2=15708, p3#2=47124, p3#2_=p3#2-1, DEG=3141593/180"
set "SIN=(t-(t2=t*t/1875)*t/320000+(t3=t2*t/15625)*t/16000*t/2560000-(t4=t3*t/15625*t/15360)*t/16000*t/44800000)"
set "COS=(10000-t*t/20000+t3*t/819200-t4*t/10240000+t4*t/16000*t/15625*t/229376000)"

set /a "wid_div_2 = wid / 2 - 3"

REM APA randomize:
for /L %%i in (1,1,%time:~-1%) do set /A !random!

set /a "XC = wid/2*10000, YC = hei/2*10000, DEG_unit = -1, th0=%random% %% 360 * DEG"

REM APA  The screen is managed via these 3 variables:
REM APA  scr2 - New points that needs to be displayed on the screen
REM APA  scr0 - Old points that needs to be cleared from the screen
REM APA  scr1 - Auxiliary buffer: it always contain the points that currently appears on the screen
set "scr1= "

for /L %%# in () do (

   set "scr0=!scr1!"
   set "scr2="

   set /a "th0 += DEG, th = th0, DEG_unit= (DEG_unit+1) %% 360,  chg=^!(DEG_unit-deg!c!), col=-1"
   if !chg! equ 1 set /A "cols=cols!c!, c=(c+1) %% n"
    
   for /L %%r in (0 1 %wid_div_2%) do (
      set /a "th+=DEG * DEG_unit, t= th/100 %% p2, s1=(t-p#2^t-p3#2)>>31, s3=p3#2_-t>>31, t=(-t&s1)+(t&~s1)+(p&s1)+(pn2&s3), SINt=%SIN%, t=%COS%, COSt=(-t&s1)+(t&~s1)"
      set /a "x=(XC + %%r * COSt)/10000, y=(YC + %%r * SINt)/10000, inScr=(x-0^x-wid)&(y-0^y-hei),  col=(col+1) %% cols, co=15-col"

      if !inScr! lss 0 (
         for /F "tokens=1,2" %%x in ("!x! !y!") do (
            if "!scr1: %%x:%%y:0=!" equ "!scr1!" (
               set "scr1=!scr1! %%x:%%y:0"
               set "scr2=!scr2! %%x:%%y:!co!"
            )
            set "scr0=!scr0: %%x:%%y:0=!"
         )
      )

   )

   if "!scr0!" neq " " (
      for %%a in (!scr0!) do set "scr1=!scr1: %%a=!"
      echo !scr0:~2!
   )
   echo !scr2:~1!

)
exit


:Output

rem The parameters received via lines read have this form:
rem Series of points, coordinates and color: X1:Y1:C1 X2:Y2:C2 ...

PowerShell  ^
   cls;  ^
   $console = $Host.UI.RawUI;  ^
   $console.WindowTitle = 'Spiral in color';  ^
   $console.CursorSize = 0;  ^
   $coords = $console.CursorPosition;  ^
   foreach ( $line in $input ) {  ^
      $point,$line = $line.Split(' ');  ^
      while ( $point ) {  ^
         [int]$X,[int]$Y,[int]$Color = $point.Split(':');  ^
         $coords.X = $X;  $coords.Y = $Y;  $console.CursorPosition = $coords;  ^
         Write-Host -ForegroundColor $Color -NoNewLine '?';  ^
         $point,$line = $line;  ^
      }  ^
   }
%End PowerShell%
exit /B