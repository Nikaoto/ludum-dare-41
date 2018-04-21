conf = {}

conf.window = {
  width = 1000,
  height = 800
}

conf.mouse = {
  visible = false
}

conf.load = function()
  love.window.setMode(conf.window.width, conf.window.height)
  love.mouse.setVisible(conf.mouse.visible)
end