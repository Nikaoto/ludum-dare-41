EnemyB = Object:extend()

--[[ Global Constants ]]
EnemyB.STAND_CHANCE = 0.3
EnemyB.HEALTH = 120
EnemyB.FLEE_DISTANCE = 150
EnemyB.BUILD_DISTANCE = 50
EnemyB.IDLE_MOVE_SPEED = 200
EnemyB.FLEE_MOVE_SPEED = 400

--[[ Animation ]]
EnemyB.spritesheet = love.graphics.newImage("res/enemy.png")
EnemyB.spritesheet:setFilter("nearest", "nearest")
EnemyB.sheet_width = 13*4
EnemyB.sheet_height = 15*2
EnemyB.sprite_width = 13
EnemyB.sprite_height = 15
EnemyB.grid = anim8.newGrid(Enemy.sprite_width, Enemy.sprite_height, Enemy.sheet_width, Enemy.sheet_height)
EnemyB.idle_animation = anim8.newAnimation(Enemy.grid("1-4",1), 0.15)
EnemyB.run_animation = anim8.newAnimation(Enemy.grid("1-4",2), 0.1)


--[[ Utils ]]
function EnemyB:getX() return self.x + self.ox end
function EnemyB:getY() return self.y + self.oy end

--[[ Constructor ]]
function EnemyB:new(x, y)
  self.x = x
  self.y = y
  self.name = "Enemy"
  self.width = 55
  self.height = 60
  self.health = EnemyB.HEALTH

  self.ox = self.width/2
  self.oy = self.height/2
  self.move_direction = lume.random(math.pi)
  self.idle_move_speed = EnemyB.IDLE_MOVE_SPEED
  self.flee_move_speed = EnemyB.FLEE_MOVE_SPEED
  self.standing = true
  self.fleeing = false

  -- Anims
  self.sprite_scale_x = self.width / EnemyB.sprite_width
  self.sprite_scale_y = self.height / EnemyB.sprite_height
  self.idle_animation = EnemyB.idle_animation:clone()
  self.run_animation = EnemyB.run_animation:clone()
  self.current_animation = self.idle_animation

  -- Timers
  self.build_timer = Timer()
  self.build_timer:every({2, 4}, function()
    local aim_angle = lume.random(math.pi*2)
    local sx, sy = lume.vector(aim_angle, self.BUILD_DISTANCE)
    self:build(self:getX() + sx, self:getY() + sy)
  end)

  self.movement_timer = Timer()
  self.movement_timer:every({1, 3}, function()
    self.move_direction = lume.random(math.pi*2)
    self.standing = lume.random(1) > Enemy.STAND_CHANCE
  end)

  self.attack_timer = Timer()
end

function EnemyB:updateAI(dt)
  self.movement_timer:update(dt)
  self.build_timer:update(dt)

  if self:shouldRunAway() then
    self:runAway(dt)
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

function EnemyB:runAway(dt)
  self.current_animation = self.run_animation

  self.move_direction = lume.angle(self.x, self.y, player.x, player.y) + math.pi
  local dx, dy = lume.vector(self.move_direction, self.flee_move_speed)
  self:move(dx * dt, dy * dt)
  self.fleeing = true
end

function EnemyB:update(dt)
  if DISABLE_TURNS or not self.dead and current_turn == self.name then
    self:updateAI(dt)
    self.current_animation:update(dt)
  end
end

function EnemyB:draw()
  if not self.dead then
    love.graphics.setColor(0.545, 0.271, 0.075)
    self.current_animation:draw(self.spritesheet, self:getX(), self:getY(), 0, 
        self.sprite_scale_x * self:getDirection(), 
        self.sprite_scale_y,
        self.sprite_width/2,
        self.sprite_height/2)

    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("line", self:getX(), self:getY(), EnemyB.FLEE_DISTANCE)

    drawCollider(self)
  end
end

-- Swings towards player
function EnemyB:build(x, y, width, height)
  table.insert(world.blocks, Block(x, y, width, height))
end

function Enemy:canBuild()
  return lume.distance(player.x, player.y, self.x, self.y) < Enemy.ATTACK_DISTANCE
end

function EnemyB:shouldRunAway()
  return lume.distance(player.x, player.y, self.x, self.y) < EnemyB.FLEE_DISTANCE
end

function EnemyB:getDirection()
  if self.move_direction > math.pi/2 and self.move_direction < math.pi*3/2 then
    return -1
  end
  return 1
end

--
function EnemyB:destroy()
  self.dead = true
  self.build_timer:destroy()
  self.movement_timer:destroy()
end

function EnemyB:takeDamage(amount)
  self.health = self.health - amount
  if self.health <= 0 then
    self:destroy()
  end
end

function EnemyB:move(dx, dy)
  self.x = self.x + dx
  self.y = self.y + dy 
end