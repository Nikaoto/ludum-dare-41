-- Slash animation for swords
-- When created, runs animates for some time and destroys itself

Slash = Object:extend()

--[[ Global Constants ]]
Slash.SLASH_TIME = 0.21
Slash.DISTANCE = 130
Slash.SHAKE = 2
Slash.COLOR = {1, 1, 1, 1}
Slash.DAMAGE = 20
Slash.spritesheet = love.graphics.newImage("res/slash.png")
Slash.sheet_width = 960
Slash.sheet_height = 384
Slash.sprite_size = 192
Slash.origin = Slash.sprite_size / 2
Slash.grid = anim8.newGrid(Slash.sprite_size, Slash.sprite_size, Slash.sheet_width, Slash.sheet_height)
Slash.animation = anim8.newAnimation(Slash.grid("1-5",1, "1-2",2), Slash.SLASH_TIME/7)
Slash.scale = 0.8

function Slash:new(args, callback)
  self.x = args.x
  self.y = args.y
  self.rotation = args.rotation or 0
  self.animation = Slash.animation:clone()
  self.active = true
  self.scale = args.scale or Slash.scale
  self.color = Slash.COLOR
  self.width = args.width or Slash.sprite_size * self.scale * 0.6 -- smaller for collisions
  self.height = args.height or Slash.sprite_size * self.scale * 0.6
  self.ox = self.width / 2
  self.oy = self.height / 2
  self.damage = args.damage or Slash.DAMAGE

  self.caller = args.caller or ""
  self.shake = args.shake or Slash.SHAKE
  self.slash_time = Slash.SLASH_TIME

  -- Detect hit objects
  local hit_objects = world.checkCollisions(self.x - self.ox, self.y - self.oy, self.width, self.height)
  -- Remove swinger from collisions
  hit_objects = lume.filter(hit_objects, function(x) return x.name ~= self.caller end)

  -- Deal damages
  for i, obj in pairs(hit_objects) do
    if obj.takeDamage then
      obj:takeDamage(self.damage)
    end
  end

  -- If hit, then add effects
  if hit_objects and #hit_objects ~= 0 then
    sounds.play("slash_hit")
    self.color = {1, 0, 0}
    self.scale = self.scale + #hit_objects
    self.slash_time = self.slash_time + 0.2 * #hit_objects
  else
    sounds.play("slash")
  end
  camera:shake(self.shake, self.slash_time, 100)

  self.timer = Timer()
  self.timer:after(Slash.SLASH_TIME, function()
    self:destroy()
    callback()
  end)
end

function Slash:update(dt)
  if self.active then
    self.timer:update(dt)
    self.animation:update(dt)
  end
end

function Slash:draw()
  -- draw hitbox
  -- love.graphics.setColor(0, 1, 0)  
  -- love.graphics.rectangle("line", self.x-self.ox, self.y-self.oy, self.width, self.height)

  if self.active then
    love.graphics.setColor(self.color)
    self.animation:draw(Slash.spritesheet, self.x, self.y, self.rotation, Slash.scale, Slash.scale, 
      Slash.origin, Slash.origin)
  end
end

function Slash:destroy()
  self.active = false
  self.timer:destroy()
  self = {}
end
