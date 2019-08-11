@echo off & setlocal enableDelayedExpansion
chcp 437
rem DEFINE ESC
for /f %%a in ('echo prompt $E^| cmd') do set "esc=%%a"

set "background=%esc%[48;5;cm"
set "textColor=%esc%[38;5;cm"
set "RGB=%esc%[38;2;r;g;bm"
set "resetAttribute=%esc%[0m"

echo %background:c=9%Hello World%resetAttribute%
echo %textColor:c=10%Hello World%resetAttribute%
echo %RGB:r;g;b=190;80;170%Hello World%resetAttribute%

pause>nul