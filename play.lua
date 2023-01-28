#!/usr/bin/env lua

local rtttl = require 'rtttl'

local infile = io.open(arg[1], 'r')
local m = infile:read('a')
local rt = rtttl.parse(m)

rtttl.play(rt)
