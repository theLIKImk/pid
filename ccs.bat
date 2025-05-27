@echo off

set CONFIG_CENTER_VERSION=1.2.3
set CONFIG_CENTER_QUEUE=%~dp0TMP\ccs_queue\

IF "%CONFIG_CENTER_FILE%"=="" (set CONFIG_CENTER_FILE=%~dp0system.ini) ELSE (
	IF NOT EXIST "%CONFIG_CENTER_FILE%" call LOG CCS WARN FILE#SP#"%CONFIG_CENTER_FILE: =#SP#%"#SP#NOT#SP#EXIST
)

if not exist "%CONFIG_CENTER_QUEUE%" mkdir "%CONFIG_CENTER_QUEUE%"

if not exist "%CONFIG_CENTER_FILE%" (
	echo.[SYS]>%CONFIG_CENTER_FILE%
	echo.NAME=Locale config group>>%CONFIG_CENTER_FILE%
	echo.INFO=none>>%CONFIG_CENTER_FILE%
	echo.VERSION=%CONFIG_CENTER_VERSION%>>%CONFIG_CENTER_FILE%
	echo.DATA_FILE=%CONFIG_CENTER_FILE%>>%CONFIG_CENTER_FILE%
	echo.CREATE_DATE=%date%>>%CONFIG_CENTER_FILE%
	echo.CREATE_TIME=%time%>>%CONFIG_CENTER_FILE%
	echo.CREATE=DONE>>%CONFIG_CENTER_FILE%
	echo.##WELCOME,TYPE "CCS /HELP" GET HELP IN SHELL>>%CONFIG_CENTER_FILE%
)

if /i "%1"=="/check-blk" goto :check_reg_blk
if /i "%1"=="/check-key" goto :check_key_in_blk
if /i "%1"=="/check-key-nblk" goto :check_key_nblk
if /i "%1"=="/blk-setinfo" goto :blk_setinfo
if /i "%1"=="/blk-reg" goto :blk_reg
if /i "%1"=="/blk-list" goto :blk_list
if /i "%1"=="/blk-keylist" goto :blk_keylist
if /i "%1"=="/blk-rm" goto :blk_rm
if /i "%1"=="/blk-info" goto :blk_info
if /i "%1"=="/key-add" goto :key_add
if /i "%1"=="/key-changeval" goto :key_change
if /i "%1"=="/key-get" goto :key_get
if /i "%1"=="/key-rm" goto :key_rm
if /i "%1"=="/key-nblk-changeval" goto :key_nblk_change
if /i "%1"=="/key-nblk-add" goto :key_nblk_add
if /i "%1"=="/key-nblk-rm" goto :key_nblk_rm
if /i "%1"=="/send" echo.%2 %3 %4 %5 %6 %7 %8 %9>%CONFIG_CENTER_QUEUE%\%random%
if /i "%1"=="/server" setlocal EnableDelayedExpansion & call log.cmd CCS INFO ON & goto :server
if /i "%1"=="/server-hide" hidecon & setlocal EnableDelayedExpansion & call log.cmd CCS INFO ON  & goto :server
if /i "%1"=="/server-stop" call log.cmd CCS INFO OFF & goto :server
if /i "%1"=="/version" goto :version

if /i "%1"=="/help" goto :help

exit /b 1

:help
	echo.ccs.bat
	echo.  /check-blk ^<blk^> 
	echo.  /check-key ^<blk^> ^<key^>
	echo.  /check-key-nblk ^<key^>
	echo.  /blk-keylist ^<blk^>
	echo.  /blk-info ^<blk^>
	echo.  /blk-list
	echo.  /blk-reg ^<blk^> [info:text]
	echo.  /blk-rm ^<blk^>
	echo.  /blk-setinfo ^<blk^> ^<info:text^>
	echo.  /key-add ^<blk^> ^<key^> [val]
	echo.  /key-changeval ^<blk^> ^<key^> ^<val^>
	echo.  /key-get ^<blk^> ^<key^>
	echo.  /key-rm ^<blk^> ^<key^>
	echo.  /key-nblk-changeval ^<key^> ^<val^>
	echo.  /key-nblk-add ^<key^> [val]	
	echo.  /key-nblk-rm ^<key^> 
	echo.
	echo.  /send ^<css-cmd^>
	echo.  /server
	echo.  /server-hide
	echo.  /server-stop
	echo.
	echo.  /version
	echo.
	echo.Version: %CONFIG_CENTER_VERSION%
exit /b 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:version
	echo.%CONFIG_CENTER_VERSION%
exit /b %CONFIG_CENTER_VERSION%

:server  
	if /i "%1"=="/server-stop" echo.stopserver>%CONFIG_CENTER_QUEUE%stopserver & exit /b 0
	
	if exist "%CONFIG_CENTER_QUEUE%stopserver" (
		del "%CONFIG_CENTER_QUEUE%stopserver"
		echo.Off
		exit /b 0
	)
	
	for /r "%CONFIG_CENTER_QUEUE%" %%f in (*) do (
		set /p cmd=<%%f
		start "" cmd /c "ccs.bat !cmd! & exit"
		del %%f
	) 
goto server

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:blk_info
	call :check_reg_blk %2
	if "%errorlevel%"=="1" exit /b 1
	
	sed -n "/^\[%2\]/I,/^\[/I {/^\[%2\]/d; /^\[/d; s/^##//p}" "%CONFIG_CENTER_FILE%"
