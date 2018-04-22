Enemy = Object:extend()

--[[ Global Constants ]]
Enemy.STAND_CHANCE = 0.5
Enemy.HEALTH = 70

--[[ Utils ]]
function Enemy:getX() return self.x - self.ox end
function Enemy:getY() return self.y - self.oy end

--[[ Constructor ]]
function Enemy:new(x, y)
  self.x = x
  self.y = y
  self.name = "Enemy"
  self.width = 60
  self.height = 60
  self.health = Enemy.HEALTH

  self.ox = self.width/2
  self.oy = self.height/2
  self.move_direction = lume.random(math.pi)
  self.idle_move_speed = 200
  self.is_standing = true

  self.sword = Sword(self.name)

  self.swing_timer = Timer()
  self.swing_timer:every({1, 10}, function()
    local aim_angle = lume.angle(player:getX(), player:getY(), self.x, self.y)
    local sx, sy = lume.vector(aim_angle, Slash.DISTANCE)
    self.sword:swing(self:getX() + sx, self:getY() + sy, lume.random(3.14))  
  end)

  self.movement_timer = Timer()
  self.movement_timer:every({1, 3}, function()
    self.move_direction = lume.random(math.pi)
    self.is_standing = lume.random(1) > Enemy.STAND_CHANCE
  end)
end

function Enemy:updateAI(dt)
  self.swing_timer:update(dt)
  self.movement_timer:update(dt)

  -- Random Movement
  if not self.is_standing then
    local dx, dy = lume.vector(self.move_direction, self.idle_move_speed)
    self:move(dx * dt, dy * dt)
  end
end

function Enemy:update(dt)
  if not self.dead then
    self:updateAI(dt)
    self.sword:update(dt)
  end
end

function Enemy:draw()
  if not self.dead then
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    self.sword:draw(self.x + self.ox, self.y + self.oy)
  end
end

function Enemy:destroy()
  self.dead = true
  self.swing_timer:destroy()
  self.movement_timer:destroy()
end

--
function Enemy:takeDamage(amount)
  self.health = self.health - amount
  if self.health <= 0 then
    print(self.name, "DEAD")
    self:destroy()
  end
end

function Enemy:move(dx, dy)
  self.x = self.x + dx
  self.y = self.y + dy 
end