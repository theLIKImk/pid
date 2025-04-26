@echo off
PUSHD %cd%
::cd /d %~dp0

set PATH=%PATH%;%~dp0
set PM_VER=0.075.8
set PM_INFO=PID VER %PM_VER%
set PIDMD_DISABLE_RUN=false

set ZW=~dp0
set "symbol_1=%%"

call :check_file

IF /I NOT "%PIDMD_CONFIG_LOADED%"=="TRUE" call loadcfg "%~dp0system.ini"
SET PIDMD_CONFIG_LOADED=TRUE

if not exist "%PIDMD_SYS%\PID\" mkdir "%PIDMD_SYS%\PID\"

if "%PIDMD_LANG%"=="" set PIDMD_LANG=zh

if "%PIDMD_CHCP_CODE%"=="" (chcp 936>nul) else (chcp %PIDMD_CHCP_CODE%>nul)
if "%PIDMD_CMD_COLOR%"=="" (color 0F) else (color %PIDMD_CMD_COLOR%)

:: DO NOT CHANG LANG STR
set en_check_pid_info=INFO:
set zh_check_pid_info=信息:
set zh_use_arg_error_1=不是内部或外部命令，也不是可运行的程序
set zh_use_arg_error_2=或批处理文件。
set en_use_arg_error_1=is not recognized as an internal or external command,
set en_use_arg_error_2=operable program or batch file.

%PIDMD_GLOBAL_CMD%

if /i "%1"=="/start" goto start
if /i "%1"=="/start-USR" goto start
if /i "%1"=="/start-SYSTEM" goto start
if /i "%1"=="/start-SRV" goto start
if /i "%1"=="/run" goto run
if /i "%1"=="/run-USR" goto run
if /i "%1"=="/run-SYSTEM" goto run
if /i "%1"=="/run-SRV" goto run
if /i "%1"=="/check_pid" goto check_pid
if /i "%1"=="/check_sys" goto check_sys
if /i "%1"=="/exist-pid" goto exist_pid
if /i "%1"=="/killpid" goto kill
if /i "%1"=="/killpid-f" goto kill
if /i "%1"=="/list" goto list
if /i "%1"=="/info-p" goto info
if /i "%1"=="/info-n" goto info
if /i "%1"=="/boot" goto boot
if /i "%1"=="/startup" goto startup
if /i "%1"=="/sys_end" goto sys_end
if /i "%1"=="/test" goto test
if /i "%1"=="/srv-list" goto SRV_LIST
if /i "%1"=="/srv-info" goto SRV
if /i "%1"=="/srv-stop" goto SRV
if /i "%1"=="/srv-start" goto SRV
if /i "%1"=="/srv-restart" goto SRV
if /i "%1"=="/usr-add" goto USR
if /i "%1"=="/usr-rmv" goto USR
if /i "%1"=="/usr-list" goto USR
if /i "%1"=="/group-list" goto GROUP
if /i "%1"=="/group-add" goto GROUP
if /i "%1"=="/group-rmv" goto GROUP
if /i "%1"=="/group-setuser" goto GROUP
if /i "%1"=="/group-rmuser" goto GROUP
if /i "%1"=="/SYSTEM_PID-PID" goto SYSTEM_PID
if /i "%1"=="/SYSTEM_PID-STATUS" goto SYSTEM_PID
if /i "%1"=="/CONFIG-LOAD" goto CONFIG
if /i "%1"=="/log" goto log
if /i "%1"=="/title" goto title
if /i "%1"=="/help" goto help
if /i "%1"=="/version" goto version
if /i "%1"=="/ABOUT" goto ABOUT
if /i "%1"=="/ABOUT-GPL" goto ABOUT
if /i "%1"=="test" goto test

exit /b

:CONFIG
	IF /I "%1"=="/CONFIG-LOAD" GOTO CONFIG_LOAD
EXIT /B

:CONFIG_LOAD
	call loadcfg "%~dp0system.ini"
EXIT /B

:SYSTEM_PID
	IF /I NOT "%PIDMD_BOOT%"=="TRUE"  EXIT /B
	IF /I "%1"=="/SYSTEM_PID-PID" ECHO.%PIDMD_SYSTEM_PID% & EXIT /B
	IF /I "%1"=="/SYSTEM_PID-STATUS" TYPE "%PIDMD_SYS%PID\SYSTEM_PID-%PIDMD_SYSTEM_PID%" & EXIT /B
	
EXIT /B


:ABOUT
	IF /I "%1"=="/ABOUT-GPL" TYPE "%PIDMD_ROOT%LICENSE" & exit /b
	ECHO Github: https://github.com/theLIKImk/pid
	ECHO /!\ This project follows the GPL-3.0 license
EXIT /B

:GROUP
	if /i "%1"=="/group-list" (
		PUSHD "%CD%"
		cd /d "%PIDMD_ALLGROUP%"
		for /d %%f in (*) do echo.%%f
		POPD
	)
	if /i "%1"=="/group-add" (
		IF EXIST "%PIDMD_ALLGROUP%%2\" ECHO Group exist! & exit /b
		mkdir "%PIDMD_ALLGROUP%%2"
		call log.cmd PIDMD INFO ADD#SP#%2#SP#GROUP
	)
	if /i "%1"=="/group-rmv" (
		IF /i "%2"=="ROOT" ECHO Cant remove & exit /b
		IF NOT EXIST "%PIDMD_ALLGROUP%%2" ECHO Group not exist! & exit /b
		rmdir /Q /S "%PIDMD_ALLGROUP%%2"
		call log.cmd PIDMD INFO REMOVE#SP#%2#SP#GROUP
	)
	if /i "%1"=="/group-setuser" (
		REM <USER> <GROUP>
		IF "%3"=="" EXIT /B
		IF NOT EXIST "%PIDMD_ALLGROUP%%3" ECHO Group not exist! & exit /b
		IF NOT EXIST "%PIDMD_ALLUSER%%2" ECHO User not exist! & exit /b
		ECHO.>"%PIDMD_ALLGROUP%%3\%2"
		call log.cmd PIDMD INFO SET#SP#USER#SP#%2#SP#GROUP:#SP#%3
	)
	if /i "%1"=="/group-rmuser" (
		REM <USER> <GROUP>
		IF "%3"=="" EXIT /B
		IF NOT EXIST "%PIDMD_ALLGROUP%%3" ECHO Group not exist! & exit /b
		IF NOT EXIST "%PIDMD_ALLUSER%%2" ECHO User not exist! & exit /b
		IF NOT EXIST "%PIDMD_ALLGROUP%%3\%2" ECHO User not in the group! & exit /b
		DEL "%PIDMD_ALLGROUP%%3\%2"
		call log.cmd PIDMD INFO REMOVE#SP#USER#SP#%2#SP#IN#SP#GROUP:#SP#%3
	)
