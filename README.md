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

# Optional paramters  
The `tapTime` (The amount of time allowed before a tap or hold is called) can be configured and has a default value of 200ms.  
The `prefix` (The prefix used for all hotkeys, default is `$`) can also be configured.  

The manager can take these optional parameters.  
`thm := new TapHoldManager(100, "$*")`  

When adding keys, you can also specify parameters to override the manager's default settings
`thm.Add("2", Func("MyFunc2"), 500, "~$")`  

When specifying parameters, you can use `-1` to leave that parameter at it's default.

# Interception addon
Also included is a variant which uses the [Interception driver](http://www.oblita.com/interception) to add support for per-keyboard hotkeys - you can bind TapHoldManager to keys on a second keyboard, and use them completely independently of your main keyboard.  

## Interception Setup
1. Set up my [AutoHotInterception](https://github.com/evilC/AutoHotInterception) AHK wrapper for Interception.  
Get the interception example running, so you know AHK can speak to interception OK.  
2. Download the latest release of TapHoldManager from the releases page and extract it to a folder of your choice.  
3. You need to add the files from AutoHotInterception's lib folder to AutoHotInterception's lib folder.  
(Or, you can make sure the contents of both lib folders are in `My Documents\AutoHotkey\Lib`)  
4. Enter the VID / PID of your keyboard(s) into the Interception example script and run  

## Usage
As the normal version, however VID and PID of the device to subscribe to must be provided before any optional parameters.  
Also, the `prefix` parameter is now the `block` parameter  
Use one manager per keyboard.  
`kb1 := new InterceptionTapHold(VID1, PID1)`  

## Optional Parameters  
`tapTime` remains the same  
`prefix` is replaced by `block` - `true` to block, `false` to not block
