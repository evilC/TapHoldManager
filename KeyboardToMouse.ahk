/*
Remaps Keyboard Numpad to Mouse cursor movement
Press and hold a key to move
Double-tap and hold to move quicker
Triple-tap and hold to move even quicker
etc...
*/
#include Lib\TapHoldManager.ahk
MoveMultiplier := 5
HoldMoveVectors := {x: 0, y: 0}
MoveFn := Func("DoMove")

thm := new TapHoldManager()
thm.Add("NumpadLeft", Func("HandleInput").Bind("x", "-1"))
thm.Add("NumpadRight", Func("HandleInput").Bind("x", "1"))

thm.Add("NumpadUp", Func("HandleInput").Bind("y", "-1"))
thm.Add("NumpadDown", Func("HandleInput").Bind("y", "1"))

HandleInput(axis, dir, isHold, taps, state := -1){
	global HoldMoveVectors, MoveFn, MoveMultiplier
	ToolTip % "isHold: " isHold ", Axis: " axis ", Dir: " dir ", Taps: " taps ", State: " state
	if (state == 1){
		HoldMoveVectors[axis] := (dir * taps) * MoveMultiplier
		SetTimer, % MoveFn, 10
	} else if (state == 0){
		HoldMoveVectors[axis] := 0
		if (HoldMoveVectors.x == 0 && HoldMoveVectors.y == 0){
			SetTimer, % MoveFn, Off
		}
	} else {
		; Tap
		x := 0
		y := 0
		%axis% := (dir * taps) * MoveMultiplier * MoveMultiplier
		MouseMove, % x, % y, 0, R
	}
}

DoMove(){
	global HoldMoveVectors
	MouseMove, % HoldMoveVectors.x, % HoldMoveVectors.y , 0, R
}
^Esc::ExitApp