Player = Object:extend()

Player.DASH_DISTANCE = 220
Player.DASH_TIME = 0.15

--[[ Utils ]]
function Player:getX() return self.x - self.ox end
function Player:getY() return self.y - self.oy end

--[[ Constructor ]]
function Player:new(x, y)
  self.x = x or 100
  self.y = y or 100
  self.width = 60
  self.height = 60
  self.ox = self.width/2
  self.oy = self.height/2

  self.sword = Sword(7)
  self.dash_timer = Timer()
  self.dash_x = 0
  self.dash_y = 0
end

function Player:update(dt)
  self.sword:update(dt)
  if self.dashing then
    self.dash_timer:update(dt)
  end
end

function Player:draw()

  if self.dashing then
    love.graphics.setColor(1, 1, 1, 0.3)
    --TODO squish player on dash
    love.graphics.rectangle("fill", self:getX(), self:getY(), self.width, self.height)
    self.sword:draw(self.x, self.y)    
  else
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self:getX(), self:getY(), self.width, self.height)
    self.sword:draw(self.x, self.y)
  end
end

--[[ Attack ]]
function Player:attack(mouse_x, mouse_y)
  -- Direction of slash
  local aim_angle = lume.angle(self:getX(), self:getY(), mouse_x, mouse_y)
  -- Slash location relative to self
  local sx, sy = lume.vector(aim_angle, Slash.DISTANCE)
  -- Slash sprite rotation
  local rot = lume.random(3.14)

  self.sword:swing(self:getX() + sx, self:getY() + sy, rot)
end

--[[ Dash ]]
function Player:dash(mouse_x, mouse_y)
  if not self.dashing then
    self.dashing = true
    -- Direction of dash
    local aim_angle = lume.angle(self:getX(), self:getY(), mouse_x, mouse_y)
    -- Dash vector
    self.dash_x, self.dash_y = lume.vector(aim_angle, Player.DASH_DISTANCE)
    -- Dash final destination
    local fx, fy = self.dash_x + self.x, self.dash_y + self.y
    -- Start dash countdown
    self.dash_timer:tween(Player.DASH_TIME, self, {x = fx, y = fy}, "out-cubic", function()
      self.dashing = false
    end)
  end
end

--
function Player:move(dx, dy)  
  if not self.dashing then
    self.x = self.x + dx
    self.y = self.y + dy
  end
end