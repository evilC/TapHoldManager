#Requires AutoHotkey v2.0
; Exmaple of Context Specific hotkeys (Only applies to a certain window)  
; If the library files are in a subfolder called Lib next to the script, use this
#include Lib\TapHoldManager.ahk
; If you placed all the library files in your My Documents\AutoHotkey\lib folder, use this
;#include <TapHoldManager>

thm := TapHoldManager(,,,,"ahk_exe notepad.exe") ; with window parameter set here, default window criteria that will be set for all sub-created hotkeys under this manager object is notepad
thm.Add("1", MyFunc1)
thm.Add("2", MyFunc2)
thm.Add("3", MyFunc3,,,,,"ahk_class WordPadClass") ; this hotkey's window criteria will be WordPad (instead of manager object's previously passed-in notepad default)

MyFunc1(isHold, taps, state){
  ToolTip("1`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state)
  SetTimer(RemoveTooltip, -1000)
}

MyFunc2(isHold, taps, state){
  ToolTip("2`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state)
  SetTimer(RemoveTooltip, -1000)
}

MyFunc3(isHold, taps, state){
  ToolTip("3`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state)
  SetTimer(RemoveTooltip, -1000)
}

RemoveTooltip(){
  ToolTip
}

^Esc::ExitApp
