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
						
window (optional)		The window criteria to apply to the hotkey
						Defaults to "" (The hotkey will be available on all windows)
*/

/*
	; Test Example
	thm := new TapHoldManager(,,maxTaps = 3,,"ahk_exe notepad.exe") ; with window parameter set here, default window criteria that will be set for all sub-created hotkeys under this manager object is notepad
	thm.Add("1", Func("MyFunc1"))
	thm.Add("2", Func("MyFunc2"))
	thm.Add("3", Func("MyFunc3"),,,,,"ahk_exe sublime_text.exe") ; this hotkey's window criteria will be sublime_text (instead of manager object's previously passed-in notepad default)
	
	MyFunc1(isHold, taps, state){
		ToolTip % "1`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
	}

	MyFunc2(isHold, taps, state){
		ToolTip % "2`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
	}

	MyFunc3(isHold, taps, state){
		ToolTip % "3`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
	}
	
	$4:: ; simple/normal hotkey to hide tooltip
		ToolTip
	return
	
	$5:: ; pause hotkey "2"
		thm.PauseKey("2")
	return

	$6:: ; resume hotkey "2"
		thm.ResumeKey("2")
	return

	$7:: ; remove hotkey "2"
		thm.RemoveKey("2")
	return
*/

class TapHoldManager {
	Bindings := {}
	
	__New(tapTime := -1, holdTime := -1, maxTaps := -1, prefixes := "$", window := ""){
		if (tapTime == -1)
			tapTime := 150
		if (holdTime == -1)
			holdTime := tapTime
		this.tapTime := tapTime
		this.holdTime := holdTime
		this.maxTaps := maxTaps
		this.prefixes := prefixes
		this.window := window
	}
	
	Add(keyName, callback, tapTime := -1, holdTime := -1, maxTaps := -1, prefixes := -1, window := ""){
		this.Bindings[keyName] := new KeyManager(this, keyName, callback, tapTime, holdTime, maxTaps, prefixes, window)
	}
	
	RemoveKey(keyName){ ; to remove hotkey
		this.Bindings[keyName].SetState(0)
		this.Bindings.delete(keyName)
	}
	
	PauseKey(keyName) { ; to pause hotkey temprarily
		this.Bindings[keyName].SetState(0)
	}
	
	ResumeKey(keyName) { ; resume previously deactivated hotkey
		this.Bindings[keyName].SetState(1)
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
	
	__New(manager, keyName, Callback, tapTime := -1, holdTime := -1, maxTaps := -1, prefixes := -1, window := ""){
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
		
		if (maxTaps == -1){
			this.maxTaps := manager.maxTaps
		} else {
			this.maxTaps := maxTaps
		}
		
		if (prefixes == -1){
			this.prefixes := manager.prefixes
		} else {
			this.prefixes := prefixes
		}
		
		if (window){ ; if window criteria is passed-in
			this.window := window
		} else { ; if no window criteria passed-in
			this.window := manager.window
		}
		
		this.keyName := keyName
		
		this.HoldWatcherFn := this.HoldWatcher.Bind(this)
		this.TapWatcherFn := this.TapWatcher.Bind(this)
		this.JoyReleaseFn := this.JoyButtonRelease.Bind(this)
		this.JoyWatcherFn := this.JoyButtonWatcher.Bind(this)
		this.DeclareHotkeys()
	}
	
	DeclareHotkeys(){
		if (this.window)
			hotkey, IfWinActive, % this.window ; sets the hotkey window context if window option is passed-in
		
		fn := this.KeyEvent.Bind(this, 1)
		hotkey, % this.prefixes this.keyName, % fn, On ; On option is important in case hotkey previously defined and turned off.
		if (SubStr(this.keyName, 2, 3) = "joy"){
			fn := this.JoyReleaseFn
			hotkey, % this.keyName " up", % fn, On
		} else {
			fn := this.KeyEvent.Bind(this, 0)
			hotkey, % this.prefixes this.keyName " up", % fn, On
		}
		
		if (this.window)
			hotkey, IfWinActive ; retrieves hotkey window context to default
	}
	
	SetState(state){ ; turns On/Off hotkeys (should be previously declared) // state is either "1: On" or "0: Off"
		; "state" under this method context refers to whether the hotkey will be turned on or off, while in other methods context "state" refers to the current activity on the hotkey (whether it's pressed or released (after a tap or hold))
		if (this.window)
			hotkey, IfWinActive, % this.window

		hotkey, % this.prefixes this.keyName, % (state ? "On" : "Off")

		if (SubStr(this.keyName, 2, 3) = "joy"){
			hotkey, % this.keyName " up", % (state ? "On" : "Off")
		} else {
			hotkey, % this.prefixes this.keyName " up", % (state ? "On" : "Off")
		}

		if (this.window)
			hotkey, IfWinActive
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
				if (this.maxTaps > 0 && this.Sequence == this.maxTaps){
					fn := this.FireCallback.Bind(this, this.sequence, -1)
					SetTimer, % fn, -0
					this.ResetSequence()
				} else {
					this.SetTapWatcherState(1)
				}
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
