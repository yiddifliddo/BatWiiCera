-- BatWiiCera Plaza - LÖVE configuration
-- Version 0.1.0 | Author: Dan Lee | Licence: MIT
function love.conf(t)
  t.identity = "batwiicera-plaza"      -- save folder: ~/.local/share/love/batwiicera-plaza
  t.appendidentity = false
  t.version = "11.4"                    -- any 11.x build (Batocera and RetroBat ship 11.x)
  t.console = false
  t.accelerometerjoystick = false
  t.gammacorrect = false

  t.window.title = "BatWiiCera Plaza"
  t.window.width = 1280
  t.window.height = 720
  t.window.resizable = true
  t.window.fullscreen = true
  t.window.fullscreentype = "desktop"
  t.window.vsync = 1
  t.window.msaa = 2
  t.window.highdpi = true

  t.modules.physics = false
  t.modules.video = false
  t.modules.touch = false
  t.modules.thread = false
end
