/*
Tap and Hold Manager v1.1

Callback				A function object to call when a tap occurs
						The function will be passed the number of taps that occurred.
						The function will also be passed the event that occurred
							-1 = Tap
							1 = (Hold) Press
							0 = (Hold) Release
							
tapTime (optional)		The amount of time to wait before deciding if an event is a tap or hold
						Defaults to 200ms
						
prefixes (optional)		The prefixes to apply to the hotkey
						Defaults to $ (Do not trigger hotkey if you send that key)
*/

class TapHoldManager {
	Bindings := {}
	
	__New(tapTime := -1, holdTime := -1, prefixes := "$"){
		if (tapTime == -1)
			tapTime := 150
		if (holdTime == -1)
			holdTime := tapTime
		this.tapTime := tapTime
		this.holdTime := holdTime
		this.prefixes := prefixes
	}
	
	Add(keyName, callback, tapTime := -1, holdTime := -1, prefixes := -1){
		this.Bindings[keyName] := new KeyManager(this, keyName, callback, tapTime, holdTime, prefixes)
	}
}

/*
keyName					The name of the key to declare a hotkey to

*/
class KeyManager {
	state := 0					; Current state of the key
	sequence := 0				; Number of taps so far
	
	holdWatcherState := 0		; Are we potentially in a hold state?
	tapWatcherState := 0		; Has a tap release occurred and another could possibly happen?
	
	holdActive := 0				; A hold was activated and we are waiting for the release
	
	__New(manager, keyName, Callback, tapTime := -1, holdTime := -1, prefixes := -1){
		this.manager := manager
		this.Callback := Callback
		if (tapTime == -1){
			this.tapTime := manager.tapTime
		} else {
			this.tapTime := tapTime
		}
		
		if (holdTime == -1){
			this.holdTime := manager.holdTime
		} else {
			this.holdTime := holdTime
		}
		
		if (prefixes == -1){
			this.prefixes := manager.prefixes
		} else {
			this.prefixes := prefixes
		}
		this.keyName := keyName
		
		this.HoldWatcherFn := this.HoldWatcher.Bind(this)
		this.TapWatcherFn := this.TapWatcher.Bind(this)
		this.JoyReleaseFn := this.JoyButtonRelease.Bind(this)
		this.JoyWatcherFn := this.JoyButtonWatcher.Bind(this)
		this.DeclareHotkeys()
	}
	
	DeclareHotkeys(){
		fn := this.KeyEvent.Bind(this, 1)
		hotkey, % this.prefixes this.keyName, % fn
		if (SubStr(this.keyName, 2, 3) = "joy"){
			fn := this.JoyReleaseFn
			hotkey, % this.keyName " up", % fn
		} else {
			fn := this.KeyEvent.Bind(this, 0)
			hotkey, % this.prefixes this.keyName " up", % fn
		}
	}
	
	JoyButtonRelease(){
		fn := this.JoyWatcherFn
		SetTimer, % fn, 10
	}
	
	JoyButtonWatcher(){
		if (!GetKeyState(this.keyName)){
			fn := this.JoyWatcherFn
			SetTimer, % fn, Off
			this.KeyEvent(0)
		}
	}
	
	KeyEvent(state){
		if (state == this.state)
			return	; Suppress Repeats
		this.state := state
		if (state){
			; Key went down
			this.sequence++
			this.SetHoldWatcherState(1)
		} else {
			; Key went up
			this.SetHoldWatcherState(0)
			if (this.holdActive){
				fn := this.FireCallback.Bind(this, this.sequence, 0)
				SetTimer, % fn, -0
				this.ResetSequence()
			} else {
				this.SetTapWatcherState(1)
			}
		}
	}
	
	ResetSequence(){
		this.SetHoldWatcherState(0)
		this.SetTapWatcherState(0)
		this.sequence := 0
		this.holdActive := 0
	}
	
	; When a key is pressed, if it is not released within tapTime, then it is considered a hold
	SetHoldWatcherState(state){
		this.holdWatcherState := state
		fn := this.HoldWatcherFn
		SetTimer, % fn, % (state ? "-" this.holdTime : "Off")
	}
	
	; When a key is released, if it is re-pressed within tapTime, the sequence increments
	SetTapWatcherState(state){
		this.tapWatcherState := state
		fn := this.TapWatcherFn
		SetTimer, % fn, % (state ? "-" this.tapTime : "Off")
	}
	
	; If this function fires, a key was held for longer than the tap timeout, so engage hold mode
	HoldWatcher(){
		if (this.sequence > 0 && this.state == 1){
			; Got to end of tapTime after first press, and still held.
			; HOLD PRESS
			fn := this.FireCallback.Bind(this, this.sequence, 1)
			SetTimer, % fn, -0
			this.holdActive := 1
		}
	}
	
	; If this function fires, a key was released and we got to the end of the tap timeout, but no press was seen
	TapWatcher(){
		if (this.sequence > 0 && this.state == 0){
			; TAP
			fn := this.FireCallback.Bind(this, this.sequence)
			SetTimer, % fn, -0
			this.ResetSequence()
		}
	}
	
	FireCallback(seq, state := -1){
		this.Callback.Call(state != -1, seq, state)
	}
}
