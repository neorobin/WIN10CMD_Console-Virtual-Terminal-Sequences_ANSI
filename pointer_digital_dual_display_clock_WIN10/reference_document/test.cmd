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