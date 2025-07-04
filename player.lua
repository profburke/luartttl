local function playNote(n, d, player)
    -- beats are usually assigned to quarter notes
    local spb = 4*60/d.beat
    local beats = 1/n.duration
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
    local note = string.upper(pitch) .. octave
    local command = "play -qn synth " .. duration .. " pluck " .. (pitch ~= "p" and note or "C vol 0")
    if debugFlag then print(command) end
    os.execute(command)
 end
 
 local function play(rt, player)
    player = player or defaultPlayer
    for _, note in ipairs(rt.notes) do
       playNote(note, rt.defaults, player)
    end
 end
 
 return { play = play }
