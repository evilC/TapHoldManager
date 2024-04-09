# TapHoldManager

An AutoHotkey library that allows you to map multiple actions to one key using a tap-and hold system  
Long press / Tap / Multi Tap / Tap and Hold / Multi Tap and Hold etc are all supported  

# Getting Help

Use the [TapHoldManager Discussion Thread on the AHK Forums](https://autohotkey.com/boards/viewtopic.php?f=6&t=45116)

Or join the [HidWizards Discord server](https://discord.gg/hjeZvkyGxB)

# Normal Usage

## Setup

1. Download a zip from the releases page
2. Extract the zip to a folder of your choice
3. Run the Example script

## Usage

Include the library

```autohotkey
#include Lib\TapHoldManager.ahk
```

Instantiate TapHoldManager

```autohotkey
;v1
thm := new TapHoldManager()

;v2
thm := TapHoldManager()
```

Add some key(s)

```autohotkey
;v1
thm.Add("1", Func("MyFunc1"))
thm.Add("2", Func("MyFunc2"))

;v2
thm.Add("1", MyFunc1)
thm.Add("2", MyFunc2)
```

Add your callback function(s)

```autohotkey
;v1
MyFunc1(isHold, taps, state){
    ToolTip % "1`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
}

MyFunc2(isHold, taps, state){
    ToolTip % "2`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state
}


; v2
MyFunc1(isHold, taps, state){
    ToolTip("1`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state)
}

MyFunc2(isHold, taps, state){
    ToolTip("2`n" (isHold ? "HOLD" : "TAP") "`nTaps: " taps "`nState: " state)
}
```

`IsHold` will be true if the event was a hold. If so, `state` will holl `1` for pressed or `0` for released.  
If `IsHold` is false, the event was a tap, and `state` will be `-1`  
In either case, `taps` holds the number of taps which occurred.  
For example, if I double-tap, `IsHold` will be false, and `taps` will be `2`.  
If I double-tapped and held on the second tap, then on press the function would be fired once with `IsHold` as true, taps would as `2` and state as `1`. When the key is released, the same but `state` would be `0`  

## Instantiating TapHoldManager

```autohotkey
;v1
thm := new TapHoldManager([<tapTime>, <holdTime>, <maxTaps>, <prefix>, <window>])

;v2
thm := TapHoldManager([<tapTime>, <holdTime>, <maxTaps>, <prefix>, <window>])
```

That is to say, all parameters are optional. If omitted, they will use the default value (See below).

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

When specifying parameters, you can omit the parameter to leave that parameter at it's default.  
For example, if you only wish to alter the `prefix` (3rd) parameter, you could do:  
`thm := new TapHoldManager(,,, "$*")` 
Or  
`thm := new TapHoldManager(,,, "$*")` 

## Adding Hotkeys

`thm.Add(<keyname>, <callback (function object)>, [tapTime, holdTime, maxTaps, prefix, window])`  
When adding keys, you can also optionally add *tapTime*, *holdTime*, *maxTaps*, *prefix*, or *window* parameters (As used when instantiating the *TapHoldManager* class) to the end to override the TapHoldManager's settings . For example:

```autohotkey
;v1
thm := new TapHoldManager(,200)        ; override holdTime to 200
thm.Add("1", Func("MyFunc1"), 100)     ; override tapTime to 100
thm.Add("2", Func("MyFunc2"), , ,4)    ; override maxTaps to 4

; v2
thm := TapHoldManager(,200)            ; override holdTime to 200
thm.Add("1", MyFunc1, 100)             ; override tapTime to 100
thm.Add("2", MyFunc2, , ,4)            ; override maxTaps to 4
```

In the above example, the TapHoldManager class (`thm`) uses all default settings except `holdTime`, which is changed to `200`.

Key `1` uses a `tapTime` of  `100`, and uses the modified `holdTime` of `200` which was inherited from `thm` - all other options are default.

Key `2` uses a  `holdTime` of `200` (Inherited from `thm`) and a `maxTaps` of `4` - all other options are default

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

```autohotkey
#include Lib\TapHoldManager.ahk
#include <AutoHotInterception>

AHI := new AutoHotInterception()
keyboardId := AHI.GetKeyboardId(0x03EB, 0xFF02)
cm1 := AHI.CreateContextManager(keyboardId)

thm := new TapHoldManager()

hotkey, if, cm1.IsActive
thm.Add("1", Func("MyFunc1"))
hotkey, if
return

MyFunc1(isHold, taps, state){
    Tooltip % "IsHold: " isHold "`nTaps: " taps "`nState: " state
}

#if cm1.IsActive ; Hotkey, if needs a context to match, even if it is empty
#if
```

### AutoHotInterception Subscription Mode

A wrapper is included which extends the TapHoldManager class and replaces the hotkey bind code with Interception bind code.  

**As well as** including the TapHoldManager library, include `InterceptionTapHold.ahk` and `AutoHotInterception.ahk`.  
There are many ways to do this - you could either have one Lib folder next to the script containing the contents of both the AHI Lib folder and the THM Lib folder, and use:

```autohotkey
#include Lib\TapHoldManager.ahk
#include Lib\InterceptionTapHold.ahk
#include Lib\AutoHotInterception.ahk
```

Or, copy the contents of both the AHI and THM Lib folders to `C:\My Documents\AutoHotkey\Lib`, and use  

```autohotkey
#include <AutoHotInterception>
#include <InterceptionTapHold>
#include <TapHoldManager>
```

Instantiate AutoHotInterception:  

```autohotkey
;v1
AHI := new AutoHotInterception()

;v2
AHI := AutoHotInterception()
```

Get the ID of your device:  

```autohotkey
;v1 / v2
keyboard1Id := AHI.GetKeyboardId(0x03EB, 0xFF02)
```




Instantiate `InterceptionTapHold` **instead of** `TapHoldManager` and pass in the AHI instance and the id of the device:  

```autohotkey
;v1
ITH := new InterceptionTapHold(<AHI Instance>, <Device ID> [, <tapTime>, <holdTime>, <maxTaps>, <block>])

;v2
ITH := InterceptionTapHold(<AHI Instance>, <Device ID> [, <tapTime>, <holdTime>, <maxTaps>, <block>])
```

eg

```autohotkey
;v1
ITH := new InterceptionTapHold(AHI, keyboard1Id)

;v2
ITH := InterceptionTapHold(AHI, keyboard1Id)
```

**Required Parameters**  
`AHI Instance` = An Instance of the AutoHotInterception class  
`Device ID` = The ID of the device to subscribe to  

**Optional Parameters**  
The usual THM parameters, but `window` is replaced with `block`.

`block` = whether or not to block the input. Defaults to true.  

Note: If you wish to use one script to handle multiple keyboards, use one manager per keyboard.  

```
ITH1 := new InterceptionTapHold(AHI, keyboardId1)
ITH2 := new InterceptionTapHold(AHI, keyboardId2)
```
