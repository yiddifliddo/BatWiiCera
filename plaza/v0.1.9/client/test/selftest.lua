-- BatWiiCera Plaza - client self-test
-- Version 0.1.9 | Author: yiddifliddo | Licence: MIT
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
  s:apply(json.decode('{"t":"welcome","id":"7","you":{"id":"7","name":"Me","avatar":{},"x":100,"y":100,"dir":0,"anim":"idle","game":null},"players":[{"id":"2","name":"Bob","avatar":{"head":1},"x":300,"y":120,"dir":180,"anim":"idle","game":"Tetris"}],"pitch":{"w":2400,"h":1500,"apron":320,"goalW":300,"goalDepth":70},"score":{"left":1,"right":0},"ball":[700,400,0,0,0,0,null]}'))
  eq(s.myId, "7", "my id"); eq(s.players["2"].game, "Tetris", "remote game"); eq(s.me.game, nil, "null game is nil")
  eq(s.count, 2, "count after welcome"); eq(s.pitch.w, 2400, "pitch width"); eq(s.score.left, 1, "score from welcome")
  s:apply({ t = "join", player = { id = "3", name = "Carol", avatar = {}, x = 50, y = 60 } })
  ok(s.players["3"], "joined player present")
  s.clock = 100
  s:apply({ t = "state", p = { { "2", 320, 130, 90, "run", 200, 0 }, { "7", 999, 999, 0, "run", 0, 0 } }, b = { 710, 400, 0, 50, 0, 0, "2" } })
  eq(#s.players["2"].snaps, 1, "snapshot buffered"); eq(s.players["2"].snaps[1].vx, 200, "snapshot carries velocity")
  eq(s.me.x, 100, "own position not overwritten by snapshot")
  eq(s.ball.vx, 50, "ball velocity from snapshot")
  s:apply({ t = "slap", from = "2", to = "7", dir = -1, angle = 180 })
  ok(s.vx < 0, "slap pushes me away along the slapper's facing"); ok(s.me.squash > 0, "impact squash")
  s.time = 0.1; Plaza.stepLocal(s, 1 / 60, 0, 0); eq(s.me.anim, "hit", "hit anim")
  s:apply({ t = "goal", side = "left", by = "2", score = { left = 2, right = 0 } })
  eq(s.score.left, 2, "goal updates the score"); ok(s.goalBanner and s.goalBanner.who == "Bob", "goal banner names the scorer"); ok(#s.particles > 0, "confetti")
  s:apply({ t = "leave", id = "3" })
  eq(s.players["3"], nil, "left player removed")
  s:apply({ t = "game", id = "2", game = json.null })
  eq(s.players["2"].game, nil, "game cleared")

  -- Local physics: accelerate right, hop, stay inside the stands
  s.time = 10
  s.me.hitUntil = 0; s.vx, s.vy = 0, 0; s.particles = {}
  Plaza.stepLocal(s, 1 / 60, 1, 0)
  ok(s.vx > 0 and s.vx < Plaza.MAX_SPEED * 0.5, "accelerates rather than jumping to full speed (" .. s.vx .. ")")
  for _ = 1, 60 do Plaza.stepLocal(s, 1 / 60, 1, 0) end
  ok(s.me.x > 150, "ran to the right (" .. s.me.x .. ")"); ok(math.abs(s.vx - Plaza.MAX_SPEED) < 1, "reached top speed"); eq(s.me.anim, "run", "run anim")
  ok(math.abs(s.me.facing) < 1, "facing right (" .. s.me.facing .. ")")
  -- reversing hard skids first
  Plaza.stepLocal(s, 1 / 60, -1, 0); eq(s.me.anim, "skid", "skid when reversing at speed")
  for _ = 1, 40 do Plaza.stepLocal(s, 1 / 60, 0, -1) end
  ok(math.abs(s.me.facing - 270) < 2, "turned to face up (" .. s.me.facing .. ")")
  s.vx, s.vy = 0, 0
  for _ = 1, 30 do Plaza.stepLocal(s, 1 / 60, 0, 0) end
  eq(s.me.anim, "idle", "idle once stopped")
  s.me.vz = 340
  local maxZ = 0
  for _ = 1, 90 do Plaza.stepLocal(s, 1 / 60, 0, 0); maxZ = math.max(maxZ, s.me.z) end
  ok(maxZ > 40, "hop reached height (" .. maxZ .. ")"); eq(s.me.z, 0, "landed"); ok(s.me.landed, "landing flagged for a dust puff")
  s.me.x = -300; s.vx = 0
  for _ = 1, 90 do Plaza.stepLocal(s, 1 / 60, -1, 0) end
  eq(s.me.x, -s.pitch.apron, "clamped at the edge of the stands")

  -- Remote interpolation: renders between snapshots a tenth of a second back
  local r2 = s.players["2"]
  r2.snaps = {}; r2.x, r2.y = 0, 0
  s.clock = 200.0; s:apply({ t = "state", p = { { "2", 0, 0, 0, "run", 300, 0 } } })
  s.clock = 200.1; s:apply({ t = "state", p = { { "2", 30, 0, 0, "run", 300, 0 } } })
  s.clock = 200.2; s:apply({ t = "state", p = { { "2", 60, 0, 0, "run", 300, 0 } } })
  s.clock = 200.2
  for _ = 1, 40 do Plaza.stepRemotes(s, 1 / 60) end
  ok(math.abs(r2.x - 30) < 3, "remote rendered at the delayed snapshot (" .. r2.x .. ")")
  s.clock = 200.45
  for _ = 1, 40 do Plaza.stepRemotes(s, 1 / 60) end
  ok(r2.x > 60 and r2.x <= 60 + 300 * 0.25 + 1, "extrapolates with velocity when snapshots stop (" .. r2.x .. ")")
  ok(r2.speed > 0.9, "remote speed drives the run cycle")

  -- Ball prediction keeps rolling and settles on the ground
  s.ball.vz = 200
  for _ = 1, 120 do Plaza.stepBall(s, 1 / 60) end
  ok(s.ball.x > 710, "ball rolled on"); eq(s.ball.tz, 0, "ball back on the ground")

  -- Camera: follows me, zooms out for the ball, ignores far-away players
  s.players = { ["7"] = s.me, ["2"] = s.players["2"] }
  s.vx, s.vy = 0, 0
  s.me.x, s.me.y = 100, 100; s.players["2"].x, s.players["2"].y = 200, 150
  s.ball.x, s.ball.y = 150, 120
  Plaza.updateCamera(s, 0, 1280, 720)
  local tightZoom = s.cam.zoom
  s.ball.x, s.ball.y = 1200, 800
  Plaza.updateCamera(s, 0, 1280, 720)
  ok(s.cam.zoom < tightZoom, "zoomed out to keep the ball in frame"); ok(s.cam.zoom >= 0.42, "zoom floor")
  s.ball.x, s.ball.y = 150, 120
  s.players["2"].x, s.players["2"].y = 3000, 2000
  Plaza.updateCamera(s, 0, 1280, 720)
  eq(s.cam.zoom, tightZoom, "a player far away does not drag the camera out")
  s.vx = 200; Plaza.updateCamera(s, 0, 1280, 720)
  ok(s.cam.x > s.me.x, "look-ahead in the direction of travel")

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
  ok(emb.gamelist:find("Plaza%.sh") and emb.gamelist:find("plaza%-preview%.png"), "embedded gamelist points at the launcher with artwork")
  ok(emb.ports:find("^#!/bin/bash") and emb.ports:find("install%-batocera%.sh") and emb.ports:find("Plaza%.love"), "embedded Ports script installs from the theme and launches the client")
  local config = require("src.config")
  ok(config.defaults.config.host == "maglev.proxy.rlwy.net" and config.defaults.config.tcpPort == 28071, "public server is the default game address")
  ok(config.defaults.config.presenceUrl:find("^https://"), "public presence URL is the default")

  -- Welcome hands over the presence URL
  local got
  local s2 = Plaza.new({ net = fakeNet(), profile = { name = "Me" }, onPresence = function(u) got = u end })
  s2:apply({ t = "welcome", id = "1", you = { id = "1", name = "Me", avatar = {}, x = 1, y = 1 }, players = {}, world = { w = 100, h = 100 }, presence = "https://p.example" })
  eq(got, "https://p.example", "presence url delivered")

  -- Generated names: deterministic, clean, varied, identical to the server
  local names = require("src.names")
  eq(names.generate("abc", 0), "Calm Panda 1", "name matches the server's value")
  eq(names.generate("tok-x", 424242), "Fancy Kestrel 44", "name matches the server's value 2")
  local seen = {}
  for i = 0, 199 do seen[names.generate("someone", i)] = true end
  local distinct = 0; for _ in pairs(seen) do distinct = distinct + 1 end
  ok(distinct > 150, "seeds give varied names (" .. distinct .. " of 200)")
  ok(names.generate("x", 5):match("^%u%l+ %u%l+ %d+$"), "name shape Adjective Animal number")

  -- Keyboard widget (still used for the server address)
  local kb = ui.newKeyboard("", 5)
  kb:input("a"); kb:input("right"); kb:input("a"); kb:input("x"); kb:input("a")
  eq(kb.value, "ABb", "keyboard types and toggles case")
  kb:input("b"); eq(kb.value, "AB", "backspace")
  kb:input("start"); eq(kb.done, true, "start finishes")

  return checks
end

return T
