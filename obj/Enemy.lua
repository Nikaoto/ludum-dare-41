Enemy = Object:extend()

--[[ Global Constants ]]
Enemy.STAND_CHANCE = 0.4
Enemy.HEALTH = 70
Enemy.AGGRO_DISTANCE = 150
Enemy.FLEE_DISTANCE = 250
Enemy.ATTACK_DISTANCE = 50
Enemy.IDLE_MOVE_SPEED = 200
Enemy.AGGRO_MOVE_SPEED = 500

--[[ Animation ]]
Enemy.spritesheet = love.graphics.newImage("res/enemy.png")
Enemy.spritesheet:setFilter("nearest", "nearest")
Enemy.sheet_width = 13*4
Enemy.sheet_height = 15*2
Enemy.sprite_width = 13
Enemy.sprite_height = 15
Enemy.grid = anim8.newGrid(Enemy.sprite_width, Enemy.sprite_height, Enemy.sheet_width, Enemy.sheet_height)
Enemy.idle_animation = anim8.newAnimation(Enemy.grid("1-4",1), 0.15)
Enemy.run_animation = anim8.newAnimation(Enemy.grid("1-4",2), 0.1)


--[[ Utils ]]
function Enemy:getX() return self.x + self.ox end
function Enemy:getY() return self.y + self.oy end

--[[ Constructor ]]
function Enemy:new(x, y)
  self.x = x
  self.y = y
  self.name = "Enemy"
  self.width = 55
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

  -- Anims
  self.sprite_scale_x = self.width / Enemy.sprite_width
  self.sprite_scale_y = self.height / Enemy.sprite_height
  self.idle_animation = Enemy.idle_animation:clone()
  self.run_animation = Enemy.run_animation:clone()
  self.current_animation = self.idle_animation

  -- Timers
  self.swing_timer = Timer()
  self.swing_timer:every({1, 5}, function()
    local aim_angle = lume.angle(player:getX(), player:getY(), self.x, self.y)
    local sx, sy = lume.vector(aim_angle, Slash.DISTANCE)
    self.sword:swing(self:getX() + sx, self:getY() + sy, lume.random(3.14))
  end)

  self.movement_timer = Timer()
  self.movement_timer:every({1, 3}, function()
    self.move_direction = lume.random(math.pi*2)
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
    if self.standing then
      self.current_animation = self.idle_animation
    else
      -- wander around
      if world.checkOutOfBounds(self.x, self.y, self.width, self.height) then
        self.move_direction = lume.random(math.pi*2)
      end

      local dx, dy = lume.vector(self.move_direction, self.idle_move_speed)
      self:move(dx * dt, dy * dt)
      self.current_animation = self.run_animation
    end
  end
end

function Enemy:moveTowardsPlayer(dt)
  self.current_animation = self.run_animation

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
    self.current_animation:update(dt)
    self.sword:update(dt)
  end
end

function Enemy:draw()
  if not self.dead then
    love.graphics.setColor(1, 1, 1)
    self.current_animation:draw(self.spritesheet, self:getX(), self:getY(), 0, 
        self.sprite_scale_x * self:getDirection(), 
        self.sprite_scale_y,
        self.sprite_width/2,
        self.sprite_height/2)

    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("line", self:getX(), self:getY(), Enemy.AGGRO_DISTANCE)
    self.sword:draw(self:getX(), self:getY())

    drawCollider(self)
  end
end

-- Swings towards player
function Enemy:attackPlayer()
  if not self.attacking then
    self.attacking = true
    local aim_angle = lume.angle(player:getX(), player:getY(), self.x, self.y)
    local sx, sy = lume.vector(aim_angle, Enemy.ATTACK_DISTANCE)
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

function Enemy:getDirection()
  if self.move_direction > math.pi/2 and self.move_direction < math.pi*3/2 then
    return -1
  end
  return 1
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
    self:destroy()
  end
end

function Enemy:move(dx, dy)
  self.x = self.x + dx
  self.y = self.y + dy 
end