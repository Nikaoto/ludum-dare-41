world = {}
world.objects = {}
world.bounds = {
  x1 = 0,
  y1 = 0,
  x2 = 1000,
  y2 = 1000
}

current_enemy_spawn = 3

function world.load()
  math.randomseed(os.time())
  world.objects = {}
  resetTurnTimer()
  world.spawnPlayer()

  table.insert(world.objects, player)
  for i=1, current_enemy_spawn do
    table.insert(world.objects, Enemy(lume.random(conf.window.width), lume.random(conf.window.height)))
  end
end

function world.update(dt)
  local corpse_indexes = {}

  for i, obj in pairs(world.objects) do
    if obj.update then
      obj:update(dt)
      if obj.dead then
        table.insert(corpse_indexes, i)
      end
    end
  end

  -- Clear corpses
  for _, i in pairs(corpse_indexes) do
    table.remove(world.objects, i)
  end

  -- Check level finished (only player left)
  if #world.objects == 1 then
    world.nextLevel()
  end
end

function world.draw()
  love.graphics.setColor(1, 1, 1)

  -- Floor
  for x=0, world.bounds.x2, tile.width do
    for y=0, world.bounds.y2, tile.height do
      love.graphics.draw(tile.sprite, x, y, 0, tile.scale_x, tile.scale_y)
    end
  end

  -- Objects
  for i, obj in lume.ripairs(world.objects) do
    if obj.draw then
      obj:draw()
    end
  end
end

function world.nextLevel()
  current_level = current_level + 1
  current_enemy_spawn = current_enemy_spawn + math.ceil(lume.random(current_level, current_level*2))
  game_started = false
  world.load()
end

function world.spawnPlayer()
  local margin = 100
  player = Player(math.ceil(lume.random(
    world.bounds.x1 + margin, world.bounds.y1 + margin, 
    world.bounds.x2 - margin, world.bounds.y2 - margin)))
end


--[[ Utils ]]

function world.checkFirstCollision(x, y, w, h)
  for i, obj in pairs(world.objects) do
    if obj.x and obj.y and obj.width and obj.height then
      if checkCollision(x, y, w, h, obj.x, obj.y, obj.width, obj.height) then
        return obj
      end
    end
  end
end

function world.checkCollisions(x, y, w, h)
  local collided_objects = {}
  for i, obj in pairs(world.objects) do
    if obj.x and obj.y and obj.width and obj.height then
      if checkCollision(x, y, w, h, obj.x, obj.y, obj.width, obj.height) then
        table.insert(collided_objects, obj)
      end
    end
  end
  return collided_objects
end

function world.checkOutOfBounds(x, y, w, h)
  return x < world.bounds.x1 or y < world.bounds.y1
    or x + w > world.bounds.x2 or y + h > world.bounds.y2
end