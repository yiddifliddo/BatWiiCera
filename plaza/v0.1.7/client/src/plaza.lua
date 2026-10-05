-- BatWiiCera Plaza - the stadium scene
-- Version 0.1.7 | Author: yiddifliddo | Licence: MIT
--
-- A football stadium seen from the stands: a full pitch with lines, goals
-- and nets, a running track, tiered stands full of colour, floodlights and
-- a scoreboard. Players are upright figures at a ground position (x, y)
-- with a hop height z. Movement has acceleration, braking and skids, facing
-- is eight-way from the stick, other players are rendered a tenth of a
-- second behind the live server state and interpolated between snapshots,
-- and the camera glides after you with look-ahead.
--
-- The pure logic (applying server messages, local physics, interpolation,
-- camera maths) lives in functions that take the scene table, so it can be
-- exercised without a window (see client/test/run.lua).

local json = require("src.json")
local avatar = require("src.avatar")
local ui = require("src.ui")
local input = require("src.input")

local M = {}
M.__index = M

-- movement
local MAX_SPEED = 270
local ACCEL = 1500          -- units/s^2 towards the stick
local BRAKE = 1900          -- when the stick is released
local SKID_BRAKE = 2600     -- when reversing against the current velocity
local HOP_V = 340
local GRAVITY = 1050
local SEND_HZ = 15
local SLAP_PUSH = 280
local KICK_RANGE = 60       -- keep <= server KICK_RANGE
local RENDER_DELAY = 0.1    -- seconds behind the newest snapshot for remotes
local MAX_EXTRAPOLATE = 0.25

-- stadium geometry defaults (the server sends the live values)
local PITCH = { w = 2400, h = 1500, apron = 320, goalW = 300, goalDepth = 70 }

M.PITCH_DEFAULTS = PITCH
M.MAX_SPEED = MAX_SPEED

local function clamp(v, lo, hi) if v < lo then return lo elseif v > hi then return hi else return v end end
local function lerp(a, b, k) return a + (b - a) * k end
local function angleLerp(a, b, k)
  local d = (b - a + 180) % 360 - 180
  return (a + d * k) % 360
end

function M.new(opts)
  local s = setmetatable({}, M)
  s.net = opts.net
  s.profile = opts.profile
  s.players = {}
  s.me = nil
  s.myId = nil
  s.pitch = { w = PITCH.w, h = PITCH.h, apron = PITCH.apron, goalW = PITCH.goalW, goalDepth = PITCH.goalDepth }
  s.world = s.pitch   -- older code paths read world.w / world.h
  s.score = { left = 0, right = 0 }
  s.ball = { x = PITCH.w / 2, y = PITCH.h / 2, z = 0, vx = 0, vy = 0, vz = 0, tx = PITCH.w / 2, ty = PITCH.h / 2, tz = 0, spin = 0, kicker = nil }
  s.cam = { x = PITCH.w / 2, y = PITCH.h / 2, zoom = 0.8, tx = PITCH.w / 2, ty = PITCH.h / 2, tzoom = 0.8 }
  s.time = 0
  s.clock = 0            -- wall clock used for snapshot timing (injectable in tests)
  s.sendAcc = 0
  s.status = "connecting"
  s.toast = nil
  s.toastUntil = 0
  s.count = 0
  s.leaveRequested = false
  s.onLeave = opts.onLeave
  s.onEdit = opts.onEdit
  s.onPresence = opts.onPresence
  s.vx, s.vy = 0, 0
  s.particles = {}
  s.goalFlash = 0
  s.goalBanner = nil
  s.crowd = nil          -- cached stand dots, rebuilt when the pitch changes
  return s
end

-- Message handling -----------------------------------------------------------
local function newRemote(p)
  return {
    id = p.id, name = p.name or "Player", avatar = avatar.sanitize(p.avatar),
    x = p.x or 0, y = p.y or 0, z = 0, vz = 0, vx = 0, vy = 0,
    facing = tonumber(p.dir) or 0, anim = p.anim or "idle",
    game = (p.game ~= nil and p.game ~= json.null) and p.game or nil,
    hitUntil = 0, px = 0, py = 0, snaps = {}, seed = (tonumber(p.id) or 0) * 0.37,
    speed = 0, squash = 0, wasAirborne = false
  }
end

