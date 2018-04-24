Object = require "lib/classic"
lume = require "lib/lume"
anim8 = require "lib/anim8"
Timer = require "lib/Timer"
Camera = require "lib/Camera"

inspect = require "lib/inspect"

require "conf"
require "controls"
require "world"
require "sounds"
require "obj/Slash"
require "obj/Sword"
require "obj/Player"
require "obj/Enemy"
require "obj/EnemyB"
require "obj/Block"

--[[ Global constants ]]
TURN_DURATION = 3
STUCK_DAMAGE = 5
player_turn = "Player"
enemy_turn = "Enemy"
current_level = 1
total_kills = 0
total_turns = 0
total_swings = 0
swings_hit = 0
score = 0
won = false
first_time = true
game_started = false
current_turn = player_turn
screen_scale = 1

-- Music
MUSIC_VOLUME = 0.35
music = love.audio.newSource("res/bgmusic.mp3", "stream")
music:setLooping(true)
music:setVolume(MUSIC_VOLUME)

-- Load font
font = love.graphics.newImageFont("res/imageFont.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
font:setFilter("nearest", "nearest")

-- for testing
DISABLE_TURNS = false
INVINCIBLE = false

function love.load()
  conf.load()

  local sw, sh = love.graphics.getDimensions()
  camera = Camera(conf.window.width, conf.window.height, sw, sh)

  camera:setFollowLerp(0.1)
  camera:setFollowStyle("LOCKON")

  tile = {
    width = 100,
    height = 100,
    sprite = love.graphics.newImage("res/tile.jpg")
  }
  tile.sprite:setFilter("nearest", "nearest")
  tile.actual_height = tile.sprite:getHeight()
  tile.actual_width = tile.sprite:getWidth()
  tile.scale_x = tile.width / tile.actual_width
  tile.scale_y = tile.height / tile.actual_height

  world.load()

  turn_timer = Timer()
  turn_timer_tag = turn_timer:every(TURN_DURATION, nextTurn)

  love.graphics.setFont(font)
  canvas = love.graphics.newCanvas(conf.window.width, conf.window.height)

  music:play()
end

function love.update(dt)
  if game_started then
    turn_timer:update(dt)
    camera:update(dt)
    camera:follow(player.x, player.y)
    controls.update(dt)
    world.update(dt)
  end
end

function love.draw()
  if conf.window.fullscreen then
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
  end
  --
  camera:attach()
  world.draw()
  camera:detach()
  camera:draw()
  drawTurnTimer()

  if not game_started then
    if first_time then
      drawIntroScreen()  
    else
      if won then
        drawWinScreen()
      else
        drawLoseScreen()
      end
    end
  end

  drawLevelOverlay()
  --
  if conf.window.fullscreen then
    love.graphics.setCanvas()
    
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    local temp_w, temp_h = love.graphics.getDimensions()

    local small_w, small_h = math.min(temp_w, conf.window.width), math.min(temp_h, conf.window.height)
    local big_w, big_h = math.max(temp_w, conf.window.width), math.max(temp_h, conf.window.height)

    screen_scale = big_h/small_h
    local offset = math.floor(big_w/2 - small_w * screen_scale/2)
    love.graphics.draw(canvas, offset, 0, 0, screen_scale, screen_scale)
    love.graphics.setBlendMode('alpha')
  end
  controls.drawMouse(screen_scale)
end

function love.keypressed(k, s)
  if k == "escape" then
    love.event.quit()
  end

  if k == "f" then
    conf.window.fullscreen = not conf.window.fullscreen
    love.window.setFullscreen(conf.window.fullscreen)
    screen_scale = 1
  end

  controls.keypressed(key, s)
end

function love.mousepressed(x, y, button)
  controls.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  controls.mousereleased(x, y, button)
end

function nextTurn()
  total_turns = total_turns + 1
  sounds.play("turn")
  if current_turn == player_turn then
    current_turn = enemy_turn
  else
    current_turn = player_turn
  end

  if player and world.checkOutOfBounds(player.x, player.y, player.width, player.height) then
    player:takeDamage(STUCK_DAMAGE, true)
  end
end

function resetTurnTimer()
  if turn_timer then
    turn_timer:destroy()
    turn_timer = Timer()
    current_turn = player_turn
    turn_timer_tag = turn_timer:every(TURN_DURATION, nextTurn)  
  end
end

function drawLevelOverlay()
  local w, h = conf.window.width, conf.window.height
  local margin = 10
  local scale = 2
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf("Level "..current_level, 0, margin, w/scale - margin, "right", 0, scale, scale)

  -- Draw player health
  if player then
    if player.health then
      local max_w = w * 0.2
      local height = h * 0.03
      local width = math.ceil(player.health * max_w / Player.HEALTH) 
      local pad = 6
      love.graphics.setColor(0, 0, 0, 1)
      love.graphics.rectangle("fill", margin, margin, max_w + pad*2, height + pad*2)
      love.graphics.setColor(0.92, 0, 0, 1)
      love.graphics.rectangle("fill", margin + pad, margin + pad, width, height)
    end
  end
end

function drawIntroScreen()
  drawMenuOverlay()
  -- NOTE: DO NOT CROSS 0.25 and 0.75 screen width with text
  local w, h = conf.window.width, conf.window.height
  local scale = 1.4
  love.graphics.printf("Click anywhere to start", w*0.3, h*0.3, w/scale, 'left', 0, scale, scale)
  local instructions_text = "Move - WASD\nAim - Mouse\nSlash - Left Mouse Button\nDash - Right Mouse Button\n\n3 second turns\nDash when stuck in blocks\nKill them all"
  love.graphics.printf(instructions_text, w*0.3, h*0.4, w/scale, 'left', 0, scale, scale)
end

function drawWinScreen()
  drawMenuOverlay()
  -- NOTE: DO NOT CROSS 0.25 and 0.75 screen width with text
  local w, h = conf.window.width, conf.window.height
  local scale = 1.4
  love.graphics.setColor(1, 0.843, 0)
  love.graphics.printf("You win!", 0, h*0.3, w/scale, 'center', 0, scale, scale)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf("\n\nTotal kills: "..total_kills, 0, h*0.3, w/scale, 'center', 0, scale, scale)
  love.graphics.printf("\n\n\nTotal turns: "..total_turns, 0, h*0.3, w/scale, 'center', 0, scale, scale)
  love.graphics.printf("Click anywhere to proceed", 0, h*0.6, w/scale, 'center', 0, scale, scale)

  love.graphics.setColor(1, 1, 1, 1)
end

function drawLoseScreen()
  drawMenuOverlay()
  -- NOTE: DO NOT CROSS 0.25 and 0.75 screen width with text
  local w, h = conf.window.width, conf.window.height
  local scale = 1.4
  love.graphics.setColor(1, 0.843, 0)
  love.graphics.printf("You died", 0, h*0.3, w/scale, 'center', 0, scale, scale)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf("\n\nTotal kills: "..total_kills, 0, h*0.3, w/scale, 'center', 0, scale, scale)
  love.graphics.printf("\n\n\nTotal turns: "..total_turns, 0, h*0.3, w/scale, 'center', 0, scale, scale)
  if total_swings ~= 0 then
    local swing_accuracy = swings_hit/total_swings
    swing_accuracy = (swing_accuracy - (swing_accuracy % 0.01))*100
    love.graphics.printf("\n\n\n\nSwing accuracy: "..swing_accuracy.."%", 0, h*0.3, w/scale, 'center', 0, scale, scale)
  end
  love.graphics.printf("Click anywhere to retry", 0, h*0.6, w/scale, 'center', 0, scale, scale)
  love.graphics.setColor(1, 1, 1, 1)
end

function drawTurnTimer()
  local w, h = conf.window.width, conf.window.height
  local scale = 2
  local margin_top = 10
  love.graphics.setColor(1, 1, 1)
  local current_time, max_time = turn_timer:getTime(turn_timer_tag)
  local time_left = max_time - current_time
  
  -- Set turn color
  if current_turn == player_turn then
    love.graphics.setColor(0, 1, 0, 1)
  else
    love.graphics.setColor(1, 1, 0, 1)
  end
  local turn_text = "TURN: "..current_turn
  love.graphics.printf(turn_text, 0, margin_top, w/scale, "center", 0, scale, scale)

  local time_text = "\n"..time_left - (time_left % 0.01)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf(time_text, w/2-40, margin_top, w/scale, "left", 0, scale, scale)
end


--[[ Utils ]]

function drawMenuOverlay()
  local w, h = conf.window.width, conf.window.height
  love.graphics.setColor(0, 0, 0, 0.9)
  love.graphics.rectangle("fill", w/4, h/4, w/2, h/2)
  love.graphics.setColor(1, 1, 1, 1)
end

function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1
end

function sq(n) return n*n end

function drawCollider(obj)
  --love.graphics.setColor(1, 0, 0)
  --love.graphics.rectangle("line", obj.x, obj.y, obj.width, obj.height)
end