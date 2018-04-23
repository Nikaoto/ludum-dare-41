conf = {}

conf.window = {
  width = 1000,
  height = 800
}

conf.mouse = {
  visible = false
}

function love.conf(t)
  t.window.width = conf.window.width
  t.window.height = conf.window.height
end

function conf.load()
  love.mouse.setVisible(conf.mouse.visible)
end