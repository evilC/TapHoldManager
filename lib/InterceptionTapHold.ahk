#include %A_LineFile%\..\TapHoldManager.ahk
#include %A_LineFile%\..\AutoHotInterception.ahk

; Patch for TapAndHoldManager to convert it to use Interception
class InterceptionTapHold extends TapHoldManager {
	__New(VID, PID, tapTime := -1, holdTime := -1, block := true){
		this.Interception := AutoHotInterception_Init()
		
		if (!vid || !pid){
			MsgBox % "No VID or PID supplied for hotkey " this.keyName
			ExitApp
		}
		this.VID := VID, this.PID := PID, this.block := block
		result := this.Interception.GetDeviceId(this.vid, this.pid)
		if (result == 0){
			MsgBox % "Device VID " vid " PID " pid " not found"
			ExitApp
		}

		base.__New(tapTime, holdTime, "")
	}
	
	Add(keyName, callback, tapTime := -1, holdTime := -1, prefixes := -1){
		this.Bindings[keyName] := new InterceptionKeyManager(this, keyName, callback, tapTime, holdTime, prefixes)
	}

	GetKeyboardList(){
		return this.Interception.GetDeviceList()
	}
}

class InterceptionKeyManager extends KeyManager {
	__New(manager, keyName, Callback, tapTime := -1, holdTime := -1, block := -1){
		if (block == -1){
			block := manager.block
		}
		this.block := block
		base.__New(manager, keyName, Callback, tapTime, holdTime, "")
	}

	DeclareHotkeys(){
		result := this.manager.Interception.SubscribeKey(GetKeySC(this.keyName), this.block, this.KeyEvent.Bind(this), this.manager.VID, this.manager.PID)
		if (result != -1){
			MsgBox % "Could not bind to key " this.keyName ". Error code: " result
		}
	}
}