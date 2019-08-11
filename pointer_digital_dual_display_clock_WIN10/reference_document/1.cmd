@echo off & setlocal enableDelayedExpansion

call :macros

for /l %%# in () do ( for /l %%s in (1,1,%stars%) do (

		if !z[%%s]! lss 1 (
			set /a "x[%%s]=!random! %% wid", "y[%%s]=!random! %% hei", "z[%%s]=wid"
			set /a "pz[%%s]=z[%%s]"
		)

		2>nul set /a ^
			"z[%%s]-=speed",^
			"sx=(wid/2)+((x[%%s]-(wid/4))-(wid/2))*((((x[%%s]*100)/z[%%s])/10)-(0))/((100)-(0))",^
			"sy=(hei/2)+((y[%%s]-(hei/4))-(hei/2))*((((y[%%s]*100)/z[%%s])/10)-(0))/((100)-(0))",^
			"px=(wid/2)+((x[%%s]-(wid/4))-(wid/2))*((((x[%%s]*100)/pz[%%s])/10)-(0))/((100)-(0))",^
			"py=(hei/2)+((y[%%s]-(hei/4))-(hei/2))*((((y[%%s]*100)/pz[%%s])/10)-(0))/((100)-(0))",^
			"pz[%%s]=z[%%s]"

		%line% px py sx sy %%s
		set "screen=!screen!!$line!"

	)
	<nul set /p "=%esc%[2J!screen!" & set "screen="
)

:macros
(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER =%
)
for /F %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
<nul set /p "=!esc![?25l"

set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "sin=(a=(x * 31416 / 180)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%) / 10000"
set "cos=(a=(15708 - x * 31416 / 180)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%) / 10000"


set /a "hei=wid=100"
mode %wid%,%hei%

set /a "stars=5", "speed=4"
for /l %%a in (1,1,%stars%) do (
	set /a "x[%%a]=!random! %% wid", "y[%%a]=!random! %% hei", "z[%%a]=!random! %% (wid/2) + wid"
	set /a "pz[%%a]=z[%%a]"
)

set line=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-5" %%1 in ("^!args^!") do (%\n%
	if "%%~5" equ "" ( set "hue=255" ) else ( set "hue=%%~5")%\n%
	set "$line=%esc%[38;5;^!hue^!m"%\n%
	set /a "xa=%%~1", "ya=%%~2", "xb=%%~3", "yb=%%~4", "dx=%%~3 - %%~1", "dy=%%~4 - %%~2"%\n%
	if ^^!dy^^! lss 0 ( set /a "dy=-dy", "stepy=-1" ) else ( set "stepy=1" )%\n%
	if ^^!dx^^! lss 0 ( set /a "dx=-dx", "stepx=-1" ) else ( set "stepx=1" )%\n%
	set /a "dx<<=1", "dy<<=1"%\n%
	if ^^!dx^^! gtr ^^!dy^^! (%\n%
		set /a "fraction=dy - (dx >> 1)"%\n%
		for /l %%x in (^^!xa^^!,^^!stepx^^!,^^!xb^^!) do (%\n%
			if ^^!fraction^^! geq 0 set /a "ya+=stepy", "fraction-=dx"%\n%
			set /a "fraction+=dy"%\n%
			set "$line=^!$line^!%esc%[^!ya^!;%%xH?"%\n%
		)%\n%
	) else (%\n%
		set /a "fraction=dx - (dy >> 1)"%\n%
		for /l %%y in (^^!ya^^!,^^!stepy^^!,^^!yb^^!) do (%\n%
			if ^^!fraction^^! geq 0 set /a "xa+=stepx", "fraction-=dy"%\n%
			set /a "fraction+=dx"%\n%
			set "$line=^!$line^!%esc%[%%y;^!xa^!H?"%\n%
		)%\n%
	)%\n%
)) else set args=
goto :eof