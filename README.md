## luartttl
### A Lua library to parse and play RTTTL files.

Nokia created the Ring Tone Text Transfer Language (RTTTL) as a means to transfer ring tones to cellphones.
A detailed description of RTTTL can be found in [doc/nokia_rtttl.txt](./doc/nokia_rtttl.txt). An internet search should turn up collections of music expressed in RTTTL.

This library parses RTTTL strings into a data structure that can be passed to the `play` function to actually play the tune.

## How to Use

There are two main functions, `parse` and `play`. Using them is straight-forward: the `parse` function takes an RTTTL string and returns either a ring tone object, or nil and an error message.  The `play` function takes a ring tone object and plays it either using a default note-playing function or by means of a custom function passed in as a second argument. The default note-playing function (currently) depends on Sound eXchange (SoX).

The following example, reads in a file (whose name is specified on the command line), parses the text into an RTTTL object and plays it.

~~~lua
rtttl = require 'rtttl'
player = require 'player'

infile = io.open(arg[1], 'r')
m = infile:read('a')
rt = rtttl.parse(m)

player.play(rt)
~~~

To use a custom note-player, you supply a function with the following signature: 

~~~lua
function (pitch, octave, duration)
~~~

where `pitch` is the note's pitch (e.g. B#), the octave of the note (in octave 4, the frequency for A is 440Hz), and the duration of the note (whole note, half note, etc). See the comments in [rtttl.lua](./rtttl.lua) or the specification in [doc/nokia_rtttl.txt](./doc/nokia_rtttl.txt) for more details. See the example files (e.g. [examples/](./examples/)) for custom note players.

Two other functions are currently exposed, although they will likely be changed or removed soon. These are `print` and `playNote`. `Print` takes a ringtone object and prints it to the console. Eventually this will be replaced by a `__tostring` metamethod.

`PlayNote` determines the actual duration for the note (a combination of the note's duration and the ringtones beat and invokes the note-playing function. (_Yes, the names and separation of concerns between `playNote` and `player` are confusing and should be improved._)

## How to Install

#### Dependencies

This library was developed with Lua 5.4.2 but ought to work with any 5.x version. The default player assumes that SoX is installed. See [SoX's Home Page](https://sox.sourceforge.net/) for details on acquiring and ibstalling it.

To install the library, put the files, `rtttl.lua` and `player.lua`, in any directory in Lua's path (e.g. `/usr/local/lib/lua/5.4`). The file, `play.lua` can be placed in any directory in the shell's PATH (e.g. `/usr/local/bin`). Change it's file permissions to make it executable.

## How to Help

Pull requests to fix bugs, extend functionality or resolve one of the following TODO items are welcome. But non-code contributions are appreciated as well. These include improvements to documentation, ideas for new functionlity or new types of players, and, of course, bug reports.

In addition, I would really enjoy hearing if anybody uses this library. Send me the details!

### TODO

- Add a test suite
- Add additional (_hopefully interesting_) examples
- Devise a configuration mechanism to specify note players and/or automatic detection and configuration
- Support flats, double-sharps, repeats, and ???
- Support luarocks




## License

Copyright (c) 2023-2025 Bluedino Software

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

