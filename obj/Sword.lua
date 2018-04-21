package.path = package.path .. ";../?.lua"

Sword = Object:extend()

local ROTATION_MOD = math.pi*1.2
local fallback_sprite = love.graphics.newImage("res/sword.png")

--[[ Utils ]]
local get_random_tilt = function()
  local upper = 0.9
  local lower = 0.1
  if lume.random(2) <= 1 then
    return lume.random(-upper, -lower) 
  else
    return lume.random(lower, upper)
  end
end

--[[ Constructor ]]
function Sword:new(sprite)
  self.sprite = sprite or fallback_sprite
  self.ox = self.sprite:getWidth() * 0.1
  self.oy = self.sprite:getHeight() / 2
  self.tilt = 1
  self.swinging = false
  self.rot = 0

  self.slash = nil
end

function Sword:draw(player_x, player_y)
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.sprite, player_x, player_y, self.rot, 1, 1, self.ox, self.oy)

  if self.swinging and self.slash then
    self.slash:draw()
  end
end

function Sword:update(dt)
  if self.slash then
    self.slash:update(dt)
  end
end

function Sword:swing(x, y, rot)
  self.tilt = get_random_tilt()

  self.swinging = true
  self.slash = Slash(x, y, rot, function() self.swinging = false end)
end

--
function Sword:set_rotation(rot)
  self.rot = rot + self.tilt * ROTATION_MOD
end

function Sword:get_rotation()
  return self.rot
end