Player = Object:extend()

--[[ Utils ]]
function Player:getX() return self.x - self.ox end
function Player:getY() return self.y - self.oy end

--[[ Constructor ]]
function Player:new()
  self.x = 100
  self.y = 100
  self.width = 60
  self.height = 60
  self.ox = self.width/2
  self.oy = self.height/2

  self.sword = Sword()
end

function Player:update(dt)
  self.sword:update(dt)
end

function Player:draw()
  love.graphics.rectangle("fill", self:getX(), self:getY(), self.width, self.height)
  self.sword:draw(self.x, self.y)
end

--
function Player:move(dx, dy)  
  self.x = self.x + dx
  self.y = self.y + dy 
end