EXIT /B

:USR
	if /i "%1"=="/usr-list" (
		PUSHD "%CD%"
		cd /d "%PIDMD_ALLUSER%"
		for /r %%f in (*) do echo.%%~nxf
		POPD
	)
	if /i "%1"=="/usr-add" (
		IF EXIST "%PIDMD_ALLUSER%%2" ECHO User exist! & exit /b
		echo.>"%PIDMD_ALLUSER%%2"
		call log.cmd PIDMD INFO ADD#SP#%2#SP#USER
	)
	if /i "%1"=="/usr-rmv" (
		IF /i "%2"=="SYSTEM" ECHO Cant remove & exit /b
		IF NOT EXIST "%PIDMD_ALLUSER%%2" ECHO User not exist! & exit /b
		DEL "%PIDMD_ALLUSER%%2" >NUL
		call log.cmd PIDMD INFO REMOVE#SP#%2#SP#USER
	)
EXIT /B

:version
	echo.%PM_VER%
exit /b

:help
	echo call pid /START {^<PID^>^|SOLO} ^<Path^>
	echo call pid /START-USR {^<PID^>^|SOLO} ^<Path^>
	echo call pid /START-SRV {^<PID^>^|SOLO} ^<Path^>
	echo call pid /START-SYSTEM {^<PID^>^|SOLO} ^<Path^>
	echo call pid /run ^<Path^>
	echo call pid /run-USR ^<Path^>
	echo call pid /run-SRV ^<SRV:name^> ^<SRV:cmd^>
	echo call pid /run-SYSTEM ^<Path^>
	echo call pid /killpid ^<PID^>
	echo call pid /killpid-f ^<PID^>
	echo call pid /list
	echo call pid /exist_pid ^<PID^>
	echo call pid /info-p ^<PID^>
	echo call pid /info-n ^<PID^>
	echo call pid /boot [Path]
	echo call pid /sys_end
	echo call pid /srv-list
	echo call pid /srv-info ^<SRV:name^>
	echo call pid /srv-start ^<SRV:name^>
	echo call pid /srv-stop ^<SRV:name^>
	echo call pid /srv-restart ^<SRV:name^>
	echo call pid /usr-list
	echo call pid /usr-add ^<USERNAME^>
	echo call pid /usr-rmv ^<USERNAME^>
	echo call pid /group-list
	echo call pid /group-add ^<GROUP^>
	echo call pid /group-rmv ^<GROUP^>
	echo call pid /group-setuser ^<USERNAME^> ^<GROUP^>
	echo call pid /group-rmuser ^<USERNAME^> ^<GROUP^>
	echo call pid /config-load
	echo call pid /system_pid-pid
	echo call pid /system_pid-status
	echo call pid /log
	echo call pid /title
	echo call pid /help
	echo call pid /version
	echo call pid /about
	echo call pid /about-gpl
	echo.
	echo.v%PM_VER%
	echo.
exit /b

:title
	echo.   ___  __  __     _  _  __
	echo.  /__/  /  /  \   / / / /  \
	echo. /    _/_ /__/   /   / /__/     Ver%PM_VER%
exit /b

:log
	type "%~dp0\SYS\LOG\PIDMD.log"
exit /b

:check_file
	if not exist "%~dp0hiderun.cmd" (
		call log.cmd PIDMD INFO --CREATE#SP#^|#SP#hiderun.cmd--
		echo @echo off>"%~dp0hiderun.cmd"
		echo TITLE HIDERUN>>"%~dp0hiderun.cmd"
		echo ::HIDERUN ^<CMD^>>>"%~dp0hiderun.cmd"
		echo hidew>>"%~dp0hiderun.cmd"
		echo %%%** exit /b>>"%~dp0hiderun.cmd"
		echo exit>>"%~dp0hiderun.cmd"
	)
	
	if not exist "%~dp0start.bat" (
		call log.cmd PIDMD INFO --CREATE#SP#^|#SP#start.bat--
		echo @echo off>"%~dp0start.bat"
		echo :: START ^<PATH^>>>"%~dp0start.bat"
		echo call pid /start solo %%%**>>"%~dp0start.bat"
		echo exit /b>>"%~dp0start.bat"
	)
	
	if not exist "%~dp0cpretpid.exe" (
		title Dowlnoad cpretpid.exe......
		call log.cmd PIDMD INFO --DOWNLOAD#SP#^|#SP#cpretpid.exe--
		bitsadmin /transfer cpretpid /download /priority normal http://bcn.bathome.net/tool/cpretpid.exe "%~dp0\cpretpid.exe"
	)

	if not exist "%~dp0hidecon.exe" (
		title Dowlnoad hidecon.exe......
		call log.cmd PIDMD INFO --DOWNLOAD#SP#^|#SP#hidecon.exe--
		bitsadmin /transfer hidecon /download /priority normal http://bcn.bathome.net/tool/hidecon.exe "%~dp0\hidecon.exe"
	)
	
	if not exist "%~dp0log.cmd" (
		call log.cmd PIDMD INFO CREATE:log.cmd
		echo. @REM LOG LITE VERSION>"%~dp0log.cmd"
		echo. @echo %%%**>>"%~dp0log.cmd"
		echo. @echo %%%**^>^>"%%%ZW%\log.log">>"%~dp0log.cmd"
	)
	
	if not exist "%~dp0logHE.cmd" (
		call log.cmd PIDMD INFO CREATE:logHE.cmd
		echo. @REM LOGHE LITE VERSION>"%~dp0logHE.cmd"
		echo. @echo %%%**^>^>"%%%ZW%\log.log">>"%~dp0logHE.cmd"
	)
	
	if not exist "%~dp0system.ini" (
		call log.cmd PIDMD INFO CREATE:system.ini
		echo [PIDMD]>"%~dp0system.ini"
		echo LANG=zh>>"%~dp0system.ini"
		echo CHCP_CODE=936>>"%~dp0system.ini"
		echo CMD_COLOR=0F>>"%~dp0system.ini"
		echo ROOT=%~dp0>>"%~dp0system.ini"
		echo SYS=%symbol_1%PIDMD_ROOT%symbol_1%SYS\>>"%~dp0system.ini"
		echo TMP=%symbol_1%PIDMD_ROOT%symbol_1%TMP\>>"%~dp0system.ini"
		echo LOG=%symbol_1%PIDMD_SYS%symbol_1%LOG\>>"%~dp0system.ini"
		echo SRV=%symbol_1%PIDMD_SYS%symbol_1%SRV\>>"%~dp0system.ini"
		echo ALLUSER=%symbol_1%PIDMD_SYS%symbol_1%USER\>>"%~dp0system.ini"
		echo ALLGROUP=%symbol_1%PIDMD_SYS%symbol_1%GROUP\>>"%~dp0system.ini"
		echo DEFAULT_USER=SYSTEM>>"%~dp0system.ini"
		echo GLOBAL_CMD=>>"%~dp0system.ini"
		echo DISABLE_RUN=false>>"%~dp0system.ini"
		echo STARTUP_STALLED=FALSE>>"%~dp0system.ini"
		echo STARTUP_STALLED_TIME=5>>"%~dp0system.ini"
		echo END_CLEAR=FALSE>>"%~dp0system.ini"
		echo CHECK_PATH=TRUE>>"%~dp0system.ini"
	)

