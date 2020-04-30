; Patch for TapAndHoldManager to convert it to use Interception
class InterceptionTapHold extends TapHoldManager {
	__New(ahi, id, tapTime := -1, holdTime := -1, maxTaps := -1, block := true){
		this.AHI := ahi
		this.isMouse := (id > 10)
		this.block := block
		this.id := id
		base.__New(tapTime, holdTime, maxTaps, "")
	}
	
	Add(keyName, callback, tapTime := -1, holdTime := -1, maxTaps := -1, prefixes := -1){
		this.Bindings[keyName] := new InterceptionKeyManager(this, keyName, callback, tapTime, holdTime, maxTaps, prefixes)
	}

	GetKeyboardList(){
		return this.AHI.GetDeviceList()
	}
}

class InterceptionKeyManager extends KeyManager {
	mouseButtonIds := {LButton: 0, RButton: 1, MButton: 2, XButton1: 3, XButton2: 4}
	__New(manager, keyName, Callback, tapTime := -1, holdTime := -1, maxTaps := -1, block := -1){
		if (block == -1){
			block := manager.block
		}
		this.block := block
		base.__New(manager, keyName, Callback, tapTime, holdTime, maxTaps, "")
	}

	DeclareHotkeys(){
		if (this.manager.isMouse){
			if (!this.mouseButtonIds.HasKey(this.keyName)){
				MsgBox % "Unknown Mouse Button name " this.keyName
				ExitApp
			}
			keyName := this.mouseButtonIds[this.keyName]
			result := this.manager.AHI.SubscribeMouseButton(this.manager.id, keyName, this.block, this.KeyEvent.Bind(this))
		} else {
			result := this.manager.AHI.SubscribeKey(this.manager.id, GetKeySC(this.keyName), this.block, this.KeyEvent.Bind(this))
		}
	}
}
