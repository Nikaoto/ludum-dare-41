Object = require "lib/classic"
lume = require "lib/lume"
anim8 = require "lib/anim8"
Timer = require "lib/Timer"
Camera = require "lib/Camera"
Bump = require "lib/bump"

require "conf"
require "controls"
require "world"
require "obj/Slash"
require "obj/Sword"
require "obj/Player"
require "obj/Enemy"

function love.load()
  conf.load()

  camera = Camera()
  camera:setFollowLerp(0.1)
  camera:setFollowStyle("LOCKON")

  world.load()

  player = Player()
  tile = {
    width = 100,
    height = 100,
    sprite = love.graphics.newImage("res/tile.jpg")
  }
  tile.actual_height = tile.sprite:getHeight()
  tile.actual_width = tile.sprite:getWidth()
  tile.scale_x = tile.width / tile.actual_width
  tile.scale_y = tile.height / tile.actual_height
end

function love.update(dt)
  camera:update(dt)
  camera:follow(player.x, player.y)
  controls.update(dt)
  world.update(dt)
  player:update(dt)
end

function love.draw()
  camera:attach()
  world.draw()
  player:draw()
  camera:detach()
  camera:draw()
  controls.drawMouse()

  love.graphics.setColor(1, 1, 1)
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