exit /b 0

:blk_setinfo
	call :check_reg_blk %2
	if "%errorlevel%"=="1" exit /b 1
	
	sed -i "/^\[%2\]/I,/^\[/I {s/^##.*/##%3/}" "%CONFIG_CENTER_FILE%"
	
exit /b 0

:blk_rm

	if /i "%2"=="SYS" echo Can not remove block SYS & exit /b 1

	call :check_reg_blk %2
	if "%errorlevel%"=="1" exit /b 1
	
	sed -i "/^\[%2\]/I,/^\[[^]]\+\]/I { /^\[%2\]/I d; /^\[[^]]\+\]/I!d }" "%CONFIG_CENTER_FILE%"
	echo.Remove block %2
exit /b 0

:blk_keylist
	call :check_reg_blk %2
	if "%errorlevel%"=="1" exit /b 1
	
	sed -n "/^\[%2\]/I,/^\[/I {/^\[%2\]/I d; /^\[/d; /^[^#]/p}" "%CONFIG_CENTER_FILE%"
exit /b 0

:blk_list
	sed -n "s/^\[\(.*\)\]/\1/p" "%CONFIG_CENTER_FILE%"
exit /b 0

:blk_reg
	call :check_reg_blk %2
	if "%errorlevel%"=="0" echo block %2 exist & exit /b 1
	
	sed -i "$a[%2]\n##%3" "%CONFIG_CENTER_FILE%"
	echo.Registered
exit /b 0

:check_reg_blk
	if "%1"=="/check-blk" (set blk=%2) else (set blk=%1)
	
	FOR /F %%s in ('sed -n "/^\[%blk%\]/I p" "%CONFIG_CENTER_FILE%"') do set search_blk=%%s
	if "%search_blk%"=="" echo Waring: Block %blk% is not register & exit /b 1
	set search_blk=
exit /b 0

:check_key_in_blk

	if "%1"=="/check-key" (set blk=%2 & set key=%3) else (set blk=%1 & set key=%2)

	call :check_reg_blk %blk%
	if "%errorlevel%"=="1" exit /b 1

	FOR /F %%s in ('sed -n "/^\[%blk%\]/I,/^ *\[/I{/^%key% *=/Ip}" "%CONFIG_CENTER_FILE%"') do set search_key_in_lable=%%s
	if "%search_key_in_lable%"=="" echo Waring: Key %key% is not exist & exit /b 1
	set search_key_in_lable=
exit /b 0

:check_key_nblk
	if "%1"=="/check-key-nblk" (set key=%2) else (set key=%1)
	
	FOR /F %%s in ('sed -n "/^%key%=.*/Ip" "%CONFIG_CENTER_FILE%"') do set search_key_nblk=%%s
	if "%search_key_nblk%"=="" echo Waring: Key %key% is not exist & exit /b 1
	set search_key_nblk=
exit /b 0

:key_add
	call :check_reg_blk %2
	if "%errorlevel%"=="1" exit /b 1
	call :check_key_in_blk %2 %3
	if "%errorlevel%"=="0" echo Key %3 exist & exit /b 1
	
	sed -i "/^\[%2\]/a\%3=%4" "%CONFIG_CENTER_FILE%"
	echo Create %3 in [%2].
exit /b 0

:key_rm
	call :check_key_in_blk %2 %3
	if "%errorlevel%"=="1" echo Key %3 not exist & exit /b 1
	
	sed -i "/^\[%2\]/,/^\[/ {/%3/d}" "%CONFIG_CENTER_FILE%"
exit /b 0

:key_get
	if "%3"=="" echo key value is empty & exit /b 1
	
	call :check_key_in_blk %2 %3
	if "%errorlevel%"=="1" echo Get Fail & exit /b 1
	
	FOR /F "delims=*" %%s in ('sed -n "/^\[%2\]/I,/^ *\[/I{/\b%3 *=/I{s/.*=//p}}" "%CONFIG_CENTER_FILE%"') do set %2_%3=%%s
exit /b 0


:key_change
	if "%4"=="" echo value is empty & exit /b 1
	
	call :check_key_in_blk %2 %3
	if "%errorlevel%"=="1" echo Change Fail & exit /b 1
	
	sed -i "/^\[%2\]/I,/^ *\[/I s/^%3 *=.*/%3=%4/I" "%CONFIG_CENTER_FILE%"
exit /b 0


:key_nblk_change
	if "%3"=="" echo value is empty & exit /b 1
	
	call :check_key_nblk %2
	if "%errorlevel%"=="1" echo Change Fail & exit /b 1
	
	sed -i "s/%2=.*/%2=%3/Ig" "%CONFIG_CENTER_FILE%"
exit /b 0

:key_nblk_add
	if "%2"=="" echo value is empty & exit /b 1
	
	call :check_key_nblk %2
	if "%errorlevel%"=="0" echo Add Fail & exit /b 1
	echo %2=%3>>"%CONFIG_CENTER_FILE%"
exit /b 0

:key_nblk_rm
	if "%2"=="" echo value is empty & exit /b 1
	
	call :check_key_nblk %2
	if "%errorlevel%"=="1" echo RM Fail & exit /b 1
	sed -i "/^%2=*/d" "%CONFIG_CENTER_FILE%"
exit /b 0
