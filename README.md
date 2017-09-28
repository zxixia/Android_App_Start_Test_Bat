# Android_App_Start_Test_Bat
```shell
Android App Launch Time test bat version 1.0.2
Author: xixia
input format:
  start-activity <-t> <-a> [-c] [-k]
parameter explain:
   -t <num between 1~999>           - how many times to do this launch tests
   -a <componentName/activityName>  - example:
                                    - com.android.calculator2/.Calculator
   -c <componentName>               - default:intercept from para -a
                                    - example:com.android.calculator2
   -k <num between 1~4>             - choose which command to kill the app
                                    - default:
                                    -  1 :
                                    -      adb shell pm clear <compnentName>
                                    -  2 : adb shell kill <process-id>
                                    -  3 : adb shell am force-stop
                                         : <compnentName>
                                    -  4 : adb reboot : to restart the device
example:
  start-activity -t 5 -a com.android.calculator2/.Calculator -c com.android.calculator2 -k 2
```
