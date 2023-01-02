#!/usr/bin/env lua

require 'rtttl'

local infile = io.open(arg[1], 'r')
local m = infile:read('a')
local rt = parseRTTTL(m)
play(rt)
