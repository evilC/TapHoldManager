# TapHoldManager

An AutoHotkey library that allows you to map multiple actions to one key using a tap-and hold system  
Long press / Tap / Multi Tap / Tap and Hold / Multi Tap and Hold etc are all supported  

# Getting Help
Use the [TapHoldManager Discussion Thread on the AHK Forums](https://autohotkey.com/boards/viewtopic.php?f=6&t=45116)

# Normal Usage
## Setup
1. Download a zip from the releases page
2. Extract the zip to a folder of your choice
3. Run the Example script

## Usage

Include the library
```
#include Lib\TapHoldManager.ahk
```

Instantiate TapHoldManager
```
thm := new TapHoldManager()
```

Add some key(s)
```
thm.Add("1", Func("MyFunc1"))
thm.Add("2", Func("MyFunc2"))
```

Add your callback function(s)
```
MyFunc1(isHold, taps, state){
	ToolTip % "1`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
}

MyFunc2(isHold, taps, state){
	ToolTip % "2`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
}
```

`IsHold` will be true if the event was a hold. If so, `state` will holl `1` for pressed or `0` for released.  
If `IsHold` is false, the event was a tap, and `state` will be `-1`  
In either case, `taps` holds the number of taps which occurred.  
For example, if I double-tap, `IsHold` will be false, and `taps` will be `2`.  
If I double-tapped and held on the second tap, then on press the function would be fired once with `IsHold` as true, taps would as `2` and state as `1`. When the key is released, the same but `state` would be `0`  

## Instantiating TapHoldManager  
`thm := new TapHoldManager([ <tapTime := -1>, holdTime := -1, <maxTaps := -1>, <prefix := "$">, <window := ""> ])`

**tapTime** The amount of time after a tap occured to wait for another tap.  
Defaults to 150ms.  
**holdTime** The amount of time that you need to hold a button for it to be considered a hold.  
Defaults to the same as `tapTime`.  
**maxTaps** The maximum number of taps before the callback will be fired.  
Defaults to infinite.  
Setting this value to `1` will force the callback to be fired after every tap, whereas by default if you tapped 3 times quickly it would fire the callback once and pass it a `taps` value of `3`, it would now be fired 3 times with a `taps` value of `1`.  
If `maxTaps` is 1, then the `tapTime` setting will have no effect.  
**prefix** The prefix used for all hotkeys, default is `$`  
**window** An AHK [WinTitle](https://www.autohotkey.com/docs/misc/WinTitle.htm) string that defines which windows the hotkey will take effect in  
For example, to make Hotkeys only work in Notepad, you could use:  
`thm := new TapHoldManager(,,,,"ahk_exe notepad.exe")`  

You can pass as many parameters as you want.  
`thm := new TapHoldManager()`  
`thm := new TapHoldManager(100, 200, 1, "$*")`  

When specifying parameters, you can omit the parameter (or use `-1`) to leave that parameter at it's default.  
For example, if you only wish to alter the `prefix` (3rd) parameter, you could do:  
`thm := new TapHoldManager(-1, -1, -1, "$*")` 
Or  
`thm := new TapHoldManager(,,, "$*")` 

## Adding Hotkeys
`thm.Add("<keyname>", <callback (function object)> [,<tapTime := -1>, holdTime := -1, <maxTaps := -1>, <prefix := "$">, <window := "">])`  
When adding keys, you can also add the same parameters to the end to override the manager's default settings  
`thm.Add("2", Func("MyFunc2"), 300, 1000, 1, "~$")`  

## Enabling or Disabling Hotkeys  
Hotkeys can be disabled by calling `PauseHotkey` and passing the name of the key to pause:  
`thm.PauseHotkey("1")`  

Hotkeys can be re-enabled by calling `ResumeHotkey` and passing the name of the key to resume:  
`thm.PauseHotkey("1")`  

Hotkeys can be removed by calling `RemoveHotkey` and passing the name of the key to remove:  
`thm.RemoveKey("1")`  

## Logic Flowchart
(Note that the firing of the function on key release during a hold is omitted from this diagram for brevity)
![flowchart](LogicFlowchart.png)  

## Example Timelines
![timeline](Timelines.png)

## Minimizing response times  
To make taps fire as quickly as possible, set `tapTime` as low as possible.  
If you do not require multi-tap or multi-tap-and-hold, then setting `maxTaps` to 1 will make taps respond instantly upon release of the key. In this mode, the `tapTime` setting will have no effect.  
To make holds fire as quickly as possible, setting `holdTime` as low as possible will help. `maxTaps` will not affect response time of holds, as they always end a sequence.

# Integration with the Interception driver (Multiple Keyboard support)
TapHoldManager can use the [Interception driver](http://www.oblita.com/interception) to add support for per-keyboard hotkeys - you can bind TapHoldManager to keys on a second keyboard, and use them completely independently of your main keyboard.  

## Interception Setup
1. Set up my [AutoHotInterception](https://github.com/evilC/AutoHotInterception) AHK wrapper for Interception.  
Get the interception example running, so you know AHK can speak to interception OK.  
2. Download the latest release of TapHoldManager from the releases page and extract it to a folder of your choice.  
3. You need to add the files from TapHoldManager's lib folder to AutoHotInterception's lib folder.  
(Or, you can make sure the contents of both lib folders are in `My Documents\AutoHotkey\Lib`)  
4. Enter the VID / PID of your keyboard(s) into the Interception example script and run  

## AutoHotInterception modes
TapHoldManager works in both AutoHotInterception modes - "Context" and "Subscription" modes.  

### AutoHotInterception Context Mode
Just before you call `Add`, set the context for hotkeys using `hotkey, if, <context var>` which matches that which your AHK Context Callback sets.  
For example:  
```
SetKb1Context(state){
	global isKeyboard1Active
	Sleep 0		; We seem to need this for hotstrings to work, not sure why
	isKeyboard1Active := state
}

