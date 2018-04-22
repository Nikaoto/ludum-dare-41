Enemy = Object:extend()

--[[ Global Constants ]]
Enemy.STAND_CHANCE = 0.5
Enemy.HEALTH = 70
Enemy.AGGRO_DISTANCE = 150
Enemy.FLEE_DISTANCE = 250
Enemy.ATTACK_DISTANCE = 50
Enemy.IDLE_MOVE_SPEED = 200
Enemy.AGGRO_MOVE_SPEED = 500

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
  self.idle_move_speed = Enemy.IDLE_MOVE_SPEED
  self.aggro_move_speed = Enemy.AGGRO_MOVE_SPEED
  self.standing = true
  self.attacking = true

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
    self.standing = lume.random(1) > Enemy.STAND_CHANCE
  end)

  self.attack_timer = Timer()
end

function Enemy:updateAI(dt)
  self.swing_timer:update(dt)
  self.movement_timer:update(dt)
  self.attack_timer:update(dt)

  if self:aggroed() then
    self:moveTowardsPlayer(dt)
  else
    -- Random Movement
    if not self.standing then
      local dx, dy = lume.vector(self.move_direction, self.idle_move_speed)
      self:move(dx * dt, dy * dt)
    end
  end
end

function Enemy:moveTowardsPlayer(dt)
  self.move_direction = lume.angle(self.x, self.y, player.x, player.y)
  local dx, dy = lume.vector(self.move_direction, self.aggro_move_speed)
  self:move(dx * dt, dy * dt)

  if self:canAttackPlayer() then
    self.attack_timer:update(dt)
    self:attackPlayer()
  else
    self.attacking = false
  end
end

function Enemy:update(dt)
  if DISABLE_TURNS or not self.dead and current_turn == self.name then
    self:updateAI(dt)
    self.sword:update(dt)
  end
end

function Enemy:draw()
  if not self.dead then
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("line", self.x + self.ox, self.y + self.ox, Enemy.AGGRO_DISTANCE)
    self.sword:draw(self.x + self.ox, self.y + self.oy)
  end
end

-- Swings towards player
function Enemy:attackPlayer()
  if not self.attacking then
    self.attacking = true
    local aim_angle = lume.angle(player:getX(), player:getY(), self.x, self.y)
    local sx, sy = lume.vector(aim_angle, Slash.DISTANCE)
    self.sword:swing(self:getX() + sx, self:getY() + sy, lume.random(math.pi))

    self.attack_timer:after({1, 2}, function() 
      self.attacking = false
    end)
  end
end

function Enemy:canAttackPlayer()
  return lume.distance(player.x, player.y, self.x, self.y) < Enemy.ATTACK_DISTANCE
end

function Enemy:aggroed()
  return lume.distance(player.x, player.y, self.x, self.y) < Enemy.AGGRO_DISTANCE
end

--
function Enemy:destroy()
  self.dead = true
  self.swing_timer:destroy()
  self.movement_timer:destroy()
end

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