goto :eof

:SRV
	set SRV_NAME=%2
	if "%SRV_NAME%"=="" echo Is empty & exit /b
	
	if /i "%PIDMD_BOOT%"=="true" (
		IF NOT EXIST "%PIDMD_SYS%GROUP\ROOT\%PIDMD_USER%" (
			call log.cmd PIDMD ERRO User#SP#%PIDMD_USER%#SP#does#SP#not#SP#have#SP#permissions#SP#[%SRV_NAME%]
			exit /b
		)
	)
	
	if not exist "%PIDMD_SYS%SRV\%SRV_NAME%" call log.cmd PIDMD ERRO %SRV_NAME%#SP#Not#SP#exist! & exit /b
	
	if /i "%1"=="/srv-info" call :SRV_INFO
	if /i "%1"=="/srv-start" call :SRV_START
	if /i "%1"=="/srv-stop" call :SRV_STOP
	if /i "%1"=="/srv-restart" call :SRV_RESTART
EXIT /B

:SRV_RESTART
	call log.cmd PIDMD INFO Restart#sp#SRV#sp#%SRV_NAME%
	
	SET RELOAD_CMD=
	call loadcfg "%PIDMD_SYS%SRV\%SRV_NAME%"
	if DEFINED RELOAD_CMD (
		echo.>nul &%RELOAD_CMD:#NL#=&%& exit /b
	)
	
	CALL :SRV_STOP
	CALL :SRV_START
EXIT /B

:SRV_STOP
	if not exist "%PIDMD_SYS%SRVRUN\%SRV_NAME%" call log.cmd PIDMD ERRO Noting#SP#find#SP#%SRV_NAME% & exit /b
	
	call log.cmd PIDMD INFO Stop#SP#SRV#SP#%SRV_NAME%
	
	SET STOP_CMD=
	call loadcfg "%PIDMD_SYS%SRV\%SRV_NAME%"
	if DEFINED STOP_CMD (
		call log.cmd PIDMD INFO Stop#SP#SRV#SP#%SRV_NAME%#SP#CL:%STOP_CMD: =#SP#%
		%STOP_CMD%
		DEL "%PIDMD_SYS%SRVRUN\%SRV_NAME%"
		set STOP_CMD=
	) ELSE (
	
		set /P SRV_PID=<"%PIDMD_SYS%SRVRUN\%SRV_NAME%"
		call PID /killpid-f %SRV_PID%
		DEL "%PIDMD_SYS%SRVRUN\%SRV_NAME%"
	)
EXIT /B

:SRV_START
	if exist "%PIDMD_SYS%SRVRUN\%SRV_NAME%" call log.cmd PIDMD ERRO %SRV_NAME%#SP#in#SP#runing! & exit /b
	
	call log.cmd PIDMD INFO Run#SP#SRV#SP#%SRV_NAME%
	call loadcfg "%PIDMD_SYS%SRV\%SRV_NAME%"
	SET PID_START_PATH_SET=%CMD%
	start hiderun PID.CMD /start-SRV SOLO %SRV_NAME%
EXIT /B

:SRV_INFO
	IF NOT EXIST "%PIDMD_SYS%SRV\%SRV_NAME%" ECHO NOT EXIST SRV & EXIT /B
	call loadcfg "%PIDMD_SYS%SRV\%SRV_NAME%"
	echo NAME:%NAME%[%TYPE%]  USE:%USE% 
	echo Boot to PID MANANGER :%STARTUP%
	echo.
	echo %INFO%
	echo.
	if not exist "%PIDMD_SYS%SRVRUN\%SRV_NAME%" (echo Status:STOP) else (echo Status:RUNING)
	
exit /b

:SRV_LIST
	PUSHD "%cd%"
	CD /D "%PIDMD_SYS%SRVRUN\"
	for /r %%f in (*) do echo %%~nxf
	POPD
exit /b

