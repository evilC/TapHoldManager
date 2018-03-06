#include lib\InterceptionTapHold.ahk
;~ #include TapHoldManager.ahk
#SingleInstance force
#Persistent

VID := 0x04F2, PID := 0x0112
;~ tahm := new TapAndHoldManager()	; TapTime / Prefix can now be set here
kb1 := new InterceptionTapHold(VID, PID)	; TapTime / Prefix can now be set here
kb1.Add("1", Func("MyFunc"))			; TapFunc / HoldFunc now always one function

;~ kb2 := new InterceptionTapHold(0x413C, 0x2107)	; TapTime / Prefix can now be set here
;~ kb2.Add("1", Func("MyFunc2"))			; TapFunc / HoldFunc now always one function

MyFunc(isHold, taps, state){
	ToolTip % (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
}

MyFunc2(isHold, taps, state){
	ToolTip % "2`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
}

^Esc::ExitApp
