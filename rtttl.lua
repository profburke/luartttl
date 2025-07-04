--[[
   Parser for RTTTL.

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

N = {}
function N:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   return o
end

function N:__tostring()
   local s = (self.duration or '') .. self.pitch .. (self.octave or '')
   if self.dotted then s = s .. '.' end
   return s
end

RT = {}
function RT:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   return o
end

function RT:__tostring()
   local h = string.format("Title: %s\nDefaults: beat = %d, duration = %d, octave = %d\n",
      self.title, self.defaults.beat, self.defaults.duration, self.defaults.octave)
   local s = ""
   for i,n in ipairs(self.notes) do
      s = s .. (i > 1 and ", " or "") .. tostring(n)
   end
   return h .. "Notes: " .. s
end

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
   local b, p, o, d = note:match("(%d*)(%a#?)(%d?)(%.?)")
   
   local n = N:new{
      duration = tonumber(b) or defaults.duration,
      pitch = p,
      octave = tonumber(o) or defaults.octave,
      dotted = (d == '.')
   }
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

   local defaults = parseDefaults(sections[2])
   local r = RT:new{
      title = sections[1],
      defaults = defaults,
      notes = parseNotes(sections[3], defaults),
   }
   
   return r
end


package = {
   parse = parse,
   _VERSION = "0.6.1"
}

return package
