package.path = package.path .. ";../?.lua"

Sword = Object:extend()

local ROTATION_MOD = math.pi*1.2
local fallback_sprite = love.graphics.newImage("res/sword.png")
local SWING_TIME = 0.21

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

  -- Slash animation
  self.slash = {
    sprite = love.graphics.newImage("res/slash.png"),
    width = 960,
    height = 384,
    grid_size = 192
  }
  local grid = anim8.newGrid(self.slash.grid_size, self.slash.grid_size, self.slash.width, self.slash.height)
  self.animation = anim8.newAnimation(grid("1-5",1, "1-2",2), SWING_TIME/7)
  self.animation_timer = Timer()
  self.draw_animation = function(player_x, player_y, rot)
    self.animation:draw(self.slash.sprite, player_x, player_y, rot, 1, 1, self.slash.grid_size/2, 
      self.slash.grid_size/2)
  end
end

function Sword:draw(player_x, player_y)
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.sprite, player_x, player_y, self.rot, 1, 1, self.ox, self.oy)

  if self.swinging then
    self.draw_animation(player_x, player_y, self.animation_rot)
  end
end

function Sword:update(dt)
  self.animation:update(dt)
  self.animation_timer:update(dt)
end

function Sword:swing(x, y, rot)
  self.tilt = get_random_tilt()

  self.swinging = true
  self.animation:resume()

  self.animation_timer:after(SWING_TIME, function() 
    self.swinging = false
    self.animation:pauseAtStart() -- reset animation
  end)
end

function Sword:set_rotation(rot)
  self.rot = rot + self.tilt * ROTATION_MOD
end