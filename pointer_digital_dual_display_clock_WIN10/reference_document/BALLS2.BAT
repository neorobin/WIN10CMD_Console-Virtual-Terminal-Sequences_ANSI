@echo off
if "%~1"=="RUN" goto :run
if "%~1"=="LOOP" goto :loop
setlocal enableDelayedExpansion

:::
:::BALLS2.BAT  [/Option [Value]]...
:::
:::  /B Balls  - Ball count     (default 5)
:::  /H Height - screen Height  (default 50)
:::  /W Width  - screen Width   (default 100)
:::  /T cSec   - min frame Time (default 0)
:::  /X Char   - piXel char     (default @)
:::  /C ColorBitCount - 4,8,24  (default 4)
:::  /G - color Gradient
:::  /S - Solid balls
:::  /P - Pause after each frame refresh
:::  /D - Debug mode
:::  /? - Help
:::

:: Define options
set "options= -?: -S: -P: -D: -G: -H:50 -W:100 -B:5 -C:4 -X:"@" -T:0 "

:: Set default option values
for %%O in (%options%) do for /f "tokens=1* delims=:" %%A in ("%%O") do set "%%A=%%~B"

:: Get options
:optionLoop
if not "%~1"=="" (
  set "arg=%~1"
  if "!arg:~0,1!" equ "/" set "arg=-!arg:~1!"
  for /f delims^=^ eol^= %%A in ("!arg!") do set "test=!options:*%%A:=! "
  if "!test!"=="!options! " (
      >&2 echo Error: Invalid option %~1. Use %~nx0 -? to get help.
      exit /b 1
  ) else if "!test:~0,1!"==" " (
      set "!arg!=1"
      if /i "!arg!" equ "-U" set "-z="
  ) else (
      set "!arg!=%~2"
      shift /1
  )
  shift /1
  goto :optionLoop
)

if defined -? (
  if not defined -D mode 50,25
  for /f "delims=: tokens=*" %%A in ('findstr "^:::" "%~f0"') do echo(%%A
  exit /b
)

:: Validate options and configure
set /a "ballCnt=4, ballCnt=%-B%-1" 2>nul
set /a "ht=50, ht=%-H%" 2>nul
set /a "wd=100, wd=%-W%" 2>nul
set /a "delay=0, delay=%-T%" 2>nul
set "validColorBits= 4 8 24 "
if "!validColorbits:%-C%=!" equ "!validColorBits!" set "-C=4"
if %ballCnt% lss 0 set "ballCnt=0"
if defined -X (set "-X=!-X:~0,1!") else set "-X=@"
if "!-X!"==" " set "-X=@"
if %ht% lss 20 set "ht=20"
if %wd% lss 20 set "wd=20"
if %ht% gtr 400 set "ht=400"
if %wd% gtr 400 set "wd=400"
for /F %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
if defined -D set "ESC=E"
if %-C%==4 (
  set "pixelLen=6"
  set "blankPixel=!esc![00m "
)
if %-C%==8 (
  set "pixelLen=12"
  set "blankPixel=!esc![38,5,000m "
)
if %-C%==24 (
  set "pixelLen=20"
  set "blankPixel=!esc![38,2,000;000;000m "
)

if not defined -D mode %wd%,%ht%
set /a wd-=1, ht-=1

set "blankLine="
for /l %%x in (0 1 !wd!) do set "blankLine=!blankLine!!blankPixel!"
if defined -D set blankLine

:: ---- Define macros ----
(set LF=^
%= Empty line generates linefeed =%
)
set ^"\n=^^^%LF%%LF%^%LF%%LF%^^"

:: plot  x  y  coordList
set plot=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-3" %%1 in ("^!args^!") do (%\n%
  for %%C in (^^!%%3^^!) do for /f "tokens=1-4" %%a in (%%C) do (%\n%
    set /a "x=%%a*pixelLen+%%1*pixelLen, y=%%b+%%2, z=x+%%d"%\n%
    for /f "tokens=1-3" %%x in ("^!x^! ^!y^! ^!z^!") do set "ln%%y=^!ln%%y:~0,%%x^!%%c^!ln%%y:~%%z^!"%\n%
  )%\n%
)) else set args=
if defined -D set plot

if %delay% gtr 0 (
  set "compute=1"
  set "t1=0"
  set "initDelay=if defined compute ("
  set openDelay=set compute=^)%\n%
    for /f "tokens=1-4 delims=:.," %%a in ("^!time: =0^!"^) do set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, tDiff=t2-t1"%\n%
    if ^^!tDiff^^! lss 0 set /a tDiff+=24*60*60*100%\n%
    if ^^!tDiff^^! geq !delay! (
  set "closeDelay=set compute=1&set t1=^!t2^!)"
) else (
  set "initDelay="
  set "openDelay="
  set "closeDelay="
)

if defined -P (set "pause=pause >nul <con") else set "pause="
:: ---- End macros ----

