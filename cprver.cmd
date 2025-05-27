@echo off
setlocal enabledelayedexpansion
set CPRVER_VERSION=1.0.0

if /i "%~1"=="/help" (
	echo.call cprver.cmd ^<ver1^> ^<ver2^>
    echo.
    echo.errorlevel:
    echo.ver1 = ver2  ^|  0 
    echo.ver1 ^> ver2  ^|  1
    echo.ver1 ^< ver2  ^|  2
	echo.
	echo.v%CPRVER_VERSION%
    exit /b 3
)

set ver1=%~1
set ver2=%~2

rem ��ְ汾��1�����鲢ת��Ϊ����
set ver1=%ver1:.= %
set count1=0
for %%a in (%ver1%) do (
    set /a count1+=1
    set /a "ver1_!count1!=%%a" 2>nul || set /a "ver1_!count1!=0"
)

rem ��ְ汾��2�����鲢ת��Ϊ����
set ver2=%ver2:.= %
set count2=0
for %%a in (%ver2%) do (
    set /a count2+=1
    set /a "ver2_!count2!=%%a" 2>nul || set /a "ver2_!count2!=0"
)

rem ȷ��������
set max_parts=%count1%
if %count2% gtr %max_parts% set max_parts=%count2%

rem ��αȽϰ汾��
for /l %%i in (1,1,%max_parts%) do (
    set v1=0
    set v2=0
    if %%i leq %count1% set /a v1=!ver1_%%i!
    if %%i leq %count2% set /a v2=!ver2_%%i!
    if !v1! gtr !v2! (
        REM echo %~1 ���� %~2
		setlocal DisableDelayedExpansion
        exit /b 1
    )
    if !v1! lss !v2! (
        REM echo %~2 ���� %~1
		setlocal DisableDelayedExpansion
        exit /b 2
    )
)

REM echo �����汾�����
setlocal DisableDelayedExpansion
exit /b 0