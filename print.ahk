/* Function: Print
 *     Print 'args' to to the stream 'file' separated by 'sep' and followed
 *     by 'end' OR alternatively sends the output the script's main window or
 *     to a specified function.
 * Requirements: AutoHotkey v1.1.17+ OR v2.0-a057+
 * License: WTFPL [http://www.wtfpl.net/]
 * Syntax:
 *     print( args* [, kwargs := [ "file=*", "sep=", "end=`n" ] ] )
 * Return value:
 *     None
 * Parameter(s):
 *     args*   [in, variadic] - items to print
 *     kwargs*      [in, opt] - string(s) in the following format: 'option=value'.
 *                              Where 'option' can be any of the following:
 *                              'sep' or 's' - separator, 'end' or 'e' - ending
 *                              character(s), 'file' or 'f' - file to write to,
 *                              defaults to stdout. Other values are also available
 *                              for the 'file' option as listed below in the
 *                              next section.
 * Other values for 'file' option:
 * 1.) Specify a question mark(?) followed by a function name to send output to
 *     a custom function. Output is passed as 1st parameter.
 * 2.) Alternatively, output may also be displayed on the script's main window.
 *     To do so, 'value' must begin with a colon(:) optionally followed by one
 *     or more of the following option(s), whitespace-delimited:
 *     Xn,Yn,Wn,Hn - size and position of the script's main window when shown.
 *     Tn          - timeout in milliseconds before returning. If value is
 *                   negative, the window will be automatically closed after
 *                   timeout has elapsed. Otherwise, window remains visible.
 *                   To wait indefinitely, specify an asterisk for 'n'. Default
 *                   is 0.
 * 3.) To send output to one of the standard I/O streams (stdout / stderror),
 *     specify 0 up to 2 asterisks(*). Wherein, one(1) asterisk is stdout and
 *     two(2) asterisks is stderror. Default value for file is "*".
 * Example usage:
 *     ; Displays 'Auto|Hot|Key>' in the script's main window.
 *     print( "Auto", "Hot", "Key", "sep=|", "end=>", "file=:x0 y0 t*" )
 */
print(args*)
{
	static ObjRemoveAt := Func( A_AhkVersion < "2" ? "ObjRemove" : "ObjRemoveAt" )

	;// Initialize w/ default values first: file=stdout, sep=none, end=newline
	f := "*", s := "", e := "`n"

	;// Process args, separate options from the object(s) to be printed
	;// n+1 = index where first option could be expected
	n := (n := NumGet(&args + 4*A_PtrSize)) - (n > 3 ? 3 : n-1) 
	j := 0 ;// counter, incremented every time a valid option is found
	for i, arg in ObjClone(args) ;// clone so that we can remove items during enumeration
	{
		if (A_Index > n) && (arg ~= "si)^(f(ile)?|s(ep)?|e(nd)?)=.*$")
		{
			%ObjRemoveAt%(args, i-j++) ;// remove from array of objects to print
			opt := SubStr(arg, 1, 1), %opt% := SubStr(arg, InStr(arg, "=")+1)
		}
	}
	
	;// Prepare string output: <item1><sep><item2><sep>...<end>
	out := "", n := NumGet(&args + 4*A_PtrSize)
	for i, arg in args
		out .= ( IsObject(arg) ? print_r(arg) : arg ) . ( i < n ? s : e )
	
	;// Output is to be sent to a function
	if ( (tok := SubStr(f, 1, 1)) == "?" )
		if (fn := Func(SubStr(f, 2))) ;// call if it's a valid function else cast
			return %fn%(out)

	;// Output is to be written to a file or standard stream
	if (tok != ":")
	{
		f := FileOpen(f, "w")
		f.Write(out), f.Close()
		return
	}

	;// Else print to script's main window
	DetectHiddenWindows % (dhw := A_DetectHiddenWindows) ? "On" : "On"
	if !WinExist("ahk_id " A_ScriptHwnd)
		return

	i := 0
	while (i := InStr(out, "`r`n",, i+1)) ;// DOS to Unix
		out := SubStr(out, 1, i-1) . "`n" . SubStr(out, i+2)
	i := 0
	while (i := InStr(out, "`r",, i+1)) ;// Mac to Unix
		out := SubStr(out, 1, i-1) . "`n" . SubStr(out, i+1)
	i := -1
	while (i := InStr(out, "`n",, i+2)) ;// Unix to DOS
		out := SubStr(out, 1, i-1) . "`r`n" . SubStr(out, i+1)
	ControlGet hEdit, Hwnd,, Edit1
	ControlSetText,, %out%, ahk_id %hEdit%
	
	static delims := [" ", "`t", "`r", "`n"]
	x := y := w := h := "", t := 0 ;// initialize with default values
	for i, option in StrSplit(SubStr(f, 2), delims)
	{
		if ( InStr(" xywht", opt := SubStr(option, 1, 1)) > 1 )
		{
			value := SubStr(option, 2)
			%opt% := (opt != "t") ? value : (value == "*" ? "" : value/1000)
		}
	}
	
	WinMove ahk_id %A_ScriptHwnd%,, %x%, %y%, %w%, %h%
	if !DllCall("IsWindowVisible", "Ptr", A_ScriptHwnd)
		WinShow
	if (t != 0) ;// No need to call these commands if timeout is 0
	{
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
print_r(obj)
{
	static is_v2   := A_AhkVersion >= "2", q := Chr(34)
	     , Type    := is_v2 ? Func("Type") : ""
	     , regex   := RegExMatch("", is_v2? "" : "O)", regex) ? regex : 0
	
	if IsObject(obj)
	{
		ObjType := is_v2                           ? %Type%(obj)
		        :  ObjGetCapacity(obj) != ""       ? "Object"
		        :  IsFunc(obj)                     ? "Func"
		        :  ComObjType(obj) != ""           ? "ComObject"
		        :  NumGet(&obj) == NumGet(&regex)  ? "RegExMatchObject"
		        :                                    "FileObject"
		if (ObjType != "Object")
			return Format("<{1:s} at {2:#x}>", ObjType, &obj)

		;// standard AHK object
		is_array := 0, enum := ObjNewEnum(obj) ;// bypass _NewEnum() meta-function
		while enum[k] ;// for k in obj
			if !( is_array := (k == A_Index) )
				break
		out := "", enum := ObjNewEnum(obj) ;// reset enumerator
		while enum[k, v] ;// for k, v in obj
		{
			if !is_array
				out .= print_r(k) . ": "
			out .= print_r(v) . ", "
		}
		out := Trim(out, ", ")
		return is_array ? "[" out "]" : "{" out "}"
	}
	;// not a string, assume number
	if (ObjGetCapacity([obj], 1) == "")
		return obj
	
	static esc_seq := { ;// AHK escape sequences
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
	for k, v in esc_seq
	{
		/* StringReplace/StrReplace routine for v1.1 & v2.0-a compatibility
		 * TODO: Compare speed with RegExReplace()
		 */
		i := -1
		while (i := InStr(obj, k,, i+2))
			obj := SubStr(obj, 1, i-1) . v . SubStr(obj, i+1)
	}
	return q . obj . q
}