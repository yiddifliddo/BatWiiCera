-- BatWiiCera Plaza - client self-test
-- Version 0.1.4 | Author: yiddifliddo | Licence: MIT
--
-- Exercises the logic that does not need a window: JSON, avatar validation,
-- message handling, local physics, camera framing and the on-screen keyboard.
-- Runs two ways:
--   lua5.1 client/test/run.lua          (fake love table, no LÖVE needed)
--   love client --selftest              (inside LÖVE)

local json = require("src.json")
local avatar = require("src.avatar")
local Plaza = require("src.plaza")
local ui = require("src.ui")

local T = {}
local checks = 0

local function eq(a, b, what)
  checks = checks + 1
  if a ~= b then error(string.format("%s: expected %s, got %s", what or "check", tostring(b), tostring(a)), 2) end
end
local function ok(v, what)
  checks = checks + 1
  if not v then error((what or "check") .. " failed", 2) end
end

local function fakeNet()
  return { state = "connected", sent = {}, send = function(self, m) self.sent[#self.sent + 1] = m; return true end,
           update = function() end, poll = function() return {} end, close = function() end }
end

function T.run()
  -- JSON round trip
  local obj = { t = "hello", v = 1, name = "Dan \"L\"", avatar = { head = 2 }, list = { 1, 2.5, "x", false }, n = json.null }
  local back = json.decode(json.encode(obj))
  eq(back.t, "hello", "json string"); eq(back.v, 1, "json int"); eq(back.name, 'Dan "L"', "json escape")
  eq(back.avatar.head, 2, "json nested"); eq(#back.list, 4, "json array"); eq(back.list[4], false, "json false")
  eq(back.n, json.null, "json null"); eq(json.encode({}), "[]", "empty table is []")
  eq(json.decode('"\\u00e9\\ud83d\\ude00"'), "\195\169\240\159\152\128", "unicode escapes")
  local badOk = pcall(json.decode, "{bad json")
  eq(badOk, false, "bad json raises")

  -- Avatar validation
  local a = avatar.sanitize({ head = 99, skin = -1, hair = "3", shirt = 5.7 })
  eq(a.head, 3, "head clamped"); eq(a.skin, 0, "skin clamped"); eq(a.hair, 3, "hair from string"); eq(a.shirt, 5, "shirt floored")
  eq(avatar.optionName("hair", 7), "Bald", "option names")
  local r = avatar.random(function(lo, hi) return hi end)
  eq(r.mouth, 5, "random uses range")

  -- Scene: welcome, join, state, slap, kick, leave
  local net = fakeNet()
  local s = Plaza.new({ net = net, profile = { name = "Me" } })
  s:apply(json.decode('{"t":"welcome","id":"7","you":{"id":"7","name":"Me","avatar":{},"x":100,"y":100,"dir":1,"anim":"idle","game":null},"players":[{"id":"2","name":"Bob","avatar":{"head":1},"x":300,"y":120,"dir":-1,"anim":"idle","game":"Tetris"}],"world":{"w":1400,"h":800},"ball":[700,400,0,0,0,0,null]}'))
  eq(s.myId, "7", "my id"); eq(s.players["2"].game, "Tetris", "remote game"); eq(s.me.game, nil, "null game is nil")
  eq(s.count, 2, "count after welcome")
  s:apply({ t = "join", player = { id = "3", name = "Carol", avatar = {}, x = 50, y = 60 } })
  ok(s.players["3"], "joined player present")
  s:apply({ t = "state", p = { { "2", 320, 130, 1, "run" }, { "7", 999, 999, 1, "run" } }, b = { 710, 400, 0, 50, 0, 0, "2" } })
  eq(s.players["2"].tx, 320, "remote target updated"); eq(s.me.x, 100, "own position not overwritten by snapshot")
  eq(s.ball.vx, 50, "ball velocity from snapshot")
  s:apply({ t = "slap", from = "2", to = "7", dir = -1 })
  ok(s.vx < 0, "slap pushes me away"); eq(s.me.anim, "hit", "hit anim")
  s:apply({ t = "leave", id = "3" })
  eq(s.players["3"], nil, "left player removed")
  s:apply({ t = "game", id = "2", game = json.null })
  eq(s.players["2"].game, nil, "game cleared")

  -- Local physics: run right, hop, stay in world
  s.time = 10
  s.me.hitUntil = 0; s.vx, s.vy = 0, 0
  for _ = 1, 60 do Plaza.stepLocal(s, 1 / 60, 1, 0) end
  ok(s.me.x > 150, "ran to the right (" .. s.me.x .. ")"); eq(s.me.dir, 1, "facing right"); eq(s.me.anim, "run", "run anim")
  s.me.vz = 330
  local maxZ = 0
  for _ = 1, 90 do Plaza.stepLocal(s, 1 / 60, 0, 0); maxZ = math.max(maxZ, s.me.z) end
  ok(maxZ > 40, "hop reached height (" .. maxZ .. ")"); eq(s.me.z, 0, "landed"); eq(s.me.anim, "idle", "idle after landing")
  s.me.x = 5
  for _ = 1, 60 do Plaza.stepLocal(s, 1 / 60, -1, 0) end
  eq(s.me.x, 0, "clamped at left wall")

  -- Remote interpolation moves towards targets
  s.players["2"].x = 0; s.players["2"].tx = 400
  for _ = 1, 30 do Plaza.stepRemotes(s, 1 / 60) end
  ok(s.players["2"].x > 300, "remote eased towards target")

  -- Ball prediction keeps rolling and settles on the ground
  s.ball.vz = 200
  for _ = 1, 120 do Plaza.stepBall(s, 1 / 60) end
  ok(s.ball.x > 710, "ball rolled on"); eq(s.ball.tz, 0, "ball back on the ground")

  -- Camera: zoom shrinks as players spread out, never below 0.28
  s.players = { ["7"] = s.me, ["2"] = s.players["2"] }
  s.me.x, s.me.y = 100, 100; s.players["2"].x, s.players["2"].y = 200, 150
  s.ball.x, s.ball.y = 150, 120
  Plaza.updateCamera(s, 0, 1280, 720)
  local tightZoom = s.cam.zoom
  s.players["2"].x, s.players["2"].y = 3000, 2000
  Plaza.updateCamera(s, 0, 1280, 720)
  ok(s.cam.zoom < tightZoom, "zoomed out for a spread crowd"); ok(s.cam.zoom >= 0.28, "zoom floor")
  eq(tightZoom, 1.0, "close crowd uses full zoom")

  -- Actions: A kicks when near the ball, slaps otherwise
  s.me.x, s.me.y = 150, 120; s.ball.x, s.ball.y = 160, 120
  net.sent = {}
  s:action("a"); eq(net.sent[1].t, "kick", "kick when near ball")
  s.ball.x = 900
  s:action("a"); eq(net.sent[2].t, "slap", "slap when ball far")
  s:action("x"); eq(net.sent[3].t, "jump", "jump sends jump"); ok(s.me.vz > 0, "jump sets vertical speed")

  -- Palette detection from an EmulationStation settings file
  local tmp = os.tmpname()
  local f = io.open(tmp, "w"); f:write('<config>\n<string name="subset.colorset" value="dark" />\n</config>'); f:close()
  eq(ui.detectThemeMode(tmp), "dark", "dark set detected")
  f = io.open(tmp, "w"); f:write('<config><string name="subset.colorset" value="sky" /></config>'); f:close()
  eq(ui.detectThemeMode(tmp), "light", "other sets map to light")
  os.remove(tmp)
  eq(ui.detectThemeMode("/nonexistent/es_settings.cfg"), nil, "missing file gives nil")
  ui.setPalette("dark"); eq(ui.mode, "dark", "palette switch"); ui.setPalette("light")

  -- Embedded install files are present and look right
  local emb = require("src.embedded")
  ok(emb.hook:find("^#!/bin/bash"), "embedded hook has a shebang")
  ok(emb.esSystems:find("<name>plaza</name>"), "embedded system file names the plaza system")
  ok(emb.logo:find("<svg"), "embedded logo is an svg")
  ok(emb.gamelist:find("Plaza.love"), "embedded gamelist points at the client")
  ok(emb.ports:find("^#!/bin/bash") and emb.ports:find("install%-batocera%.sh") and emb.ports:find("Plaza%.love"), "embedded Ports script installs from the theme and launches the client")
  local config = require("src.config")
  ok(config.defaults.config.host == "maglev.proxy.rlwy.net" and config.defaults.config.tcpPort == 28071, "public server is the default game address")
  ok(config.defaults.config.presenceUrl:find("^https://"), "public presence URL is the default")

  -- Welcome hands over the presence URL
  local got
  local s2 = Plaza.new({ net = fakeNet(), profile = { name = "Me" }, onPresence = function(u) got = u end })
  s2:apply({ t = "welcome", id = "1", you = { id = "1", name = "Me", avatar = {}, x = 1, y = 1 }, players = {}, world = { w = 100, h = 100 }, presence = "https://p.example" })
  eq(got, "https://p.example", "presence url delivered")

  -- Keyboard widget
  local kb = ui.newKeyboard("", 5)
  kb:input("a"); kb:input("right"); kb:input("a"); kb:input("x"); kb:input("a")
  eq(kb.value, "ABb", "keyboard types and toggles case")
  kb:input("b"); eq(kb.value, "AB", "backspace")
  kb:input("start"); eq(kb.done, true, "start finishes")

  return checks
end

return T
