conf = {}

conf.window = {
  width = 1024,
  height = 768,
  fullscreen = false
}

conf.mouse = {
  visible = false
}

function love.conf(t)
  t.window.title = "12Slash"
  t.window.width = conf.window.width
  t.window.height = conf.window.height
  t.window.fullscreen = conf.window.fullscreen
end

function conf.load()
  love.mouse.setVisible(conf.mouse.visible)
end