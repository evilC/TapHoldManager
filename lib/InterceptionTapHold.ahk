#include %A_LineFile%\..\TapHoldManager.ahk
#include %A_LineFile%\..\AutoHotInterception.ahk

; Patch for TapAndHoldManager to convert it to use Interception
class InterceptionTapHold extends TapHoldManager {
	__New(VID, PID, isMouse := false, instance := 1, tapTime := -1, holdTime := -1, block := true){
		this.AHI := new AutoHotInterception()
		this.isMouse := isMouse, this.block := block
		this.id := this.AHI.GetDeviceId(isMouse, vid, pid, instance)
		id := this.id
		if (!(this.id > 0 &&  this.id < 21)){
			MsgBox % "Unknown device id " this.id " for device VID " VID ", PID " PID ", Instance " instance
		}
		base.__New(tapTime, holdTime, "")
	}
	
	Add(keyName, callback, tapTime := -1, holdTime := -1, prefixes := -1){
		this.Bindings[keyName] := new InterceptionKeyManager(this, keyName, callback, tapTime, holdTime, prefixes)
	}

	GetKeyboardList(){
		return this.AHI.GetDeviceList()
	}
}

class InterceptionKeyManager extends KeyManager {
	mouseButtonIds := {LButton: 0, RButton: 1, MButton: 2, XButton1: 3, XButton2: 4}
	__New(manager, keyName, Callback, tapTime := -1, holdTime := -1, block := -1){
		if (block == -1){
			block := manager.block
		}
		this.block := block
		base.__New(manager, keyName, Callback, tapTime, holdTime, "")
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