@IF NOT "%XDev%"=="" GOTO XDev
@ECHO Please set system variable XDev=X:\Path\To\XDev
@PAUSE
@EXIT

:XDev
@SET PATH=%XDev%\WinDev\Bin\MinGW\bin;%PATH%
@SET lib=-I %XDev%\Ofront\Lib\Obj -I %XDev%\Ofront\Lib\Mod
@SET gcc=gcc.exe -Os -fno-exceptions -fno-asynchronous-unwind-tables

%gcc% -c %1.c %lib%
@IF errorlevel 1 PAUSE
