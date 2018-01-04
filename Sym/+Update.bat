@IF NOT "%XDev%"=="" GOTO XDev
@ECHO Please set system variable XDev=X:\Path\To\XDev
@PAUSE
@EXIT

:XDev
@FOR %%i IN (*.sym) DO COPY /B /Y %XDev%\Ofront\Lib\Sym\%%i
