@echo off
setlocal EnableDelayedExpansion  
IF NOT EXIST "%~dp0\TMP\LogTimeline" mkdir "%~dp0\TMP\LogTimeline" >NUL
IF NOT EXIST "%~dp0\SYS\LOG" mkdir "%~dp0\SYS\LOG" >NUL
set bfh=%

if "%1"=="" (
	title LOG_PUT
	cd /d %~dp0 
	goto viewlog
)

if /i "%1"=="/help" (
	echo [HIDE ECHO ver]
	echo call logHE ^<logname^> ^<level^> ^<msg^>
	echo call logHE /help
	echo call logHE /clear
	echo call logHE /clearlt
	echo start cmd.exe log /view
	
	exit /b
)

if /i "%1"=="/view" (
	title LOG_PUT
	cd /d %~dp0 
	goto viewlog
)

if /i "%1"=="/clearlt" (
	del /f /s /q "%~dp0TMP\LogTimeline\*" > nul
	exit /b
)

if /i "%1"=="/clear" (
	del /f /s /q "%~dp0SYS\LOG\*" > nul
	exit /b
)

if /i "%log_debug_saveput%"=="true" echo %*>>%~dp0\SYS\LOG\logput.log

::<logname> <level> <msg>
FOR /F "tokens=1,2,3* delims= " %%a in ("%*") do (
	set LOG_MSG_STR=%%c
	set LOG_MSG_STR=!LOG_MSG_STR:#sp#= !
	set LOG_MSG_STR=!LOG_MSG_STR:#l#=^|!
	REM echo.!LOG_MSG_STR!
	echo.[!date! - !time!][%%b]!LOG_MSG_STR!>>%~dp0\SYS\LOG\%%a.log
	
	REM for /f "delims=*" %%f in ('Powershell Get-Date -UFormat %%%s') do (
	REM 	SET LOG_TIME_NAME=%%f
	REM )
	
	set LOG_TIME_DATE=!DATE:~0,-3!
	set LOG_TIME_DATE=!LOG_TIME_DATE:/=!
	set LOG_TIME_NAME=%TIME::=%
	if "!LOG_TIME_NAME:~0,1!"==" " set LOG_TIME_NAME=!LOG_TIME_NAME:~1!
	echo.%%a  %%b  !LOG_MSG_STR!>>"%~dp0TMP\LogTimeline\!LOG_TIME_DATE!!LOG_TIME_NAME!"
)
setlocal DisableDelayedExpansion 
exit /b

:viewlog
for /r %%l in (TMP\LogTimeline\*) do (
	REM for /f "delims=*" %%f in (%%l) do (echo %%f)
	REM for /f "delims=*" %%f in ('type %%l') do (echo %%f)
	type %%l
	del /f /s /q "%%l" >nul

)
goto viewlog