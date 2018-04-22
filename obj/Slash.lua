-- Slash animation for swords
-- When created, runs animates for some time and destroys itself

Slash = Object:extend()

--[[ Global Constants ]]
Slash.SLASH_TIME = 0.21
Slash.DISTANCE = 130
Slash.SHAKE = 2
Slash.COLOR = {1, 1, 1, 1}
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
  self.color = args.color or Slash.COLOR

  -- Shake stronger on collision
  camera:shake(shake or Slash.SHAKE, Slash.SLASH_TIME, 100)

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