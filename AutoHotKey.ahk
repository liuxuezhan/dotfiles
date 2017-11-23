
^!n::
IfWinExist Untitled - Notepad
	WinActivate
else
	Run Notepad
return

;----------------------切换文本----------------------------------
#q::
DetectHiddenWindows, on
IfWinNotExist ahk_class Notepad++
Run C:\Program Files (x86)\Notepad++\notepad++.exe
Else
IfWinNotActive ahk_class Notepad++
WinActivate
Else
WinMinimize
Return
;----------------------切换TC----------------------------------
#z::
DetectHiddenWindows, on
IfWinNotExist ahk_class TTOTAL_CMD
Run C:\Users\Administrator\AppData\Local\TotalCMD64\Totalcmd64.exe
Else
IfWinNotActive ahk_class TTOTAL_CMD
WinActivate
Else
WinMinimize
Return 

;----------------------右键加左键复制中键粘贴---------------------
~RButton::
Hotkey, MButton, Paste
Keywait, LButton, d, t0.9
        ; 参数 d （down）表示按键处于按下状态，t0.2 是等待 0.2 秒。
if errorlevel = 0
        ; 如果返回的错误码（errorlevel，很多的 AHK 命令都会返回错误码，这个变量是 AHK 自带的。）是 0 ，也就是说上面的 Keywait 命令执行成功。如果是 1 的话，说明 Keywait 执行失败。失败说明我们按下了右键之后，没有在 0.2 秒内按下左键。
{
send ^c
Hotkey, MButton, on
}
return

Paste:
send ^v
Hotkey, MButton, off
return

^MButton::
send ^v
return

;----------------------切换浏览器----------------------------------
;一键打开、激活、或隐藏Chrome，请先设置Path_Browser
#a::
Path_Browser := "C:\Program Files\Mozilla Firefox\firefox.exe"
hyf_winActiveOrOpen("Ahk_class MozillaWindowClass", Path_Browser, 1, "Max") ; {{{2
Return
 
hyf_winActiveOrOpen(title, path, m := 0, size := "", args := "") ;激活title的窗口，如不存在则打开path   {{{3
{ ;像火狐和chrome的多线程，要提取主进程ID才能激活，请设置m=1，size为Run命令的窗口尺寸, args为path后面的参数
    Static Arr_MainID := {} ;记录ID的值
    DetectHiddenWindows, On
    SplitPath, path, exeName, , ext
    If size
        size .= " UseErrorLevel"
    If ((ext = "CHM") && !WinExist(title)) || ((ext != "CHM") && !hyf_winExist(exeName)) ;用这个会导致chm文件判断错误
    {
        ;Run, %path% %args%, , %size%
		Run %path%
		hyf_tooltipAndRemoveOrExit("启动中，请稍等...")
        WinWaitActive %title%
		
    }
    Else IfWinActive %title%
    {
        If (m = 1)
        {
            WinGet, ID_A, ID, A
            If (Arr_MainID[exeName] != ID_A)
                Arr_MainID[exeName] := ID_A
        }
        If (exeName = "chrome.exe")
            WinMinimize
        WinHide
        MouseGetPos, , , ID_A
        WinActivate Ahk_id %ID_A%
    }
    Else
    {
        If (m = 1)
        {
            If !(d := Arr_MainID[exeName]) || !WinExist("Ahk_id " . d) ;d不存在或窗口被关闭，则重新获取
            {
                Arr_MainID[exeName] := d := hyf_getMainIDOfProcess(title) ;写入数组，下次不用重新获取
                If !d
                    hyf_msgBox("没找到程序" . exeName . "激活的窗口，请检查脚本", , 1)
                WinGetTitle, Title_A, Ahk_id %d%
            }
            Else
                WinGetTitle, Title_A, Ahk_id %d%
            ;hyf_tooltipAndRemoveOrExit("获取数组数据" . exeName . "`n标题：" . Title_A . "`nAhk_id " . d, 3)
            WinShow Ahk_id %d%
            WinActivate Ahk_id %d%
            ;hyf_processCloseWhenNotActive(exeName)
        }
        Else
        {
            WinShow %title%
            WinActivate %title%
        }
        If InStr(size, "Max")
            WinMaximize
    }
}
 
hyf_winExist(n) ;判断进程是否存在（返回PID）   {{{3
{ ;n为进程名
    Process, Exist, %n% ;比IfWinExist可靠
    Return ErrorLevel
}
 
hyf_tooltipAndRemoveOrExit(str, t := 1, ExitScript := 0, x := "", y := "")  ;提示t秒并自动消失   {{{3
{
    t *= 1000
    ToolTip, %str%, %x%, %y%
    SetTimer, hyf_removeToolTip, -%t%
    If ExitScript
    {
        Gui, Destroy
        Exit
    }
}
 
hyf_getMainIDOfProcess(Win) ;获取类似chrome等多进程的主程序ID {{{3
{ ;Win为完整类名, v为判断的值，tp为v的类型
    DetectHiddenWindows, On
    If InStr(Win, "Ahk_class")
        RegExMatch(Win, "i)Ahk_class\s\S+", WinTitle)
    Else If InStr(Win, "Ahk_exe")
        RegExMatch(Win, "i)Ahk_exe\s\S+", WinTitle)
    If !(Win ~= "i)^ahk_")
        RegExMatch(Win, "i)\S+", TitleMatch)
    WinGet, Arr, List, %WinTitle%
    ;str := ",Default IME,MSCTFIME UI,关闭标签页,nsAppShell:EventWindow" ;排除标题列表 todo 待完善
    Loop,% Arr
    {
        n := Arr%A_Index%
        ;If (hyf_winGet("MinMax", "Ahk_id " . n) = 0) ;跳过不是最大化也不是最小化的
        WinGetTitle, TitleLoop, Ahk_id %n%
        If (TitleLoop = "") || (TitleMatch && (TitleLoop != TitleMatch))
            Continue
        Return n
    }
    Return 0
}
 
hyf_msgBox(str, o := 262144, ExitScript := 0, TimeOut := "", title := "")  ;弹窗  {{{3
;o:4为是否，3为是/否/取消，256/512设置第2/3按钮为默认, 262144为置顶（默认）
{
    MsgBox,% o, %title%, %str%, %TimeOut%
    If (ExitScript = 1)
    {
        Gui, Destroy
        Exit
    }
    Else If (ExitScript = 2)
        ExitApp
}
 
hyf_processCloseWhenNotActive(n := "chrome.exe") ;窗口激活失败则关闭进程  {{{3
{
    WinWaitActive, Ahk_exe %n%, , 1 ;激活失败
    If ErrorLevel ;激活失败
    {
        hyf_msgBox("窗口激活失败，是否结束所有进程", 4)
        IfMsgBox No
            Return
        Loop
        {
            Process, Close, %n%
            Sleep, 200
        }
        Until (ErrorLevel = 0)
        Run, %Path_Browser%, , Max
        hyf_tooltipAndRemoveOrExit("软件重启中...", 2)
    }
}
 
hyf_removeToolTip() ;清除ToolTip {{{2
{
    ToolTip
}
 
hyf_winGet(cmd := "title", WinTitle := "A") ;不支持Pos等多变量输出命令  {{{3
{
    If (cmd = "title")
        WinGetTitle, v, %WinTitle%
    Else If (cmd = "Class")
        WinGetClass, v, %WinTitle%
    Else If (cmd = "Text")
        WinGetText, v, %WinTitle%
    Else
        WinGet, v, %cmd%, %WinTitle%
    Return v
}





