  
; If the library files are in a subfolder called Lib next to the script, use this
#include Lib\TapHoldManager.ahk
; If you placed all the library files in your My Documents\AutoHotkey\lib folder, use this
;#include <TapHoldManager>

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
  thm.PauseHotkey("2")
return

$6:: ; resume hotkey "2"
  thm.ResumeHotkey("2")
return

$7:: ; remove hotkey "2"
  thm.RemoveHotkey("2")
return

^Esc::ExitApp
