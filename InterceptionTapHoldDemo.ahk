#SingleInstance force
#include <AutoHotInterception>
#include <InterceptionTapHold>
#include <TapHoldManager>

AHI := new AutoHotInterception()
; keyboard1Id := AHI.GetDeviceIdFromHandle(false, "HID\VID_03EB&PID_FF02&REV_0008&MI_03")
keyboard1Id := AHI.GetKeyboardId(0x03EB, 0xFF02)
ITH1 := new InterceptionTapHold(AHI, keyboard1Id)

ITH1.Add("1", Func("Func1"))
ITH1.Add("2", Func("Func2"))
return

Func1(isHold, taps, state){
    ToolTip % "KB 1 Key 1`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
}

Func2(isHold, taps, state){
    ToolTip % "KB 1 Key 2`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
}

^Esc::
	ExitApp