sounds = {
  ["slash"] = love.audio.newSource("res/slash.wav", "static"),
  ["dash"] = love.audio.newSource("res/dash.wav", "static"),
  ["slash_hit"] = love.audio.newSource("res/slash_hit.wav", "static"),
  ["turn"] = love.audio.newSource("res/turn.wav", "static"),
  ["win"] = love.audio.newSource("res/win.wav", "static"),
  ["lose"] = love.audio.newSource("res/lose.wav", "static")
}

-- Adjust volume
for _, s in pairs(sounds) do
  s:setVolume(0.7)
end
sounds["slash"]:setVolume(1)
sounds["dash"]:setVolume(1)

sounds.play = function(sound_name)
  if sounds[sound_name] then
    if sounds[sound_name]:isPlaying() then
      sounds[sound_name]:clone():play()
    else
      sounds[sound_name]:play()
    end
  end
end