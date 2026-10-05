-- BatWiiCera Plaza - the room scene
-- Version 0.1.2 | Author: Dan Lee | Licence: MIT
--
-- Top-down plaza: every player is an upright figure standing on a tiled
-- floor at a ground position (x, y) with a hop height z. The camera frames
-- everyone and zooms out as the crowd grows. The ball is simulated by the
-- server; we interpolate towards its snapshots and predict between them.
--
-- The pure logic (applying server messages, local physics, camera maths)
-- lives in functions that take the scene table, so it can be exercised
-- without a window (see client/test/run.lua).

local json = require("src.json")
local avatar = require("src.avatar")
local ui = require("src.ui")
local input = require("src.input")

local M = {}
M.__index = M

local RUN_SPEED = 230
local HOP_V = 330
local GRAVITY = 1000
local SEND_HZ = 15
local SLAP_PUSH = 260
local KICK_RANGE = 60   -- keep <= server KICK_RANGE

function M.new(opts)
  local s = setmetatable({}, M)
  s.net = opts.net
  s.profile = opts.profile
  s.players = {}          -- id -> remote player
  s.me = nil              -- our own record (also in players once welcomed)
  s.myId = nil
  s.world = { w = 1400, h = 800 }
  s.ball = { x = 700, y = 400, z = 0, vx = 0, vy = 0, vz = 0, tx = 700, ty = 400, tz = 0, spin = 0, kicker = nil }
  s.cam = { x = 700, y = 400, zoom = 1, tx = 700, ty = 400, tzoom = 1 }
  s.time = 0
  s.sendAcc = 0
  s.status = "connecting"
  s.toast = nil
  s.toastUntil = 0
  s.count = 0
  s.font = nil
  s.leaveRequested = false
  s.onLeave = opts.onLeave
  s.onEdit = opts.onEdit
  s.vx, s.vy = 0, 0
  return s
end

-- Message handling -----------------------------------------------------------
local function newRemote(p)
  return {
    id = p.id, name = p.name or "Player", avatar = avatar.sanitize(p.avatar),
    x = p.x or 0, y = p.y or 0, z = 0, vz = 0, tx = p.x or 0, ty = p.y or 0,
    dir = p.dir or 1, anim = p.anim or "idle",
    game = (p.game ~= nil and p.game ~= json.null) and p.game or nil,
    hitUntil = 0, px = 0, py = 0, bob = 0
  }
end

function M:apply(msg)
  local t = msg.t
  if t == "welcome" then
    self.myId = msg.id
    self.players = {}
    for _, p in ipairs(msg.players or {}) do self.players[p.id] = newRemote(p) end
    local me = newRemote(msg.you)
    me.isMe = true
    self.me = me
    self.players[me.id] = me
    if msg.world then self.world.w, self.world.h = msg.world.w or self.world.w, msg.world.h or self.world.h end
    if msg.ball then self:applyBall(msg.ball, true) end
    self.status = "connected"
    self.count = 0
    for _ in pairs(self.players) do self.count = self.count + 1 end
    self.cam.x, self.cam.y = me.x, me.y
  elseif t == "join" then
    local p = msg.player
    if p and p.id ~= self.myId then
      self.players[p.id] = newRemote(p)
      self:say(p.name .. " joined")
    end
  elseif t == "leave" then
    local p = self.players[msg.id]
    if p and not p.isMe then
      self.players[msg.id] = nil
      self:say(p.name .. " left")
    end
  elseif t == "world" then
    if msg.w then self.world.w = msg.w end
    if msg.h then self.world.h = msg.h end
    if msg.n then self.count = msg.n end
  elseif t == "state" then
    for _, row in ipairs(msg.p or {}) do
      local id, x, y, dir, anim = row[1], row[2], row[3], row[4], row[5]
      local p = self.players[id]
      if p and not p.isMe then
        p.tx, p.ty = x, y
        p.dir = dir
        if anim ~= "jump" then p.anim = anim end
      end
    end
    if msg.b then self:applyBall(msg.b, false) end
  elseif t == "jump" then
    local p = self.players[msg.id]
    if p and not p.isMe and p.z <= 0 then p.vz = HOP_V; p.anim = "jump" end
  elseif t == "slap" then
    local from, to = self.players[msg.from], msg.to and self.players[msg.to] or nil
    if from then from.slapUntil = self.time + 0.25 end
    if to then
      to.hitUntil = self.time + 0.45
      to.anim = "hit"
      if to.isMe then
        self.vx = self.vx + (msg.dir or 1) * SLAP_PUSH
        if self.me.z <= 0 then self.me.vz = 150 end
      else
        to.px = (msg.dir or 1) * SLAP_PUSH
      end
    end
  elseif t == "kick" then
    if msg.ball then self:applyBall(msg.ball, true) end
    local p = self.players[msg.id]
    if p then p.kickUntil = self.time + 0.25 end
  elseif t == "game" then
    local p = self.players[msg.id]
    if p then p.game = (msg.game ~= nil and msg.game ~= json.null) and msg.game or nil end
  elseif t == "player" then
    local p = self.players[msg.player.id]
    if p then
      p.name = msg.player.name
      p.avatar = avatar.sanitize(msg.player.avatar)
      p.game = (msg.player.game ~= nil and msg.player.game ~= json.null) and msg.player.game or nil
    end
  elseif t == "error" then
    self.status = "error"
    self.errorMessage = msg.message or msg.code or "error"
  end