local function applyPitch(s, p)
  if type(p) ~= "table" then return end
  for _, k in ipairs({ "w", "h", "apron", "goalW", "goalDepth" }) do
    if tonumber(p[k]) then s.pitch[k] = tonumber(p[k]) end
  end
  s.crowd = nil
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
    if msg.pitch then applyPitch(self, msg.pitch)
    elseif msg.world then applyPitch(self, { w = msg.world.w, h = msg.world.h }) end
    if msg.score then self.score.left, self.score.right = msg.score.left or 0, msg.score.right or 0 end
    if msg.ball then self:applyBall(msg.ball, true) end
    if type(msg.presence) == "string" and msg.presence ~= "" and self.onPresence then self.onPresence(msg.presence) end
    self.status = "connected"
    self.count = 0
    for _ in pairs(self.players) do self.count = self.count + 1 end
    self.cam.x, self.cam.y = me.x, me.y
    self.cam.tx, self.cam.ty = me.x, me.y
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
    applyPitch(self, { w = msg.w, h = msg.h, apron = msg.apron })
    if msg.n then self.count = msg.n end
    if msg.score then self.score.left, self.score.right = msg.score.left or 0, msg.score.right or 0 end
  elseif t == "state" then
    local now = self.clock
    for _, row in ipairs(msg.p or {}) do
      local id, x, y, dir, anim, vx, vy = row[1], row[2], row[3], row[4], row[5], row[6], row[7]
      local p = self.players[id]
      if p and not p.isMe then
        local snaps = p.snaps
        snaps[#snaps + 1] = { t = now, x = x, y = y, vx = vx or 0, vy = vy or 0, facing = tonumber(dir) or 0, anim = anim or "idle" }
        if #snaps > 12 then table.remove(snaps, 1) end
      end
    end
    if msg.b then self:applyBall(msg.b, false) end
  elseif t == "jump" then
    local p = self.players[msg.id]
    if p and not p.isMe and p.z <= 0 then p.vz = HOP_V; p.anim = "jump"; p.jumpUntil = self.time + 0.9 end
  elseif t == "slap" then
    local from, to = self.players[msg.from], msg.to and self.players[msg.to] or nil
    if from then from.slapAt = self.time end
    if to then
      to.hitUntil = self.time + 0.5
      local dir = tonumber(msg.dir) or 1
      local ang = (msg.angle ~= nil) and tonumber(msg.angle) or ((dir < 0) and 180 or 0)
      local kx, ky = math.cos(math.rad(ang)), math.sin(math.rad(ang))
      if to.isMe then
        self.vx = self.vx + kx * SLAP_PUSH
        self.vy = self.vy + ky * SLAP_PUSH
        if self.me.z <= 0 then self.me.vz = 150 end
        self.me.squash = 0.18
      else
        to.px, to.py = kx * SLAP_PUSH, ky * SLAP_PUSH
        to.squash = 0.18
      end
      self:puff(to.x, to.y, 6)
    end
  elseif t == "kick" then
    if msg.ball then self:applyBall(msg.ball, true) end
    local p = self.players[msg.id]
    if p then p.kickAt = self.time end
  elseif t == "goal" then
    if msg.score then self.score.left, self.score.right = msg.score.left or 0, msg.score.right or 0 end
    local by = msg.by and self.players[msg.by] or nil
    self.goalBanner = { text = "GOAL!", who = by and by.name or nil, until_ = self.time + 3.2, side = msg.side }
    self.goalFlash = 1
    local gx = (msg.side == "left") and 0 or self.pitch.w
    self:confetti(gx, self.pitch.h / 2, 90)
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

-- Particles ------------------------------------------------------------------
function M:puff(x, y, n, spread)
  spread = spread or 60
  for i = 1, n or 5 do
    local a = math.random() * 2 * math.pi
    local v = 20 + math.random() * spread
    self.particles[#self.particles + 1] = { kind = "dust", x = x + math.random(-6, 6), y = y + math.random(-3, 3), z = 2, vx = math.cos(a) * v, vy = math.sin(a) * v * 0.4, vz = 30 + math.random() * 50, life = 0.45 + math.random() * 0.3, age = 0, size = 4 + math.random() * 5 }
  end
  if #self.particles > 320 then for _ = 1, #self.particles - 320 do table.remove(self.particles, 1) end end
end

function M:confetti(x, y, n)
  local palette = ui.colors.crowd
  for i = 1, n do
    local a = -math.pi / 2 + (math.random() - 0.5) * 1.6
    local v = 220 + math.random() * 320
    self.particles[#self.particles + 1] = { kind = "confetti", x = x + math.random(-40, 40), y = y + math.random(-120, 120), z = 20, vx = math.cos(a) * v * 0.6, vy = (math.random() - 0.5) * 120, vz = math.sin(-a) * v, life = 1.8 + math.random() * 1.2, age = 0, size = 5 + math.random() * 4, color = palette[math.random(#palette)], spin = math.random() * 6 }
  end
end

function M.stepParticles(s, dt)
  local keep = {}
  for _, p in ipairs(s.particles) do
    p.age = p.age + dt
    if p.age < p.life then
      p.x = p.x + p.vx * dt; p.y = p.y + p.vy * dt
      p.vz = p.vz - ((p.kind == "confetti") and 420 or 160) * dt
      p.z = math.max(0, p.z + p.vz * dt)
      if p.kind == "confetti" then p.vx = p.vx * (1 - dt * 1.5); p.spin = p.spin + dt * 7 end
      keep[#keep + 1] = p
    end
  end
  s.particles = keep
end

-- Simulation -------------------------------------------------------------------
local function bounds(s)
  local p = s.pitch
  return -p.apron, -p.apron, p.w + p.apron, p.h + p.apron
end

-- Local movement step; `ax, ay` is the input vector. Pure: no love.* calls.
function M.stepLocal(s, dt, ax, ay)
  local me = s.me
  if not me then return end
  local hit = s.time < (me.hitUntil or 0)
  local mag = math.sqrt(ax * ax + ay * ay)
  if mag > 1 then ax, ay = ax / mag, ay / mag; mag = 1 end
  local wantSpeed = (hit and MAX_SPEED * 0.3 or MAX_SPEED) * mag
  local tvx, tvy = 0, 0
  if mag > 0.05 then tvx, tvy = ax / mag * wantSpeed, ay / mag * wantSpeed end
  local speed = math.sqrt(s.vx * s.vx + s.vy * s.vy)
  -- choose the rate: accelerate, brake, or skid when reversing
  local dot = (speed > 1) and ((s.vx * ax + s.vy * ay) / speed) or 1
  local rate = ACCEL
  local skidding = false
  if mag <= 0.05 then rate = BRAKE
  elseif dot < -0.3 and speed > MAX_SPEED * 0.45 then rate = SKID_BRAKE; skidding = true end
  local dvx, dvy = tvx - s.vx, tvy - s.vy
  local dlen = math.sqrt(dvx * dvx + dvy * dvy)
  local step = rate * dt
  if dlen <= step then s.vx, s.vy = tvx, tvy else s.vx = s.vx + dvx / dlen * step; s.vy = s.vy + dvy / dlen * step end
  local x0, y0, x1, y1 = bounds(s)
  me.x = clamp(me.x + s.vx * dt, x0, x1)
  me.y = clamp(me.y + s.vy * dt, y0, y1)
  speed = math.sqrt(s.vx * s.vx + s.vy * s.vy)
  -- facing: turn towards the stick while pushing, else keep the last heading
  if mag > 0.05 then
    local target = math.deg(math.atan2(ay, ax)) % 360
    me.facing = angleLerp(me.facing or 0, target, 1 - math.exp(-dt * 14))
  end
  -- hop
  local airborne = me.z > 0 or me.vz > 0
  if airborne then
    me.vz = me.vz - GRAVITY * dt
    me.z = me.z + me.vz * dt
    if me.z <= 0 then
      me.z, me.vz = 0, 0
      me.squash = 0.22
      me.landed = true
    end
  end
  -- squash recovers
  me.squash = (me.squash or 0) * math.max(0, 1 - dt * 9)
  me.speed = speed / MAX_SPEED
  if hit then me.anim = "hit"
  elseif me.z > 0 then me.anim = "jump"
  elseif s.time < (me.slapAt or -1) + 0.3 then me.anim = "slap"
  elseif s.time < (me.kickAt or -1) + 0.32 then me.anim = "kick"
  elseif skidding then me.anim = "skid"
  elseif speed > 18 then me.anim = "run"
  else me.anim = "idle" end
  me.skidding = skidding
  me.moving = mag > 0.05
  me.mvx, me.mvy = ax, ay
end

-- Remote players: interpolate between snapshots at (now - RENDER_DELAY).
function M.stepRemotes(s, dt)
  local renderAt = s.clock - RENDER_DELAY
  for id, p in pairs(s.players) do
    if not p.isMe then
      local snaps = p.snaps
      local n = #snaps
      if n > 0 then
        local a, b = nil, nil
        for i = n, 1, -1 do
          if snaps[i].t <= renderAt then a = snaps[i]; b = snaps[i + 1]; break end
        end
        local tx, ty, facing, anim
        if a and b then
          local span = b.t - a.t
          local k = (span > 0) and clamp((renderAt - a.t) / span, 0, 1) or 1
          tx, ty = lerp(a.x, b.x, k), lerp(a.y, b.y, k)
          facing = angleLerp(a.facing, b.facing, k)
          anim = (k < 0.5) and a.anim or b.anim
          p.vx, p.vy = lerp(a.vx, b.vx, k), lerp(a.vy, b.vy, k)
        elseif a then
          -- newest snapshot is older than the render time: extrapolate a little
          local ahead = clamp(renderAt - a.t, 0, MAX_EXTRAPOLATE)
          tx, ty = a.x + a.vx * ahead, a.y + a.vy * ahead
          facing, anim = a.facing, a.anim
          p.vx, p.vy = a.vx, a.vy
        else
          local first = snaps[1]
          tx, ty, facing, anim = first.x, first.y, first.facing, first.anim
        end
        -- knockback nudge on top, decaying
        if p.px ~= 0 or p.py ~= 0 then
          p.nx = (p.nx or 0) + p.px * dt; p.ny = (p.ny or 0) + p.py * dt
          p.px = p.px * math.max(0, 1 - dt * 6); p.py = p.py * math.max(0, 1 - dt * 6)
          if math.abs(p.px) + math.abs(p.py) < 5 then p.px, p.py = 0, 0 end
        end
        p.nx = (p.nx or 0) * math.max(0, 1 - dt * 4); p.ny = (p.ny or 0) * math.max(0, 1 - dt * 4)
        local jump = math.abs(tx - p.x) > 400 or math.abs(ty - p.y) > 400
        if jump then p.x, p.y = tx, ty else
          local k = 1 - math.exp(-dt * 25)
          p.x = lerp(p.x, tx + p.nx, k); p.y = lerp(p.y, ty + p.ny, k)
        end
        p.facing = angleLerp(p.facing or 0, facing, 1 - math.exp(-dt * 12))
        if anim ~= "jump" and p.z <= 0 then p.anim = anim end
        p.speed = clamp(math.sqrt(p.vx * p.vx + p.vy * p.vy) / MAX_SPEED, 0, 1)
      end
      if p.z > 0 or p.vz > 0 then
        p.vz = p.vz - GRAVITY * dt
        p.z = p.z + p.vz * dt
        if p.z <= 0 then p.z, p.vz = 0, 0; p.squash = 0.22; if p.anim == "jump" then p.anim = "idle" end; s:puff(p.x, p.y, 4) end
      end
      p.squash = (p.squash or 0) * math.max(0, 1 - dt * 9)
      if s.time < (p.hitUntil or 0) then p.anim = "hit" end
      if s.time < (p.slapAt or -1) + 0.3 then p.anim = "slap" end
      if s.time < (p.kickAt or -1) + 0.32 then p.anim = "kick" end
    end
  end
end

function M.stepBall(s, dt)
  local b = s.ball
  b.tx = b.tx + b.vx * dt
  b.ty = b.ty + b.vy * dt
  local k = 1 - math.exp(-dt * 8)
  b.x = b.x + (b.tx - b.x) * k
  b.y = b.y + (b.ty - b.y) * k
  b.vz = b.vz - 900 * dt
  b.tz = math.max(0, b.tz + b.vz * dt)
  if b.tz == 0 and b.vz < 0 then b.vz = math.abs(b.vz) > 60 and -b.vz * 0.55 or 0 end
  b.z = b.z + (b.tz - b.z) * k
  local sp = math.sqrt(b.vx * b.vx + b.vy * b.vy)
  b.spin = b.spin + (sp / 14) * dt
  if sp > 1 then b.rollDir = math.atan2(b.vy, b.vx) end
end

-- Camera: follow me with look-ahead; zoom so the ball and nearby players fit.
function M.updateCamera(s, dt, sw, sh)
  local me = s.me
  if not me then return end
  local lookX, lookY = s.vx * 0.35, s.vy * 0.35
  local fx, fy = me.x + lookX, me.y + lookY
  -- frame: me, the ball, and anyone within reach
  local minx, miny, maxx, maxy = fx, fy, fx, fy
  local function include(x, y) minx = math.min(minx, x); maxx = math.max(maxx, x); miny = math.min(miny, y); maxy = math.max(maxy, y) end
  include(s.ball.x, s.ball.y)
  for _, p in pairs(s.players) do
    if not p.isMe then
      local d = math.sqrt((p.x - me.x) ^ 2 + (p.y - me.y) ^ 2)
      if d < 900 then include(p.x, p.y) end
    end
  end
  local marginX, marginY = 360, 300
  local bw = (maxx - minx) + marginX * 2
  local bh = (maxy - miny) + marginY * 2
  local zoom = clamp(math.min(sw / bw, sh / bh), s.zoomMin or 0.42, s.zoomMax or 0.9)
  -- dead zone: only chase when the frame centre drifts from the camera
  local cx, cy = (minx + maxx) / 2, (miny + maxy) / 2 - 30
  if math.abs(cx - s.cam.tx) > 24 or math.abs(cy - s.cam.ty) > 24 then s.cam.tx, s.cam.ty = cx, cy end
  s.cam.tzoom = zoom
  local k = 1 - math.exp(-dt * 3.2)
  local kz = 1 - math.exp(-dt * 1.8)
  s.cam.x = lerp(s.cam.x, s.cam.tx, k)
  s.cam.y = lerp(s.cam.y, s.cam.ty, k)
  s.cam.zoom = lerp(s.cam.zoom, s.cam.tzoom, kz)
  if dt == 0 then s.cam.x, s.cam.y, s.cam.zoom = cx, cy, zoom; s.cam.tx, s.cam.ty = cx, cy end
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
  self.clock = now
  self.net:update(now)
  for _, msg in ipairs(self.net:poll()) do self:apply(msg) end
  if self.net.state == "failed" and self.status ~= "error" then self.status = "reconnecting" end
  if self.net.state == "connected" and self.status == "reconnecting" then self.status = "connecting" end

  local ax, ay = input.axis()
  local wasSkid = self.me and self.me.skidding
  M.stepLocal(self, dt, ax, ay)
  if self.me then
    if self.me.landed then self.me.landed = false; self:puff(self.me.x, self.me.y, 7) end
    if self.me.skidding and not wasSkid then self:puff(self.me.x, self.me.y, 5, 30) end
    if self.me.skidding and math.random() < dt * 18 then self:puff(self.me.x, self.me.y, 1, 20) end
  end
  M.stepRemotes(self, dt)
  M.stepBall(self, dt)
  M.stepParticles(self, dt)
  M.updateCamera(self, dt, love.graphics.getWidth(), love.graphics.getHeight())
  self.goalFlash = math.max(0, self.goalFlash - dt * 0.6)

  if self.me and self.net.state == "connected" then
    self.sendAcc = self.sendAcc + dt
    if self.sendAcc >= 1 / SEND_HZ then
      self.sendAcc = 0
      self.net:send({ t = "move", x = math.floor(self.me.x + 0.5), y = math.floor(self.me.y + 0.5),
        vx = math.floor(self.vx + 0.5), vy = math.floor(self.vy + 0.5),
        dir = math.floor((self.me.facing or 0) + 0.5) % 360, anim = self.me.anim })
    end
  end
end

function M:action(a)
  if a == "x" then
    if self.me and self.me.z <= 0 then
      self.me.vz = HOP_V
      self.me.squash = -0.1
      self.net:send({ t = "jump" })
    end
  elseif a == "a" then
    if not self.me then return end
    if self:nearBall() then
      local dx, dy = self.me.mvx or 0, self.me.mvy or 0
      if math.abs(dx) + math.abs(dy) < 0.1 then dx, dy = math.cos(math.rad(self.me.facing or 0)), math.sin(math.rad(self.me.facing or 0)) end
      self.net:send({ t = "kick", dx = dx, dy = dy, power = 1 })
      self.me.kickAt = self.time
    else
      self.net:send({ t = "slap" })
      self.me.slapAt = self.time
    end
  elseif a == "b" then
    if self.onLeave then self.onLeave() end
  elseif a == "start" then
    if self.onEdit then self.onEdit() end
  end
end

-- Drawing ----------------------------------------------------------------------
local function buildCrowd(s)
  -- deterministic seats for the stands, built once per pitch size as a
  -- sprite batch of small squares in world units (so they scale with zoom)
  local lg = love.graphics
  local p = s.pitch
  local palette = ui.colors.crowd
  local rnd = 12345
  local function r() rnd = (rnd * 1103515245 + 12345) % 2147483648; return rnd / 2147483648 end
  local ax0, ay0, ax1, ay1 = -p.apron, -p.apron, p.w + p.apron, p.h + p.apron
  local tierD = 70
  local seats = {}
  for tier = 1, 3 do
    local o = (tier - 1) * tierD
    local x0, y0, x1, y1 = ax0 - o, ay0 - o, ax1 + o, ay1 + o
    local function row(xa, ya, xb, yb)
      local len = math.sqrt((xb - xa) ^ 2 + (yb - ya) ^ 2)
      local n = math.floor(len / 13)
      for i = 0, n do
        if r() < 0.8 then
          local k = i / math.max(1, n)
          seats[#seats + 1] = { xa + (xb - xa) * k + (r() - 0.5) * 5, ya + (yb - ya) * k + (r() - 0.5) * 5, palette[math.floor(r() * #palette) + 1] }
        end
      end
    end
    for line = 0, 3 do
      local d = line * 15 + 12
      row(x0 + 70, y0 - d, x1 - 70, y0 - d)
      row(x0 + 70, y1 + d, x1 - 70, y1 + d)
      row(x0 - d, y0 + 70, x0 - d, y1 - 70)
      row(x1 + d, y0 + 70, x1 + d, y1 - 70)
    end
  end
  if not (love.image and lg.newSpriteBatch) then return { seats = seats } end
  local id = love.image.newImageData(2, 2); id:mapPixel(function() return 1, 1, 1, 1 end)
  local img = lg.newImage(id)
  local batch = lg.newSpriteBatch(img, #seats, "static")
  for _, seat in ipairs(seats) do
    local c = seat[3]
    batch:setColor(c[1], c[2], c[3], 1)
    batch:add(seat[1], seat[2], 0, 4.5, 4.5, 1, 1)
  end
  batch:setColor(1, 1, 1, 1)
  return { seats = seats, batch = batch }
end

local function drawStadium(s)
  local lg = love.graphics
  local c = ui.colors
  local p = s.pitch
  local w, h = p.w, p.h
  local ax0, ay0, ax1, ay1 = -p.apron, -p.apron, w + p.apron, h + p.apron

  -- stands: three tiers stepping outwards, darker as they rise
  local tierD = 70
  for tier = 3, 1, -1 do
    local o = tier * tierD + 10
    ui.col(c.standEdge); lg.rectangle("fill", ax0 - o - 6, ay0 - o - 6, (ax1 - ax0) + 2 * o + 12, (ay1 - ay0) + 2 * o + 12, 60, 60)
    ui.col((tier % 2 == 0) and c.stand2 or c.stand1); lg.rectangle("fill", ax0 - o, ay0 - o, (ax1 - ax0) + 2 * o, (ay1 - ay0) + 2 * o, 56, 56)
  end
  -- crowd
  if not s.crowd then s.crowd = buildCrowd(s) end
  if s.crowd.batch then lg.setColor(1, 1, 1, 1); lg.draw(s.crowd.batch) end
  -- concrete apron with running track
  ui.col(c.concrete); lg.rectangle("fill", ax0, ay0, ax1 - ax0, ay1 - ay0, 40, 40)
  ui.col(c.track); lg.rectangle("fill", -p.apron * 0.55, -p.apron * 0.55, w + p.apron * 1.1, h + p.apron * 1.1, 160, 160)
  ui.col(c.trackLine); lg.setLineWidth(3)
  for i = 1, 4 do
    local d = p.apron * 0.55 - i * 30
    lg.rectangle("line", -d, -d, w + 2 * d, h + 2 * d, 140, 140)
  end
  -- grass with mown stripes
  ui.col(c.grass1); lg.rectangle("fill", -40, -40, w + 80, h + 80)
  ui.col(c.grass2)
  local stripes = 12
  for i = 0, stripes - 1, 2 do lg.rectangle("fill", i * (w / stripes), -40, w / stripes, h + 80) end
  -- pitch markings
  ui.col(c.line); lg.setLineWidth(6)
  lg.rectangle("line", 0, 0, w, h)
  lg.line(w / 2, 0, w / 2, h)
  lg.circle("line", w / 2, h / 2, h * 0.12)
  lg.circle("fill", w / 2, h / 2, 7)
  local boxW, boxH = w * 0.17, h * 0.55
  local sixW, sixH = w * 0.06, h * 0.26
  lg.rectangle("line", 0, (h - boxH) / 2, boxW, boxH); lg.rectangle("line", w - boxW, (h - boxH) / 2, boxW, boxH)
  lg.rectangle("line", 0, (h - sixH) / 2, sixW, sixH); lg.rectangle("line", w - sixW, (h - sixH) / 2, sixW, sixH)
  lg.circle("fill", w * 0.115, h / 2, 7); lg.circle("fill", w - w * 0.115, h / 2, 7)
  lg.arc("line", "open", w * 0.115, h / 2, h * 0.12, -0.93, 0.93)
  lg.arc("line", "open", w - w * 0.115, h / 2, h * 0.12, math.pi - 0.93, math.pi + 0.93)
  lg.arc("line", "open", 0, 0, 26, 0, math.pi / 2)
  lg.arc("line", "open", w, 0, 26, math.pi / 2, math.pi)
  lg.arc("line", "open", w, h, 26, math.pi, 1.5 * math.pi)
  lg.arc("line", "open", 0, h, 26, 1.5 * math.pi, 2 * math.pi)
  -- corner flags
  for _, cx in ipairs({ 0, w }) do for _, cy in ipairs({ 0, h }) do
    ui.col(c.post); lg.setLineWidth(4); lg.line(cx, cy, cx, cy - 46)
    ui.col(c.crowd[1]); lg.polygon("fill", cx, cy - 46, cx + 26, cy - 38, cx, cy - 30)
  end end
  -- goals: nets drawn as grids behind the goal line, posts on top
  local gw, gd = p.goalW, p.goalDepth
  local gy0 = (h - gw) / 2
  for _, g in ipairs({ { x0 = -gd, x1 = 0, dir = 1 }, { x0 = w, x1 = w + gd, dir = -1 } }) do
    ui.col(c.net, 0.75); lg.setLineWidth(1.5)
    for xx = g.x0, g.x1, 12 do lg.line(xx, gy0 - 50, xx, gy0 + gw) end
    for yy = gy0 - 50, gy0 + gw, 12 do lg.line(g.x0, yy, g.x1, yy) end
    ui.col(c.post); lg.setLineWidth(7)
    local lineX = (g.dir == 1) and 0 or w
    lg.line(lineX, gy0, lineX, gy0 - 52)                               -- near post
    lg.line(lineX, gy0 + gw, lineX, gy0 + gw - 52)                     -- far post
    lg.line(lineX, gy0 - 52, lineX, gy0 + gw - 52)                     -- crossbar (top edge)
    lg.line(lineX, gy0 - 52, lineX - g.dir * gd, gy0 - 50)             -- top bars back
    lg.line(lineX, gy0 + gw - 52, lineX - g.dir * gd, gy0 + gw - 50)
  end
  -- floodlights at the four corners of the stands
  for _, fx in ipairs({ ax0 - 2 * tierD, ax1 + 2 * tierD }) do for _, fy in ipairs({ ay0 - 2 * tierD, ay1 + 2 * tierD }) do
    ui.col(c.standEdge); lg.setLineWidth(8); lg.line(fx, fy, fx, fy - 190)
    ui.col(c.roof); lg.rectangle("fill", fx - 34, fy - 232, 68, 46, 8, 8)
    ui.col({ 1, 0.98, 0.85 }, (ui.mode == "dark") and 1 or 0.6)
    for i = 0, 3 do lg.circle("fill", fx - 24 + i * 16, fy - 209, 5) end
  end end
  -- scoreboard above the north stand
  local sbW, sbH = 520, 150
  local sbX, sbY = w / 2 - sbW / 2, ay0 - 3 * tierD - 60 - sbH
  ui.col(c.standEdge); lg.rectangle("fill", sbX - 10, sbY - 10, sbW + 20, sbH + 20, 18, 18)
  local flash = s.goalFlash
  ui.col({ c.scoreBg[1] + flash * 0.3, c.scoreBg[2] + flash * 0.2, c.scoreBg[3] }); lg.rectangle("fill", sbX, sbY, sbW, sbH, 14, 14)
  lg.setLineWidth(1)
end

local function drawScoreboardText(s)
  local lg = love.graphics
  local c = ui.colors
  local p = s.pitch
  local tierD = 70
  local sbW, sbH = 520, 150
  local sbX, sbY = p.w / 2 - sbW / 2, -p.apron - 3 * tierD - 60 - sbH
  lg.push()
  lg.translate(sbX, sbY)
  lg.setFont(ui.fonts.big)
  ui.col(c.scoreFg)
  lg.printf(string.format("%d", s.score.left), 0, 42, sbW / 2 - 40, "right")
  lg.printf(string.format("%d", s.score.right), sbW / 2 + 40, 42, sbW / 2 - 40, "left")
  lg.setFont(ui.fonts.title); lg.printf("-", 0, 48, sbW, "center")
  lg.setFont(ui.fonts.small); ui.col(c.scoreFg, 0.75)
  lg.printf("WEST GOAL", 20, 14, sbW / 2 - 60, "left"); lg.printf("EAST GOAL", sbW / 2 + 40, 14, sbW / 2 - 60, "right")
  lg.printf(string.format("%d in the stadium", s.count), 0, sbH - 34, sbW, "center")
  lg.pop()
end

local function drawBall(s)
  local lg = love.graphics
  local b = s.ball
  local r = 14
  local sh = math.max(0.4, 1 - b.z / 600)
  ui.col({ 0, 0, 0, 0.16 }); lg.ellipse("fill", b.x, b.y + 2, r * sh, r * 0.45 * sh)
  local by = b.y - r - b.z
  ui.col({ 0.82, 0.82, 0.84 }); lg.circle("fill", b.x, by, r)
  ui.col({ 1, 1, 1 }); lg.circle("fill", b.x - r * 0.18, by - r * 0.18, r * 0.82)
  ui.col({ 0.15, 0.15, 0.18 })
  local ang0 = b.spin
  for i = 0, 4 do
    local a = ang0 + i * (2 * math.pi / 5)
    local px, py = math.cos(a) * r * 0.55, math.sin(a) * r * 0.55
    lg.circle("fill", b.x + px, by + py, r * 0.2)
  end
  lg.setLineWidth(2); ui.col({ 0.3, 0.3, 0.33 }); lg.circle("line", b.x, by, r); lg.setLineWidth(1)
end

local function drawParticles(s)
  local lg = love.graphics
  for _, p in ipairs(s.particles) do
    local k = 1 - p.age / p.life
    if p.kind == "dust" then
      ui.col({ 0.75, 0.72, 0.66, 0.5 * k })
      lg.circle("fill", p.x, p.y - p.z, p.size * (1.6 - k))
    else
      ui.col(p.color, 0.4 + 0.6 * k)
      lg.push(); lg.translate(p.x, p.y - p.z); lg.rotate(p.spin); lg.rectangle("fill", -p.size / 2, -p.size / 3, p.size, p.size * 0.66); lg.pop()
    end
  end
end

local function drawPlayer(s, p, zoom)
  local lg = love.graphics
  local opts = { speed = p.speed or 0, z = p.z or 0, vz = p.vz or 0, squash = p.squash or 0, seed = p.seed or 0 }
  if p.anim == "slap" then opts.phase = clamp((s.time - (p.slapAt or 0)) / 0.3, 0, 1) end
  if p.anim == "kick" then opts.phase = clamp((s.time - (p.kickAt or 0)) / 0.32, 0, 1) end
  avatar.draw(p.avatar, p.x, p.y, 1, p.facing or 0, p.anim, s.time, opts)
  -- labels (counter-scaled so they stay readable when zoomed out)
  local labelScale = math.max(1, 0.9 / zoom)
  lg.push()
  lg.translate(p.x, p.y - (p.z or 0) - avatar.height(1) - 8)
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
  ui.col(ui.colors.sky); lg.rectangle("fill", 0, 0, sw, sh)

  lg.push()
  lg.translate(sw / 2, sh / 2)
  lg.scale(self.cam.zoom, self.cam.zoom)
  lg.translate(-self.cam.x, -self.cam.y)
  drawStadium(self)
  drawScoreboardText(self)

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
  drawParticles(self)
  lg.pop()

  -- HUD
  ui.panel(16, 14, 300, 54, 18)
  ui.text(string.format("%d in the stadium   %d - %d", self.count, self.score.left, self.score.right), 30, 28, 280, "left", ui.fonts.body)
  if self.goalBanner and self.time < self.goalBanner.until_ then
    local k = clamp((self.goalBanner.until_ - self.time) / 3.2, 0, 1)
    local pop = 1 + 0.15 * math.sin(math.min(1, (1 - k) * 4) * math.pi)
    lg.push(); lg.translate(sw / 2, sh * 0.3); lg.scale(pop, pop)
    ui.textOutlined("GOAL!", -sw / 2, -30, sw, "center", ui.fonts.big, ui.colors.white)
    if self.goalBanner.who then ui.textOutlined(self.goalBanner.who, -sw / 2, 24, sw, "center", ui.fonts.title, ui.colors.accentL) end
    lg.pop()
  end
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
  ui.col({ 0, 0, 0, 0.38 }); lg.rectangle("fill", sw / 2 - 260, sh - 46, 520, 40, 20, 20)
  ui.promptsLight(prompts, sh - 34, sw)
end

return M
