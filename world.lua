world = {}
world.objects = {}
world.blocks = {}
world.bounds = {
  x1 = 0,
  y1 = 0,
  x2 = 600,
  y2 = 600
}

STARTING_ENEMY_SPAWN = 3
ENEMYB_RATIO = 3
BLOCK_RATIO = 4

current_enemy_spawn = STARTING_ENEMY_SPAWN

function world.reset()
  music:play()
  current_enemy_spawn = STARTING_ENEMY_SPAWN
  current_level = 1
  world.load()
end

function world.load()
  math.randomseed(os.time())
  world.objects = {}
  world.blocks = {}
  resetTurnTimer()
  world.spawnPlayer()

  table.insert(world.objects, player)

  world.bounds.x2 = world.bounds.x2 + tile.width
  world.bounds.y2 = world.bounds.y2 + tile.width

  local spawn_margin = 70
  local max_spawn_x = world.bounds.x2 - spawn_margin
  local max_spawn_y = world.bounds.y2 - spawn_margin

  for i=1, current_enemy_spawn do
    -- Blocks
    if current_level > 2 and i % BLOCK_RATIO == 0 then
      table.insert(world.blocks, Block(lume.random(max_spawn_x), lume.random(max_spawn_y)))
    end
    -- Enemies
    if current_level > 3 and i % ENEMYB_RATIO == 0 then
      table.insert(world.objects, EnemyB(lume.random(max_spawn_x), lume.random(max_spawn_y)))
    else
      table.insert(world.objects, Enemy(lume.random(max_spawn_x), lume.random(max_spawn_y)))
    end
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

  for i, block in pairs(world.blocks) do
    if block.update then
      block:update(dt)
    end
  end

  -- Clear corpses
  for _, i in pairs(corpse_indexes) do
    if world.objects[i] and world.objects[i].dead then
      table.remove(world.objects, i)
      total_kills = total_kills + 1
    end
  end

  -- Check level finished (only player left)
  if #world.objects == 1 then
    world.nextLevel()
  end
end

function world.draw()
  love.graphics.clear(0.353, 0.404, 0.451, 0.9)
  love.graphics.setColor(1, 1, 1)

  -- Draw bounds
  --love.graphics.rectangle("fill", world.bounds.x1, world.bounds.y1, world.bounds.x2, world.bounds.y2)

  -- Floor
  for x=1, world.bounds.x2, tile.width do
    for y=1, world.bounds.y2, tile.height do
      love.graphics.draw(tile.sprite, x, y, 0, tile.scale_x, tile.scale_y)
    end
  end

  -- Objects
  for i, obj in lume.ripairs(world.objects) do
    if obj.draw then
      obj:draw()
    end
  end

  -- Blocks
  for i, block in pairs(world.blocks) do
    if block.draw then
      block:draw()
    end
  end

end

function world.lose()
  sounds.play("lose")
  game_started = false
  won = false
  music:stop()
  world.reset()
end

function world.nextLevel()
  sounds.play("win")
  current_level = current_level + 1
  current_enemy_spawn = current_enemy_spawn + math.ceil(lume.random(current_level, current_level*1.1))
  game_started = false
  won = true
  world.load()
end

function world.spawnPlayer()
  local margin = 100
  player = Player(math.ceil(lume.random(world.bounds.x1 + margin, world.bounds.x2 - margin)),
    math.ceil(lume.random(world.bounds.y1 + margin, world.bounds.y2 - margin)))
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

function world.checkBlockCollision(x, y, w, h)
  for i, obj in pairs(world.blocks) do
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