end

function M:applyBall(b, snap)
  local ball = self.ball
  ball.tx, ball.ty, ball.tz = b[1], b[2], b[3]
  ball.vx, ball.vy, ball.vz = b[4], b[5], b[6]
  ball.kicker = b[7]
  if snap or math.abs(ball.x - ball.tx) > 120 or math.abs(ball.y - ball.ty) > 120 then
    ball.x, ball.y, ball.z = ball.tx, ball.ty, ball.tz
  end
end

function M:say(text)
  self.toast = text
  self.toastUntil = self.time + 2.5
end

-- Simulation -------------------------------------------------------------------
local function clamp(v, lo, hi) if v < lo then return lo elseif v > hi then return hi else return v end end

-- Local movement step; `ax, ay` is the input vector. Pure: no love.* calls.
function M.stepLocal(s, dt, ax, ay)
  local me = s.me
  if not me then return end
  local hit = s.time < (me.hitUntil or 0)
  local speed = hit and RUN_SPEED * 0.3 or RUN_SPEED
  local tvx, tvy = ax * speed, ay * speed
  -- blend towards target velocity (knockback decays into it)
  local k = 1 - math.exp(-dt * 12)
  s.vx = s.vx + (tvx - s.vx) * k
  s.vy = s.vy + (tvy - s.vy) * k
  me.x = clamp(me.x + s.vx * dt, 0, s.world.w)
  me.y = clamp(me.y + s.vy * dt, 0, s.world.h)
  if math.abs(ax) > 0.05 then me.dir = ax > 0 and 1 or -1 end
  -- hop
  if me.z > 0 or me.vz > 0 then
    me.vz = me.vz - GRAVITY * dt
    me.z = me.z + me.vz * dt
    if me.z <= 0 then me.z, me.vz = 0, 0 end
  end
  if hit then me.anim = "hit"
  elseif me.z > 0 then me.anim = "jump"
  elseif math.abs(ax) + math.abs(ay) > 0.1 then me.anim = "run"
  else me.anim = "idle" end
  me.moving = math.abs(ax) + math.abs(ay) > 0.1
  me.mvx, me.mvy = ax, ay
end

function M.stepRemotes(s, dt)
  for id, p in pairs(s.players) do
    if not p.isMe then
      -- knockback impulse
      if p.px ~= 0 then p.tx = p.tx + p.px * dt; p.px = p.px * math.max(0, 1 - dt * 6); if math.abs(p.px) < 5 then p.px = 0 end end
      local k = 1 - math.exp(-dt * 10)
      p.x = p.x + (p.tx - p.x) * k
      p.y = p.y + (p.ty - p.y) * k
      if p.z > 0 or p.vz > 0 then
        p.vz = p.vz - GRAVITY * dt
        p.z = p.z + p.vz * dt
        if p.z <= 0 then p.z, p.vz = 0, 0; if p.anim == "jump" then p.anim = "idle" end end
      end
      if s.time > (p.hitUntil or 0) and p.anim == "hit" then p.anim = "idle" end
    end
  end
end

function M.stepBall(s, dt)
  local b = s.ball
  -- predict with last known velocity, then ease towards the server position
  b.tx = b.tx + b.vx * dt
  b.ty = b.ty + b.vy * dt
  local k = 1 - math.exp(-dt * 8)
  b.x = b.x + (b.tx - b.x) * k
  b.y = b.y + (b.ty - b.y) * k
  b.vz = b.vz - 900 * dt
  b.tz = math.max(0, b.tz + b.vz * dt)
  if b.tz == 0 and b.vz < 0 then b.vz = math.abs(b.vz) > 60 and -b.vz * 0.55 or 0 end
  b.z = b.z + (b.tz - b.z) * k
  b.spin = b.spin + (b.vx / 14) * dt
