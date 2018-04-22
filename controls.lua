controls = {}

--[[ Constants ]]
DIAGONAL_MOVEMENT_MOD = 0.75
CROSSHAIR_RADIUS = 12
CROSSHAIR_SEGMENTS = 8

--[[ Variables ]]
dx = 0
dy = 0
speed = 450

--[[ Utils ]]
local isDown = function(key) return love.keyboard.isDown(key) end
local transform_mouse_position = function(x, y) 
  return (x - conf.window.width / 2), (y - conf.window.height / 2) 
end

local getMousePosition = function(px, py, mx, my)
  return (px + mx - conf.window.width/2), (py + my - conf.window.height/2)
end


controls.mouse_x = 0
controls.mouse_y = 0

function controls.movement(dt)
  if current_turn == player_turn then
    dx, dy = 0, 0
     
    if isDown("w") then
      dy = dy - speed * dt
    end

    if isDown("s") then
      dy = dy + speed * dt
    end

    if isDown("a") then
      dx = dx - speed * dt
    end

    if isDown("d") then
      dx = dx + speed * dt
    end

    if dx ~= 0 and dy ~= 0 then
      dx, dy = dx * DIAGONAL_MOVEMENT_MOD, dy * DIAGONAL_MOVEMENT_MOD
    end
    player:move(dx, dy)
  end
end

function controls.aim(dt)
  -- Rotate player sword
  local angle = lume.angle(player:getX(), player:getY(), controls.mouse_x, controls.mouse_y)
  player.sword:setRotation(angle)

  -- Set player direction
  local a = angle + math.pi
  if a > math.pi/2 and a < math.pi*3/2 then
    player:setDirection(1)
  else
    player:setDirection(-1)
  end
end

--[[ Update ]]
function controls.update(dt)
  controls.movement(dt)
  controls.aim(dt)
end

--[[ Callbacks ]]
function controls.mousepressed(x, y, button)
  if current_turn == player_turn then
    if button == 1 then
      player:attack(controls.mouse_x, controls.mouse_y)
    end

    if button == 2 then
      player:dash(controls.mouse_x, controls.mouse_y)
    end
  end
end

function controls.mousereleased(x, y, button)
  if current_turn == player_turn then
    --print("controls.mousereleased("..x..", "..y..", "..button..")")
  end
end

--[[ Draw Mouse]]
function controls.drawMouse()
  -- Update mouse position
  local mx, my = love.mouse.getPosition()
  controls.mouse_x, controls.mouse_y = getMousePosition(player.x, player.y, mx, my)

  local mouse_x, mouse_y = love.mouse.getPosition()
  love.graphics.setColor(1, 1, 1)
  love.graphics.circle("line", mouse_x, mouse_y, CROSSHAIR_RADIUS, CROSSHAIR_SEGMENTS)

  love.graphics.setColor(0, 0, 0)
  love.graphics.circle("line", mouse_x, mouse_y, CROSSHAIR_RADIUS * 0.9, CROSSHAIR_SEGMENTS)
  love.graphics.circle("line", mouse_x, mouse_y, CROSSHAIR_RADIUS * 0.8, CROSSHAIR_SEGMENTS)
  love.graphics.circle("line", mouse_x, mouse_y, CROSSHAIR_RADIUS * 0.7, CROSSHAIR_SEGMENTS)

  love.graphics.setColor(1, 1, 1)
  love.graphics.circle("line", mouse_x, mouse_y, CROSSHAIR_RADIUS * 0.6, CROSSHAIR_SEGMENTS)
end