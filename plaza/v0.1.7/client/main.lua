-- BatWiiCera Plaza - entry point
-- Version 0.1.7 | Author: yiddifliddo | Licence: MIT
--
-- Scenes: menu -> plaza (room) / editor. Each scene implements
-- update(dt), draw(), action(name). Input events are translated to action
-- names by src/input.lua so gamepad and keyboard behave identically.

VERSION = "0.1.7"

local ui = require("src.ui")
local input = require("src.input")
local config = require("src.config")
local Net = require("src.net")
local Menu = require("src.menu")
local Editor = require("src.editor")
local Plaza = require("src.plaza")

local scene = nil
local net = nil
local cfg, profile
local selftest = false

local colorsOverride = nil

local function applyColors()
  local mode = profile.colors
  if mode == "auto" or mode == nil then mode = ui.detectThemeMode() or "light" end
  ui.setPalette(mode)
  local c = ui.colors.bg
  love.graphics.setBackgroundColor(c[1], c[2], c[3])
end

local function helloMessage()
  return {
    t = "hello", v = 1, token = profile.token, nameSeed = profile.nameSeed,
    avatar = profile.avatar, share = profile.share
  }
end

local showMenu, showEditor, showPlaza

showMenu = function(notice)
  scene = Menu.new({
    profile = profile, config = cfg, notice = notice,
    onEnter = function() showPlaza() end,
    onEdit = function() showEditor(showMenu) end,
    onQuit = function() love.event.quit() end,
  })
end

showEditor = function(back)
  scene = Editor.new({
    profile = profile,
    onDone = function(saved)
      applyColors()
      if saved and net and net.state == "connected" then
        net:send({ t = "update", nameSeed = profile.nameSeed, avatar = profile.avatar, share = profile.share })
      end
      back()
    end,
  })
end

showPlaza = function()
  if net then net:close() end
  net = Net.new(cfg.host, cfg.tcpPort, helloMessage())
  net:connect()
  local room
  room = Plaza.new({
    net = net, profile = profile,
    onLeave = function() net:close(); showMenu() end,
    onEdit = function() showEditor(function() scene = room end) end,
    onPresence = function(url)
      if cfg.presenceUrl ~= url then cfg.presenceUrl = url; config.saveConfig() end
    end,
  })
  scene = room
  if net.state == "failed" then room.status = "error"; room.errorMessage = net.error end
end

-- Demo mode (--demo [outdir]): fills the plaza with pretend players, renders
-- the three screens and saves PNGs, then quits. Used for previews and as a
-- rendering crash test under a virtual framebuffer.
local demo = nil

