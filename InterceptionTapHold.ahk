#include TapHoldManager.ahk
#include CLR.ahk
; Patch for TapAndHoldManager to convert it to use Interception
class InterceptionTapHold extends TapHoldManager {
	__New(VID, PID, tapTime := 150, block := true){
		dllFile := "AutoHotInterception.dll"
		if (!FileExist(dllFile)){
			MsgBox % "Unable to find " dllFile ", exiting..."
			ExitApp
		}
		
		asm := CLR_LoadLibrary(dllFile)
		try {
			this.Interception := asm.CreateInstance("InterceptionWrapper")
		}
		catch {
			MsgBox Interception failed to load
			ExitApp
		}
		if (this.Interception.Test() != "OK"){
			MsgBox Interception Test failed
			ExitApp
		}
		
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

		base.__New(tapTime, "")
	}
	
	Add(keyName, callback, tapTime := -1, prefixes := -1){
		this.Bindings[keyName] := new InterceptionKeyManager(this, keyName, callback, tapTime, prefixes)
	}

}

class InterceptionKeyManager extends KeyManager {
	__New(manager, keyName, Callback, tapTime := -1, block := -1){
		if (block == -1){
			block := manager.block
		}
		this.block := block
		base.__New(manager, keyName, Callback, tapTime, "")
	}

	DeclareHotkeys(){
		result := this.manager.Interception.SubscribeKey(GetKeySC(this.keyName), this.block, this.KeyEvent.Bind(this), this.manager.VID, this.manager.PID)
		if (result != -1){
			MsgBox % "Could not bind to key " this.keyName ". Error code: " result
		}
	}
}