[...]

hotkey, if, isKeyboard1Active	; < Causes TapHoldManager's hotkeys to use the context
thm.Add("1", Func("MyFunc1"))
```

### AutoHotInterception Subscription Mode 
A wrapper is included which extends the TapHoldManager class and replaces the hotkey bind code with Interception bind code.  

**As well as** including the TapHoldManager library, include `InterceptionTapHold.ahk` and `AutoHotInterception.ahk`.  
There are many ways to do this - you could either have one Lib folder next to the script containing the contents of both the AHI Lib folder and the THM Lib folder, and use:
```
#include Lib\TapHoldManager.ahk
#include Lib\InterceptionTapHold.ahk
#include Lib\AutoHotInterception.ahk
```

Or, copy the contents of both the AHI and THM Lib folders to `C:\My Documents\AutoHotkey\Lib`, and use  
```
#include <AutoHotInterception>
#include <InterceptionTapHold>
#include <TapHoldManager>
```

Instantiate AutoHotInterception:  
`AHI := new AutoHotInterception()`

Get the ID of your device:  
`keyboard1Id := AHI.GetKeyboardId(0x03EB, 0xFF02)`

Instantiate `InterceptionTapHold` **instead of** `TapHoldManager` and pass in the AHI instance and the id of the device:  
`THI1 := new InterceptionTapHold(<AHI Instance>, <Device ID> [, <tapTime>, <holdTime>, <maxTaps>, <block>])`  
eg `ITH1 := new InterceptionTapHold(AHI, keyboard1Id)`  

**Required Parameters**  
`AHI Instance` = An Instance of the AutoHotInterception class  
`Device ID` = The ID of the device to subscribe to  

**Optional Parameters**  
The usual THM parameters, plus:  
`block` = whether or not to block the input. Defaults to true.  

Note: Use one manager per keyboard.  
```
ITH1 := new InterceptionTapHold(AHI, keyboardId1)
ITH2 := new InterceptionTapHold(AHI, keyboardId2)
```
