#Requires AutoHotkey v2.0

; Patch for TapAndHoldManager to convert it to use Interception
class InterceptionTapHold extends TapHoldManager {
	__New(ahi, id, tapTime?, holdTime?, maxTaps?, block := true){
		this.AHI := ahi
		this.isMouse := (id > 10)
		this.block := block
		this.id := id
		super.__New(tapTime?, holdTime?, maxTaps?)
	}
	
	Add(keyName, callback, tapTime?, holdTime?, maxTaps?, block?){
		this.Bindings[keyName] := InterceptionKeyManager(this, keyName, callback, tapTime ?? this.tapTime, holdTime ?? this.holdTime, maxTaps ?? this.maxTaps, block ?? this.block)
	}

	GetKeyboardList(){
		return this.AHI.GetDeviceList()
	}
}

class InterceptionKeyManager extends TapHoldManager.KeyManager {
	mouseButtonIds := {LButton: 0, RButton: 1, MButton: 2, XButton1: 3, XButton2: 4}
	__New(manager, keyName, Callback, tapTime, holdTime, maxTaps, block){
		this.block := block ?? manager.block
		super.__New(manager, keyName, Callback, tapTime, holdTime, maxTaps)
	}

	DeclareHotkeys(){
		this.SetState(1)
	}
	
	SetState(state){
		if (this.manager.isMouse){
			if (!this.mouseButtonIds.HasKey(this.keyName)){
				MsgBox("Unknown Mouse Button name " this.keyName)
				ExitApp
			}
			keyName := this.mouseButtonIds[this.keyName]
			if (state)
				result := this.manager.AHI.SubscribeMouseButton(this.manager.id, keyName, this.block, this.KeyEvent.Bind(this))
			else
				result := this.manager.AHI.UnsubscribeMouseButton(this.manager.id, keyName)
				
		} else {
			if (state)
				result := this.manager.AHI.SubscribeKey(this.manager.id, GetKeySC(this.keyName), this.block, this.KeyEvent.Bind(this))
			else
				result := this.manager.AHI.UnsubscribeKey(this.manager.id, GetKeySC(this.keyName))
		}
	}
}