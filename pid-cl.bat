@echo off
SET PID_CL_VERSION=0.0.1
call pid /title
echo.
echo "help" to get help list
echo.
title pid-cl

if DEFINED PIDCL_MAIN (
	call log.cmd PIDCL INFO Load#SP#custom#SP#main#SP#in#SP#setting......
	IF NOT EXIST "%PIDCL_MAIN%" (call log.cmd PIDCL ERRO %PIDCL_MAIN%#SP#NOT#SP#EXIST) else (echo>nul&%PIDCL_MAIN%&echo>nul)
)

:loop
	set /p pid_cmd=
	if /i "%pid_cmd%"=="" goto loop
		
	call logHE.cmd PIDCL INFO USER#SP#COMMAND:%pid_cmd: =#SP#%
	if /i "%pid_cmd%"=="quit" exit /b
	
	if /i "%pid_cmd%"=="help" (
		for /f "tokens=1,2,3-9 delims= " %%1 in ('call pid /help') do echo./%%3 %%4 %%5 %%6 %%7 %%8 %%9
		echo.//type "quit" to exit
		set pid_cmd=
		goto loop
	)

	
	call pid /%pid_cmd%
	
	set pid_cmd=
goto loop
