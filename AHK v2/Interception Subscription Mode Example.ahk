#Requires AutoHotkey v2.0
#SingleInstance force

; Demonstrates Interception Subscription Mode with TapHoldManager

; Use these includes if you placed the contents of the TapHoldManager and AutoHotInterception Lib folders in the AHK lib folder (My Documents\AutoHotkey\Lib)
; #include <AutoHotInterception>
; #include <InterceptionTapHold>
; #include <TapHoldManager>

; Use these includes if you placed the contents of the TapHoldManager and AutoHotInterception Lib folders in a lib folder next to this script
; ie copy the AutoHotInterception Lib folder into the TapHoldManager Lib folder
#include Lib\AutoHotInterception.ahk
#include Lib\InterceptionTapHold.ahk
#include Lib\TapHoldManager.ahk

AHI := AutoHotInterception()
; keyboard1Id := AHI.GetDeviceIdFromHandle(false, "HID\VID_03EB&PID_FF02&REV_0008&MI_03")
; keyboard1Id := AHI.GetKeyboardId(0x03EB, 0xFF02)
keyboard1Id := 3
ITH1 := InterceptionTapHold(AHI, keyboard1Id)

ITH1.Add("1", Func1)
ITH1.Add("2", Func2)
return

Func1(isHold, taps, state){
    ToolTip("KB 1 Key 1`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state)
}

Func2(isHold, taps, state){
    ToolTip("KB 1 Key 2`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state)
}

^Esc::{
	ExitApp
}