#InstallKeybdHook
ecm_active_duration:=	7
ecm_reload_duration:=	13
prog_active_1=		FFFF00
prog_active_2=		FFA500
prog_reload_1=		Green
prog_reload_2=		Red
bf4_color=		2E81AC
;Screen startup position
st_x=			2115
st_y=			829


CoordMode, Menu, Screen
Gui, +AlwaysOnTop +LastFound +Owner +hwndguihwnd +ToolWindow -MinimizeBox -MaximizeBox
Gui, Color, %bf4_color%
Gui, Add, Progress, y0 w560 h20 +c%prog_reload_2% +Background%bf4_color% Range0-1000 vMyProgress
Gui, Show, x%st_x% y%st_y%, ECM: Ready

reset:=true
return

Odd(n)
{
    return n&1
}

*~$x::
if (reset)
{
Gui, Show, NA, ECM: Active
GuiControl, +c%prog_reload_2% +Background%prog_reload_1%, MyProgress,0
DllCall("QueryPerformanceCounter", "Int64*", CounterBefore)
DllCall("QueryPerformanceFrequency", "Int64*", Frequency)
reset:=false
SetTimer, CM_active, 1
}
return


CM_active:
DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
et:=(CounterAfter - CounterBefore)/Frequency
lt:=round(ecm_active_duration-et,2)
If (et >= ecm_active_duration)
{
	SetTimer,CM_active,Off
	Gui, Show, NA, ECM: Reloading
	GuiControl, +c%prog_reload_1% +Background%prog_reload_2%, MyProgress
	GuiControl,, MyProgress, 0
	DllCall("QueryPerformanceCounter", "Int64*", CounterBefore)
	DllCall("QueryPerformanceFrequency", "Int64*", Frequency)
	SetTimer,CM_reloading,1
	return
}
else
{
	if (Odd(round(et*10)))
	{
		GuiControl, +c%prog_active_1% +Background%bf4_color%, MyProgress
	}
	else
	{
		GuiControl, +c%prog_active_2% +Background%bf4_color%, MyProgress
	}
	Gui, Show, NA, ECM: Active %lt%
	GuiControl,, MyProgress, % (et*1000/ecm_active_duration)
}
return

CM_reloading:
DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
et:=(CounterAfter - CounterBefore)/Frequency
lt:=round(ecm_reload_duration-et,2)
If (et >= ecm_reload_duration)
{
	GuiControl, +c%prog_reload_2% +Background%bf4_color%, MyProgress
	GuiControl,, MyProgress, 0
	SetTimer,CM_reloading,Off
	Gui, Show, NA, ECM: Ready
	reset:=true
	return
}
else
{
	Gui, Show, NA, ECM: Reloading %lt%
	GuiControl,, MyProgress, % (et*1000/ecm_reload_duration)
}
return
