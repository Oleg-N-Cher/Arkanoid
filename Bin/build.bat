@ECHO OFF
IF NOT "%XDev%"=="" GOTO XDev
ECHO Please set system variable XDev=X:\Path\To\XDev
PAUSE
EXIT

:XDev
SET PATH=%XDev%\WinDev\Bin\MinGW\bin
SET StripExe=-nostartfiles ..\Mod\crt1.c -Wl,-e__WinMain -D_WINMAIN
SET lib=-I %XDev%\Ofront\Lib\Obj -I %XDev%\Ofront\Lib\Mod %XDev%\Ofront\Lib\Ofront.a %XDev%\WinDev\Bin\MinGW\lib\libSDL2.dll.a %XDev%\WinDev\Bin\MinGW\lib\libSDL2_image.dll.a %XDev%\WinDev\Bin\MinGW\lib\libSDL2_mixer.dll.a
SET gcc=gcc.exe %StripExe% -s -Os -fno-exceptions -fno-asynchronous-unwind-tables -Wl,--gc-sections -Wl,--file-alignment,512 %lib%

%gcc% Game.c -mwindows %lib% -o ..\Game.exe
IF errorlevel 1 PAUSE
%XDev%\Bin\upx.exe ..\Game.exe