:test
	REM ECHO %pidmd_test%
	if "%pidmd_test%"=="0" echo test
	if "%pidmd_test%"=="1" echo test
	if "%pidmd_test%"=="2" echo test
	if "%pidmd_test%"=="3" echo test
	if "%pidmd_test%"=="4" echo test
	if "%pidmd_test%"=="5" echo test
	if "%pidmd_test%"=="6" echo test
	if "%pidmd_test%"=="7" echo test
	if "%pidmd_test%"=="8" echo test
	if "%pidmd_test%"=="9" echo test
	if "%pidmd_test%"=="10" echo test
	if "%pidmd_test%"=="11" echo just test!
	if "%pidmd_test%"=="12" echo Hey(#'O′)
	if %pidmd_test% GTR 12 echo There's something wrong with your designation
	
	echo.>test
	set /a pidmd_test+=1
exit /b 114514

:boot-CHECK_PATH-CUT
	SET PIDMD_TEMP_C1=%1
	SET PIDMD_TEMP_C2=%2
EXIT /B

:boot-CHECK_PATH
	SET PIDMD_TEMP_PATH=%~DP0
	SET PIDMD_TEMP_PATH=[%PIDMD_TEMP_PATH%]
	SET PIDMD_TEMP_PATH=%PIDMD_TEMP_PATH:!= %
	SET PIDMD_TEMP_PATH=%PIDMD_TEMP_PATH:"= %
	SET PIDMD_TEMP_PATH=%PIDMD_TEMP_PATH:(= %
	SET PIDMD_TEMP_PATH=%PIDMD_TEMP_PATH:)= %
	call :boot-CHECK_PATH-CUT %PIDMD_TEMP_PATH%
	IF NOT "%PIDMD_TEMP_C2%"=="" COLOR 40 & CALL :LOG-ERRO ERROR PATH %~DP0 & PAUSE & EXIT
EXIT /B

:boot
	::call PID /CONFIG-LOAD
	title -- BOOT --
	call log.cmd PIDMD BOOT #sp##sp##sp#___#sp##sp#__#sp##sp#__#sp##sp##sp##sp##sp#_#sp##sp#_#sp##sp#__
	call log.cmd PIDMD BOOT #sp##sp#/__/#sp##sp#/#sp##sp#/#sp##sp#\#sp##sp##sp#/#sp#/#sp#/#sp#/#sp##sp#\
	call log.cmd PIDMD BOOT #sp#/#sp##sp##sp##sp#_/_#sp#/__/#sp##sp##sp#/#sp##sp##sp#/#sp#/__/#sp##sp##sp##sp##sp#Ver%PM_VER%
	call log.cmd PIDMD BOOT #SP#
	call log.cmd PIDMD BOOT #SP#
	call log.cmd PIDMD BOOT LOADING
	if exist "%PIDMD_SYS%PID\SYSTEM_PID-*" (
		call log.cmd PIDMD BOOT Is#SP#runing
		exit /b
	)
	
	call log.cmd PIDMD BOOT --#SP#CHECK#SP#ENV#SP#--
	
	IF /I NOT "%PIDMD_CHECK_PATH%"=="FALSE" CALL :boot-CHECK_PATH
	
	call log.cmd PIDMD BOOT --#SP#SET#SP#FILE#SP#--
	if not exist "%PIDMD_SYS%SRV\" (
		mkdir "%PIDMD_SYS%SRV"
		mkdir "%PIDMD_SYS%SRVRUN"
		
		echo.NAME=task>"%PIDMD_SYS%SRV\task.srv"
		echo.STARTUP=TRUE>>"%PIDMD_SYS%SRV\task.srv"
		echo.TYPE=SYS>>"%PIDMD_SYS%SRV\task.srv"
		echo.USE=TRUE>>"%PIDMD_SYS%SRV\task.srv"
		echo.>>"%PIDMD_SYS%SRV\task.srv"
		echo.INFO=VIEW PID LIST>>"%PIDMD_SYS%SRV\task.srv"
		echo.>>"%PIDMD_SYS%SRV\task.srv"
		echo.CMD=task.bat>>"%PIDMD_SYS%SRV\task.srv"
		
		call log.cmd PIDMD BOOT SYS\SRV\task.srv#SP#OK
		
		echo.NAME=srv-list>"%PIDMD_SYS%SRV\srv-list.srv"
		echo.STARTUP=TRUE>>"%PIDMD_SYS%SRV\srv-list.srv"
		echo.TYPE=SYS>>"%PIDMD_SYS%SRV\srv-list.srv"
		echo.USE=TRUE>>"%PIDMD_SYS%SRV\srv-list.srv"
		echo.>>"%PIDMD_SYS%SRV\srv-list.srv"
		echo.INFO=VIEW PID LIST>>"%PIDMD_SYS%SRV\srv-list.srv"
		echo.>>"%PIDMD_SYS%SRV\srv-list.srv
		echo.CMD=srv-list.bat>>"%PIDMD_SYS%SRV\srv-list.srv
		
		call log.cmd PIDMD BOOT SYS\SRV\srv-list.srv#SP#OK
		
		echo.NAME=timestop>"%PIDMD_SYS%SRV\timestop.srv"
		echo.STARTUP=TRUE>>"%PIDMD_SYS%SRV\timestop.srv"
		echo.TYPE=SYS>>"%PIDMD_SYS%SRV\timestop.srv"
		echo.USE=TRUE>>"%PIDMD_SYS%SRV\timestop.srv"
		echo.>>"%PIDMD_SYS%SRV\timestop.srv"
		echo.RELOAD_CMD=CALL PID /start-SYSTEM solo timestop.bat /SERVER-STOP #NL# CALL PID /start-SYSTEM solo timestop.bat /SERVER-HIDE>>"%PIDMD_SYS%SRV\timestop.srv"
		echo.STOP_CMD=timestop.bat /SERVER-STOP>>"%PIDMD_SYS%SRV\timestop.srv"
		echo.>>"%PIDMD_SYS%SRV\timestop.srv"
		echo.INFO=timestop server>>"%PIDMD_SYS%SRV\timestop.srv"
		echo.>>"%PIDMD_SYS%SRV\timestop.srv"
		echo.CMD=timestop.bat /SERVER-HIDE>>"%PIDMD_SYS%SRV\timestop.srv"

		call log.cmd PIDMD BOOT SYS\SRV\timestop.srv#SP#OK
		
		echo.@echo off>"%PIDMD_ROOT%task.bat"
		echo.title TASK-LIST>>"%PIDMD_ROOT%task.bat"
		echo.:loop>>"%PIDMD_ROOT%task.bat"
		echo.cls>>"%PIDMD_ROOT%task.bat"
		echo.call pid /list>>"%PIDMD_ROOT%task.bat"
		echo.timeout 1 ^>nul>>"%PIDMD_ROOT%task.bat"
		echo.goto loop>>"%PIDMD_ROOT%task.bat"
		
		call log.cmd PIDMD BOOT task.bat#SP#OK
		
		echo.@echo off>"%PIDMD_ROOT%srv-list.bat"
		echo.title SRV-LIST>>"%PIDMD_ROOT%srv-list.bat"
		echo.:loop>>"%PIDMD_ROOT%srv-list.bat"
		echo.cls>>"%PIDMD_ROOT%srv-list.bat"
		echo.call pid /SRV-LIST>>"%PIDMD_ROOT%srv-list.bat"
		echo.timeout 1 ^>nul>>"%PIDMD_ROOT%srv-list.bat"
		echo.goto loop>>"%PIDMD_ROOT%srv-list.bat"
		call log.cmd PIDMD BOOT srv-list.bat#SP#OK
	)
	
	if not exist "%PIDMD_TMP%PID" mkdir "%PIDMD_TMP%PID"
	if not exist "%PIDMD_SYS%USER" (
		call :LOG-INFO CREATE USER
		mkdir "%PIDMD_SYS%USER" 
		ECHO.>"%PIDMD_SYS%USER\SYSTEM"
		ECHO.>"%PIDMD_SYS%USER\USER"
	)

	if not exist "%PIDMD_SYS%GROUP" (
		call :LOG-INFO CREATE GROUP
		mkdir "%PIDMD_SYS%GROUP"
		mkdir "%PIDMD_SYS%GROUP\ROOT"
		ECHO.>"%PIDMD_SYS%GROUP\ROOT\SYSTEM"
	)
	
	call log.cmd PIDMD BOOT --#sp#LOAD#sp#SET#sp#--
	
	CALL :LOG-INFO --ALL OK---
	IF /I "%PIDMD_STARTUP_STALLED%"=="TRUE" (timeout %PIDMD_STARTUP_STALLED_TIME% >nul)
	
	call log.cmd PIDMD BOOT --#SP#BOOT#SP#--
	
	set PIDMD_BOOT=true
	set PIDMD_USER=SYSTEM
	cpretpid PID.cmd /startup %2
	set PG_PID=%errorlevel%
	
	if "%PG_PID%"=="0" call log.cmd PIDMD BOOT -WAR-#SP#PID#SP#is#SP#0
	
	echo PID=%PG_PID%>"%PIDMD_SYS%PID\SYSTEM_PID-%PG_PID%"
	echo NAME=SYSTEM_PID>>"%PIDMD_SYS%PID\SYSTEM_PID-%PG_PID%"
	echo TYPE=SYSTEM>>"%PIDMD_SYS%PID\SYSTEM_PID-%PG_PID%"
	echo USER=SYSTEM>>"%PIDMD_SYS%PID\SYSTEM_PID-%PG_PID%"
	echo GROUP=SYS>>"%PIDMD_SYS%PID\SYSTEM_PID-%PG_PID%"
	echo COMVAL=PID.cmd>>"%PIDMD_SYS%PID\SYSTEM_PID-%PG_PID%"
	
	start hiderun PID.cmd /check_sys %PG_PID%
