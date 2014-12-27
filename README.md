# Print

### Port of [Python's](https://www.python.org/) [print()](https://docs.python.org/3/library/functions.html#print) for **[AutoHotkey](http://ahkscript.org)**

Print _args_ to the stream _file_ separated by _sep_ and followed by _end_ OR alternatively display the output in the script's main window OR send output to a user-defined function.

Requires v1.1.17+ or v2.0-a056+

**License:** [WTFPL](http://www.wtfpl.net/)
<hr>

### Syntax:
```javascript
print( args*, [ , kwargs* := [ "file=*", "sep=", "end=`n" ] ] )
```

### Parameters:

**args*** ``[in, variadic]`` - items to print, can be a _string_, _number_ or _object_

**kwargs*** ``[in, variaidic]`` - each argument should be in this format: _option=value_, where _option_ can be any of the following:

 * _sep_ or _s_ - separator, default is none ``"sep="``
 * _end_ or _e_ - ending, default is _newline_, ``"end=`n"``
 * _file_ or _f_ - file to write to, defaults to _stdout_, ``"file=*"``


##### Alternative _value(s)_ for _file_ option_(kwargs parameter)_:

 1. To send output to a function, _**value**_ must begin with a question mark(``?``) followed by the function name. Output is passed as the first parameter.<br>_e.g.:_ ``"file=?MyFunc"``
 
 2. To send output to one of the standard I/O streams(_stdout_, _stderror_), specify 1 or 2 asterisks(``*``). One asterisk is _stdout_ and two is _stderror_.<br>_e.g.:_ ``"file=*"`` or ``"file=**"``
 
 3. To display output in the script's main window, **_value_** must begin with a colon(``:``) followed by one or more of the following options:
  * _Xn, Yn, Wn, Hn_ - size and position of the script's main window when shown.
  * _Tn_ - timeout in milliseconds before returning.If _n_ is negative, the window will be automatically closed after timeout has elapsed. Otherwise, window remains visible. To wait indefinitely, specify an asterisk(``*``) for _n_ . Default is 0.
 
 _e.g.:_ ``"file=:x0 y0 w500 t*"``