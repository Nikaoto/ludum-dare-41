package.path = package.path .. ";../?.lua"

Sword = Object:extend()

Sword.SHAKE = 4
Sword.SWING_TIME = 0.18 -- == Slash.SLASH_TIME

local fallback_sprite = love.graphics.newImage("res/sword.png")

--[[ Utils ]]
local getRandomTilt = function(prev_tilt)
  local upper = math.pi * 0.8
  local lower = math.pi * 0.5
  if prev_tilt > 0 then
    return lume.random(-upper, -lower) 
  else
    return lume.random(lower, upper)
  end
end

--[[ Constructor ]]
function Sword:new(owner, shake, sprite)
  self.sprite = sprite or fallback_sprite
  self.ox = self.sprite:getWidth() * 0.1
  self.oy = self.sprite:getHeight() / 2
  self.tilt = 1
  self.swinging = false
  self.rot = 0
  self.shake = shake or Sword.SHAKE
  self.slash = nil
  self.owner = owner or ""
  
  self.swing_animator = Timer()
  self.swing_animating = false
end

function Sword:draw(player_x, player_y)
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.sprite, player_x, player_y, self.rotation, 1, 1, self.ox, self.oy)

  if self.swinging and self.slash then
    self.slash:draw()
  end
end

function Sword:update(dt)
  self.swing_animator:update(dt)
  if self.slash then
    self.slash:update(dt)
  end
end

function Sword:swing(x, y, rot)
  self.swinging = true
  self.swing_animator:tween(Sword.SWING_TIME, self, { tilt = getRandomTilt(self.tilt) }, "out-cubic")

  self.slash = Slash({ 
    x = x, 
    y = y, 
    rotation = rot,
    shake = self.shake,
    caller = self.owner
  }, function() 
    self.swinging = false
  end)
end

--
function Sword:setRotation(rot)
  self.rotation = rot + self.tilt
end

function Sword:getRotation()
  return self.rototation
end