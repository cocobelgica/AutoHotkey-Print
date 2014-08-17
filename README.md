# **Print()**
#### Python-like `print()` for **[AutoHotkey](http://ahkscript.org)** with a twist.
_Tested on AHK **[v1.1.15.03](http://ahkscript.org/download/)** and **[v2.0-a049](http://ahkscript.org/boards/viewtopic.php?p=22371#p22371)**_
- - -
#### Description:
Print `objects` to the stream `f` separated by `s` and followed by `e`.
#### Syntax:
```javascript
print( objects*, [, kwargs := {s:"", e:"`n", f:"*"} ] )
```
#### Parameters:
 * **objects** `in` - Variadic number of item(s) to print. Item(s) can be a string, number or object.
 * **kwargs** `in, optional` - An **[asscoiative array](http://ahkscript.org/docs/Objects.htm#Usage_Associative_Arrays)** w/ the following keys(optional):
    * `s` - separator for the object(s), default is blank.
    * `e` - ending character, default is newline ``n`
    * `f` - path to the file to write to, default is `stdout`. Other options are also available for this argument, see below:
    * **_Options for_** `kwargs['f']` **:**
      1. An object with a `Write(string)` method may also be specified for more control on how to display the output. _e.g.: display in GUI, MsgBox, etc._ _**Example**:_
      `print("Hello World", {f: custom_object})`
      2. Alternatively, output may also be displayed on the script's main window. To do so, argument must begin with a colon(`:`) optionally followed by one or more of the following option(s), _whitespace-delimited_:
        * `Xn,Yn,Wn,Hn` - size and position of the script's main window when shown.
        * `Tn` - timeout in milliseconds before returning. If value is negative, the window will be automatically closed after timeout has elapsed. Otherwise, window remains visible. To wait indefinitely, specify an asterisk for `n`. Default is `0`. _**Example**:_ `print("Hello World", {f: ":x0 y0 w600 h400 t5000"}) ; 5 seconds`
      3. To send output to one of the **[standard I/O streams](http://en.wikipedia.org/wiki/Standard_streams)** (`stdin` - _uncommon, does it even work??_, `stdout` & `stderror`), specify `0` up to `2` asterisks(`*`). Wherein, no asterisk is ` stdin`, 1 asterisk is `stdout` and 2 asterisks is `stderror`. Default value of `kwargs["f"]` is ` *`, which is `stdout`. _**Example**:_ `print("Hello World", {f:"**"}) ; print to stderror`
      

#### Remarks:
 * When printing actual **[objects](http://ahkscript.org/docs/Objects.htm)**, only standard AHK object(s) are supported. Other types such as `COM`, `Func`, `RegExMatch`, etc. objects are not supported.
 * For `v2.0-a`, this function will require `A_AhkVersion >= v2.0-a049`