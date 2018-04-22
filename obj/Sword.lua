package.path = package.path .. ";../?.lua"

Sword = Object:extend()

Sword.SHAKE = 4

local fallback_sprite = love.graphics.newImage("res/sword.png")

--[[ Utils ]]
local get_random_tilt = function(prev_tilt)
  local upper = math.pi * 0.8
  local lower = math.pi * 0.5
  if prev_tilt > 0 then
    return lume.random(-upper, -lower) 
  else
    return lume.random(lower, upper)
  end
end

--[[ Constructor ]]
function Sword:new(shake, sprite)
  self.sprite = sprite or fallback_sprite
  self.ox = self.sprite:getWidth() * 0.1
  self.oy = self.sprite:getHeight() / 2
  self.tilt = 1
  self.swinging = false
  self.rot = 0
  self.shake = shake or Sword.SHAKE
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
  self.swinging = true
  self.tilt = get_random_tilt(self.tilt)

  self.slash = Slash(x, y, rot, self.shake, function() 
    self.swinging = false
  end)
end

--
function Sword:set_rotation(rot)
  self.rot = rot + self.tilt
end

function Sword:get_rotation()
  return self.rot
end