exit

:startup-getpidmdInfo
	CALL LOADCFG "%PIDMD_SYS%PID\SYSTEM_PID-*"
	SET PIDMD_SYSTEM_PID=%PID%
exit /b

:startup
	IF EXIST "%PIDMD_SYS%PID\SYSTEM_PID-*" CALL :startup-getpidmdInfo
	
	if /i "%PIDMD_BOOT%"=="true" (
		title -- PID MANAGER MODE ^| %PM_INFO% --
		call log.cmd PIDMD INFO PID#sp#MANAGER#sp#MODE
		echo.
	
		if not exist "%PIDMD_ROOT%SYSTEM.INI" call log.cmd PIDMD WARN @system.ini#sp#file#sp#path#sp#is#sp#suspected#sp#to#sp#be#sp#incorrect
		call log.cmd PIDMD INFO @Version:#sp#%PM_VER%
		call log.cmd PIDMD INFO @Run#sp#SRV:
		
		PUSHD "%CD%"
		CD /D "%PIDMD_SYS%SRV"
		for /r %%f in (*.srv) do (
			call :srvbootup %%~nxf
			REM start hiderun PID /srv-start %%~nxf
		)
		call log.cmd PIDMD INFO @Run#sp#Main:#sp#%2
		call log.cmd PIDMD INFO @Default#SP#User:#sp#%PIDMD_DEFAULT_USER%
		POPD
	)
	if "%2"=="" GOTO MAIN
	call log.cmd PIDMD INFO @Hello,%PIDMD_DEFAULT_USER%!
	echo.
	SET PIDMD_USER=%PIDMD_DEFAULT_USER%
	%2 %3 %4 %5 %6 %7 %8 %9
	exit /b
:main
	set /p cml=%username%@%userdomain%\\%cd%^>
	if "%cml%"=="exit" exit /b
	call START %cml%
	set cml=
goto main

:srvbootup
	call loadcfg "%PIDMD_SYS%SRV\%1"
	if /i "%STARTUP%"=="TRUE" (
		if /i "%USE%"=="TRUE" (
			REM call log.cmd PIDMD INFO [%NAME%]--%TYPE%--#SP#SRV#SP#RUN
			REM start hiderun PID.cmd /RUN-SRV %1 %CMD%
			start hiderun PID /srv-start %1
			call log.cmd PIDMD INFO #sp#-#sp##sp#SRV#sp#:#sp#%1#sp#[START]
		) else (
			call log.cmd PIDMD INFO #sp#-#sp##sp#SRV#sp#:#sp#%1#sp#[DISBLE]
		)
		REM ECHO RUNING > SYS/SRVRUN/%1
	)
