title 指针时钟2.3 by neorobin 谢: liuzhaonan11 netbenton
rem 三角函数采用 6°间隔变量列表预设, 指针绘图采用 Bresenham 直线算法, 屏幕缓存变量采用一维串变量 strScr.
rem 主程序采用了 先绘图, 后 "预算" 的方法, 即绘出当前时间的钟面图后, 立即计算好未来下一秒的钟面绘图, 
rem 当时间到达未来下一秒时, 就可在最小的延迟时间后 显示出钟面图.
rem
rem getNextSec 过程出于避免代码过长的考虑, 采用了日期的不完全正确计算方式,
rem 在一些情况下会出现错误日期. 但钟面显示不用此日期, 故无影响.
rem
rem 时间正向变化 1 秒后才会触发表盘更新, 一个负向时间调整会引起表面 "停止"
rem 但至多 2 秒后将再次与系统时钟同步.
@echo off
msg %username% /time:60 请右键单击时钟窗口标题栏, 选择“属性”-^>“字体”选项卡,“点阵字体”,大小: 6 x 12,以得到更好的显示效果
setlocal enabledelayedexpansion
color 9f
set /a "size=19, HandS=size-2, HandM=HandS-3, HandH=HandM-3, rScale=size-1, width=2*size+1"
set /a "indexMax=(2*size+1)*(2*size+1)"
set /a "xStart=size, xEnd=-size, yStart=-size, yEnd=size"
set /a "Cols=(size*2+1)*2, Lines=size*2+1+1"
(set PntCenter=◎)&(set PntH=●)&(set PntM=○)&(set PntS=·)&(set PntB=▓)
(set RomanNumbers=ⅠⅡⅢⅣⅤⅥⅦⅧⅨⅩⅪⅫ)
(set days=一二三四五六日一)
set /a "leftSpaces=size*2+1-13-1" & (set Blanks=)
for /l %%i in (1,1,!leftSpaces!) do (set Blanks= !Blanks!)
mode con cols=!Cols! Lines=!Lines!
call :math
(set strScr=) & rem 全角空格初始化
for /l %%i in (1,1,!indexMax!) do (set strScr=　!strScr!)
(call :creatDial strScr !PntB!)
:loop
cls & (set /p=!strScr!!Blanks! !date! !futureTime!!Blanks!<nul)
for %%i in (!PntH!,!PntM!,!PntS!) do ( rem 擦除指针
  for /f "tokens=1" %%p in ("!PntB!") do (set strScr=!strScr:%%i=%%p!)
)
(call :getNextSec futureTime futureDate)
(call :drawScale strScr) & rem 当指针设置过长时, 会覆盖刻度, 需要重绘.
for %%i in (h,m,s) do (call :drawHand strScr !Hand%%i! %%i !futureTime!)
(call :setPoint strScr 0 0 !PntCenter!)
:testSec
(set datetime=%date:~0,10%%time:~0,8%)&&(set datetime=!datetime: =0!)
(set futureDateTime=!futureDate:~0,10!!futureTime:~0,8!)
if "!datetime!" geq "!futureDateTime!" (goto loop)
rem 当系统时钟向过去调整后, 确保至多在2秒后仍能与系统时钟同步
(set /a past=1!futureTime:~6,2! - 1!datetime:~16,2!) && (set past=!past:-=!)
if "!futureTime:~6,2!" equ "00" if "!datetime:~16,2!" equ "59" (goto testSec)
if !past! gtr 1 (goto loop)
goto testSec
exit /b
rem ========== end of main program =================================================================
:math
set /a "sin0=0,sin6=105,sin12=208,sin18=309,sin24=407,sin30=500,sin36=588,sin42=669,sin48=743,sin54=809,sin60=866,sin66=914,sin72=951,sin78=978,sin84=995,sin90=1000"
for /l %%i in (0, 6, 90) do (
  set /a "a1=180-%%i, a2=180+%%i, a3=360-%%i"
  set /a "sin!a1!=!sin%%i!, sin!a2!=-!sin%%i!, sin!a3!=-!sin%%i!"
)
for /l %%i in (0, 6, 360) do (
  set /a "a4=450-%%i, a4%%=360"
  set /a "cos%%i=sin!a4!"
)
exit /b

rem creatDial Screen !pointDial!
:creatDial
for /l %%x in (!xStart!,-1,!xEnd!) do for /l %%y in (!yStart!,1,!yEnd!) do (
  (set /a inDial=size*size-%%x*%%x-%%y*%%y+1*size) && if !inDial! geq 0 (call :setPoint %1 %%x %%y %2)
)
(call :drawScale %1)
exit /b

