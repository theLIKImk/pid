# PID.BAT
Simple BAT script process management script  
It can help you manage multiple BAT script windows

> [!TIP]
> Do not include half-width spaces and parentheses in the path  
> 路径中不要包含半角空格和括号  

> [!WARNING]
> This script cannot obtain the same running results on multiple computers, please pay attention to ensure the security of your data!  
> **I am not responsible for the data on your hard drive!!**  
> 本脚本未能在多个电脑获取同样运行结果，请注意保证你的数据安全！**我无法负责你硬盘上的数据!!**

## It can do?
> Simple management of multitasking script processes  
> Simple user system(beta) 

## All command
| Command | info |
| -------------- | ------------------------ |
| `call pid /start {<PID>\|SOLO} <path>` <br> `call pid /start-USR {<PID>\|SOLO} <path>` <br> `call pid /start-SRV {<PID>\|SOLO} <path>` <br> `call pid /start-START {<PID>\|SOLO} <path>` | Create separate processes and subprocesses |  
| `call pid /run <Path> ` | Run the program in a new window and create the corresponding file in `#PID.BAT DIR#\SYS\PID` |  
| `call pid /run-USR <Path>` | (by User)Run the program in a new window and create the corresponding file in `#PID.BAT DIR#\SYS\PID` |  
| `call pid /run-SRV <SRV:name> <SRV:cmd>` | (by service)Run the program in a new window and create the corresponding file in `#PID.BAT DIR#\SYS\PID` |  
| `call pid /run-SYSTEM <Path>` | (by system/root)Run the program in a new window and create the corresponding file in `#PID.BAT DIR#\SYS\PID` |  
| `call pid /killpid <PID>` | end process |
| `call pid /killpid-f <PID>` | Force end of process |
| `call pid /list` | Show process list |
| `call pid /exist_pid <PID>` | Check whether the process PID exists (%errorleve% is 0 if it exists, otherwise it is 1) |
| `call pid /info-p <PID>` | Get brief information based on process PID |
| `call pid /info-n <PID>` | Get brief information based on process program name |
| `call pid /boot [Path]` | Start management mode and run customized programs |
| `call pid /sys_end` | End management mode and force the end of all processes and services |
| `call pid /srv-list` | Service list |
| `call pid /srv-info <SRV:name>` | Get service info |
| `call pid /srv-start <SRV:name>` | Start service |
| `call pid /srv-stop <SRV:name>` | Stop service |
| `call pid /srv-restart <SRV:name>` | Restart service |
| `call pid /srv-enable <SRV:name>` | enable service startup |
| `call pid /srv-disable <SRV:name>` | disable service startup |
| `call pid /usr` | Set user |
| `call pid /usr-list` | User list(`#PID.BAT DIR#\SYS\USER`) |
| `call pid /usr-add <USERNAME>` | User added |
| `call pid /usr-rmv <USERNAME>` | User delete |
| `call pid /group-list` | group list(`#PID.BAT DIR#\SYS\GROUP`) |
| `call pid /group-add <GROUP>` | Group add |
| `call pid /group-rmv <GROUP>` | Group add remove |
| `call pid /group-setuser <USERNAME> <GROUP>` | Set the users to be added to the group |
| `call pid /group-rmuser <USERNAME> <GROUP>` | Set the users to be removed from the group |
| `call pid /config-load` | Load system.ini |
| `call pid /system_pid-pid` | Get SYSTEM_PID
| `call pid /system_pid-status` | TYPE `#PID.BAT DIR#\SYS\PID\SYSTEM_PID-xxxxxx` |
| `call pid /log` | Print PID process log(`#PID.BAT DIR#\SYS\LOG\PIDMD.LOG`)
| `call pid /title` | Print management mode LOGO |
| `call pid /help` | Print command list |
| `call pid /version` | Version |
| `call pid /about` | About |
| `call pid /about-gpl` | GPL 3.0 |

## .srv File `#PID.BAT DIR#\SYS\SRV`
```
NAME=<Service name>
#automatic start
STARTUP=TRUE
# Service type
TYPE=SYS
#Enable this service
USE=TRUE

RELOAD_CMD=<cmd 1>#NL#<cmd 2>#NL#<cmd 3>
STOP_CMD=<cmd 1>#NL#<cmd 2>#NL#<cmd 3>

INFO=<Service details>

CMD=<Program> <Arg 1> <Arg 2> ... <Arg 9>
```

## system.ini config file `#PID.BAT DIR#\system.ini`
```
[PIDMD]
#Lang: zh, en
LANG=zh
CHCP_CODE=936
CMD_COLOR=F0
ROOT=D:\#PID.BAT DIR#\
SYS=%PIDMD_ROOT%SYS\
TMP=%PIDMD_ROOT%TMP\
LOG=%PIDMD_SYS%LOG\
SRV=%PIDMD_SYS%SRV\
ALLUSER=%PIDMD_SYS%USER\
ALLGROUP=%PIDMD_SYS%GROUP\
DEFAULT_USER=SYSTEM
GLOBAL_CMD=
DISABLE_RUN=FALSE
STARTUP_STALLED=TRUE
STARTUP_STALLED_TIME=1
END_CLEAR=FALSE
CHECK_PATH=TRUE
```

##  Version & Change Log

<details>
  <summary>0.075.10</summary>

  > Add `/srv-enable` <br>
  > Add `/srv-disable` <br>
  > Add `/usr`
</details>

<details>
  <summary>0.075.9</summary>
  
  > Add Config and pack
</details>

<details>
  <summary>0.075.8</summary>
  
  > Other BUG fixes 
</details>

<details>
  <summary>0.075.7</summary>
  
  > Fix srv cant reload <br>
  > Add `/CONFIG-LOAD`<br>
  > Speed ​​optimization<br>
  > Other BUG fixes 
</details>

<details>
  <summary>0.075.6</summary>
  
  > Add `CHECK_PATH` Setting<br>
  > Other BUG fixes 
</details>

<details>
  <summary>0.075.5</summary>
  
  > Add `END_CLEAR` Setting<br>
  > Other BUG fixes 
</details>

<details>
  <summary>0.075.4</summary>
  
  > Add `/SYSTEM_PID-PID` <br>
  > Add `/SYSTEM_PID-STATUS` <br>
  > Add `/ABOUT-GPL` <br>
  > Other BUG fixes 
</details>

<details>
  <summary>0.075.3</summary>
  
  > Fixed `/info`<br>
  > Add `/about` <br>
  > Other BUG fixes 
</details>

<details>
  <summary>0.075.2</summary>
  
  > Fixed the problem that closing the parent process and the child process will not end <br>
  > Fixed `/start-srv` ending immediately after running <br>
  > Other BUG fixes 
</details>

<details>
  <summary>0.075.1</summary>
  
  > Subprocess support <br>
  > Add setting entry `PIDMD_DISABLE_RUN` (default value **FALSE**) <br>
  > Other BUG fixes 
</details>

<details>
  <summary>0.074.1147</summary>
  
  > Fixed the problem that the **xxx.SRV** file in the `%PIDMD_ROOT%\SYS\SRVRUN\` directory would not be deleted after the SRV specified process.<br>
  > Other BUG fixes
</details>

<details>
  <summary>0.074.1146</summary>
  
  > BUG fixes<br>
  > `%PIDMD_DEFAULT_USER%` set `SYSTEM`
</details>

<details>
  <summary>0.074.1145</summary>
  
  > Added simple users, groups, permissions<br>
  > PID can be executed in any directory<br>
  > `PIDMD_ROOT` can be set arbitrarily<br>
  > Other BUG fixes
</details>