end

-- Camera: fit everyone (and the ball) with margins; zoom out as the crowd grows.
function M.updateCamera(s, dt, sw, sh)
  local minx, miny, maxx, maxy = math.huge, math.huge, -math.huge, -math.huge
  local n = 0
  for _, p in pairs(s.players) do
    minx = math.min(minx, p.x); maxx = math.max(maxx, p.x)
    miny = math.min(miny, p.y); maxy = math.max(maxy, p.y)
    n = n + 1
  end
  if n == 0 then return end
  local b = s.ball
  minx = math.min(minx, b.x); maxx = math.max(maxx, b.x)
  miny = math.min(miny, b.y); maxy = math.max(maxy, b.y)
  local marginX, marginY = 320, 300
  local bw = (maxx - minx) + marginX * 2
  local bh = (maxy - miny) + marginY * 2
  local zoom = math.min(sw / bw, sh / bh)
  zoom = clamp(zoom, 0.28, 1.0)
  local cx = (minx + maxx) / 2
  local cy = (miny + maxy) / 2 - 40
  s.cam.tx, s.cam.ty, s.cam.tzoom = cx, cy, zoom
  local k = 1 - math.exp(-dt * 3)
  s.cam.x = s.cam.x + (s.cam.tx - s.cam.x) * k
  s.cam.y = s.cam.y + (s.cam.ty - s.cam.y) * k
  s.cam.zoom = s.cam.zoom + (s.cam.tzoom - s.cam.zoom) * k
  if dt == 0 then s.cam.x, s.cam.y, s.cam.zoom = cx, cy, zoom end
end

function M:nearBall()
  if not self.me then return false end
  local dx, dy = self.ball.x - self.me.x, self.ball.y - self.me.y
  return (dx * dx + dy * dy) <= KICK_RANGE * KICK_RANGE
end

-- LÖVE callbacks -------------------------------------------------------------
function M:update(dt)
  self.time = self.time + dt
  local now = love.timer.getTime()
  self.net:update(now)
  for _, msg in ipairs(self.net:poll()) do self:apply(msg) end
  if self.net.state == "failed" and self.status ~= "error" then self.status = "reconnecting" end
  if self.net.state == "connected" and self.status == "reconnecting" then self.status = "connecting" end

  local ax, ay = input.axis()
  M.stepLocal(self, dt, ax, ay)
  M.stepRemotes(self, dt)
  M.stepBall(self, dt)
  M.updateCamera(self, dt, love.graphics.getWidth(), love.graphics.getHeight())

  if self.me and self.net.state == "connected" then
    self.sendAcc = self.sendAcc + dt
    if self.sendAcc >= 1 / SEND_HZ then
      self.sendAcc = 0
      self.net:send({ t = "move", x = math.floor(self.me.x + 0.5), y = math.floor(self.me.y + 0.5), dir = self.me.dir, anim = self.me.anim })
    end
  end
end

function M:action(a)
  if a == "x" then
    if self.me and self.me.z <= 0 then
      self.me.vz = HOP_V
      self.net:send({ t = "jump" })
    end
  elseif a == "a" then
    if not self.me then return end
    if self:nearBall() then
      local dx, dy = self.me.mvx or 0, self.me.mvy or 0
      if math.abs(dx) + math.abs(dy) < 0.1 then dx, dy = self.ball.x - self.me.x, self.ball.y - self.me.y end
      self.net:send({ t = "kick", dx = dx, dy = dy, power = 1 })
      self.me.kickUntil = self.time + 0.25
    else
      self.net:send({ t = "slap" })
      self.me.slapUntil = self.time + 0.25
    end
  elseif a == "b" then
    if self.onLeave then self.onLeave() end
  elseif a == "start" then
    if self.onEdit then self.onEdit() end
  end
end

-- Drawing ----------------------------------------------------------------------
local function drawFloor(s, sw, sh)
  local lg = love.graphics
  local w, h = s.world.w, s.world.h
  -- plaza slab
  ui.col(ui.colors.shadow); lg.rectangle("fill", -14, -8, w + 28, h + 30, 30, 30)
  ui.col(ui.colors.floor); lg.rectangle("fill", -20, -20, w + 40, h + 40, 30, 30)
  -- diamond tiles
  local tile = 80
  ui.col(ui.colors.tile)
  for y = 0, h, tile do
    for x = 0, w, tile do
      local off = (math.floor(y / tile) % 2 == 0) and 0 or tile / 2
      local cx, cy = x + off, y + tile / 2
      lg.polygon("fill", cx, cy - tile * 0.5, cx + tile * 0.5, cy, cx, cy + tile * 0.5, cx - tile * 0.5, cy)
    end
  end
  -- blue edge like the theme's bar
  lg.setLineWidth(6); ui.col(ui.colors.accent); lg.rectangle("line", -20, -20, w + 40, h + 40, 30, 30); lg.setLineWidth(1)