exit /b

:info
	SET NAME=
	SET SRV=
	
	PUSHD "%CD%"
	CD /D "%PIDMD_SYS%PID"
	
	if /i "%1"=="/info-p" (
		for /r %%f in (*-%2) do (
			call loadcfg "%PIDMD_SYS%PID\%%~nxf"
		)
	)
	if /i "%1"=="/info-n" (
		for /r %%f in (%2-*) do (
			call loadcfg "%PIDMD_SYS%PID\%%~nxf"
		)
	)
	
	POPD
	
	IF "%NAME%"=="" ECHO NOT EXIST & EXIT /B
	
	echo Name:%NAME%
	IF NOT "%SRV%"=="" echo SRV:%SRV%
	echo.
	echo PID:%PID%
	echo CMD:%COMVAL%
	echo TYPE:%TYPE%
	echo FROM USER:%USER%
	echo RELY ON PID:%RELY_ON%
	
exit /b

:list
	PUSHD "%CD%"
	CD /D "%PIDMD_SYS%PID"
	for /r %%f in (*) do echo %%~nxf
	POPD
exit /b

:kill
	if "%2"=="" echo empty PID & goto :eof
	call :exist_pid %2
	if "%errorlevel%"=="1" (
		call log.cmd PIDMD ERRO %2#SP#Not#SP#exist
		if exist "%PIDMD_SYS%PID\*-%2" call log.cmd PIDMD ERRO -RMV-#SP#Clear#SP#PID#SP#file &del "%PIDMD_SYS%PID\*-%2"
		IF DEFINED SRV call log.cmd PIDMD ERRO -RMV-#SP#Clear#SP#%SRV%#SP#file & del /F /S /Q "%PIDMD_SYS%\SRVRUN\%SRV%"
		exit /b
	)
	
	CALL LOADCFG "%PIDMD_SYS%PID\*-%2"
	
	if /i "%PIDMD_BOOT%"=="true" (
		IF "%TYPE%"=="SYSTEM" (
			IF NOT EXIST "%PIDMD_SYS%GROUP\ROOT\%PIDMD_USER%" (
				call log.cmd PIDMD ERRO User#SP#%PIDMD_USER%#SP#does#SP#not#SP#have#SP#permissions#SP#kill#SP#%PID%
				exit /b
			)
		)
		IF "%TYPE%"=="SRV" (
			IF NOT EXIST "%PIDMD_SYS%GROUP\ROOT\%PIDMD_USER%" (
				call log.cmd PIDMD ERRO User#SP#%PIDMD_USER%#SP#does#SP#not#SP#have#SP#permissions#SP#kill#SP#SRV#SP#%PID%
				exit /b
			)
		)
	)
	
	if /i "%1"=="/killpid-f" (taskkill /F /PID %2>nul) else (taskkill /PID %2>nul)
	if /i "%TYPE%"=="SRV" del /F /S /Q "%PIDMD_SYS%\SRVRUN\%SRV%"
	IF DEFINED SRV del /F /S /Q "%PIDMD_SYS%\SRVRUN\%SRV%"
	del "%PIDMD_SYS%PID\*-%2" >nul
	call log.cmd PIDMD INFO END#sp#PID#sp#%2#sp#[%PID_TYPE%]
exit /b

:run
	if /i "%PIDMD_DISABLE_RUN%"=="true" exit /b -2
	if "%2"=="" exit /b
	
	set PID_TYPE=USR
	if /i "%1"=="/run-USR" set PID_TYPE=USR
	
	if /i "%PIDMD_BOOT%"=="true" (
		if /i "%1"=="/run-SRV" (
			IF NOT EXIST "%PIDMD_ALLGROUP%ROOT\%PIDMD_USER%" (
				CALL LOG.CMD PIDMD ERRO User#SP#%PIDMD_USER%#SP#does#SP#not#SP#have#SP#permissions[%2#SP#-#SP#%3]
				EXIT /B
			) ELSE (
				set PID_TYPE=SRV
				set SRV=%2
			)
		)
		if /i "%1"=="/run-SYSTEM" (
			IF NOT EXIST "%PIDMD_ALLGROUP%ROOT\%PIDMD_USER%" (
				CALL LOG.CMD PIDMD ERRO User#SP#%PIDMD_USER%#SP#does#SP#not#SP#have#SP#permissions[%2]
				EXIT /B
			) ELSE (
				set PID_TYPE=SYSTEM
			)
		)
	)
	
	if /i "%1"=="/run-SRV" (cpretpid %3 %4 %5 %6 %7 %8 %9>NUL) else (cpretpid %2 %3 %4 %5 %6 %7 %8 %9>NUL)
	
	set PG_PID=%errorlevel%
	set PG_NAME=%2
	if /i "%1"=="/run-SRV" (set PG_NAME=%3)
	set PG_NAME=%PG_NAME:\=#BS#%
	set PG_NAME=%PG_NAME:/=#SS#%
	set PG_NAME=%PG_NAME::=#CL#%
	
	if "%PG_PID%"=="0" call logHE PIDMD ERRO -ERR-#sp#%3#sp#Create#sp#fail & popd & exit /b
	
	for /F  %%p in ('call pid.cmd /system_pid-pid') do SET SYSTEM_PID_RELY_ON=%%p
	
	if /i "%1"=="/run-SRV" (
		call log.cmd PIDMD INFO --SRV--#sp#%2#SP#RUN#SP#in#SP#%PG_PID%
		echo PID=%PG_PID%>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
		echo NAME=%3>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
		echo TYPE=SRV>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
		echo USER=%PIDMD_USER%>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
		echo GROUP=SYS>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
		echo SRV=%2>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
		echo COMVAL=%4 %5 %6 %7 %8 %9>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
		
		if "%SYSTEM_PID_RELY_ON%"=="" (
			echo RELY_ON=SOLO>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
		) ELSE (
			echo RELY_ON=%SYSTEM_PID_RELY_ON%>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
		)
		
		echo %PG_PID%>"%PIDMD_SYS%SRVRUN\%2"
	) else (
		call log.cmd PIDMD INFO RUN#sp#%2#SP#in#SP#%PG_PID%
		echo PID=%PG_PID%>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
		echo NAME=%2>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
		echo TYPE=%PID_TYPE%>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
		echo USER=%PIDMD_USER%>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
		echo GROUP=SYS>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
		echo COMVAL=%3 %4 %5 %6 %7 %8 %9>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
		if "%SYSTEM_PID_RELY_ON%"=="" (
			echo RELY_ON=SOLO>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
		) ELSE (
			echo RELY_ON=%SYSTEM_PID_RELY_ON%>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
		)
	)
	
	start hiderun PID.cmd /check_pid %PG_PID% %PG_NAME% %PID_TYPE% SOLO
	popd
