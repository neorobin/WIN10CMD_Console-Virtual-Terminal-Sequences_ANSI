@echo off & setlocal enabledelayedexpansion & color f0 & chcp 437
set /a "wid=60,hei=40,wid|=1,hei|=1,iMax=wid*hei,cols=wid,row=hei+1"
title maze !wid! col X !hei! row
mode con cols=!cols! lines=!row!

set "maze="
for /l %%y in (1 1 !hei!) do for /l %%x in (1 1 !wid!) do set "maze=!maze!#"
REM {1,2,4,8} -> {17,18,20,24} <-> {Up,Left,Right,Down}
set "d17=y-=2" & set "d18=x-=2" & set "d20=x+=2" & set "d24=y+=2" & set "d=0"
set "w17=y+=1" & set "w18=x+=1" & set "w20=x-=1" & set "w24=y-=1" & set "w=0"
set "dirs=" & set "cells=." & set /a "x=2, y=2"

for /l %%* in () do (
  if defined n!x!_!y! ( rem backtrack point
    if !dirs:~-2! equ 0x1f ( rem all dirs be searched at backtrack point
      set "dirs=!dirs:~0,-2!"
      set "cells=!cells:~1!" & set "cells=!cells:*.=.!"
      if "!cells!"=="." (
        <nul set /p "=" & title Maze generation completed, any key to exit...
        >nul pause & exit
      )
      for /f "tokens=1-2 delims=.#" %%x in ("!cells!") do (set x=%%x&set y=%%y)
    ) else ( rem exist some dirs not searched at backtrack point
      for /f "tokens=1-2 delims=.#" %%x in ("!cells!") do (set x=%%x&set y=%%y)
      set "dir=!dirs:~-2!"

      set /a "visit=1, randS=!random! & 3, randE=randS | 4"
      for /l %%d in (!randS! 1 !randE!) do if !visit! neq 0 (
        set /a "dc=1<<(%%d &3), visit=dir&dc,dir|=dc, dc|=0x10"
        if !visit! equ 0 (
          for %%r in (d!dc!) do set /a "!%%r!"
          set "dirs=!dirs:~0,-2!!dir!"
    ) ) )
  ) else ( rem can pass point
    set /a "xin=x-2^x-wid,yin=y-2^y-hei,in=(xin&yin)>>31"
    if !in! equ 0 ( rem out of the region
      for /f "tokens=1-2 delims=.#" %%x in ("!cells!") do (set x=%%x&set y=%%y)
    ) else ( rem In the region
      set "cells=.!x!#!y!!cells!"
      set "n!x!_!y!=1"

      for %%r in (w!dc!) do for %%i in (1 2) do (
        set /a "ind=(x-1)+(y-1)*wid+1, lL=ind-1, lR=iMax-ind"
        for /f "tokens=1-3" %%a in ("!lL! !ind! !lR!") do (set maze=!maze:~0,%%a!+!maze:~%%b,%%c!)
        set /a "!%%r!"
      )
      for %%r in (d!dc!) do set /a "!%%r!"
      cls & <nul set /p "=!maze:+= !"

      set /a "dc=(1<<(!random!&3))|0x10"
      set "dirs=!dirs!!dc!"
      for %%r in (d!dc!) do set /a "!%%r!"
) ) )
exit