Block = Object:extend()

Block.WIDTH = 50
Block.HEIGHT = 50

Block.HEALTH = 200

function Block:new(x, y, width, height, health)
  self.x = x
  self.y = y
  self.width = width or Block.WIDTH
  self.height = height or Block.HEIGHT
  self.health = health or Block.HEALTH

  self.dead = false

  --[[local b = 
  if wolrd.checkBlockCollision(self.x, self.y, self.width, self.height) then
  end--]]
end

function Block:draw()
  if not self.dead then
    -- Draw outline
    local pad = 5
    love.graphics.setColor(0.545, 0, 0.275)
    for i=0, pad do
      love.graphics.rectangle("line", self.x - i, self.y - i, self.width + i*2, self.height + i*2)
    end
    -- Draw self
    love.graphics.setColor(0.6, 0.6, 0.6, 0.5)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  else
    -- draw trail
    love.graphics.setColor(0.545, 0, 0, 0.2)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  end
end

function Block:takeDamage(amount)
  self.health = self.health - amount
  if self.health <= 0 then
    self:destroy()
  end
end

function Block:destroy()
  self.dead = true
end