exit /b %PG_PID%


:start
	if /i "%PIDMD_BOOT%"=="true" (
		if /i "%1"=="/start-SRV" (
			IF NOT EXIST "%PIDMD_ALLGROUP%ROOT\%PIDMD_USER%" (
				CALL :LOG-ERRO User %PIDMD_USER% does not have permissions[%2-%3]
				EXIT /B
			) ELSE (
				set PID_TYPE=SRV
				set SRV=%2
			)
		)
		if /i "%1"=="/start-SYSTEM" (
			IF NOT EXIST "%PIDMD_ALLGROUP%ROOT\%PIDMD_USER%" (
				CALL :LOG-ERRO User %PIDMD_USER% does not have permissions[%2]
				EXIT /B
			) ELSE (
				set PID_TYPE=SYSTEM
			)
		)
	)
	
	if /i not "%2"=="SOLO" (
		if not exist "%PIDMD_ROOT%SYS\PID\*-%2" (
			CALL :LOG-ERRO Rely on pid[%2] not exist
			exit /b
		)
	)
	
	if DEFINED PID_START_PATH_SET (cpretpid %PID_START_PATH_SET%) else 	(
		if not "%3"=="" (cpretpid %3 %4 %5 %6 %7 %8 %9) else (CALL :LOG-ERRO Path not set & exit /b -1)
	)

	set PG_PID=%errorlevel%
	set PID_RELY_ON=%2
	SET PG_NAME=%3
	SET PID_TYPE=USR
	SET SRV=%3
	IF /I "%1"=="/START-USR" SET PID_TYPE=USR
	IF /I "%1"=="/START-SRV" SET PID_TYPE=SRV
	IF /I "%1"=="/START-SYSTEM" SET PID_TYPE=SYSTEM
	
	if "%PG_PID%"=="0" CALL :LOG-ERRO Create fail & exit /b -1
	
	goto SET_PID_FILE

:SET_PID_FILE
	echo PID=%PG_PID%>"%PIDMD_ROOT%SYS\PID\%3-%PG_PID%"
	echo NAME=%3>>"%PIDMD_ROOT%SYS\PID\%3-%PG_PID%"
	echo TYPE=%PID_TYPE%>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
	echo USER=%PIDMD_USER%>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
	
	echo GROUP=SYS>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
	IF /I "%1"=="/START-SRV" echo SRV=%3>>"%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
	
	if DEFINED PID_START_PATH_SET (
			echo COMVAL=%PID_START_PATH_SET%>>"%PIDMD_ROOT%SYS\PID\%3-%PG_PID%"
		) else (
			echo COMVAL=%4 %5 %6 %7 %8>>"%PIDMD_ROOT%SYS\PID\%3-%PG_PID%"
		)
		echo RELY_ON=%2>>"%PIDMD_ROOT%SYS\PID\%3-%PG_PID%"
	)
	
	IF /I "%PID_TYPE%"=="SRV" ECHO.%PG_PID%>"%PIDMD_SYS%SRVRUN\%SRV%"
	
	start hiderun PID.cmd /check_pid %PG_PID% %PG_NAME% %PID_TYPE% %PID_RELY_ON%
	
	set PID_START_PATH_SET=
	SET PID_RUN_PATH_SET=
	
	exit /b %PG_PID%

:LOGHE-INFO
	SET _LOG_STR=%*
	SET _LOG_STR=%_LOG_STR: =#sp#%
	CALL LOGHE.CMD PIDMD INFO %_LOG_STR%
	SET _LOG_STR=
EXIT /B

:LOGHE-WARN
	SET _LOG_STR=%*
	SET _LOG_STR=%_LOG_STR: =#sp#%
	CALL LOGHE.CMD PIDMD WARN %_LOG_STR%
	SET _LOG_STR=
EXIT /B

:LOGHE-ERRO
	SET _LOG_STR=%*
	SET _LOG_STR=%_LOG_STR: =#sp#%
	CALL LOGHE.CMD PIDMD ERRO %_LOG_STR%
	SET _LOG_STR=
EXIT /B

:LOG-INFO
	SET _LOG_STR=%*
	SET _LOG_STR=%_LOG_STR: =#sp#%
	CALL LOG.CMD PIDMD INFO %_LOG_STR%
	SET _LOG_STR=
EXIT /B

:LOG-WARN
	SET _LOG_STR=%*
	SET _LOG_STR=%_LOG_STR: =#sp#%
	CALL LOG.CMD PIDMD WARN %_LOG_STR%
	SET _LOG_STR=
EXIT /B

:LOG-ERRO
	SET _LOG_STR=%*
	SET _LOG_STR=%_LOG_STR: =#sp#%
	CALL LOG.CMD PIDMD ERRO %_LOG_STR%
	SET _LOG_STR=
EXIT /B

:exist_pid
::call :exist_pid [PID]
	FOR /F %%s in ('TASKLIST /FI "PID eq %1"') do set cmdput=%%s
	if /i "%PIDMD_LANG%"=="zh" (
		if "%cmdput%"=="%zh_check_pid_info%" exit /b 1
	)
	if /i "%PIDMD_LANG%"=="en" (
		if "%cmdput%"=="%en_check_pid_info%" exit /b 1
	)
