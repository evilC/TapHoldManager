#Requires AutoHotkey v2.0

class TapHoldManager {
	Bindings := Map()

	__New(tapTime?, holdTime?, maxTaps := "", prefixes := "$", window := ""){
		this.tapTime := tapTime ?? 150
		this.holdTime := holdTime ?? this.tapTime
		this.maxTaps := maxTaps
		this.prefixes := prefixes
		this.window := window
	}

    ; Add a key
	Add(keyName, callback, tapTime?, holdTime?, maxTaps?, prefixes?, window?){
		if this.Bindings.Has(keyName)
			this.RemoveHotkey(keyName)
		this.Bindings[keyName] := TapHoldManager.KeyManager(this, keyName, callback, tapTime ?? this.tapTime, holdTime ?? this.holdTime, maxTaps?? this.maxTaps, prefixes?, window?)
	}

    ; Remove a key
	RemoveHotkey(keyName){
		this.Bindings.Delete(keyName).SetState(0)
	}

    ; Pause a key
	PauseHotkey(keyName){
		this.Bindings[keyName].SetState(0)
	}

    ; Unpause a key
	ResumeHotkey(keyName){
		this.Bindings[keyName].SetState(1)
	}

	class KeyManager {
        ; AutoHotInterception mod does not use prefixes or window, so these parameters must be optional
		__New(manager, keyName, callback, tapTime, holdTime, maxTaps, prefixes?, window?){
            this.state := 0					; Current state of the key
            this.sequence := 0				; Number of taps so far
            
            this.holdWatcherState := 0		; Are we potentially in a hold state?
            this.tapWatcherState := 0		; Has a tap release occurred and another could possibly happen?
            
            this.holdActive := 0				; A hold was activated and we are waiting for the release
    
            this.manager := manager
            this.keyName := keyName
            this.callback := callback
            this.tapTime := tapTime
            this.holdTime := holdTime
            this.maxTaps := maxTaps
            this.prefixes := prefixes ?? manager.prefixes
            this.window := window ?? manager.window

			this.HoldWatcherFn := this.HoldWatcher.Bind(this)
			this.TapWatcherFn := this.TapWatcher.Bind(this)
            this.JoyReleaseFn := this.JoyButtonRelease.Bind(this)
			this.DeclareHotkeys()
		}

        ; Internal use only - declares hotkeys
		DeclareHotkeys(){
			if (this.window)
				HotIfWinactive this.window ; sets the hotkey window context if window option is passed-in

			Hotkey this.prefixes this.keyName, this.KeyEvent.Bind(this, 1), "On" ; On option is important in case hotkey previously defined and turned off.
			if (this.keyName ~= "i)^\d*Joy"){
				Hotkey this.keyName " up", (*) => SetTimer(this.JoyReleaseFn, 10), "On"
			} else {
				Hotkey this.prefixes this.keyName " up", this.KeyEvent.Bind(this, 0), "On"
			}

			if (this.window)
				HotIfWinactive ; restores hotkey window context to default
		}

        ; Turns On/Off hotkeys (should be previously declared) // state is either "1: On" or "0: Off"
		SetState(state){ 
			; "state" under this method context refers to whether the hotkey will be turned on or off, while in other methods context "state" refers to the current activity on the hotkey (whether it's pressed or released (after a tap or hold))
			if (this.window)
				HotIfWinactive this.window

			state := (state ? "On" : "Off")
			Hotkey this.prefixes this.keyName, state
			if (this.keyName ~= "i)^\d*Joy"){
				Hotkey this.keyName " up", state
			} else {
				Hotkey this.prefixes this.keyName " up", state
			}

			if (this.window)
				HotIfWinactive
		}

        ; For correcting a bug in AHK
        ; A joystick button hotkey such as "1Joy1 up::" will fire on button down, and not on release up
        ; So when the button is pressed, we start a timer which checks the actual state of the button using GetKeyState...
        ; ... and when it is actually released, we fire the up event
		JoyButtonRelease(){
			if (GetKeyState(this.keyName))
                return
			SetTimer this.JoyReleaseFn, 0
			this.KeyEvent(0)
		}

        ; Called when key events (down / up) occur
		KeyEvent(state, *){
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
					this.holdActive := 0
					SetTimer this.FireCallback.Bind(this, this.sequence, 0), -1
					this.ResetSequence()
					return
				} else {
                    if (this.maxTaps && this.Sequence == this.maxTaps){
                        SetTimer this.FireCallback.Bind(this, this.sequence, -1), -1
                        this.ResetSequence()
                    } else {
                        this.SetTapWatcherState(1)
                    }
                }
			}
		}

        ; Resets everything once a sequence completes
        ResetSequence(){
            this.SetHoldWatcherState(0)
            this.SetTapWatcherState(0)
            this.sequence := 0
            this.holdActive := 0
        }

        ; When a key is pressed, if it is not released within tapTime, then it is considered a hold
        SetHoldWatcherState(state){
            this.holdWatcherState := state
            SetTimer this.HoldWatcherFn, (state ? "-" this.holdTime : 0)
        }
        
        ; When a key is released, if it is re-pressed within tapTime, the sequence increments
        SetTapWatcherState(state){
            this.tapWatcherState := state
            ; SetTimer this.TapWatcherFn, (state ? "-" this.tapTime : 0)
            SetTimer this.TapWatcherFn, (state ? "-" this.tapTime : 0)
        }
        
		; If this function fires, a key was held for longer than the tap timeout, so engage hold mode
		HoldWatcher(){
			if (this.sequence > 0 && this.state == 1){
				; Got to end of tapTime after first press, and still held.
				; HOLD PRESS
				SetTimer this.FireCallback.Bind(this, this.sequence, 1), -1
				this.holdActive := 1
			}
		}

		; If this function fires, a key was released and we got to the end of the tap timeout, but no press was seen
		TapWatcher(){
			if (this.sequence > 0 && this.state == 0){
				; TAP
				SetTimer this.FireCallback.Bind(this, this.sequence), -1
				this.ResetSequence()
			}
		}

        ; Fires the user-defined callback
		FireCallback(seq, state := -1){
			this.Callback.Call(state != -1, seq, state)
		}
	}
}