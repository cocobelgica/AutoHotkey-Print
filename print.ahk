/* Function: print
 * Print 'objects' to the stream 'f' separated by 's' and followed by 'e'.
 * Syntax:
 *     print( objects* [, kwargs := {s:"", e:"`n", f:""} ] )
 * Parameter(s):
 *     objects*  [in] - Variadic number of item(s) to print. Item can be
 *                      a string, number or object*.
 *     kwargs    [in] - An asscoiative array w/ the following keys(optional):
 *     • s            - separates each object with the specified character(s).
 *     • e            - ending character, default is newline (`n)
 *     • f            - file to write to, defaults to StdOut. Other options
 *                      are also available for this argument, see below:
 *
 * Options for kwargs["f"]:
 * 1.) If the argument begins w/ an asterisk(*), it is assumed to be either
 *     one of the standard IO streams: StdIn, StdOut OR StdErr. Specify either
 *     of the following strings: "in", "out", "error" after the asterisk to
 *     print to the respective standard device. There must be no whitespace in
 *     between the asterisk and the word.
 *     Usage: print("Hello World", {f: "*error"}) ; writes to StdErr
 *                      
 * 2.) An object with a Write(string) method may also be specified for more
 *     control on how to display the output. e.g.: display in GUI, MsgBox, etc.
 *     Usage: print("Hello World", {f: custom_object})
 *
 * 3.) Alternatively, output may also be displayed on the script's main window.
 *     To do so, argument must begin with a colon(:) optionally followed by one
 *     or more of the following option(s), space-delimited:
 *     Xn,Yn,Wn,Hn - size and position of the script's main window when shown.
 *     Tn          - timeout in milliseconds before returning. Defaults to 0
 *                   which is no timeout. If 'n' is negative, the window will
 *                   be automatically closed after timeout has elapsed. Otherwise,
 *                   window remains visible. To wait indefinitely, specify an
 *                   asterisk for 'n'.
 *     Usage: print("Hello World", {f: ":x0 y0 w600 h400 t5000"}) ; 5 seconds
 *
 * Remarks:
 *     When printing object(s), only standard AHK object(s) are supported.
 *     Other types such as COM, Func, File, RegExMatch, etc. objects are not
 *     supported.
 */
print(args*) {
	static is_v2 := A_AhkVersion >= "2"
	     , len   := Func(is_v2 ? "ObjLength"   : "ObjMaxIndex")
	     , del   := Func(is_v2 ? "ObjRemoveAt" : "ObjRemove")
	static default := { ;// default values for kwargs
	(Join Q C
		"f": "",  ;// file to write to, default is StdOut
		"s": "",  ;// separator
		"e": "`n" ;// end
	)}
	static std_streams := {"in":-10, "out":-11, "error":-12}
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
	
	;// File object(not advisable) OR custom object with a Write(string) method
	if IsObject(file := kwargs.f) {
		file.Write(out)
		return
	}

	file := Trim(file, " `t`r`n"), token := SubStr(file, 1, 1)
	if (token != ":") {
		if (is_std := InStr("*", token))
			if !(file := InStr("*", file) ? -11 : std_streams[SubStr(file, 2)])
				file := -11
		f := FileOpen(
		(Join Q C
			is_std ? DllCall("GetStdHandle", "Int", file, "Ptr") : file,
			is_std ? "h" : "w"
		))
		f.Write(out), f.Close() ;// flushes the write buffer
		return
	}
	;// else print output to script's main window
	dhw := A_DetectHiddenWindows
	DetectHiddenWindows On
	if !WinExist("ahk_id " A_ScriptHwnd) ;// make LastFound
		return
	;// convert line endings to "`r`n" (Windows)
	out := Trim(out, kwargs.e), i := 1
	while (i := InStr(out, "`r",, i))
		out := SubStr(out, 1, i-1) . SubStr(out, i+1)
	i := -1
	while (i := InStr(out, "`n",, i+2))
		out := SubStr(out, 1, i-1) "`r`n" SubStr(out, i+1)
	
	ControlGet hEdit, Hwnd,, Edit1
	ControlSetText,, %out%, ahk_id %hEdit%
	;// parse options
	x := y := w := h := "", t := 0, i := 1
	while ((ch := SubStr(file, ++i, 1)) != "") {
		if !InStr("xywht", ch)
			continue
		val := SubStr(file, i+1, (SubStr(file, i+1) ~= "\s|$")-1)
		, i += StrLen(val)-1
		, %ch% := (ch != "t") ? val : (val == "*" ? "" : val/1000)
	}
	WinMove ahk_id %A_ScriptHwnd%,, %x%, %y%, %w%, %h%
	if !DllCall("IsWindowVisible", "Ptr", A_ScriptHwnd)
		WinShow
	if InStr(file, "t") {
		DetectHiddenWindows Off
		WinWaitClose, ahk_id %A_ScriptHwnd%,, % Abs(t)
		if (ErrorLevel && t < 0) ;// timed out and value is negative
			;// 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE
			PostMessage 0x112, 0xF060,,, ahk_id %A_ScriptHwnd%
	}
	DetectHiddenWindows %dhw%
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