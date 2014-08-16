/* Function: print
 * Print 'objects' to the stream 'f' separated by 's' and followed by 'e'.
 * Syntax:
 *     print( objects* [, kwargs := {s:"", e:"`n", f:"*", w:0} ] )
 * Parameter(s):
 *     objects*  [in] - Variadic number of item(s) to print. Item can be
 *                      a string, number or object*.
 *     kwargs    [in] - An asscoiative array w/ the following keys(optional):
 *     • s            - separates each object with the specified character(s).
 *     • e            - ending character, default is newline (`n)
 *     • f            - the file to write to, default is StdOut. Specifiy "~"
 *                      to print object(s) to the script's main window.
 *     • w            - When "~" is specified for kwargs["f"], specifying 1,
 *                      tells the function to wait until the script's main
 *                      window is closed before returning/proceeding.
 *                      Default is 0/false.
 * Remarks:
 *     Only generic AHK object(s) are supported. Other types such as COM, Func,
 *     File, RegExMatch, etc. objects are not supported.
 */
print(args*) {
	static is_v2 := A_AhkVersion >= "2"
	     , len   := Func(is_v2 ? "ObjLength"   : "ObjMaxIndex")
	     , del   := Func(is_v2 ? "ObjRemoveAt" : "ObjRemove")
	static default := { ;// default values for kwargs
	(Join Q C
		"s": "",   ;// separator
		"e": "`n", ;// end
		"f": "*",  ;// file to write to, default is StdOut
		"w": 0     ;// wait, applies to f:="~", print to script's main window
	)}
	;// MaxIndex/Length == Count
	if ((max := %len%(args)) == NumGet(&args+4*A_PtrSize)) {
		match := false
		for k in args[max]
			match := default.HasKey(k)
		until !match
		kwargs := match ? %del%(args, max) : default
	;// kwargs parameter passed using variadic syntax -> kwargs*
	} else {
		kwargs := args.Clone(), kwargs.Remove(1, max)
		for k in kwargs
			args.Remove(k)
	}
	for key, val in (kwargs != default ? default : 0)
		if !kwargs.HasKey(key)
			kwargs[key] := val
	out := "", max := %len%(args)
	for i, obj in args
		out .= (IsObject(obj) ? print_r(obj) : obj) . kwargs[i < max ? "s" : "e"]
	;// print object(s) to script's main window
	if (kwargs.f == "~") {
		dhw := A_DetectHiddenWindows
		DetectHiddenWindows On
		if !WinExist("ahk_id " A_ScriptHwnd) ;// make LastFound
			return
		;// Convert line endings to "`r`n" (Windows)
		out := Trim(out, kwargs.e), i := 1
		while (i := InStr(out, "`r",, i))
			out := SubStr(out, 1, i-1) . SubStr(out, i+1)
		i := -1
		while (i := InStr(out, "`n",, i+2))
			out := SubStr(out, 1, i-1) "`r`n" SubStr(out, i+1)
		
		ControlGet hEdit, Hwnd,, Edit1
		ControlSetText,, %out%, ahk_id %hEdit%
		DetectHiddenWindows %dhw%
		if !DllCall("IsWindowVisible", "Ptr", A_ScriptHwnd)
			WinShow
		if kwargs.w
			WinWaitClose
		return
	}
	stdout := kwargs.f == "*"
	f := FileOpen(
	(Join Q C
		stdout ? DllCall("GetStdHandle", "Int", -11, "Ptr") : kwargs.f,
		stdout ? "h" : "w"
	))
	f.Write(out), f.Close() ;// flushes the write buffer
}
/* Function: print_r (helper function)
 * Return a string containing a printable representation of an object*.
 * Syntax:
 *     sobj := print_r( obj )
 * Parameter(s):
 *     obj       [in] - An object, string or number. If 'obj' is string,
 *                      output is surrounded in double quotes. Escape
 *                      sequences are represented as is.
 * Remarks:
 *     Object* can be an AHK object, a string or a number (integer OR float).
 *     Only generic AHK object(s) are supported. Other types such as COM, Func,
 *     File, RegExMatch, etc. objects are not supported.
 * TODO:
 *     Add detection of circular references, output as '{...}' like Python
 */
print_r(obj) {
	q := Chr(34) ;// Double quotes, make it work for both v1.1 and v2.0-a
	if IsObject(obj) {
		is_array := 0
		for k in obj
			is_array := (k == A_Index)
		until !is_array
		;// count := NumGet(&obj+4*A_PtrSize) -> unreliable, object might have custom behavior
		out := ""
		for k, v in obj {
			if !is_array
				out .= print_r(k) . ": "
			out .= print_r(v) . ", "
		}
		out := Trim(out, ", ")
		return is_array ? "[" out "]" : "{" out "}"
	}
	if (ObjGetCapacity([obj], 1) == "") ;// not a string, assume number
		return obj
	/*
	float := "float"
	if obj is %float%
		return obj
	*/
	esc_seq := {          ;// AHK escape sequences
	(Join Q C
		(q):  "``" . q,   ;// double-quotes
		"`n": "``n",      ;// newline
		"`r": "``r",      ;// carriage return
		"`b": "``b",      ;// backspace
		"`t": "``t",      ;// tab
		"`v": "``v",      ;// vertical tab
		"`a": "``a",      ;// alert (bell)
		"`f": "``f"       ;// formfeed
	)}
	i := -1
	while (i := InStr(obj, "``",, i+2))
		obj := SubStr(obj, 1, i-1) . "````" . SubStr(obj, i+1)
	for k, v in esc_seq {
		/* StringReplace/StrReplace routine for v1.1 & v2.0-a compatibility
		 * TODO: Compare speed with RegExReplace()
		 */
		i := -1
		while (i := InStr(obj, k,, i+2))
			obj := SubStr(obj, 1, i-1) . v . SubStr(obj, i+1)
	}
	return q . obj . q
}