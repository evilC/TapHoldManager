; If the library files are in a subfolder called Lib next to the script, use this
#include Lib\InterceptionTapHold.ahk
; If you placed all the library files in your My Documents\AutoHotkey\lib folder, use this
;#include <InterceptionTapHold>

#Persistent	; Interception scripts may not declare hotkeys, so you may need this to stop it exiting
#SingleInstance force

; Add the VID / PID of the keyboard you wish to filter here
VID1 := 0x04F2, PID1 := 0x0112

; A second keyboard can be filtered by filling this out ...
; ... and making sure the kb2 code below is not commented out
VID2 := 0x413C, PID2 := 0x2107

kb1 := new InterceptionTapHold(VID1, PID1)	; TapTime / Prefix can now be set here
kb1.Add("1", Func("Kb1Func"))			; TapFunc / HoldFunc now always one function

;kb2 := new InterceptionTapHold(VID2, PID2)	; TapTime / Prefix can now be set here
;kb2.Add("1", Func("Kb2Func"))			; TapFunc / HoldFunc now always one function

Kb1Func(isHold, taps, state){
	ToolTip % "KB 1 Key 1`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
}

Kb2Func(isHold, taps, state){
	ToolTip % "KB 2 Key 1`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
}

^Esc::ExitApp
