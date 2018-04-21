controls = {}

--[[ Constants ]]
DIAGONAL_MOVEMENT_MOD = 0.75
CROSSHAIR_RADIUS = 12
CROSSHAIR_SEGMENTS = 8

--[[ Variables ]]
dx = 0
dy = 0
speed = 400

--[[ Utils ]]
local isDown = function(key) return love.keyboard.isDown(key) end

--[[ Update ]]
function controls.update(dt)
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

--[[ Draw Mouse]]
function controls.draw_mouse()
  mouse_x, mouse_y = love.mouse.getPosition()
  love.graphics.setColor(1, 1, 1)
  love.graphics.circle("line", mouse_x, mouse_y, CROSSHAIR_RADIUS, CROSSHAIR_SEGMENTS)

  love.graphics.setColor(0, 0, 0)
  love.graphics.circle("line", mouse_x, mouse_y, CROSSHAIR_RADIUS * 0.9, CROSSHAIR_SEGMENTS)
  love.graphics.circle("line", mouse_x, mouse_y, CROSSHAIR_RADIUS * 0.8, CROSSHAIR_SEGMENTS)
  love.graphics.circle("line", mouse_x, mouse_y, CROSSHAIR_RADIUS * 0.7, CROSSHAIR_SEGMENTS)

  love.graphics.setColor(1, 1, 1)
  love.graphics.circle("line", mouse_x, mouse_y, CROSSHAIR_RADIUS * 0.6, CROSSHAIR_SEGMENTS)
end