exit /b 0

:check_pid
	set PG_PID=%2
	set PG_NAME=%3
	set PID_TYPE=%4
	set PID_RELY_ON=%5
	
	if /i "%PID_TYPE%"=="SYSTEM" (
		title PIDSYS %PG_NAME% %PG_PID%
	) else (
		title PIDCHECK %PG_NAME% %PG_PID%
	)
	
	call loadcfg "%PIDMD_SYS%PID\%PG_NAME%-%PG_PID%"
	echo %PG_PID% %PG_NAME% %PID_TYPE%
	call log.cmd PIDMD INFO PC-%PG_PID%,RUN:%PG_PID%,NAME:%PG_NAME%,TYPE:%PID_TYPE%
	:check_pid_looop
		
		if /i not "%PID_RELY_ON%"=="SOLO" (
			IF NOT EXIST "%PIDMD_ROOT%SYS\PID\*-%PID_RELY_ON%" (
				start hiderun call PID.cmd /killpid-f %PG_PID%
				exit /b
			)
		)
		
		echo [FILE]
		if not exist "%PIDMD_SYS%PID\*-%2" (
			call log.cmd PIDMD INFO PC-%PG_PID%,FILE#SP#END,GOOD#SP#BEY
			start hiderun call PID.cmd /killpid-f %PG_PID%
			exit
		)
		
		echo [PID]
		call :exist_pid %2
		if "%errorlevel%"=="1" (
			call log.cmd PIDMD INFO PC-%PG_PID%,PID#SP#END,GOOD#SP#BEY
			start hiderun call PID.cmd /killpid %PG_PID%
			exit
		)
		
		echo [SRV-FILE]
		if /i "%PID_TYPE%"=="SRV" (
			echo %SRV%
			IF NOT exist "%PIDMD_SYS%SRVRUN\%SRV%" (
				call log.cmd PIDMD INFO PC-%PG_PID%-DOWN SRV#SP#END,GOOD#SP#BEY
				start hiderun call PID.cmd /killpid %PG_PID%
			)
		)
		timeout 1 >nul
	goto check_pid_looop
exit
	
:check_sys
	call log.cmd PIDMD INFO PIDSYS#SP#CHECK#SP#RUN[%2]
	title PIDSYS %SYS_PID% SYSTEM_PID
	set SYS_PID=%2
	:check_sys_loop
		if not exist "%PIDMD_SYS%PID\*-%SYS_PID%" (
			call log.cmd PIDMD DOWN ---SYS--END---
			start hiderun %~dp0pid.cmd /sys_end
			exit
		)
		call :exist_pid %SYS_PID%
		if "%errorlevel%"=="1" (
			call log.cmd PIDMD DOWN ---SYS--END---
			start hiderun %~dp0pid.cmd /sys_end
			exit
		)
	goto check_sys_loop

:sys_end_kill	
	call loadcfg %1
	if /i "%TYPE%"=="SYSTEM" exit /b
	call log.cmd PIDMD DOWN --PG:%NAME%^|%PID%#sp#END--
	start hiderun call PID.cmd /killpid-f %PID%
exit /b

:sys_get_pid
		PUSHD "%CD%"
		CD /D "%PIDMD_SYS%PID\"
		for /r %%f in (SYSTEM_PID-*) do call loadcfg "%%~nxf"
		call log.cmd PIDMD DOWN %NAME%[%PID%]
		set SYS_PID=%PID%
		POPD
exit /b

:sys_kill_pidcheck
	set _kill_pck_pid=%1
	set _kill_pck_pid=%_kill_pck_pid:~1,-1%
	call log.cmd PIDMD DOWN --#sp#KILL#sp#%_kill_pck_pid%
	taskkill /f /pid %_kill_pck_pid% >nul
exit /b

:sys_end
	SET bfuser=%PIDMD_USER%
	SET PIDMD_USER=SYSTEM
	if "%SYS_PID%"=="" call :sys_get_pid
	if "%SYS_PID%"=="" echo Not found SYSTEM_PID. Noting to end. & pause & SET PIDMD_USER=%bfuser% & exit /b

	cd /d "%PIDMD_TMP%"
	echo.>"%PIDMD_TMP%PIDMD-END"
	timeout 2 >nul

	call log.cmd PIDMD DOWN --SYS#sp#END,#sp#SEND#sp#KILL#sp#MSG--
	call log.cmd PIDMD DOWN --END#sp#SRV--
	cd /d "%PIDMD_SYS%SRVRUN\"
	for /r %%f in (*) do (
		call log.cmd PIDMD DOWN ---#sp#STOP#sp#SRV#sp#%%~nxf#sp#---
		start hiderun call pid.cmd /srv-stop %%~nxf
	)
	
	call log.cmd PIDMD DOWN --END#sp#PG--
	cd /d "%PIDMD_SYS%PID\"
	for /r %%f in (*) do call :sys_end_kill %%f
	
	start hiderun call PID.cmd /killpid-f %SYS_PID%
	
	IF /i "%PIDMD_END_CLEAR%"=="false" goto :SYS_END-out
	
	call log.cmd PIDMD DOWN --#sp#Clear#sp#PIDCHECK#sp#--
	for /F "tokens=1,2,3,4,5,6,7,8,9 delims=," %%1 in ('tasklist.exe /v /fo csv ^| findstr /i "PIDCHECK"') do (
		call :sys_kill_pidcheck %%2
	)
	
	call log.cmd PIDMD DOWN --#sp#Clear#sp#HIDERUN#sp#--
	for /F "tokens=1,2,3,4,5,6,7,8,9 delims=," %%1 in ('tasklist.exe /v /fo csv ^| findstr /i "HIDERUN"') do (
		call :sys_kill_pidcheck %%2
	)

	:SYS_END-out
	rem del /f /s /q tmp\*
	del /f /s /q "%PIDMD_TMP%\PIDMD-END"
	call log.cmd PIDMD DOWN --BEY--
	CALL log.cmd /clearlt
	timeout 2 >nul
	exit
