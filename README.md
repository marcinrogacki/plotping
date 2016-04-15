ABOUT
=====

Plotping is a simple script which tracks ping times and plot them at terminal.
In addition it calculates tresholds.

INSTALLATION
============

Grant permissions:

```
chmod +x <full_path_to_plotping_dir>/bin/plotping`
```

Make it user friendly:

```
ln -s <full_path_to_plotping_dir>/bin/plotping /usr/bin/
```

or in `~/.bash_profile`

```
export PATH=$PATH:<full_path_to_plotping_dir>/bin
```

USAGE
=====

plotping help

SCREENSHOT
==========

![plotping screenshot](plotping.png?raw=true "plotping")

NOTE
====

Threshold are calculated incrementally. It can takes time to invoke a COMMAND
'show' after longer lack of usage.
Plotping does not count pings which reached a timeout.
It also does not count pings in equal time intervals.

COPYRIGHT
=========

MIT
Copyright (c) 2016 Marcin Rogacki <rogacki.m@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

AUTHOR
======

Marcin Rogacki rogacki.m@gmail.com

https://github.com/marcinrogacki/plotping.git
