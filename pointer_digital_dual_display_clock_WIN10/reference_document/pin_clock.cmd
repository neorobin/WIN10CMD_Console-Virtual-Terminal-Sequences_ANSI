title ָ��ʱ��2.3 by neorobin л: liuzhaonan11 netbenton
rem ���Ǻ������� 6���������б�Ԥ��, ָ���ͼ���� Bresenham ֱ���㷨, ��Ļ�����������һά������ strScr.
rem ����������� �Ȼ�ͼ, �� "Ԥ��" �ķ���, �������ǰʱ�������ͼ��, ���������δ����һ��������ͼ, 
rem ��ʱ�䵽��δ����һ��ʱ, �Ϳ�����С���ӳ�ʱ��� ��ʾ������ͼ.
rem
rem getNextSec ���̳��ڱ����������Ŀ���, ���������ڵĲ���ȫ��ȷ���㷽ʽ,
rem ��һЩ����»���ִ�������. ��������ʾ���ô�����, ����Ӱ��.
rem
rem ʱ������仯 1 ���Żᴥ�����̸���, һ������ʱ�������������� "ֹͣ"
rem ������ 2 ����ٴ���ϵͳʱ��ͬ��.
@echo off
msg %username% /time:60 ���Ҽ�����ʱ�Ӵ��ڱ�����, ѡ�����ԡ�-^>�����塱ѡ�,���������塱,��С: 6 x 12,�Եõ����õ���ʾЧ��
setlocal enabledelayedexpansion
color 9f
set /a "size=19, HandS=size-2, HandM=HandS-3, HandH=HandM-3, rScale=size-1, width=2*size+1"
set /a "indexMax=(2*size+1)*(2*size+1)"
set /a "xStart=size, xEnd=-size, yStart=-size, yEnd=size"
set /a "Cols=(size*2+1)*2, Lines=size*2+1+1"
(set PntCenter=��)&(set PntH=��)&(set PntM=��)&(set PntS=��)&(set PntB=��)
(set RomanNumbers=���������������������)
(set days=һ������������һ)
set /a "leftSpaces=size*2+1-13-1" & (set Blanks=)
for /l %%i in (1,1,!leftSpaces!) do (set Blanks= !Blanks!)
mode con cols=!Cols! Lines=!Lines!
call :math
(set strScr=) & rem ȫ�ǿո��ʼ��
for /l %%i in (1,1,!indexMax!) do (set strScr=��!strScr!)
(call :creatDial strScr !PntB!)
:loop
cls & (set /p=!strScr!!Blanks! !date! !futureTime!!Blanks!<nul)
for %%i in (!PntH!,!PntM!,!PntS!) do ( rem ����ָ��
  for /f "tokens=1" %%p in ("!PntB!") do (set strScr=!strScr:%%i=%%p!)
)
(call :getNextSec futureTime futureDate)
(call :drawScale strScr) & rem ��ָ�����ù���ʱ, �Ḳ�ǿ̶�, ��Ҫ�ػ�.
for %%i in (h,m,s) do (call :drawHand strScr !Hand%%i! %%i !futureTime!)
(call :setPoint strScr 0 0 !PntCenter!)
:testSec
(set datetime=%date:~0,10%%time:~0,8%)&&(set datetime=!datetime: =0!)
(set futureDateTime=!futureDate:~0,10!!futureTime:~0,8!)
if "!datetime!" geq "!futureDateTime!" (goto loop)
rem ��ϵͳʱ�����ȥ������, ȷ��������2���������ϵͳʱ��ͬ��
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
for /l %%z in (0,1,11) do ( rem ��12���̶�
  (set /a angle=%%z+1) && (set /a angle*=30)
  set /a "x=cos!angle!*rScale/sin90, y=sin!angle!*rScale/sin90"
  (set romanNum=!RomanNumbers:~%%z,1!)
  (call :setPoint %1 !x! !y! !romanNum!)
)
exit /b

rem drawHand Screen !HandLength! !HandFlag! !timeNow! [!BlankStr!]
rem ��5������ !BlankStr! �ǿ�ѡ��, ����������Ч�ĵ�5������ʱ, ���ǲ���ָ��.
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
      rem ���ﲻ���Ǵ�С��, ƽ���µ�����, �������·ݿ��� 31 ��, ����ִ��������, ����������ʾ.
      (set /a "timeD=timeD%%31+1")
      for %%i in (һ,��,��,��,��,��,��) do (
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
(set %1=!timeH!:!timeM!:!timeS!) & (set %2=!timeY!-!timeMn!-!timeD! ����!timeDay!)
exit /b

rem setPoint Screen !x! !y! !pointStr!
:setPoint
set /a "index=(xStart-%2)*width+%3-yStart+1"
set /a "lenLeft=index-1, lenRight=indexMax-index"
for /f "tokens=1,2,3" %%a in ("!lenLeft! !index! !lenRight!") do (set %1=!%1:~0,%%a!%4!%1:~%%b,%%c!)
exit /b