Object = require "lib/classic"
require "conf"
require "controls"
require "world"

function love.load()
  love.window.setMode(conf.window.width, conf.window.height)
  player = {
    x = 100,
    y = 100,
    width = 50,
    height = 50,
    ox = 25,
    oy = 50,
    move = function(self, dx, dy) self.x = self.x + dx; self.y = self.y + dy end,
    draw = function(self) love.graphics.rectangle("fill", self.x + self.ox, self.y + self.oy, self.width, self.height) end
  }

  tile = {
    width = 75,
    height = 75
  }
  tile.sprite = love.graphics.newImage("res/tile.jpg")
end

function love.draw()
  world.draw()
  player:draw()
  controls.draw_mouse()
  love.graphics.setColor(1, 1, 1)
end

function love.update(dt)
  controls.update(dt)
end

function love.keypressed(k)
  if k == "escape" then
    love.event.quit()
  end
end