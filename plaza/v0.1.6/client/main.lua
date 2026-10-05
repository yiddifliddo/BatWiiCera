-- BatWiiCera Plaza - entry point
-- Version 0.1.6 | Author: yiddifliddo | Licence: MIT
--
-- Scenes: menu -> plaza (room) / editor. Each scene implements
-- update(dt), draw(), action(name). Input events are translated to action
-- names by src/input.lua so gamepad and keyboard behave identically.

VERSION = "0.1.6"

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
    t = "hello", v = 1, token = profile.token, name = profile.name,
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
        net:send({ t = "update", name = profile.name, avatar = profile.avatar, share = profile.share })
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
  local fakeNet = { state = "connected", send = function() return true end, update = function() end,
                    poll = function() return {} end, close = function() end }
  local room = Plaza.new({ net = fakeNet, profile = profile })
  local names = { "Alice", "Bob", "Carol", "Dave", "Erin", "Frank", "Grace", "Heidi", "Ivan", "Judy", "Mallory", "Niaj" }
  local games = { "Super Metroid (snes)", "Sonic 2 (megadrive)", json.null, "Tekken 3 (psx)", json.null, "Doom", "Tetris (gb)", json.null, "OutRun", json.null, "F-Zero (snes)", "Pac-Man" }
  local players = {}
  math.randomseed(7)
  for i, n in ipairs(names) do
    players[#players + 1] = { id = tostring(i + 1), name = n, avatar = avatar.random(math.random), x = 250 + (i % 4) * 280 + math.random(-60, 60), y = 220 + math.floor((i - 1) / 4) * 190 + math.random(-40, 40), dir = (i % 2 == 0) and 1 or -1, anim = (i % 3 == 0) and "run" or "idle", game = games[i] }
  end
  room:apply({ t = "welcome", id = "1", you = { id = "1", name = profile.name, avatar = profile.avatar, x = 700, y = 430, dir = 1, anim = "idle", game = json.null }, players = players, world = { w = 1400, h = 800 }, ball = { 760, 470, 0, 0, 0, 0, json.null } })
  for _, p in pairs(room.players) do p.x, p.y, p.tx, p.ty = p.x, p.y, p.x, p.y end
  demo = { outdir = outdir or ".", frame = 0, room = room, shots = {} }
  demo.scenes = {
    { name = "plaza", scene = room },
    { name = "editor", scene = Editor.new({ profile = profile, onDone = function() end }) },
    { name = "menu", scene = Menu.new({ profile = profile, config = cfg }) },
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
    if profile.name == "Player" then profile.name = "You" end
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
