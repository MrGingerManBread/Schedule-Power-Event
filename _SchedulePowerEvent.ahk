; =================================================================================
; =================================================================================
; =================================================================================
; Schedule Power Event
; =================================================================================
; ====== by: Derek Nelson ===== 2023 ==============================================
; =================================================================================
; HOTKEYS (#IfWinActive): d, e, h, m, r, s, t, w, x, z, {ENTER}, {ESCAPE}

;fp1 steal win-spy drag'n'drop thingy for WINDOW EVENT
;fp2 populate 'DelayValue' EDIT field with ListView selection or FindTool (real-time) selection
;fp3 write in code for EXE/WINDOW EVENTS into the ENTER hotkey area
;fp4 tweak countdown box to show remaining days, hours, minutes, and seconds (as necessary)


;;;;;;;;;;;;;;;;;;;;
;;; SETUP
;;;;;;;;;;;;;;;;;;;;

#NoEnv
#SingleInstance, Force
#NoTrayIcon
SetTitleMatchMode, 3 ; exact matches only
#IfWinActive, Schedule Power Event

; images
ResDir:= "E:\Downloads\!! STUFF !!\WinSpy\Resources"
Bitmap1:= ResDir . "\FindTool1.bmp"
Bitmap2:= ResDir . "\FindTool2.bmp"
hCrossHair:= DllCall("LoadImage", Int, 0, Str, ResDir . "\CrossHair.cur", Int, 2, Int, 32, "Int", 32, UInt, 0x10) ; LR_LOADFROMFILE
VarSetCapacity(AndMask, 32*4, 0xFF), VarSetCapacity(XorMask, 32*4, 0) ; Setup a blank icon
hIcon:= DllCall("CreateCursor", Uint,0, Int,0, Int,0, Int,32, Int,32, Uint,&AndMask, Uint,&XorMask) ; Setup a blank icon

; variable optimization
dtit:= "[3] CHOOSE "
dtit1:= dtit . "DELAY AMOUNT:"
rd:= " +Redraw"
btxt:= "+cBlack" . rd
ptxt:= "+cPurple" . rd
rtxt:= "+cRed" . rd
ytxt:= "+cYellow" . rd

; default text blinking at GUI creation
BlinkEvent:= 3 ; SLEEP blink
BlinkDelay:= 4 ; SECONDS blink
EVENT_TYPE:= "Z" ; SLEEP


;;;;;;;;;;;;;;;;;;;;
;;; MAIN BODY
;;;;;;;;;;;;;;;;;;;;

Gui Color, Black, Black
Gui Margin, 0, 15
Gui Font, Bold s12 cPurple, Hermit
	Gui Add, Text, Center cLime x0 y0 w300					, ___________________________
	Gui Add, Text, Center cRed x0 y+9 w300					, !! SCHEDULE POWER EVENT !!
	Gui Add, Text, Center cLime x0 y+-6 w300				, ___________________________
Gui Add, GroupBox, Section cLime x15 y+9 h122 w270			, [1] CHOOSE POWER EVENT:
	Gui Add, Text, vbt1 cBlack x25 ys+25					, ►►
	Gui Add, Text, vt1 x+10								, (R) RESTART
	Gui Add, Text, vbt2 cBlack x25 y+						, ►►
	Gui Add, Text, vt2 x+10								, (T) SHUTDOWN
	Gui Add, Text, vbt3 cBlack x25 y+						, ►►
	Gui Add, Text, vt3 cYellow x+10						, (Z) SLEEP
	Gui Add, Text, Section cRed x55 y+						, (X) EXIT
	Gui Font, s10
	Gui Add, Text, cRed x+30 y+-21						, (Esc) Reload
	Gui Font, s12
Gui Add, GroupBox, Section cLime x15 ys+42 h168 w270			, [2] CHOOSE WAITING TYPE:
	Gui Add, Text, vbt4 cBlack x25 ys+25					, ►►
	Gui Add, Text, vt4 cYellow x+10						, (S) SECONDS
	Gui Add, Text, vbt5 cBlack x25 y+						, ►►
	Gui Add, Text, vt5 x+10								, (M) MINUTES
	Gui Add, Text, vbt6 cBlack x25 y+						, ►►
	Gui Add, Text, vt6 x+10								, (H) HOURS
	Gui Add, Text, vbt7 cBlack x25 y+						, ►►
	Gui Add, Text, vt7 x+10								, (D) DAYS
	Gui Add, Text, vbt8 cBlack x25 y+						, ►►
	Gui Add, Text, vt8 x+10								, (E) EXE TERMINATION
	Gui Add, Text, vbt9 cBlack x25 y+						, ►►
	Gui Add, Text, vt9 x+10								, (W) WINDOW CLOSURE
Gui Add, GroupBox, vDelayTitle Section cLime x15 y+19 h90 w270	, % dtit1
	Gui Add, Edit, gEditMod hwndhEDIT vDelayValue Center Number cYellow x25 ys+30 h25 w250 ; <<<===@@@ DelayValue EDIT field here
	Gui Add, Text, vbt10 Center Section cBlack y+7 w250
Gui Font, s10
	Gui Add, ListView, gLVMod vEXElv AltSubmit Grid +Hidden -Multi R6 BackgroundWhite cBlack x15 ys+42 w270, PID|Process
	Gui Add, Picture, gFindToolHandler vFINDtl Border +Hidden x30 ys+42 h28 w31, %Bitmap1%
	Gui Add, Text, vFINDtx +Hidden cLime x+15 y+-33, Drag && drop this onto`na window to select it
Gui -Caption +hwndhSPE +LastFound +Owner -SysMenu ; Removes titlebar (and buttons), taskbar icon, and preps for blanking the alt-tab icon
SendMessage, 0x80, 1, hIcon ; Call blank icon
Gui Show, AutoSize Center, Schedule Power Event

; FindTool stuff
OnMessage(0x200, "OnWM_MOUSEMOVE")
OnMessage(0x202, "OnWM_LBUTTONUP")
; no return here!! go directly into the Blink timer below.


;;;;;;;;;;;;;;;;;;;;
;;; LABELS / SUBS
;;;;;;;;;;;;;;;;;;;;

Blink:
	yblink:= (toggle:= !toggle) ? ytxt : btxt ; toggle yellow & black
	rblink:= (toggle) ? rtxt : btxt ; toggle red & black
	Loop, 10 {
		if (A_Index <= 3)
			GuiControl, % (BlinkEvent = A_Index) ? yblink : btxt, bt%A_Index%
		else if (A_Index <= 9)
			GuiControl, % (BlinkDelay = A_Index) ? yblink : btxt, bt%A_Index%
		else {
			GuiControl,, bt%A_Index%, % (BlinkCommit)
			? "►►► NOW PRESS ENTER ◄◄◄"
			: (BlinkDelay > 7) ? "▼ make your selection ▼"
			: " ▲▲   type a number   ▲▲ "
			GuiControl, % (BlinkCommit) ? rblink : yblink, bt%A_Index%
		}
	}
	SetTimer, Blink, % (toggle) ? "750" : "250"
	return

EditMod:
	Gui, Submit, NoHide
	BlinkCommit:= (DelayValue != "") ? 1 : 0
	return

EditScroll:
	ControlSend,, % (etoggle:= !etoggle) ? "{End}" : "{Home}", ahk_id %hEDIT%
	return

ExitSub:
	ExitApp
	return

FindToolHandler:
	Dragging:= True
	GuiControl,, FINDtl, %Bitmap2%
	DllCall("SetCapture", Ptr, hSPE)
	holdCursor:= DllCall("SetCursor", Ptr, hCrossHair)
	return

LVMod:
	if (A_GuiControlEvent = "Normal") || (A_GuiControlEvent = "DoubleClick") {
		LVrow:= A_EventInfo
		LV_GetText(LVpid, LVrow)
		LV_GetText(LVproc, LVrow, 2)
		GuiControl,, DelayValue, %LVproc% (%LVpid%) ; @@@@@@@@@@@@@ EXE DelayValue @@@@@@@@@@@@@
		Gui, Submit, NoHide
		EditLen:= StrLen(DelayValue)
		SetTimer, EditScroll, % (EditLen > 22) ? "1500" : "Off"
		BlinkCommit:= 1
	}
	return

ProcessList:
	WTSEnumProcesses(), LV_Delete()
	loop % arrLIST.MaxIndex() {
		if (arrLIST[A_Index, "PID"] = 0)
			Continue
		LV_Add("", arrLIST[A_Index, "PID"], arrLIST[A_Index, "Process"])
	}
	LV_ModifyCol(1, "Integer AutoHdr Sort", "PID"), LV_ModifyCol(2, "AutoHdr Sort", "Process")
	return

ReloadSub:
	reload
	return

WindowList:
	/*
		WinGet, WinList, List
		loop % WinList {
			WinGet, EXEname, ProcessName, % "ahk_id " . WinList%A_Index%
			EXEname:= SubStr(EXEname, 1, StrLen(EXEname)-4)
			WinGetTitle, WinTit, % "ahk_id " . WinList%A_Index%
			if (WinTit = "")
				Continue
			LV_Add("", EXEname, WinTit)
		}
		LV_ModifyCol(2, "AutoHdr Sort", "Title"), LV_ModifyCol(1, "100 Sort", "Process")
	*/
	return


;;;;;;;;;;;;;;;;;;;;
;;; HOTKEYS
;;;;;;;;;;;;;;;;;;;;

x::Goto ExitSub
Escape::Goto ReloadSub

p::Msgbox % "DV @" . DelayValue . "@`nNT @" . NewText . "@" ; @@@ test line @@@

r::
t::
z::
	EVENT_TYPE:= A_ThisHotkey
	BlinkEvent:= (EVENT_TYPE = "R") ? 1 : (EVENT_TYPE = "T") ? 2 : 3
	SetTimer, Blink, 0
	Loop, 3
		GuiControl, % (BlinkEvent = A_Index) ? ytxt : ptxt, t%A_Index%
	return

s::
m::
h::
d::
e::
w::
	SetTimer, EditScroll, Off
	GuiControl,, DelayValue ; erase edit control's contents
	DELAY_TYPE:= A_ThisHotkey
	BlinkDelay:= (DELAY_TYPE = "S") ? 4
		: (DELAY_TYPE = "M") ? 5
		: (DELAY_TYPE = "H") ? 6
		: (DELAY_TYPE = "D") ? 7
		: (DELAY_TYPE = "E") ? 8
		: 9 ; DELAY_TYPE = W
	GuiControl, % (BlinkDelay > 7) ? "Disable" : "Enable", DelayValue
	SetTimer, Blink, 0
	Loop, 6 {
		lnum:= A_Index + 3
		GuiControl, % (BlinkDelay = lnum) ? ytxt : ptxt, t%lnum%
	}
	GuiControl,, DelayTitle, % (BlinkDelay = 8) ? dtit . "AN EXE:" : (BlinkDelay = 9) ? dtit . "A WINDOW:" : dtit1
	if (BlinkDelay > 7)
		Gosub, % (BlinkDelay = 8) ? "ProcessList" : "WindowList" ; @@@@@@@@@@ GO SUBS @@@@@@@@@@
	GuiControl, % (BlinkDelay = 8) ? "Show" : "Hide", EXElv
	GuiControl, % (BlinkDelay = 9) ? "Show" : "Hide", FINDtl
	GuiControl, % (BlinkDelay = 9) ? "Show" : "Hide", FINDtx
	GuiControl, Focus, % (BlinkDelay = 8) ? "EXElv" : "DelayValue"
	Gui Show, AutoSize Center
	return

Enter::
NumpadEnter::
	Gui Submit, NoHide
	if (DelayValue = "")
		return
	if (BlinkDelay > 7) {
		;fp3 (if delay is EXE or WINDOW)
		; do something with DelayValue
	}
	else
		DelayValue *= (DELAY_TYPE = "M") ? 60 : (DELAY_TYPE = "H") ? 3600 : (DELAY_TYPE = "D") ? 86400 : 1
	Gui Destroy
	Gui Color, Black, Black
	Gui Font, Bold s12 cLime, Hermit
	Gui Add, Text, y0 w320 Center, _________________________________
	Gui Add, Text, cYellow, % EVENT:= (EVENT_TYPE = "R") ? "RESTART" : (EVENT_TYPE = "T") ? "SHUTDOWN" : "SLEEP"
	Gui Add, Text, x+m, % (BlinkDelay > 7) ? "WHEN:" : "IN:"
	Gui Add, Text, cPurple x+m vCounter, %DelayValue%
	Gui Add, Text, x+m vseconds, % (BlinkDelay > 7) ? "CLOSES" : "SECONDS"
	Gui Add, Text, xm y+-4 w320 Center, _________________________________
	Gui Add, Button, Center x110 gReloadSub, Cancel?
	Gui +Owner +LastFound -SysMenu -Caption
		SendMessage, 0x80, 1, hIcon ; Call for blank icon
	Gui Show, Autosize Center, % EVENT . " COUNTDOWN"
	if (BlinkDelay = 8) {
		; !ProcessExist(pidORname)
	}
	else if (BlinkDelay = 9) {
		; WinWaitClose
	}
	else {
		DelayValueTotal:= DelayValue
		Loop % DelayValue {
			GuiControl,, Counter, % DelayValue--
			GuiControl, % (DelayValueTotal-A_Index+1 <= 10) ? rtxt : ptxt, Counter
			Sleep 1000
		}
	}
	Gui Destroy
	; MsgBox BANG! ; @@@ test line @@@
	; Goto, ReloadSub ; @@@ test line @@@
	if (EVENT_TYPE = "Z")
		DllCall("PowrProf\SetSuspendState", int, 0, int, 1, int, 0) ; force sleep
	else
		Shutdown, % (EVENT_TYPE = "T") ? (4+1) : (4+2) ; if T, force shutdown else force restart
	ExitApp
	return


;;;;;;;;;;;;;;;;;;;;
;;; FUNCTIONS
;;;;;;;;;;;;;;;;;;;;

OnWM_MOUSEMOVE(wParam, lParam, msg, hWnd) {
	Static hOldWnd:= 0
	If (Dragging) {
		MsgBox howdy1
		MouseGetPos x, y, hWin
		g_hWnd:= hWin
		If (g_hWnd != hOldWnd)
			ShowBorder(g_hWnd)
		hOldWnd:= g_hWnd
	}
}

OnWM_LBUTTONUP(wParam, lParam, msg, hWnd) {
	If (Dragging) {
		MsgBox howdy3
		Dragging:= False
		DllCall("ReleaseCapture")
		DllCall("SetCursor", Ptr, hOldCursor)
		GuiControl,, FINDtl, %Bitmap1%
		Loop 4 {
			Index:= A_Index + 90
			Gui %Index%: Destroy
		}
		WinGetTitle, Title, ahk_id %g_hWnd%
		WinGet PID, PID, ahk_id %g_hWnd%
		MsgBox % Title . " (" . PID . ")"
	}
}

ProcessExist(pidORname) {
	Process, Exist, %pidORname%
	return ErrorLevel
}

ShowBorder(hWnd, Color:= "0x3FBBE3", r:= 3) {
	Local wx, wy, ww, wh, x, y, w, h, Index
	MsgBox howdy2
	WinGetPos wx, wy, ww, wh, ahk_id %hWnd%
	If (!ww) {
		Return
	}
	x:= wx, y:= wy, w:= ww, h:= wh
	Loop 4 {
		Index:= A_Index + 90
		Gui %Index%: +AlwaysOnTop -Caption +ToolWindow
		Gui %Index%: Color, %Color%
	}
	Gui 91: Show, % "NA x" (x - r) " y" (y - r) " w" (w + r + r) " h" r
	Gui 92: Show, % "NA x" (x - r) " y" (y + h) " w" (w + r + r) " h" r
	Gui 93: Show, % "NA x" (x - r) " y" y " w" r " h" h
	Gui 94: Show, % "NA x" (x + w) " y" y " w" r " h" h
}

WTSEnumProcesses() { ; By SKAN modified by jNizM  
	local tPtr:=pPtr:=nTTL:= 0, LIST:= ""
	hModule:= DllCall("kernel32.dll\LoadLibrary", "Str", "wtsapi32.dll", "Ptr")
	if !(DllCall("wtsapi32.dll\WTSEnumerateProcesses", "Ptr", 0, "UInt", 0, "UInt", 1, "Ptr*", pPtr, "UInt*", nTTL))
		return "", DllCall("kernel32.dll\SetLastError", "UInt", -1)
	tPtr:= pPtr, arrLIST:= []
	loop % (nTTL) {
		arrLIST[A_Index, "PID"]     := NumGet(tPtr + 4, "UInt")    ; ProcessId (PID)
		arrLIST[A_Index, "Process"] := StrGet(NumGet(tPtr + 8))    ; ProcessName
		tPtr += (A_PtrSize = 4 ? 16 : 24)                          ; sizeof(WTS_PROCESS_INFO)
	}
	DllCall("wtsapi32.dll\WTSFreeMemory", "Ptr", pPtr)
	if (hModule)
		DllCall("kernel32.dll\FreeLibrary", "Ptr", hModule)
	return arrLIST, DllCall("kernel32.dll\SetLastError", "UInt", nTTL)
} ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=4365#p44554