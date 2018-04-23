Player = Object:extend()

Player.DASH_DISTANCE = 220
Player.DASH_TIME = 0.25
Player.NUDGE_TIME = 0.21
Player.HEALTH = 100

Player.spritesheet = love.graphics.newImage("res/player1.png")
Player.spritesheet:setFilter("nearest", "nearest")
Player.sheet_width = 13*4
Player.sheet_height = 15*2
Player.sprite_width = 13
Player.sprite_height = 15
Player.grid = anim8.newGrid(Player.sprite_width, Player.sprite_height, Player.sheet_width, Player.sheet_height)
Player.idle_animation = anim8.newAnimation(Player.grid(1,1), 0.2)
Player.run_animation = anim8.newAnimation(Player.grid("1-4",2), 0.1)

--[[ Utils ]]
function Player:getX() return self.x - self.ox end
function Player:getY() return self.y - self.oy end

--[[ Constructor ]]
function Player:new(x, y)
  self.x = x or 100
  self.y = y or 100
  self.scale_x = 1
  self.scale_y = 1
  self.width = 55
  self.height = 60
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

  self.current_animation:draw(Player.spritesheet, self.x, self.y, 0, 
      self.scale_x * self.sprite_scale_x * self.direction, 
      self.scale_y * self.sprite_scale_y,
      Player.sprite_width/2,
      Player.sprite_height/2)
  self.sword:draw(self.x, self.y)
end

--[[ Attack ]]
function Player:attack(mouse_x, mouse_y)
  -- Direction of slash
  local aim_angle = lume.angle(self:getX(), self:getY(), mouse_x, mouse_y)
  -- Slash location relative to self
  local sx, sy = lume.vector(aim_angle, Slash.DISTANCE)
  -- Slash sprite rotation
  local rot = lume.random(math.pi)
  -- Swing
  self.sword:swing(self.x + sx, self.y + sy, rot)
  -- Nudge player
  if not self.moving then
    self.nudging = true
    self.swing_nudge:tween(Player.NUDGE_TIME, self, {
      x = self.x + sx*0.3, 
      y = self.y + sy*0.3
    }, "out-cubic", function() 
      self.nudging = false
    end)
  end
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

    -- Squish player
    self.scale_y = self.x / (self.x + fx * Player.DASH_TIME)
    self.scale_x = self.y / (self.y + fy * Player.DASH_TIME)
    -- Start dash countdown
    self.dash_timer:tween(Player.DASH_TIME, self, {
      x = fx, 
      y = fy,
      scale_x = 1,
      scale_y = 1
    }, "out-quad", function()
      self.dashing = false
    end)
  end
end

--
function Player:takeDamage(amount)
  if not self.dashing then
    self.health = self.health - amount

    if self.health <= 0 then
      print(self.name, "DEAD")
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
end

function Player:move(dx, dy)
  if dx ~= 0 or dy ~= 0 then
    if not self.dashing then
      self.x = self.x + dx
      self.y = self.y + dy
    end
    self.moving = true
  else
    self.moving = false
  end
end