rem drawScale Screen
:drawScale
for /l %%z in (0,1,11) do ( rem 标12个刻度
  (set /a angle=%%z+1) && (set /a angle*=30)
  set /a "x=cos!angle!*rScale/sin90, y=sin!angle!*rScale/sin90"
  (set romanNum=!RomanNumbers:~%%z,1!)
  (call :setPoint %1 !x! !y! !romanNum!)
)
exit /b

rem drawHand Screen !HandLength! !HandFlag! !timeNow! [!BlankStr!]
rem 第5个参数 !BlankStr! 是可选的, 当传递了有效的第5个参数时, 将是擦除指针.
:drawHand
(set timeC=%4)
(set timeh=!timeC:~0,2!)&(set timem=!timeC:~3,2!)&(set times=!timeC:~6,2!)
for %%i in (h,m,s) do if !time%%i! lss 10 (set time%%i=!time%%i:~-1!)
set /a "timeh%%=12"
set /a "angleh=30*timeh+(timem+6)/12*6, anglem=6*timem, angles=6*times"
set /a "xE=%2*cos!angle%3!*2/sin90, yE=%2*sin!angle%3!*2/sin90"
if "%5"=="" (call :line %1 0 0 !xE! !yE! %2 !Pnt%3!) else (call :line %1 0 0 !xE! !yE! %2 %5)
exit /b

rem line Screen x1 y1 x2 y2 !LenHand! !PointChr!
:line
(set x0=%2)&(set y0=%3)&(set x1=%4)&(set y1=%5)&(set /a SQLenHand=%6*%6)
set /a "steep=(y1 - y0)*(y1 - y0) - (x1 - x0)*(x1 - x0)"
if !steep! gtr 0 (
  (set tt=!x0!&& set x0=!y0!&& set y0=!tt!)
  (set tt=!x1!&& set x1=!y1!&& set y1=!tt!)
)
if !x0! gtr !x1! (
  (set tt=!x0!&& set x0=!x1!&& set x1=!tt!)
  (set tt=!y0!&& set y0=!y1!&& set y1=!tt!)
)
set /a "deltax=x1-x0, twoDeltax=2*deltax"
set /a "twoDeltay=2*(y1-y0)" && (set twoDeltay=!twoDeltay:-=!)
set /a "eps=0, y=y0"
if !y0! lss !y1! (set yStep=1) else (set yStep=-1)
for /l %%x in (!x0!,1,!x1!) do (
  set /a "SQSum=%%x*%%x+y*y"
  if !SQSum! leq !SQLenHand! (
    if !steep! gtr 0 (call :setPoint %1 !y! %%x %7) else (call :setPoint %1 %%x !y! %7)
  )
  (set /a eps+=twoDeltay)
  if !eps! gtr !deltax! (set /a "y+=yStep, eps-=twoDeltax")
)
exit /b

rem getNextSec futureTime futureDate
:getNextSec
(set time1=!time:~0,-3!)&(set date1=!date!)
(set timeh=!time1:~0,2!)&(set timem=!time1:~3,2!)&(set times=!time1:~6,2!)
(set timeY=!date1:~0,4!)&(set timeMn=!date1:~5,2!)&(set timeD=!date1:~8,2!)&(set timeDay=!date1:~-1!)
for %%i in (h,m,s,Mn,D) do if !time%%i! lss 10 (set time%%i=!time%%i:~-1!)
(set /a "timeS=(timeS+1)%%60")
if !timeS! equ 0 (
  (set /a "timeM=(timeM+1)%%60")
  if !timeM! equ 0 (
    (set /a "timeH=(timeH+1)%%24")
    if !timeH! equ 0 (
      rem 这里不考虑大小月, 平闰月的问题, 将所有月份看作 31 天, 会出现错误的日期, 不能用于显示.
      (set /a "timeD=timeD%%31+1")
      for %%i in (一,二,三,四,五,六,日) do (
        if "%%i"=="!timeDay!" (set nextDay=!days:*%%i=!)&&(set nextDay=!nextDay:~0,1!)
      )
      (set timeDay=!nextDay!)
      if !timeD! equ 1 (
        (set /a "timeMn=timeMn%%12+1")
        if !timeMn! equ 1 (set /a timeY+=1)
      )
    )
  )
)
for %%i in (h,m,s,Mn,D) do if !time%%i! lss 10 (set time%%i=0!time%%i!)
(set %1=!timeH!:!timeM!:!timeS!) & (set %2=!timeY!-!timeMn!-!timeD! 星期!timeDay!)
exit /b

rem setPoint Screen !x! !y! !pointStr!
:setPoint
set /a "index=(xStart-%2)*width+%3-yStart+1"
set /a "lenLeft=index-1, lenRight=indexMax-index"
for /f "tokens=1,2,3" %%a in ("!lenLeft! !index! !lenRight!") do (set %1=!%1:~0,%%a!%4!%1:~%%b,%%c!)
exit /b