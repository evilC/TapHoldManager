; If the library files are in a subfolder called lib next to the script, use this
#include lib\TapHoldManager.ahk
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

^Esc::ExitApp
