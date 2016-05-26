echo off
set testTimes=0
set activityName=activityName_error
set componentName=componentName_error
set killAppType=1

set error_list=-t -a -c -k

:LOOP

	set index=%1
	if %index%! == ! goto DO_TEST
	
    if "%index%"=="-t" (
        goto get_para_testTimes
    )    
    
    if "%index%"=="-a" (
        goto get_para_activityName
    )

    if "%index%"=="-c" (
        goto get_para_componentName
    )

    if "%index%"=="-k" (
        goto get_para_killAppType
    )
    ::走到这一步，说明我们碰到了出了上面我们要处理四种参数以外的其他奇怪字符
    goto tip
:get_next_para
    ::连续跳跃两个参数，越过当前"-t"这样的参数，以及它后面紧跟的参数
    shift
    shift
	goto LOOP
	

:tip
cls
echo Android App Launch Time test bat version 1.0.2
echo Author: xixia
echo input format:
echo   start-activity ^<-t^> ^<-a^> [-c] [-k]
echo parameter explain:
echo    -t ^<num between 1~999^>           - how many times to do this launch tests
echo    -a ^<componentName/activityName^>  - example:
echo                                     - com.android.calculator2/.Calculator
echo    -c ^<componentName^>               - default:intercept from para -a
echo                                     - example:com.android.calculator2
echo    -k ^<num between 1~4^>             - choose which command to kill the app
echo                                     - default: 
echo                                     -  1 : 
echo                                     -      adb shell pm clear ^<compnentName^>
echo                                     -  2 : adb shell kill ^<process-id^>
echo                                     -  3 : adb shell am force-stop 
echo                                          : ^<compnentName^>
echo                                     -  4 : adb reboot : to restart the device 
echo example:
echo   start-activity -t 5 -a com.android.calculator2/.Calculator -c com.android.calculator2 -k 2
pause
goto END_0

:get_para_testTimes
    if "%2"=="" goto tip
    echo %error_list% | findstr \%2 && goto tip||set /a testTimes=%2
    if  not "%2"=="" ( 
        if %2 lss 1 goto tip
        if %2 gtr 999 goto tip
    )    
    goto get_next_para

:get_para_activityName
    if "%2"=="" goto tip
    echo %error_list% | findstr \%2 && goto tip||set activityName=%2
    goto get_next_para

:get_para_componentName
    if "%2"=="" goto tip
    echo %error_list% | findstr \%2 && goto tip||set componentName=%2
    goto get_next_para

:get_para_killAppType
    if "%2"=="" goto tip
    echo %error_list% | findstr \%2 && goto tip||set killAppType=%2
    if  not "%2"=="" ( 
        if %2 lss 1 goto tip
        if %2 gtr 4 goto tip
    )    
    goto get_next_para

:DO_TEST
cls
if "%testTimes%"=="0" goto tip
if "%activityName%"=="activityName_error" goto tip
if "%componentName%"=="componentName_error" (
    for /F  "tokens=1* delims=/" %%A in ("%activityName%") do (
        set componentName=%%A
    )
)

echo Start> start-activity.sa_tmp

echo -t:%testTimes%
echo -a:%activityName%
echo -c:%componentName%
echo -k:%killAppType%
echo ==================

set testLoopCount=0
:TEST_LOOP
    set /a testLoopCount=%testLoopCount%+1
    if %testLoopCount% gtr %testTimes% goto TEST_LOOP_END
        echo No %testLoopCount%'s test
        adb shell am start -W -n %activityName% >> start-activity.sa_tmp
        ::睡眠5秒
        ping -n 5 127.0>nul
        if "%killAppType%"=="1" ( adb shell pm clear %componentName%  )
        if "%killAppType%"=="2" ( call :kill-component "%componentName%" )
        if "%killAppType%"=="3" (adb shell am force-stop %componentName%  )
        if "%killAppType%"=="4" (adb reboot)
:NOCONNECTED
        if "%killAppType%"=="4" (
            if %testLoopCount% == %testTimes% goto TEST_LOOP_END
            adb devices | findstr "\<device\>"
            if ERRORLEVEL 1 goto NOCONNECTED
            echo ADB Connected
            echo Sleep 60 secs
            ping -n 60 127.0>nul )
    goto TEST_LOOP
:TEST_LOOP_END
::清屏
cls
echo -t:%testTimes%
echo -a:%activityName%
echo -c:%componentName%
echo -k:%killAppType%
echo ==================
echo Result:
::输出启动时间
@findstr /b /n /c:"TotalTime" start-activity.sa_tmp 
goto END_0

::调用函数
:kill-component
::暂时输出到kill-component.kc_tmp文件中
adb shell ps | find %1 > kill-component.kc_tmp

for /f "tokens=1,2,3" %%a in (kill-component.kc_tmp) do (
    echo %%b
    adb shell kill %%b
) 

if exist kill-component.kc_tmp (
    del kill-component.kc_tmp
)
goto END_0

:END_0