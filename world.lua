world = {}
world.enemies = {}

function world.load()
  math.randomseed(os.time())

  --bump = Bump.newWorld(64)
  for i=0, 5 do
    table.insert(world.enemies, Enemy(lume.random(conf.window.width), lume.random(conf.window.height)))
  end
end

function world.update(dt)
  for i, enemy in pairs(world.enemies) do
    enemy:update(dt)
  end
end

function world.draw()
  love.graphics.setColor(1, 1, 1)

  -- Floor
  for x=0, conf.window.width + tile.width, tile.width do
    for y=0, conf.window.height + tile.height, tile.height do
      love.graphics.draw(tile.sprite, x, y, 0, tile.scale_x, tile.scale_y)
    end
  end

  -- Enemies
  for i, enemy in pairs(world.enemies) do
    enemy:draw(dt)
  end
end