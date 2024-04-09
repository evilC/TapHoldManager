#Requires AutoHotkey v2.0
/*
Remaps Keyboard Numpad to Mouse cursor movement
Press and hold a key to move
Double-tap and hold to move quicker
Triple-tap and hold to move even quicker
etc...
*/
#include Lib\TapHoldManager.ahk
MoveMultiplier := 5
InitMoveVectors()

thm := TapHoldManager()
thm.Add("NumpadLeft", HandleInput.Bind("x", "-1"))
thm.Add("NumpadRight", HandleInput.Bind("x", "1"))

thm.Add("NumpadUp", HandleInput.Bind("y", "-1"))
thm.Add("NumpadDown", HandleInput.Bind("y", "1"))

HandleInput(axis, dir, isHold, taps, state := -1){
	global MoveVectors, MoveMultiplier
	ToolTip("isHold: " isHold ", Axis: " axis ", Dir: " dir ", Taps: " taps ", State: " state)
	if (state == 1){
		MoveVectors[axis] := (dir * taps) * MoveMultiplier
		SetTimer(DoMove, 10)
	} else if (state == 0){
		MoveVectors[axis] := 0
		if (MoveVectors["x"] == 0 && MoveVectors["y"] == 0){
			SetTimer(DoMove, 0)
		}
	} else {
		; Tap
		InitMoveVectors()
		MoveVectors[axis] := (dir * taps) * MoveMultiplier
		MouseMove(MoveVectors["x"], MoveVectors["y"], 0, "R")
	}
}

InitMoveVectors(){
	global MoveVectors
	MoveVectors := Map("x", 0, "y", 0)
}

DoMove(){
	global MoveVectors
	MouseMove(MoveVectors["x"], MoveVectors["y"] , 0, "R")
}

^Esc::ExitApp