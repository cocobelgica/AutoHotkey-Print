# **Print()**
#### Python-like `print()` for **[AutoHotkey](http://ahkscript.org)**
_Tested on AHK **[v1.1.15.03](http://ahkscript.org/download/)** and **[v2.0-a049](http://ahkscript.org/boards/viewtopic.php?p=22371#p22371)**_
- - -
#### Description:
Print `objects` to the stream `f` separated by `s` and followed by `e`.
#### Syntax:
```
print( objects*, [, kwargs := {s:"", e:"`n", f:"*", w:0} ] )
```
#### Parameters:
 * **objects** `in` - Variadic number of item(s) to print. Item(s) can be a string, number or object.
 * **kwargs** `in, optional` - An [asscoiative array](http://ahkscript.org/docs/Objects.htm#Usage_Associative_Arrays) w/ the following keys(optional):
    * `s` - separator for the object(s), default is blank.
    * `e` - ending character, default is newline ``n`
    * `f` - path to the file to write to, default is `StdOut`. Specifiy `~` to print `object(s)` to the script's main window.
    * `w` - When `~` is specified for `kwargs["f"]`, specifying `1`, tells the function to wait until the script's main window is closed before returning/proceeding. Default is `0/false`.

#### Remarks:
 * For actual **[objects](http://ahkscript.org/docs/Objects.htm)**, only generic AHK object(s) are supported. Other types such as `COM`, `Func`, `RegExMatch`, etc. objects are not supported.
 * For `v2.0-a`, this function will require `A_AhkVersion >= v2.0-a049`