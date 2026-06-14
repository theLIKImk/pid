@echo off
if not exist "%1" echo %1 not exist! & exit /b

set LOADCFG_VERSION=1.1.0

set CFGINI_DIR=%~dp1
set CFGINI_FILE=%~nx1
set CFGINI_THIS_INDEX=0

pushd "%cd%"
cd /d "%CFGINI_DIR%"

FOR /F "delims=* eol=#" %%f in (%CFGINI_FILE%) do (
	call :setload %%f
)

set config_parent_tag=
set /a CFGINI_THIS_INDEX-=1
popd
exit /b

:setload
	set obj=%*
	if "%obj:~0,1%"=="[" (
		set config_parent_tag=%obj:~1,-1%_
		set CFGINI_THIS_INDEX_%CFGINI_THIS_INDEX%=%obj:~1,-1%
		set /a CFGINI_THIS_INDEX+=1
	)
	if not "%obj:~0,1%"=="[" set %config_parent_tag%%obj%
goto :eof
