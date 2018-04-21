package.path = package.path .. ";../?.lua"

Sword = Object:extend()

local ROTATION_MOD = math.pi
local fallback_sprite = love.graphics.newImage("res/sword.png")

--[[ Utils ]]
local get_random_tilt = function() return lume.random(-1.7, 1.7) end

function Sword:new(sprite)
  self.sprite = sprite or fallback_sprite
  self.ox = self.sprite:getWidth() * 0.1
  self.oy = self.sprite:getHeight() / 2
  self.tilt = 1
end

function Sword:draw(player_x, player_y)
  love.graphics.setColor(1, 1, 1)

  local mouse_x, mouse_y = love.mouse.getPosition()
  local rot = lume.angle(player_x, player_y, mouse_x, mouse_y) * self.tilt + ROTATION_MOD
  love.graphics.draw(self.sprite, player_x, player_y, rot, 1, 1, self.ox, self.oy)
end

function Sword:swing()
  self.tilt = get_random_tilt()
end