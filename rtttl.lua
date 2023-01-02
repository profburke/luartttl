--[[
   Ring Tone Text Transfer Language (RTTTL)
   Rough Spec
   See https://some.other/doc for a BNF description

   Three sections, separated by ":".
   
   Name <= 10 chars
   d can be 1, 2, 4, 8, 16, 32; default 4
   o can be 4, 5, 6, 7; default 6
   b can be 25, 28, 31, 35, 40, 45, 50, 56, 63, 70, 80, 90,
            100, 112, 125, 140, 160, 180, 200, 225, 250, 285,
            320, 355, 400, 450, 500, 565, 635, 715, 800, 900; default 63
   
   Octave 4 - A = 440Hz; 5 => 880, 6 => 1760, 7 => 3520
--]]

package = {}

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
      io.stderr:write("RTTTL descriptor must contain three sections.\n")
      os.exit(1)
   end

   local r = {}
   r.title = sections[1]
   r.defaults = parseDefaults(sections[2])
   r.notes = parseNotes(sections[3], r.defaults)
   
   return r
end

-- TODO: make use of mt.__tostring ...
local function printNote(n)
   local s = ""
   if n.duration ~= nil then
      s = s .. n.duration
   end

   s = s .. n.pitch

   if n.octave ~= nil then
      s = s .. n.octave
   end

   if n.dotted then
      s = s .. "."
   end
   
   print(s)
end

local function printRingtone(rt)
   print("Title: " .. rt.title)
   print("Defaults: beat = " .. rt.defaults.beat .. " duration = " .. rt.defaults.duration .. " octave = " .. rt.defaults.octave)
   for _, n in ipairs(rt.notes) do
      printNote(n)
   end
end

local function playNote(n, d)
   if n.pitch == "p" then return end -- TODO: deal with rests
   
   local spb = 60/d.beat
   local beats = d.duration / n.duration
   local seconds = beats * spb
   if n.dotted then
      seconds = seconds + 1/2*seconds
   end
   local command = "play -qn synth " .. seconds .. " pluck " .. string.upper(n.pitch) .. n.octave
   if debugFlag then print(command) end
   os.execute(command)
end

local function play(rt)
   for _, note in ipairs(rt.notes) do
      playNote(note, rt.defaults)
   end
end

package.parse = parse
package.play = play
package.print = printRingtone
package.playNote = playNote

return package
