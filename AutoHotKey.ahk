
^!n::
IfWinExist Untitled - Notepad
	WinActivate
else
	Run Notepad
return

;----------------------�л��ı�----------------------------------
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
;----------------------�л�TC----------------------------------
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

;----------------------�Ҽ�����������м�ճ��---------------------
~RButton::
Hotkey, MButton, Paste
Keywait, LButton, d, t0.9
        ; ���� d ��down����ʾ�������ڰ���״̬��t0.2 �ǵȴ� 0.2 �롣
if errorlevel = 0
        ; ������صĴ����루errorlevel���ܶ�� AHK ����᷵�ش����룬��������� AHK �Դ��ġ����� 0 ��Ҳ����˵����� Keywait ����ִ�гɹ�������� 1 �Ļ���˵�� Keywait ִ��ʧ�ܡ�ʧ��˵�����ǰ������Ҽ�֮��û���� 0.2 ���ڰ��������
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

;----------------------�л������----------------------------------
;һ���򿪡����������Chrome����������Path_Browser
#a::
Path_Browser := "C:\Program Files\Mozilla Firefox\firefox.exe"
hyf_winActiveOrOpen("Ahk_class MozillaWindowClass", Path_Browser, 1, "Max") ; {{{2
Return
 
hyf_winActiveOrOpen(title, path, m := 0, size := "", args := "") ;����title�Ĵ��ڣ��粻�������path   {{{3
{ ;������chrome�Ķ��̣߳�Ҫ��ȡ������ID���ܼ��������m=1��sizeΪRun����Ĵ��ڳߴ�, argsΪpath����Ĳ���
    Static Arr_MainID := {} ;��¼ID��ֵ
    DetectHiddenWindows, On
    SplitPath, path, exeName, , ext
    If size
        size .= " UseErrorLevel"
    If ((ext = "CHM") && !WinExist(title)) || ((ext != "CHM") && !hyf_winExist(exeName)) ;������ᵼ��chm�ļ��жϴ���
    {
        ;Run, %path% %args%, , %size%
		Run %path%
		hyf_tooltipAndRemoveOrExit("�����У����Ե�...")
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
            If !(d := Arr_MainID[exeName]) || !WinExist("Ahk_id " . d) ;d�����ڻ򴰿ڱ��رգ������»�ȡ
            {
                Arr_MainID[exeName] := d := hyf_getMainIDOfProcess(title) ;д�����飬�´β������»�ȡ
                If !d
                    hyf_msgBox("û�ҵ�����" . exeName . "����Ĵ��ڣ�����ű�", , 1)
                WinGetTitle, Title_A, Ahk_id %d%
            }
            Else
                WinGetTitle, Title_A, Ahk_id %d%
            ;hyf_tooltipAndRemoveOrExit("��ȡ��������" . exeName . "`n���⣺" . Title_A . "`nAhk_id " . d, 3)
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
 
hyf_winExist(n) ;�жϽ����Ƿ���ڣ�����PID��   {{{3
{ ;nΪ������
    Process, Exist, %n% ;��IfWinExist�ɿ�
    Return ErrorLevel
}
 
hyf_tooltipAndRemoveOrExit(str, t := 1, ExitScript := 0, x := "", y := "")  ;��ʾt�벢�Զ���ʧ   {{{3
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
 
hyf_getMainIDOfProcess(Win) ;��ȡ����chrome�ȶ���̵�������ID {{{3
{ ;WinΪ��������, vΪ�жϵ�ֵ��tpΪv������
    DetectHiddenWindows, On
    If InStr(Win, "Ahk_class")
        RegExMatch(Win, "i)Ahk_class\s\S+", WinTitle)
    Else If InStr(Win, "Ahk_exe")
        RegExMatch(Win, "i)Ahk_exe\s\S+", WinTitle)
    If !(Win ~= "i)^ahk_")
        RegExMatch(Win, "i)\S+", TitleMatch)
    WinGet, Arr, List, %WinTitle%
    ;str := ",Default IME,MSCTFIME UI,�رձ�ǩҳ,nsAppShell:EventWindow" ;�ų������б� todo ������
    Loop,% Arr
    {
        n := Arr%A_Index%
        ;If (hyf_winGet("MinMax", "Ahk_id " . n) = 0) ;�����������Ҳ������С����
        WinGetTitle, TitleLoop, Ahk_id %n%
        If (TitleLoop = "") || (TitleMatch && (TitleLoop != TitleMatch))
            Continue
        Return n
    }
    Return 0
}
 
hyf_msgBox(str, o := 262144, ExitScript := 0, TimeOut := "", title := "")  ;����  {{{3
;o:4Ϊ�Ƿ�3Ϊ��/��/ȡ����256/512���õ�2/3��ťΪĬ��, 262144Ϊ�ö���Ĭ�ϣ�
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
 
hyf_processCloseWhenNotActive(n := "chrome.exe") ;���ڼ���ʧ����رս���  {{{3
{
    WinWaitActive, Ahk_exe %n%, , 1 ;����ʧ��
    If ErrorLevel ;����ʧ��
    {
        hyf_msgBox("���ڼ���ʧ�ܣ��Ƿ�������н���", 4)
        IfMsgBox No
            Return
        Loop
        {
            Process, Close, %n%
            Sleep, 200
        }
        Until (ErrorLevel = 0)
        Run, %Path_Browser%, , Max
        hyf_tooltipAndRemoveOrExit("���������...", 2)
    }
}
 
hyf_removeToolTip() ;���ToolTip {{{2
{
    ToolTip
}
 
hyf_winGet(cmd := "title", WinTitle := "A") ;��֧��Pos�ȶ�����������  {{{3
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





