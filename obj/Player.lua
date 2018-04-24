Player = Object:extend()

Player.DASH_DISTANCE = 220
Player.DASH_TIME = 0.25
Player.NUDGE_TIME = 0.21
Player.HEALTH = 100
Player.DIRECT_DAMAGE = 10
Player.SLASH_DAMAGE = 30
Player.slash_distance = 100

Player.spritesheet = love.graphics.newImage("res/player.png")
Player.spritesheet:setFilter("nearest", "nearest")
Player.sheet_width = 13*4
Player.sheet_height = 15*2
Player.sprite_width = 13
Player.sprite_height = 15
Player.grid = anim8.newGrid(Player.sprite_width, Player.sprite_height, Player.sheet_width, Player.sheet_height)
Player.idle_animation = anim8.newAnimation(Player.grid("1-4",1), 0.15)
Player.run_animation = anim8.newAnimation(Player.grid("1-4",2), 0.1)

--[[
-- Run anim
Player.runsheet = love.graphics.newImage("res/player_run.png")

Player.run_sprite_width = Player.runsheet:getWidth()/4
Player.run_sprite_height = Player.runsheet:getHeight()/2

Player.sprite_width = Player.runsheet:getWidth()/4
Player.sprite_height = Player.runsheet:getHeight()/2

Player.run_grid = anim8.newGrid(Player.run_sprite_width, Player.run_sprite_height, 
  Player.runsheet:getWidth(), Player.runsheet:getHeight())

Player.run_animation = anim8.newAnimation(Player.run_grid("1-4",1, "1-4",2), 0.1)
--]]

--[[Player.spritesheet = love.graphics.newImage("res/run.png")
Player.sheet_width = 376
Player.sheet_height = 250
Player.sprite_width = 376/4
Player.sprite_height = 250/2
Player.grid = anim8.newGrid(Player.sprite_width, Player.sprite_height, Player.sheet_width, Player.sheet_height)
Player.idle_animation = anim8.newAnimation(Player.grid(1,1), 0.15)
Player.run_animation = anim8.newAnimation(Player.grid("1-4",1, "1-4",2), 0.1)
--]]

--[[ Utils ]]
function Player:getX() return self.x + self.ox end
function Player:getY() return self.y + self.oy end

--[[ Constructor ]]
function Player:new(x, y)
  self.x = x
  self.y = y
  self.width = 45
  self.height = 52
  self.ox = self.width/2
  self.oy = self.height/2
  self.name = "Player"
  self.health = Player.HEALTH
  self.dead = false

  self.sprite_scale_x = self.width / Player.sprite_width
  self.sprite_scale_y = self.height / Player.sprite_height

  self.sword = Sword(self.name, 7)

  self.dashing = false
  self.nudging = false

  self.swing_nudge = Timer()
  self.dash_timer = Timer()
  self.dash_x = 0
  self.dash_y = 0

  self.current_animation = self.idle_animation

  self.direction = 1
end

function Player:update(dt)
  --self:takeDamage(10) --temp
  if DISABLE_TURNS or not self.dead and current_turn == self.name then
    -- Set current animation
    if self.moving or self.dashing or self.nudging then
      self.current_animation = self.run_animation
    else
      self.current_animation = self.idle_animation
    end

    self.current_animation:update(dt)
    self.sword:update(dt)

    self.swing_nudge:update(dt)
    self.dash_timer:update(dt)
  end
end

function Player:draw()
  if self.dashing then
    love.graphics.setColor(1, 1, 1, 0.4)
  else
    love.graphics.setColor(1, 1, 1)
  end

  self.current_animation:draw(self.spritesheet, self:getX(), self:getY(), 0, 
      self.sprite_scale_x * self.direction, 
      self.sprite_scale_y,
      self.sprite_width/2,
      self.sprite_height/2)
  self.sword:draw(self:getX(), self:getY())

  drawCollider(self)
end

--[[ Attack ]]
function Player:attack(mouse_x, mouse_y)
  total_swings = total_swings + 1
  -- Direction of slash
  local aim_angle = lume.angle(self:getX(), self:getY(), mouse_x, mouse_y)
  -- Slash location relative to self (if mouse aims closer, slash closer)
  local sx, sy = lume.vector(aim_angle, 
    math.sqrt(math.min(sq(self.x - mouse_x) + sq(self.y - mouse_y), sq(self.slash_distance))))
  -- Slash sprite rotation
  local rot = lume.random(math.pi)
  -- Swing
  self.sword:swing(self.x + sx, self.y + sy, rot, Player.SLASH_DAMAGE)
  -- Damage enemies standing ON player
  local hit_objects = world.checkCollisions(self.x, self.y, self.width, self.height)
  -- Remove self from collisions
  hit_objects = lume.filter(hit_objects, function(x) return x.name ~= self.name end)
  if #hit_objects ~= 0 then
    sounds.play("slash_hit")
    -- Deal damages
    for i, obj in pairs(hit_objects) do
      if obj.takeDamage then
        obj:takeDamage(Player.DIRECT_DAMAGE)
      end
    end
  end

  -- Nudge player
  if not self.moving then

    local nx, ny = self.x + sx*0.3, self.y + sy*0.3
    if not world.checkOutOfBounds(nx, ny, self.width, self.height) then
      self.nudging = true
      self.swing_nudge:tween(Player.NUDGE_TIME, self, {
        x = nx, 
        y = ny
      }, "out-cubic", function() 
        self.nudging = false
      end)
    end
  end
end

--[[ Dash ]]
function Player:dash(mouse_x, mouse_y)
  if not self.dashing then
    sounds.play("dash")
    self.dashing = true
    -- Direction of dash
    local aim_angle = lume.angle(self:getX(), self:getY(), mouse_x, mouse_y)
    -- Dash vector
    self.dash_x, self.dash_y = lume.vector(aim_angle, Player.DASH_DISTANCE)
    -- Dash final destination
    local fx, fy = self.dash_x + self.x, self.dash_y + self.y

    -- Start dash countdown
    self.dash_timer:tween(Player.DASH_TIME, self, {
      x = fx, 
      y = fy
    }, "out-quad", function()
      self.dashing = false
    end)
  end
end

--
function Player:takeDamage(amount, override)
  if not override or not INVINCIBLE or not self.dashing then
    self.health = self.health - amount
    camera:flash(0.05, {1, 0, 0, 0.3})
    if self.health <= 0 then
      self:destroy()
    end
  end
end

function Player:setDirection(dir)
  self.direction = dir
end

function Player:destroy()
  self.dead = true
  self.swing_nudge:destroy()
  self.dash_timer:destroy()
  world.lose()
end

function Player:move(dx, dy)
  if dx == 0 and dy == 0 then
    self.moving = false
  else
    local next_x, next_y = self.x + dx, self.y + dy

    -- World bound collisions
    if next_x < world.bounds.x1 or next_x + self.width > world.bounds.x2 then
      dx = 0
    end

    if next_y < world.bounds.y1 or next_y + self.height > world.bounds.y2 then
      dy = 0
    end

    -- Block collisions
    local block = world.checkBlockCollision(self.x, self.y, self.width, self.height)
    if block then
      if next_x < block.x + block.width or next_x + self.width > block.x then
        dx = 0
      end

      if next_y < block.y + block.width or next_y + self.height > block.y then
        dy = 0
      end
    end

    self.moving = true
    if not self.dashing then
      self.x = self.x + dx
      self.y = self.y + dy
    end
  end
end

function Player:outOfBounds(next_x, next_y)
  return world.checkOutOfBounds(self.x + next_x, self.y + next_y, self.width, self.height)
end