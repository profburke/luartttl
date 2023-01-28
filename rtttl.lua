--[[
   Parser and Player for RTTTL.

   Copyright (c) 2023 Bluedino Software (https://bluedino.net)

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

   Ring Tone Text Transfer Language (RTTTL)
   (For a more complete description, see http://merwin.bespin.org/t4a/specs/nokia_rtttl.txt)

   Three sections, name, default, notes; separated by ":".
   
   Name <= 10 chars
   duration (d) can be 1, 2, 4, 8, 16, 32; default 4
   octave (o) can be 4, 5, 6, 7; default 6
   beat (b) can be 25, 28, 31, 35, 40, 45, 50, 56, 63, 70, 80, 90,
                   100, 112, 125, 140, 160, 180, 200, 225, 250, 285,
                   320, 355, 400, 450, 500, 565, 635, 715, 800, 900; default 63
   
   Frequency of A for octave 4 => 440Hz, 5 => 880Hz, 6 => 1760Hz, 7 => 3520Hz

   Various RTTTL files available at https://picaxe.com/rtttl-ringtones-for-tune-command/
--]]

function string.split(m, sep)
   sep = sep or " "
   local t = {}
   for s in string.gmatch(m, "([^" .. sep .. "]+)") do
      table.insert(t, s)
   end
   
   return t
end

local function parseDefaults(s)
   local d = { beat = 63, duration = 4, octave = 6, }
   for _, rawDefault in ipairs(s:split(",")) do
      local k,v = rawDefault:match("(%a+)=(%d+)")
      if k == 'b' then
         d.beat = tonumber(v)
      elseif k == 'o' then
         d.octave = tonumber(v)
      elseif k == 'd' then
         d.duration = tonumber(v)
      else
         -- this should not occur in a well-formed RTTTL string.
      end
   end
   
   return d
end

local function parseNote(note, defaults)
   local n = {}
   local b, p, o, d = note:match("(%d*)(%a#?)(%d?)(%.?)")
   
   n.duration = tonumber(b) or defaults.duration
   n.pitch = p
   n.octave = tonumber(o) or defaults.octave
   n.dotted = (d == '.')
   
   return n
end

local function parseNotes(s, d)
   local n = {}
   for _, rawNote in ipairs(s:split(",")) do
      table.insert(n, parseNote(rawNote, d))
   end

   return n
end

local function parse(m)
   local sections = m:split(":")
   if #sections ~= 3 then
      return nil, "RTTTL descriptor must contain three sections."
   end

   local r = {}
   r.title = sections[1]
   r.defaults = parseDefaults(sections[2])
   r.notes = parseNotes(sections[3], r.defaults)
   
   return r
end

local function printNote(n)
   local s = (n.duration or '') .. n.pitch .. (n.octave or '')
   if n.dotted then s = s .. '.' end
   print(s)
end

local function printRingtone(rt)
   print("Title: " .. rt.title)
   print("Defaults: beat = " .. rt.defaults.beat .. " duration = " .. rt.defaults.duration .. " octave = " .. rt.defaults.octave)
   for _, n in ipairs(rt.notes) do
      printNote(n)
   end
end

local function playNote(n, d, player)
   if n.pitch == "p" then return end -- TODO: deal with rests
   
   local spb = 60/d.beat
   local beats = d.duration / n.duration
   local seconds = beats * spb
   if n.dotted then
      seconds = seconds + 1/2*seconds
   end

   if player and type(player) == "function" then
      player(n.pitch, n.octave, seconds)
   end
end

-- depends on play command from SoX being installed in a location on the shell's executable PATH
-- https://sox.sourceforge.net/sox.html
function defaultPlayer(pitch, octave, duration)
   local command = "play -qn synth " .. duration .. " pluck " .. string.upper(pitch) .. octave
   if debugFlag then print(command) end
   os.execute(command)
end

local function play(rt, player)
   player = player or defaultPlayer
   for _, note in ipairs(rt.notes) do
      playNote(note, rt.defaults, player)
   end
end

package = {
   parse = parse,
   print = printRingtone,
   play = play,
   playNote = playNote,
   _VERSION = "0.6.1"
}

return package
