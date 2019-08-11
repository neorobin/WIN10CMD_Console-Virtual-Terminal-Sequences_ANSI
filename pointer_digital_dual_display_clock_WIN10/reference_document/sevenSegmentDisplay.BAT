@echo off & setlocal enableDelayedExpansion & chcp 437 & mode 50,50


rem ----------------------------------------------------------------------------------------------------------------------------
set ^"LF=^

^" Above empty line is required - do not remove
set ^"\n=^^^%LF%%LF%^%LF%%LF%^^"
for /F %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
<nul set /p "=!esc![@25l"

rem %plot% x y 0-255 CHAR
set plot=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
  set "screen=^!screen^!!esc![%%2;%%1H!esc![38;5;%%3m%%~4!esc![0m"%\n%
)) else set args=
set /a "index=0", "n[0]=0x7E", "n[1]=0x30", "n[2]=0x6D", "n[3]=0x79", "n[4]=0x33", "n[5]=0x5B", "n[6]=0x5F", "n[7]=0x70", "n[8]=0x7F", "n[9]=0x7B"
rem ----------------------------------------------------------------------------------------------------------------------------


rem main loop ------------------------------------------------------------------------------------------------------------------
set /a "index=0", "color=10"
:main
 call :sevenSegmentDisplay index color 8 8
 
 rem change index
 set /a "index=(index + 1) %% 10"
 rem create slight delay for visual purposes
 for /l %%a in (1,15,1000000) do rem
 rem display the screen
 <nul set /p "=!screen!" & set "screen="
goto :main
rem ----------------------------------------------------------------------------------------------------------------------------



:sevenSegmentDisplay
 set /a "index=%~1", "posX_1=%~3", "posX_2=%~3 + 1", "posX_3=%~3 + 2", "posX_4=%~3 - 1", "posY_1=%~4", "posY_2=%~4 + 1", "posY_3=%~4 + 2", "posY_4=%~4 + 3", "posY_5=%~4 + 4", "posY_6=%~4 + 5", "posY_7=%~4 + 6"

 for %%i in (!index!) do (
 set /a "a=!%~2! * ((n[%%i] >> 6) & 1)"
 %plot% !posX_1! !posY_1! !a! #
 %plot% !posX_2! !posY_1! !a! #
 set /a "a=!%~2! * ((n[%%i] >> 5) & 1)"
 %plot% !posX_3! !posY_2! !a! #
 %plot% !posX_3! !posY_3! !a! #
 set /a "a=!%~2! * ((n[%%i] >> 4) & 1)"
 %plot% !posX_3! !posY_5! !a! #
 %plot% !posX_3! !posY_6! !a! #
 set /a "a=!%~2! * ((n[%%i] >> 3) & 1)"
 %plot% !posX_1! !posY_7! !a! #
 %plot% !posX_2! !posY_7! !a! #
 set /a "a=!%~2! * ((n[%%i] >> 2) & 1)"
 %plot% !posX_4! !posY_5! !a! #
 %plot% !posX_4! !posY_6! !a! #
 set /a "a=!%~2! * ((n[%%i] >> 1) & 1)"
 %plot% !posX_4! !posY_2! !a! #
 %plot% !posX_4! !posY_3! !a! #
 set /a "a=!%~2! * ((n[%%i] >> 0) & 1)"
 %plot% !posX_1! !posY_4! !a! #
 %plot% !posX_2! !posY_4! !a! #
 )
goto :eof