:: Build list of relative pixel coordinates for all possible circle sizes - 2,3,4
:: Each circleN is a string in the format '"x1 y1" "x2 y2" ... "xn yn"'
:: 0 is the center of the circle
for /l %%s in (2 1 4) do (
  %== Build CircleN ==%
  set "circle%%s="
  for /l %%y in (-%%s,1,%%s) do for /l %%x in (-%%s,1,%%s) do (
    set /a "s=%%x*%%x+%%y*%%y-%%s*%%s, _3div2=%%s/2"
    if defined -S ( %== solid ball ==%
      if !s! leq 1 (set circle%%s=!circle%%s! "%%x %%y")
    ) else (        %== outline ball ==%
      if !s! geq -%%s if !s! leq !_3div2! (set circle%%s=!circle%%s! "%%x %%y")
    )
  )
)

::  Build Yes and No files using local language
if not exist "%~f0.yes" (
  for /f "delims=(/ tokens=2,3" %%A in (
    'copy /-y nul "%~f0" ^<nul'
  ) do if not exist "%~f0.yes" (
    >"%~f0.yes" echo %%A
    >"%~f0.no"  echo %%B
  )
)

:: Initialize balls
for /l %%B in (0,1,%ballCnt%) do 2>nul (
  set /a "x%%B=!random! %% (wd-10) + 10"          %= x pos (col) =%
  set /a "y%%B=!random! %% (ht-10) + 10"          %= y pos (row) =%
  set /a "i%%B=(!random!%%3+1)*(1-!random!%%2*2)" %= x delta (speed & angle) =%
  set /a "j%%B=(!random!%%2+1)*(1-!random!%%2*2)" %= y delta (speed & angle) =%
  set /a "s%%B=!random! %% 3 + 2"                 %= size =%
  set /a "t%%B=s%%B + 1"                          %= screen top edge =%
  set /a "l%%B=s%%B + 1"                          %= screen left edge =%
  set /a "b%%B=ht - s%%B"                         %= screen bottom edge =%
  set /a "r%%B=wd - s%%B"                         %= screen right edge =%

  %== Build each ball "sprite" by adding color and pixel character to each coordinate pair in circleN ==%  
  set /a "priorX=100, priorY=100, len=0"
  set "ball%%B="
  if defined -G ( %======= Color Gradient ======%
    if %-C% ==  4 (  %==  4 bit color ==%
      set /a "c%%B=31+!random!%%7"
      for %%S in (!s%%B!) do for %%C in (!circle%%S!) do for /f "tokens=1,2" %%x in ("%%~C") do (
        set /a "c=c%%B+60*^!(-%%y&1<<31)+100000"
        set /a "1/(100*(%%x-priorX-1)+%%y-priorY)" && (
          %== New line ==%
          set "ball%%B=!ball%%B! !len!" "%%~C !esc![!c:~-2!m!-X!"
          set /a len=pixelLen
        ) || (
    		  %== Line continuation ==%
          set "ball%%B=!ball%%B!!esc![!c:~-2!m!-X!"
          set /a len+=pixelLen
        )
        set /a "priorX=%%x, priorY=%%y"
      )
    )
    if %-C% ==  8 (  %==  8 bit color ==%
      set /a "c%%B=16+!random!%%6*36+!random!%%6"   %= compute random base color              =%
      set "xg=12/(s%%B*2+1), yg=2*12/(s%%B*2+1)"    %= adjust x and y gradient factor by size =%
      if defined -D echo c%%B=!c%%B!
      for %%S in (!s%%B!) do for %%C in (!circle%%S!) do for /f "tokens=1,2" %%x in ("%%~C") do (
        set /a "negX=^!^!(1<<31&%%x), absX=%%x*(1-2*negX), adj=((-%%y+4)*18/(s%%B*2+1)-absX*9/(s%%B*2+1))*6/17
        if !adj! gtr 5 set "adj=5"
				set /a "c=c%%B+adj*6+100000"
        if defined -D echo x=%%x y=%%y negX=!negX! absX=!absX! adj=!adj! c=!c:~-cLen!
        set /a "1/(100*(%%x-priorX-1)+%%y-priorY)" && (
          %== New line ==%
          set "ball%%B=!ball%%B! !len!" "%%~C !esc![38;5;!c:~-3!m!-X!"
          set /a len=pixelLen
        ) || (
    		  %== Line continuation ==%
          set "ball%%B=!ball%%B!!esc![38;5;!c:~-3!m!-X!"
          set /a len+=pixelLen
        )
        set /a "priorX=%%x, priorY=%%y"
      )
    )
    if %-C% == 24 (  %== 24 bit color ==%
      set /a "r=!random!%%60+76, g=!random!%%60+76, b=!random!%%60+76"   %= randomly select starting point for each base color    =%
      set /a "rp=^!(!random!%%3), gp=^!rp*(!random!%%2), bp=^!(rp|gp)"   %= randomly select 1 primary base color (never adjusted) =%
      set /a "rc%%B=r, rc%%B-=^!rp*r/(!random!%%3)"  %= randomly adjust red base value by none, half or all unless red is primary =%
      set /a "gc%%B=g, gc%%B-=^!gp*g/(!random!%%3)"                      %= randomly adjust green base value the same way         =%
      set /a "bc%%B=b, bc%%B-=^!bp*b/(!random!%%3)"                      %= randomly adjust  blue base value the same way         =%
      set /a "xg=15*4/s%%B, yg=30*4/s%%B"                                %= adjust x and y gradient factor by size                =%
      if defined -D (      
        echo r=!r! g=!g! b=!b!
        echo rp=!rp! gp=!gp! bp=!bp!
        echo rc=!rc%%B! gc=!gc%%B! bc=!bc%%B!
        echo(
      )
      set /a "pr=pg=pb=0"  %== Clear prior values ==%
      for %%S in (!s%%B!) do for %%C in (!circle%%S!) do for /f "tokens=1,2" %%x in ("%%~C") do (
        set /a "negX=^!^!(1<<31&%%x), absX=%%x*(1-2*negX), adj=-%%y*yg-absX*xg+100000, r=rc%%B+adj, g=gc%%B+adj, b=bc%%B+adj"
        set /a "1/((1<<31&r-100000)|(1<<31&g-100000)|(1<<31&b-100000)), r=pr,g=pg,b=pb" || set /a "pr=r,pg=g,pb=b"  %== Use prior values if negative value detected ==%
        set /a "1/(100*(%%x-priorX-1)+%%y-priorY)" && (
          %== New line ==%
          set "ball%%B=!ball%%B! !len!" "%%~C !esc![38;2;!r:~-3!;!g:~-3!;!b:~-3!m!-X!"
          set /a len=pixelLen
        ) || (
    		  %== Line continuation ==%
          set "ball%%B=!ball%%B!!esc![38;2;!r:~-3!;!g:~-3!;!b:~-3!m!-X!"
          set /a len+=pixelLen
        )
        set /a "priorX=%%x, priorY=%%y"
      )
    )
  ) else (        %===== No Color Gradient =====%
    if %-C% ==  4 (  %==  4 bit color ==%
      set /a "c%%B=31+!random!%%7 + 60*(!random!%%2)+100000"
      set "c=!esc![!c%%B:~-2!m"
    )
    if %-C% ==  8 (  %==  8 bit color ==%
      set /a "c%%B=!random!%%255+1+100000"
      set "c=!esc![38;5;!c%%B:~-3!m"
    )
    if %-C% == 24 (  %== 24 bit color ==%
      set /a "r=!random!%%240+16+100000, g=!random!%%240+16+100000, b=!random!%%240+16+100000"
      set "c=!esc![38;2;!r:~-3!;!g:~-3!;!b:~-3!m"
    )
    for %%S in (!s%%B!) do for %%C in (!circle%%S!) do for /f "tokens=1,2" %%x in ("%%~C") do (
      set /a "1/(100*(%%x-priorX-1)+%%y-priorY)" && (
        %== New line ==%
        set "ball%%B=!ball%%B! !len!" "%%~C !c!!-X!"
        set /a len=pixelLen
      ) || (
  		  %== Line continuation ==%
        set "ball%%B=!ball%%B!!c!!-X!"
        set /a len+=pixelLen
      )
      set /a "priorX=%%x, priorY=%%y"
		)
  )
  set "ball%%B=!ball%%B:~4! !len!""
)

if defined -D (
  for /l %%B in (0 1 %ballCnt%) do echo ball%%B=!ball%%B:%esc%=ESC!
  pause
  cls
)

:: Relaunch to run with input redirected to No
"%~f0" RUN <"%~f0.no"

:RUN
:: Hide the cursor
echo !esc![?25l

:: Run the main loop in new process with input redirected to Yes
cmd /c "%~f0" LOOP <"%~f0.yes"

:: Reset colors and show the cursor
echo !esc![0m!esc![?25h
cls

exit /b

:LOOP
setlocal enableDelayedExpansion
for /l %%# in () do (

  %initDelay% 

  for /l %%n in (0 1 %ht%) do set "ln%%n=!blankLine!"
  set "ln%ht%=!ln%ht%!!esc!A"

  for /l %%b in (0,1,%ballCnt%) do (

    set /a "x%%b+=i%%b, y%%b+=j%%b"
    
    if !x%%b! geq !r%%b! set /a "x%%b=r%%b, i%%b*=-1"
    if !y%%b! geq !b%%b! set /a "y%%b=b%%b, j%%b*=-1"
    if !x%%b! leq !s%%b! set /a "x%%b=s%%b, i%%b*=-1"
    if !y%%b! leq !s%%b! set /a "y%%b=s%%b, j%%b*=-1"
    %plot% !x%%b! !y%%b! ball%%b
  )

  %openDelay%
  echo !esc!8!ln0!
  for /l %%n in (1 1 %ht%) do echo !ln%%n!
  %pause%
  %closeDelay%
)