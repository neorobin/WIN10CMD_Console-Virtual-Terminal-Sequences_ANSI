::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Fifteen-segment display clock
::
:: 20190708_171144
::
:: 打开后, 显示不正常要如下设置:
:: 在 Options 选项卡, 勾选:
::       Use legacy console(requires relaunch, affects all console)
:: 		 使用旧版控制台(需要重新启动，影响所有控制台)
::
:: 在 Font 选项卡, 选择 Raster Fonts (光栅字体), 此程序最好选 8x8 Size
::
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

chcp 437

call :getBackSpaceAndASCII219

REM set "DOT=#"
set "DOT=%ASCII219%"

REM set "GAP_DOT=*"
set "GAP_DOT=%ASCII219%"

    set "_A="A = !!(x-1)""
    set "_B="B = (!!(x-1) ^& !!(x-4))""
    set "_C="C = 1""
    set "_D="D = (!(x^&3) ^| !!(x^&~3)) ^& !!(x-7)""
REM set "_E="E = 0""                                    & rem never display
    set "_F="F = !!(x-5)^&!!(x-6)""
    set "_G="G = !!(x-1)^&!!(x-7)""
    set "_H="H = !(!x ^| !(x-1) ^| !(x-7))""
    set "_I="I = 1""
    set "_J="J = ~x ^& 1 ^& !!(x-4)""
REM set "_K="K = 0""                                    & rem never display
    set "_L="L = !!(x-2)""
    set "_M="M = (!!(x-1) ^& !!(x-4) ^& !!(x-7))""
    set "_N="N = (!!(x-1) ^& !!(x-4) ^& !!(x-7))""
    set "_O="O = 1""


@echo off & setlocal enabledelayedexpansion

for /f "tokens=2 delims=[]" %%a in ('ver') do for /f "tokens=2 delims=. " %%a in ("%%a") do (
    set /a "NO_CLS=-((%%a-7)>>31)"
)

set /a "wid=37, hei=6, linesWantBackAbove = hei - 1, cntBS = 2 + (wid + 7) / 8 * linesWantBackAbove"
set "TAB=	" & for /F %%a in ('echo prompt $H ^| cmd') do Set "BS=%%a"
set "BSs=" & for /L %%a in (1 1 !cntBS!) do set "BSs=!BSs!%BS%"

color 0a & mode %wid%,%hei%

set "__=0" & set "_= "
for /l %%i in () do (
    set /a "t=!time:~-1!" & set /a "t ^= z, z ^= t"
    if !t! neq 0 (
        set "S=" & set "zeroOrOne=0"
        for %%L in ("A B C" "D _ F" "G H I" "J _ L" "M N O") do (
            for %%d in (0 _ 1 _ : _ 3 _ 4 _ : _ 6 _ 7 _ : _ 9 _ 10) do (
                if "%%d" geq "0" (
                    set "tm=!time: =0!" & set "x=!tm:~%%d,1!"
                    for %%_ in (%%~L) do set /a !_%%_! & set "S=!S!!%%_!"
                ) else if "!zeroOrOne!%%d"=="1:" (set "S=!S!%GAP_DOT%") else set "S=!S! "
            )
            set /a "zeroOrOne^=1"
        )
        set "S=!S:1=%DOT%!" & set "S=!S:0= !"

        (2>nul echo;%TAB%!BSs!) & <nul set /p "=%BS%"


        <nul set /p "=%BS%!S!"
    )
)

exit

:getBackSpaceAndASCII219
call :getASCII219
>nul copy 219.chr /b + 13.chr /b 219_CR.chr /b
<219_CR.chr set /p "ASCII219="
for %%N in (13 219 219_CR) do del %%N.chr
call :getBackSpace BS
exit /b
REM end of :getBackSpaceAndASCII219
REM ***
:getASCII219
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
REM end of :getASCII219
REM ***
:getBackSpace vRet
for /F %%a in ('"prompt $h&for %%b in (1) do rem"')do Set "%~1=%%a"
exit /b
REM end of :getBackSpace