local function startDemo(outdir)
  local avatar = require("src.avatar")
  local json = require("src.json")
  local names = require("src.names")
  local fakeNet = { state = "connected", send = function() return true end, update = function() end,
                    poll = function() return {} end, close = function() end }
  local room = Plaza.new({ net = fakeNet, profile = profile })
  local P = Plaza.PITCH_DEFAULTS
  local games = { "Super Metroid (snes)", "Sonic 2 (megadrive)", json.null, "Tekken 3 (psx)", json.null, "Doom", "Tetris (gb)", json.null, "OutRun", json.null, "F-Zero (snes)", "Pac-Man", json.null, "Street Fighter II", json.null, "Zelda (snes)" }
  local players = {}
  math.randomseed(7)
  for i = 1, 16 do
    players[#players + 1] = { id = tostring(i + 1), name = names.generate("demo", i), avatar = avatar.random(math.random),
      x = P.w * 0.5 + math.random(-650, 650), y = P.h * 0.5 + math.random(-420, 420), dir = math.random(0, 359),
      anim = (i % 3 == 0) and "run" or "idle", game = games[i] }
  end
  room:apply({ t = "welcome", id = "1", you = { id = "1", name = profile.name, avatar = profile.avatar, x = P.w * 0.5, y = P.h * 0.55, dir = 0, anim = "idle", game = json.null },
    players = players, pitch = { w = P.w, h = P.h, apron = P.apron, goalW = P.goalW, goalDepth = P.goalDepth }, score = { left = 2, right = 1 },
    ball = { P.w * 0.5 + 90, P.h * 0.55 - 30, 0, 0, 0, 0, json.null } })
  for _, p in pairs(room.players) do
    if not p.isMe then p.speed = (p.anim == "run") and 0.9 or 0 end
  end
  room.vx = 160
  room.count = 17
  -- a sheet of the avatar renderer, for judging the look
  local sheet = { time = 0 }
  function sheet:update(dt) self.time = self.time + dt end
  function sheet:draw()
    local lg = love.graphics
    local sw = lg.getWidth()
    ui.backdrop(sw, lg.getHeight())
    ui.text("Avatar renderer: idle in eight directions, run cycle, run in eight directions, actions", 20, 14, sw - 40, "left", ui.fonts.body, ui.colors.text2)
    local function sample(i) local a = avatar.default(); a.shirt = (i * 3) % 12; a.hair = i % 8; a.skin = (i * 2) % 8; a.hairColor = (i * 5) % 10; a.eyes = i % 6; a.mouth = i % 6; a.head = i % 4; a.accessory = i % 4; return a end
    local col = sw / 8
    for i = 0, 7 do avatar.draw(sample(i), col * (i + 0.5), 170, 1.1, i * 45, "idle", self.time, { seed = i }) end
    for i = 0, 7 do avatar.draw(sample(2), col * (i + 0.5), 330, 1.1, 0, "run", i / 8 * (2 * math.pi) / 14, { speed = 1 }) end
    for i = 0, 7 do avatar.draw(sample(i), col * (i + 0.5), 490, 1.1, i * 45, "run", 0.37, { speed = 1 }) end
    local poses = { { "jump", { vz = 200, z = 50 } }, { "jump", { vz = -200, z = 25 } }, { "idle", { squash = 0.2 } }, { "hit", {} }, { "slap", { phase = 0.5 } }, { "kick", { phase = 0.6 } }, { "skid", {} }, { "idle", {} } }
    for i, p in ipairs(poses) do avatar.draw(sample(i), col * (i - 0.5), 660, 1.1, (i == 8) and 270 or 0, p[1], 1.0, p[2]) end
  end
  demo = { outdir = outdir or ".", frame = 0, room = room, shots = {} }
  -- a second, wide view of the same room shows the whole stadium
  local wide = setmetatable({}, { __index = function(_, k) local v = room[k]; return v end })
  function wide:update(dt) room.zoomMin, room.zoomMax = 0.165, 0.165; room:update(dt); room.cam.zoom, room.cam.tzoom = 0.165, 0.165; room.cam.x, room.cam.y = room.pitch.w / 2, room.pitch.h / 2 - 120; room.zoomMin, room.zoomMax = nil, nil end
  function wide:draw() room:draw() end
  demo.scenes = {
    { name = "plaza", scene = room },
    { name = "stadium", scene = wide },
    { name = "editor", scene = Editor.new({ profile = profile, onDone = function() end }) },
    { name = "menu", scene = Menu.new({ profile = profile, config = cfg }) },
    { name = "avatars", scene = sheet },
  }
  demo.scenes[2].scene.row = 3
  scene = room
end

function love.load(args)
  local demoDir
  for i, a in ipairs(args or {}) do
    if a == "--selftest" then selftest = true end
    if a == "--demo" then demoDir = args[i + 1] or "." end
    if a == "--dark" then colorsOverride = "dark" end
  end
  love.graphics.setBackgroundColor(0.925, 0.925, 0.925)
  ui.load()
  input.load()
  cfg, profile = config.load()
  if colorsOverride then profile.colors = colorsOverride end
  applyColors()
  if selftest then
    local ok, err = pcall(function() require("test.selftest").run() end)
    print(ok and "selftest: passed" or ("selftest: FAILED: " .. tostring(err)))
    love.event.quit(ok and 0 or 1)
    return
  end
  if demoDir then
    startDemo(demoDir)
    return
  end
  showMenu()
end

function love.update(dt)
  if dt > 0.1 then dt = 0.1 end
  if demo then
    demo.frame = demo.frame + 1
    local idx = math.floor((demo.frame - 1) / 40) + 1
    local entry = demo.scenes[idx]
    if not entry then love.event.quit(0); return end
    scene = entry.scene
    if demo.frame % 40 == 20 then
      -- let the room settle its camera first, then capture each screen once
      love.graphics.captureScreenshot(function(img)
        local name = demo.outdir .. "/plaza-" .. entry.name .. (ui.mode == "dark" and "-dark" or "") .. ".png"
        local fd = img:encode("png")
        local f = io.open(name, "wb")
        if f then f:write(fd:getString()); f:close(); print("wrote " .. name) end
      end)
    end
  end
  if scene and scene.update then scene:update(dt) end
end

function love.draw()
  if scene and scene.draw then scene:draw() end
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(ui.fonts.label)
  ui.col(ui.colors.muted)
  love.graphics.print("Plaza " .. VERSION, love.graphics.getWidth() - 80, 8)
end

local function dispatch(action)
  if action and scene and scene.action then scene:action(action) end
end

function love.keypressed(key)
  dispatch(input.keyAction(key))
end

function love.gamepadpressed(_, button)
  dispatch(input.padAction(button))
end

-- Pads without a gamepad mapping: treat the first four buttons as A B X Y.
function love.joystickpressed(j, button)
  if j:isGamepad() then return end
  local map = { "a", "b", "x", "y", nil, nil, "select", "start" }
  dispatch(map[button])
end

function love.joystickadded(j) input.joystickAdded(j) end
function love.joystickremoved(j) input.joystickRemoved(j) end

function love.quit()
  if net then net:close() end
end
