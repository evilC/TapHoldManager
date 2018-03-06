#include lib\InterceptionTapHold.ahk
#SingleInstance force
#Persistent

VID1 := 0x04F2, PID1 := 0x0112
VID2 := 0x413C, PID2 := 0x2107

;~ tahm := new TapAndHoldManager()	; TapTime / Prefix can now be set here
kb1 := new InterceptionTapHold(VID1, PID1)	; TapTime / Prefix can now be set here
kb1.Add("1", Func("MyFunc"))			; TapFunc / HoldFunc now always one function

;~ kb2 := new InterceptionTapHold(VID2, PID2)	; TapTime / Prefix can now be set here
;~ kb2.Add("1", Func("MyFunc2"))			; TapFunc / HoldFunc now always one function

MyFunc(isHold, taps, state){
	ToolTip % (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
}

MyFunc2(isHold, taps, state){
	ToolTip % "2`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
}

^Esc::ExitApp
