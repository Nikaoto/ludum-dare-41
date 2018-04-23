Object = require "lib/classic"
lume = require "lib/lume"
anim8 = require "lib/anim8"
Timer = require "lib/Timer"
Camera = require "lib/Camera"

require "conf"
require "controls"
require "world"
require "sounds"
require "obj/Slash"
require "obj/Sword"
require "obj/Player"
require "obj/Enemy"

DISABLE_TURNS = false
TURN_DURATION = 3
player_turn = "Player"
enemy_turn = "Enemy"

current_level = 1
game_started = false

current_turn = player_turn

font = love.graphics.newImageFont("res/imagefont.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
font:setFilter("nearest", "nearest")

function love.load()
  conf.load()

  camera = Camera()
  camera:setFollowLerp(0.1)
  camera:setFollowStyle("LOCKON")

  world.load()
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

  turn_timer = Timer()
  turn_timer_tag = turn_timer:every(TURN_DURATION, function()
    sounds.play("turn")
    if current_turn == player_turn then
      current_turn = enemy_turn
    else
      current_turn = player_turn
    end
  end)

  love.graphics.setFont(font)
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
  camera:attach()
  world.draw()
  camera:detach()
  camera:draw()
  drawTurnTimer()

  if not game_started then
    drawMenu()
  end

  controls.drawMouse()
end

function love.keypressed(k)
  if k == "escape" then
    love.event.quit()
  end
end

function love.mousepressed(x, y, button)
  controls.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  controls.mousereleased(x, y, button)
end

function drawMenu()
  local w, h = conf.window.width, conf.window.height
  love.graphics.setColor(0, 0, 0, 0.9)
  love.graphics.rectangle("fill", w/4, h/4, w/2, h/2)
  love.graphics.setColor(1, 1, 1, 1)
  -- NOTE: DO NOT CROSS 0.25 and 0.75 screen width with text
  local scale = 1.8
  love.graphics.printf("Click anywhere to start", 0, conf.window.height*0.6, 
  conf.window.width/scale, 'center', 0, scale, scale)
end

function drawTurnTimer()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("TURN: "..current_turn)
  local current_time, max_time = turn_timer:getTime(turn_timer_tag)
  local time_left = max_time - current_time
  love.graphics.print("\n"..time_left- (time_left % 0.01))
  love.graphics.setColor(1, 1, 1)
end

function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1
end