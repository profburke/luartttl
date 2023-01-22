#!/usr/bin/env lua

local rtttl = require 'rtttl'

local infile = io.open(arg[1], 'r')
local m = infile:read('a')
local rt = rtttl.parse(m)

function player(pitch, octave, duration)
   local command = "play -qn synth " .. duration .. " pluck " .. string.upper(pitch) .. octave
   if debugFlag then print(command) end
   os.execute(command)
end

rtttl.play(rt, player)