end

local function drawBall(s)
  local lg = love.graphics
  local b = s.ball
  local r = 14
  ui.col({ 0, 0, 0, 0.14 }); lg.ellipse("fill", b.x, b.y + 2, r * (1 - b.z / 600), r * 0.45 * (1 - b.z / 600))
  local by = b.y - r - b.z
  ui.col({ 1, 1, 1 }); lg.circle("fill", b.x, by, r)
  ui.col({ 0.15, 0.15, 0.18 })
  for i = 0, 4 do
    local a = b.spin + i * (2 * math.pi / 5)
    lg.circle("fill", b.x + math.cos(a) * r * 0.55, by + math.sin(a) * r * 0.55, r * 0.22)
  end
  lg.setLineWidth(2); ui.col({ 0.3, 0.3, 0.33 }); lg.circle("line", b.x, by, r); lg.setLineWidth(1)
end

local function drawPlayer(s, p, zoom)
  local lg = love.graphics
  local scale = 1
  local y = p.y - (p.z or 0)
  -- slap / kick arm swing hint: tilt the whole figure briefly
  local tilt = 0
  if s.time < (p.slapUntil or 0) then tilt = (p.dir or 1) * 0.18 end
  if s.time < (p.kickUntil or 0) then tilt = (p.dir or 1) * -0.12 end
  lg.push()
  lg.translate(p.x, y)
  lg.rotate(tilt)
  avatar.draw(p.avatar, 0, 0, scale, p.dir, p.anim, s.time + (tonumber(p.id) or 0))
  lg.pop()
  -- labels (counter-scaled so they stay readable when zoomed out)
  local labelScale = math.max(1, 0.9 / zoom)
  lg.push()
  lg.translate(p.x, y - avatar.height(scale) - 8)
  lg.scale(labelScale, labelScale)
  local nameColor = p.isMe and ui.colors.accentD or ui.colors.text
  ui.bubble(p.name, 0, 0, ui.fonts.small, p.isMe and ui.colors.myBubble or ui.colors.bubble, nameColor)
  if p.game then
    ui.bubble("Playing " .. p.game, 0, -28, ui.fonts.label, ui.colors.accent, ui.colors.white)
  end
  lg.pop()
end

function M:draw()
  local lg = love.graphics
  local sw, sh = lg.getWidth(), lg.getHeight()
  ui.backdrop(sw, sh)

  lg.push()
  lg.translate(sw / 2, sh / 2)
  lg.scale(self.cam.zoom, self.cam.zoom)
  lg.translate(-self.cam.x, -self.cam.y)
  drawFloor(self, sw, sh)

  -- depth sort by ground y
  local list = {}
  for _, p in pairs(self.players) do list[#list + 1] = p end
  table.sort(list, function(a, b) return a.y < b.y end)
  local ballDrawn = false
  for _, p in ipairs(list) do
    if not ballDrawn and self.ball.y < p.y then drawBall(self); ballDrawn = true end
    drawPlayer(self, p, self.cam.zoom)
  end
  if not ballDrawn then drawBall(self) end
  lg.pop()

  -- HUD
  ui.panel(16, 14, 250, 54, 18)
  ui.text(string.format("%d in the plaza", self.count), 30, 28, 230, "left", ui.fonts.body)
  if self.status ~= "connected" then
    local msg = (self.status == "error") and (self.errorMessage or "Error")
      or (self.status == "reconnecting") and "Reconnecting..." or "Connecting..."
    ui.panel(sw / 2 - 180, sh / 2 - 40, 360, 80)
    ui.text(msg, sw / 2 - 170, sh / 2 - 14, 340, "center", ui.fonts.title, ui.colors.text2)
  end
  if self.toast and self.time < self.toastUntil then
    ui.bubble(self.toast, sw / 2, 60, ui.fonts.body)
  end
  local prompts = { { "A", self:nearBall() and "Kick" or "Slap" }, { "X", "Jump" }, { "START", "Avatar" }, { "B", "Leave" } }
  ui.prompts(prompts, sh - 34, sw)
end

return M
