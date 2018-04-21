world = {}

function world.draw()
  love.graphics.setColor(1, 1, 1)

  for x=0, conf.window.width + tile.width, tile.width do
    for y=0, conf.window.height + tile.height, tile.height do
      love.graphics.draw(tile.sprite, x, y, 0, tile.scale_x, tile.scale_y)
    end
  end
end