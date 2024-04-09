; If the library files are in a subfolder called Lib next to the script, use this
#include Lib\TapHoldManager.ahk
; If you placed all the library files in your My Documents\AutoHotkey\lib folder, use this
;#include <TapHoldManager>

#SingleInstance force

thm := new TapHoldManager()	; TapTime / Prefix can now be set here
thm.Add("1", Func("MyFunc1"))			; TapFunc / HoldFunc now always one function
thm.Add("2", Func("MyFunc2"))

MyFunc1(isHold, taps, state){
	ToolTip % "1`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
}

MyFunc2(isHold, taps, state){
	ToolTip % "2`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
}

$F1:: ; pause hotkey "2"
  thm.PauseHotkey("2")
return

$F2:: ; resume hotkey "2"
  thm.ResumeHotkey("2")
return

$F3:: ; remove hotkey "2"
  thm.RemoveHotkey("2")
return

^Esc::ExitApp
