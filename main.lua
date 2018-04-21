Object = require "lib/classic"
require "conf"
require "controls"
require "world"
require "obj/Sword"
require "obj/Player"

lume = require "lib/lume"

function love.load()
  love.window.setMode(conf.window.width, conf.window.height)
  player = Player()

  tile = {
    width = 75,
    height = 75,
    sprite = love.graphics.newImage("res/tile.jpg")
  }
end

function love.draw()
  world.draw()
  player:draw()
  controls.draw_mouse()
  love.graphics.setColor(1, 1, 1)
end

function love.update(dt)
  controls.update(dt)
  player:update(dt)
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