# TapHoldManager

An AutoHotkey library that allows you to map multiple actions to one key using a tap-and hold system  
Long press / Tap / Multi Tap / Tap and Hold / Multi Tap and Hold etc are all supported  

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

## Syntax  
```
thm := new TapHoldManager([ <tapTime = 200>, holdTime := -1, <prefix = "$"> ])
thm.Add("<keyname>", <callback (function object)>)
```

The `tapTime` (The amount of time allowed before a tap or hold is called) can be configured and has a default value of 200ms.  
The `holdTime` (The amount of time that you need to hold a button for it to be considered a hold) defaults to the same as `tapTime`.  
The `prefix` (The prefix used for all hotkeys, default is `$`) can also be configured.  

You can pass as many parameters as you want.  
`thm := new TapHoldManager()`  
`thm := new TapHoldManager(100, 200, "$*")`  

When specifying parameters, you can use `-1` to leave that parameter at it's default.  
For example, if you only wish to alter the `prefix` (3rd) parameter, you could pass `-1` for the first two parameters.  
`thm := new TapHoldManager(-1, -1, "$*")` 

When adding keys, you can also add the same parameters to the end to override the manager's default settings  
`thm.Add("2", Func("MyFunc2"), 300, 1000, "~$")`  


# Integration with the Interception driver (Multiple Keyboard support)
TapHoldManager can use the [Interception driver](http://www.oblita.com/interception) to add support for per-keyboard hotkeys - you can bind TapHoldManager to keys on a second keyboard, and use them completely independently of your main keyboard.  

## Interception Setup
1. Set up my [AutoHotInterception](https://github.com/evilC/AutoHotInterception) AHK wrapper for Interception.  
Get the interception example running, so you know AHK can speak to interception OK.  
2. Download the latest release of TapHoldManager from the releases page and extract it to a folder of your choice.  
3. You need to add the files from AutoHotInterception's lib folder to AutoHotInterception's lib folder.  
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

**Instead of** including the TapHoldManager library, **instead** include the interception version:  
```
; #include Lib\TapHoldManager.ahk
#include Lib\InterceptionTapHold.ahk
```

Instantiate `InterceptionTapHold` instead of `TapHoldManager`  
`kb1 := new InterceptionTapHold(<VID>, <PID> [, <tapTime>, <block = true>])`  

In this version, the VID and PID of the device need to be passed as the first two parameters.  
To get VIDs / PIDs, you can call `devices := kb1.GetKeyboardList()`  
Also, the `prefix` parameter is now the `block` parameter  

Note: Use one manager per keyboard.  
```
kb1 := new InterceptionTapHold(0x413C, 0x2107)
kb2 := new InterceptionTapHold(0x1234, 0x2107)
```

## Optional Parameters  
`tapTime` remains the same  
`prefix` is replaced by `block` - `true` to block, `false` to not block
