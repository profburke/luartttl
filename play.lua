#!/usr/bin/env lua

local rtttl = require 'rtttl'
local play = require('sox-player').play

local infile = io.open(arg[1], 'r')
local m = infile:read('a')
local rt = rtttl.parse(m)

play(rt)
