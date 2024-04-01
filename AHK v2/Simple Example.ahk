#Requires AutoHotkey v2.0
#SingleInstance Force

#include Lib\TapHoldManager.ahk

thm := TapHoldManager()
thm.Add("1", MyFunc1)
thm.Add("2", MyFunc2, 250, 500, 2,, "ahk_exe notepad.exe")
thm.Add("6Joy1", MyFunc3)

MyFunc1(isHold, taps, state){
	ToolTip "key: 1`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
}

MyFunc2(isHold, taps, state){
	ToolTip "key: 2`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
}

MyFunc3(isHold, taps, state){
    ToolTip "joystick:`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
}

$F1:: ; pause hotkey "2"
{
	thm.PauseHotkey("2")
}

$F2:: ; resume hotkey "2"
{
	thm.ResumeHotkey("2")
}

$F3:: ; remove hotkey "2"
{
	thm.RemoveHotkey("2")
}

^Esc::{
    ExitApp()
}