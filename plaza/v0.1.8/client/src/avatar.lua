-- BatWiiCera Plaza - avatar model and procedural renderer
-- Version 0.1.8 | Author: yiddifliddo | Licence: MIT
--
-- An original cartoon figure built from a handful of numbered parts so a
-- whole avatar fits in a few integers (which is what travels over the
-- network). Everything is drawn with primitives: no image assets, no
-- resemblance to any console maker's characters.
--
-- 0.1.7 renderer: a jointed body (hips, knees, shoulders, elbows) animated
-- by a stride cycle, eight-direction facing from one geometric model
-- (forward motion projects onto the screen by the facing angle), soft
-- two-tone shading with a consistent top-left light, outlines, lean into
-- the run, squash and stretch on impacts, and a shadow that reacts to
-- height. See M.draw for the parameters.

local M = {}

-- Part definitions. Keep LIMITS in sync with the server's AVATAR_LIMITS.
M.parts = {
  { key = "head",      label = "Head shape",  n = 4,  names = { "Round", "Oval", "Square", "Heart" } },
  { key = "skin",      label = "Skin tone",   n = 8 },
  { key = "hair",      label = "Hair style",  n = 8,  names = { "Short", "Spiky", "Bob", "Long", "Curly", "Bun", "Cap", "Bald" } },
  { key = "hairColor", label = "Hair colour", n = 10 },
  { key = "eyes",      label = "Eyes",        n = 6,  names = { "Dots", "Wide", "Happy", "Sleepy", "Wink", "Glasses" } },
  { key = "brows",     label = "Eyebrows",    n = 4,  names = { "Flat", "Raised", "Angry", "None" } },
  { key = "mouth",     label = "Mouth",       n = 6,  names = { "Smile", "Grin", "Neutral", "Open", "Smirk", "Whistle" } },
  { key = "shirt",     label = "Shirt colour", n = 12 },
  { key = "accessory", label = "Accessory",   n = 4,  names = { "None", "Headband", "Star badge", "Scarf" } },
}

M.limits = {}
for _, p in ipairs(M.parts) do M.limits[p.key] = p.n end

local function rgb(hex)
  return { tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255 }
end

M.skinTones = { rgb("F6D4BA"), rgb("EBBF9B"), rgb("D9A777"), rgb("C58C5C"), rgb("A86B43"), rgb("7D4C2B"), rgb("5A3620"), rgb("F2C9C9") }
M.hairColors = { rgb("2A1B12"), rgb("4A2F1B"), rgb("8B5A2B"), rgb("C98A3E"), rgb("E9C46A"), rgb("B0B0B0"), rgb("D93A3A"), rgb("3A7BD5"), rgb("5BAD5B"), rgb("8E44AD") }
M.shirtColors = { rgb("E2473B"), rgb("3B8BE2"), rgb("3DB34A"), rgb("F2B705"), rgb("8E44AD"), rgb("F28C28"), rgb("1ABC9C"), rgb("E84393"), rgb("34495E"), rgb("FFFFFF"), rgb("7F8C8D"), rgb("2C2C2C") }

M.palettes = { skin = M.skinTones, hairColor = M.hairColors, shirt = M.shirtColors }

function M.default()
  return { head = 0, skin = 1, hair = 0, hairColor = 1, eyes = 0, brows = 0, mouth = 0, shirt = 1, accessory = 0 }
end

function M.random(rand)
  rand = rand or math.random
  local a = {}
  for _, p in ipairs(M.parts) do a[p.key] = rand(0, p.n - 1) end
  return a
end

-- Clamp any incoming table into a valid avatar.
function M.sanitize(a)
  local out = M.default()
  if type(a) ~= "table" then return out end
  for _, p in ipairs(M.parts) do
    local v = tonumber(a[p.key])
    if v then
      v = math.floor(v)
      if v < 0 then v = 0 end
      if v >= p.n then v = p.n - 1 end
      out[p.key] = v
    end
  end
  return out
end

function M.optionName(key, value)
  for _, p in ipairs(M.parts) do
    if p.key == key then
      if p.names then return p.names[value + 1] or tostring(value) end
      return tostring(value + 1)
    end
  end
  return tostring(value)
end

-- Rendering -----------------------------------------------------------------
-- M.draw(a, x, y, scale, facing, anim, t, opts)
--   (x, y)   ground point under the feet
--   scale    1 = about 96 px tall
--   facing   degrees: 0 right, 90 towards the viewer, 180 left, 270 away.
--            Legacy 1 / -1 are accepted (right / left).
--   anim     "idle" | "run" | "jump" | "hit" | "slap" | "kick" | "skid"
--   t        running time (seconds) driving cycles and blinks
--   opts     optional: speed (0..1, run cycle rate and stride), z (height
--            above ground, for the shadow), vz (vertical speed, jump pose),
--            squash (-0.3..0.3, landing/impact), phase (0..1 for slap/kick),
--            seed (per-player offset so crowds do not move in lockstep)
local lg

local function mix(c, f) return { c[1] * f, c[2] * f, c[3] * f } end
local function lift(c, f) return { c[1] + (1 - c[1]) * f, c[2] + (1 - c[2]) * f, c[3] + (1 - c[3]) * f } end
local function setColor(c, a) lg.setColor(c[1], c[2], c[3], a or 1) end
local INK = { 0.14, 0.12, 0.13 }

-- A limb as a thick rounded stroke with an outline: dark pass then colour pass.
local function limb(x1, y1, x2, y2, w, color, outline)
  setColor(outline); lg.setLineWidth(w + 2.6)
  lg.line(x1, y1, x2, y2); lg.circle("fill", x1, y1, (w + 2.6) / 2); lg.circle("fill", x2, y2, (w + 2.6) / 2)
  setColor(color); lg.setLineWidth(w)
  lg.line(x1, y1, x2, y2); lg.circle("fill", x1, y1, w / 2); lg.circle("fill", x2, y2, w / 2)
end

local function headShape(a, hx, hy, r, mode)
  local shape = a.head
  if shape == 0 then lg.circle(mode, hx, hy, r)
  elseif shape == 1 then lg.ellipse(mode, hx, hy, r * 0.9, r * 1.07)
  elseif shape == 2 then lg.rectangle(mode, hx - r * 0.92, hy - r * 0.92, r * 1.84, r * 1.84, r * 0.4, r * 0.4)
  else
    lg.circle(mode, hx, hy - r * 0.1, r * 0.98)
    if mode == "fill" then lg.polygon(mode, hx - r * 0.95, hy, hx + r * 0.95, hy, hx, hy + r * 1.05)
    else lg.line(hx - r * 0.95, hy, hx, hy + r * 1.05, hx + r * 0.95, hy) end
  end
end

-- Hair. `fx` is the facing cosine (profile shift), `back` true when the
-- player faces away from the viewer, so the hair covers where the face was.
local function hair(a, hx, hy, r, fx, back)
  if a.hair == 7 then return end
  local c = M.hairColors[a.hairColor + 1]
  local s = a.hair
  local sh = fx * r * 0.12         -- hairline shifts a little with the facing
  setColor(c)
  if back then
    -- back of the head: a full cap, styles only change the silhouette
    lg.circle("fill", hx, hy - r * 0.08, r * 1.02)
    if s == 1 then for i = -2, 2 do local bx = hx + i * r * 0.42; lg.polygon("fill", bx - r * 0.22, hy - r * 0.75, bx + r * 0.22, hy - r * 0.75, bx + i * r * 0.1, hy - r * 1.45) end
    elseif s == 2 then lg.rectangle("fill", hx - r * 1.05, hy - r * 0.1, r * 2.1, r * 1.0, r * 0.3, r * 0.3)
    elseif s == 3 then lg.rectangle("fill", hx - r * 1.05, hy - r * 0.1, r * 2.1, r * 1.95, r * 0.3, r * 0.3)
    elseif s == 4 then for i = -3, 3 do lg.circle("fill", hx + i * r * 0.32, hy - r * 0.6 + math.abs(i) * r * 0.1, r * 0.36) end
    elseif s == 5 then lg.circle("fill", hx, hy - r * 1.15, r * 0.36)
    elseif s == 6 then setColor(mix(c, 0.8)); lg.rectangle("fill", hx - r * 1.0, hy - r * 0.22, r * 2.0, r * 0.18, r * 0.08, r * 0.08) end
    setColor(mix(c, 0.55)); lg.setLineWidth(1.2); lg.circle("line", hx, hy - r * 0.08, r * 1.02)
    return
  end
  if s == 0 then
    lg.arc("fill", hx + sh, hy - r * 0.05, r * 1.02, math.pi, 2 * math.pi)
  elseif s == 1 then
    lg.arc("fill", hx + sh, hy, r * 1.0, math.pi, 2 * math.pi)
    for i = -2, 2 do
      local bx = hx + sh + i * r * 0.42
      lg.polygon("fill", bx - r * 0.22, hy - r * 0.75, bx + r * 0.22, hy - r * 0.75, bx + i * r * 0.1, hy - r * 1.45)
    end
  elseif s == 2 then
    lg.arc("fill", hx + sh, hy, r * 1.08, math.pi, 2 * math.pi)
    lg.rectangle("fill", hx - r * 1.08, hy - r * 0.05, r * 0.32, r * 1.0, r * 0.1, r * 0.1)
    lg.rectangle("fill", hx + r * 0.76, hy - r * 0.05, r * 0.32, r * 1.0, r * 0.1, r * 0.1)
  elseif s == 3 then
    lg.arc("fill", hx + sh, hy, r * 1.08, math.pi, 2 * math.pi)
    lg.rectangle("fill", hx - r * 1.08, hy - r * 0.1, r * 0.36, r * 1.9, r * 0.15, r * 0.15)
    lg.rectangle("fill", hx + r * 0.72, hy - r * 0.1, r * 0.36, r * 1.9, r * 0.15, r * 0.15)
  elseif s == 4 then
    for i = -3, 3 do lg.circle("fill", hx + sh + i * r * 0.32, hy - r * 0.78 + math.abs(i) * r * 0.12, r * 0.34) end
    lg.circle("fill", hx - r * 0.98, hy - r * 0.2, r * 0.3); lg.circle("fill", hx + r * 0.98, hy - r * 0.2, r * 0.3)
  elseif s == 5 then
    lg.arc("fill", hx + sh, hy, r * 1.02, math.pi, 2 * math.pi)
    lg.circle("fill", hx - sh * 0.5, hy - r * 1.15, r * 0.36)
  elseif s == 6 then
    lg.arc("fill", hx + sh, hy - r * 0.08, r * 1.04, math.pi, 2 * math.pi)
    setColor(mix(c, 0.8))
    local peak = fx * r * 0.9
    lg.rectangle("fill", hx + sh + math.min(0, peak) - r * 0.3, hy - r * 0.2, math.abs(peak) + r * 0.6, r * 0.16, r * 0.08, r * 0.08)
  end
  -- a soft highlight on the lit side
  setColor(lift(c, 0.22), 0.8)
  lg.arc("fill", hx + sh - r * 0.25, hy - r * 0.25, r * 0.5, math.pi * 1.1, math.pi * 1.6)
end

local function face(a, hx, hy, r, fx, side, blink, glance)
  local ex = hx + fx * r * 0.26 + glance * r * 0.06
  local ey = hy - r * 0.03
  local gap = r * 0.36 * (1 - side * 0.45)
  local e = a.eyes
  setColor(INK)
  if blink then
    lg.setLineWidth(r * 0.08)
    lg.line(ex - gap - r * 0.14, ey, ex - gap + r * 0.14, ey); lg.line(ex + gap - r * 0.14, ey, ex + gap + r * 0.14, ey)
  elseif e == 0 then
    lg.circle("fill", ex - gap, ey, r * 0.1); lg.circle("fill", ex + gap, ey, r * 0.1)
    lg.setColor(1, 1, 1); lg.circle("fill", ex - gap - r * 0.03, ey - r * 0.03, r * 0.03); lg.circle("fill", ex + gap - r * 0.03, ey - r * 0.03, r * 0.03)
  elseif e == 1 then
    lg.setColor(1, 1, 1); lg.circle("fill", ex - gap, ey, r * 0.2); lg.circle("fill", ex + gap, ey, r * 0.2)
    setColor(INK); lg.circle("fill", ex - gap + fx * r * 0.06, ey, r * 0.1); lg.circle("fill", ex + gap + fx * r * 0.06, ey, r * 0.1)
  elseif e == 2 then
    lg.setLineWidth(r * 0.08)
    lg.arc("line", "open", ex - gap, ey + r * 0.05, r * 0.16, math.pi, 2 * math.pi)
    lg.arc("line", "open", ex + gap, ey + r * 0.05, r * 0.16, math.pi, 2 * math.pi)
  elseif e == 3 then
    lg.setLineWidth(r * 0.08)
    lg.arc("line", "open", ex - gap, ey - r * 0.05, r * 0.16, 0, math.pi)
    lg.arc("line", "open", ex + gap, ey - r * 0.05, r * 0.16, 0, math.pi)
  elseif e == 4 then
    lg.circle("fill", ex - gap, ey, r * 0.1)
    lg.setLineWidth(r * 0.08); lg.line(ex + gap - r * 0.14, ey, ex + gap + r * 0.14, ey)
  else
    lg.circle("fill", ex - gap, ey, r * 0.08); lg.circle("fill", ex + gap, ey, r * 0.08)
    lg.setLineWidth(r * 0.06)
    lg.circle("line", ex - gap, ey, r * 0.24); lg.circle("line", ex + gap, ey, r * 0.24)
    lg.line(ex - gap + r * 0.24, ey, ex + gap - r * 0.24, ey)
  end
  local b = a.brows
  if b ~= 3 then
    setColor(INK); lg.setLineWidth(r * 0.07)
    local by = ey - r * 0.32
    if b == 0 then
      lg.line(ex - gap - r * 0.16, by, ex - gap + r * 0.16, by); lg.line(ex + gap - r * 0.16, by, ex + gap + r * 0.16, by)
    elseif b == 1 then
      lg.line(ex - gap - r * 0.16, by + r * 0.05, ex - gap + r * 0.16, by - r * 0.08); lg.line(ex + gap - r * 0.16, by - r * 0.08, ex + gap + r * 0.16, by + r * 0.05)
    else
      lg.line(ex - gap - r * 0.16, by - r * 0.08, ex - gap + r * 0.16, by + r * 0.06); lg.line(ex + gap - r * 0.16, by + r * 0.06, ex + gap + r * 0.16, by - r * 0.08)
    end
  end
  local m = a.mouth
  local mx, my = hx + fx * r * 0.3, hy + r * 0.45
  lg.setColor(0.45, 0.16, 0.16); lg.setLineWidth(r * 0.07)
  if m == 0 then lg.arc("line", "open", mx, my - r * 0.08, r * 0.26, 0.15 * math.pi, 0.85 * math.pi)
  elseif m == 1 then lg.arc("fill", mx, my - r * 0.05, r * 0.3, 0, math.pi); lg.setColor(1, 1, 1); lg.rectangle("fill", mx - r * 0.22, my - r * 0.05, r * 0.44, r * 0.09)
  elseif m == 2 then lg.line(mx - r * 0.2, my, mx + r * 0.2, my)
  elseif m == 3 then lg.ellipse("fill", mx, my + r * 0.02, r * 0.16, r * 0.2)
  elseif m == 4 then lg.line(mx - r * 0.18, my + r * 0.04, mx + r * 0.2, my - r * 0.06)
  else lg.circle("fill", mx + fx * r * 0.05, my, r * 0.09) end
end

local function accessory(a, hx, hy, r, chestX, chestY, bw, fx, back)
  local acc = a.accessory
  if acc == 1 then
    lg.setColor(0.93, 0.2, 0.2); lg.rectangle("fill", hx - r * 1.02, hy - r * 0.45, r * 2.04, r * 0.18, r * 0.09, r * 0.09)
  elseif acc == 2 and not back then
    lg.setColor(1, 0.84, 0.2)
    local sx, sy, sr = chestX + fx * bw * 0.22 - bw * 0.1, chestY, r * 0.16
    local pts = {}
    for i = 0, 9 do
      local ang = -math.pi / 2 + i * math.pi / 5
      local rad = (i % 2 == 0) and sr or sr * 0.45
      pts[#pts + 1] = sx + math.cos(ang) * rad; pts[#pts + 1] = sy + math.sin(ang) * rad
    end
    lg.polygon("fill", pts)
  elseif acc == 3 then
    lg.setColor(0.2, 0.6, 0.9)
    lg.rectangle("fill", chestX - bw * 0.55, chestY - r * 0.55, bw * 1.1, r * 0.26, r * 0.12, r * 0.12)
    lg.rectangle("fill", chestX + fx * bw * 0.25 - r * 0.12, chestY - r * 0.4, r * 0.24, r * 0.75, r * 0.1, r * 0.1)
  end
end

local function facingToRad(facing)
  if facing == nil then return 0 end
  if facing == 1 then return 0 end
  if facing == -1 then return math.pi end
  return math.rad(facing)
end

function M.draw(a, x, y, scale, facing, anim, t, opts)
  lg = lg or love.graphics
  a = M.sanitize(a)
  scale = scale or 1; anim = anim or "idle"; t = t or 0; opts = opts or {}
  local speed = opts.speed or ((anim == "run") and 1 or 0)
  local seed = opts.seed or 0
  local fr = facingToRad(facing)
  local fx, fy = math.cos(fr), math.sin(fr)
  local side = math.abs(fx)                 -- 1 profile, 0 front/back
  local back = fy < -0.35                    -- facing away: no face
  local depth = 0.32                         -- how much "forward" shows on screen vertically

  -- pose ------------------------------------------------------------------
  local phase = (t + seed) * (8 + 6 * speed)
  local stride = 0
  local lean = 0                             -- torso lean along the facing (px at scale 1)
  local bob = 0
  local armSwing = 0
  local legL, legR = { hip = 0, knee = 0 }, { hip = 0, knee = 0 }
  local armL, armR = { sh = 0.15, el = 0.35 }, { sh = -0.15, el = 0.35 }
  local headTilt = 0
  local breathe = 1 + math.sin((t + seed) * 1.9) * 0.012

  if anim == "run" then
    stride = 0.55 + 0.5 * speed
    legL.hip = math.sin(phase) * stride
    legR.hip = -math.sin(phase) * stride
    legL.knee = math.max(0, math.cos(phase - 0.6)) * (0.9 + 0.6 * speed)
    legR.knee = math.max(0, -math.cos(phase - 0.6)) * (0.9 + 0.6 * speed)
    armL.sh = -math.sin(phase) * stride * 0.75; armL.el = 0.9 + 0.5 * speed
    armR.sh = math.sin(phase) * stride * 0.75; armR.el = 0.9 + 0.5 * speed
    lean = 1.5 + 3.5 * speed
    bob = -math.abs(math.cos(phase)) * (1.5 + 2.5 * speed)
    headTilt = math.sin(phase * 2) * 0.03
  elseif anim == "jump" then
    local up = (opts.vz or 0) > 0
    legL.hip = up and 0.9 or 0.25; legL.knee = up and 1.6 or 0.3
    legR.hip = up and 0.3 or -0.1; legR.knee = up and 1.2 or 0.15
    armL.sh = up and -2.4 or -1.6; armL.el = 0.3
    armR.sh = up and -2.2 or -1.4; armR.el = 0.3
    lean = up and 2 or -1.5
  elseif anim == "hit" then
    local sh = math.sin(t * 50) * 0.08
    lean = -5
    headTilt = -0.25 + sh
    armL.sh = -1.9 + sh; armL.el = 1.4
    armR.sh = -1.7 - sh; armR.el = 1.4
    legL.hip = 0.5; legL.knee = 0.4; legR.hip = -0.4; legR.knee = 0.2
  elseif anim == "slap" then
    local p = opts.phase or 0.5                          -- 0 wind-up, 1 follow-through
    local swing = math.sin(math.min(1, p) * math.pi)      -- out and back
    armR.sh = -1.2 - 1.3 * swing; armR.el = 0.15 + 0.2 * (1 - swing)
    armL.sh = 0.5 - 0.4 * swing; armL.el = 0.9
    lean = 1 + 3 * swing
    legL.hip = 0.35; legR.hip = -0.35; legL.knee = 0.2
  elseif anim == "kick" then
    local p = opts.phase or 0.5
    local k = math.sin(math.min(1, p) * math.pi)
    legR.hip = -0.9 + 2.0 * k; legR.knee = 0.9 * (1 - k)
    legL.hip = -0.2; legL.knee = 0.1
    armL.sh = -0.9 * k; armR.sh = 0.9 * k
    lean = -1.5 + 3.5 * k
  elseif anim == "skid" then
    lean = -4.5
    legL.hip = 0.75; legR.hip = -0.55; legL.knee = 0.15; legR.knee = 0.75
    armL.sh = -0.9; armR.sh = -1.1; armL.el = 0.8; armR.el = 0.8
    headTilt = 0.08
  else -- idle
    local w = math.sin((t + seed) * 1.9)
    armL.sh = 0.12 + w * 0.04; armR.sh = -0.12 - w * 0.04; armL.el = 0.25; armR.el = 0.25
    legL.hip = 0.06; legR.hip = -0.06
    bob = w * 0.6
  end

  -- squash / stretch about the feet
  local sq = opts.squash or 0
  if anim == "jump" and (opts.vz or 0) > 150 then sq = -0.08 end
  local sx, sy = (1 + sq) * scale, (1 - sq) * scale * breathe

  -- shadow (before the transform: it stays on the ground)
  local z = opts.z or 0
  local shrink = math.max(0.45, 1 - z / 520)
  lg.setColor(0, 0, 0, 0.16 * math.max(0.3, 1 - z / 420))
  lg.ellipse("fill", x, y + 2 * scale, 24 * scale * shrink, 7 * scale * shrink)

  lg.push()
  lg.translate(x, y - z)
  lg.scale(sx, sy)
  lg.translate(0, bob)

  -- geometry at scale 1 (feet at origin, up is negative y)
  local r = 20                       -- head radius
  local bw, bh = 30 * (0.64 + 0.36 * (1 - side)), 32   -- torso narrows towards profile
  local upperLeg, lowerLeg = 20, 18
  local upperArm, lowerArm = 13, 12
  local hipY = -(upperLeg + lowerLeg) + 2
  local hipHalf = 6.5
  local function fwd(f) return f * fx, f * fy * depth end       -- forward offset -> screen
  local function lat(l) return -l * fy, l * fx * depth end       -- lateral offset -> screen

  local shirt = M.shirtColors[a.shirt + 1]
  local shorts = mix(shirt, 0.62)
  local skin = M.skinTones[a.skin + 1]
  local shoe = { 0.16, 0.16, 0.19 }
  local outline = mix(shirt, 0.42)

  -- leg endpoints: hip -> knee -> foot, forward swing projected by facing
  local function legPoints(L, lateral)
    local lx, ly = lat(lateral)
    local hx0, hy0 = lx, hipY + ly
    local kf, kv = math.sin(L.hip) * upperLeg, math.cos(L.hip) * upperLeg
    local ka = L.hip - L.knee                                  -- knee bends the shin back
    local ff, fv = kf + math.sin(ka) * lowerLeg, kv + math.cos(ka) * lowerLeg
    local kfx, kfy = fwd(kf); local ffx, ffy = fwd(ff)
    return hx0, hy0, hx0 + kfx, hy0 + kfy + kv, hx0 + ffx, hy0 + ffy + fv
  end
  -- which leg is nearer the viewer draws last
  local legs = { { L = legL, lat = -hipHalf }, { L = legR, lat = hipHalf } }
  if fy < 0 then legs[1], legs[2] = legs[2], legs[1] end
  local footY = {}
  for i, leg in ipairs(legs) do
    local hx0, hy0, kx, ky, fx0, fy0 = legPoints(leg.L, leg.lat)
    limb(hx0, hy0, kx, ky, 8.5, shorts, outline)
    limb(kx, ky, fx0, fy0, 7.5, skin, mix(skin, 0.5))
    -- shoe: an ellipse pointing along the facing
    setColor(mix(shoe, 0.6)); lg.ellipse("fill", fx0 + fx * 2, fy0 + 1, 7.5 + 2 * side, 3.6)
    setColor(shoe); lg.ellipse("fill", fx0 + fx * 2, fy0, 7 + 2 * side, 3.2)
    footY[i] = fy0
  end

  -- torso: leans along the facing; drawn as a rounded body with a lit band
  local lxf, lyf = fwd(lean)
  local shoulderY = hipY - bh
  local chestX, chestY = lxf * 0.6, (hipY + shoulderY) / 2 + lyf * 0.6
  lg.push()
  lg.translate(0, hipY)
  lg.shear(math.max(-0.18, math.min(0.18, lxf / bh)), 0)
  lg.translate(0, -hipY)
  setColor(outline); lg.rectangle("fill", -bw / 2 - 1.3, shoulderY - 1.3, bw + 2.6, bh + 2.6, 10, 10)
  setColor(shirt); lg.rectangle("fill", -bw / 2, shoulderY, bw, bh, 9, 9)
  setColor(lift(shirt, 0.28), 0.9); lg.rectangle("fill", -bw / 2 + 3, shoulderY + 3, bw * 0.38, bh - 6, 6, 6)
  setColor(mix(shirt, 0.82)); lg.rectangle("fill", bw / 2 - 7, shoulderY + 4, 4.5, bh - 8, 3, 3)
  -- collar
  setColor(mix(shirt, 0.75)); lg.ellipse("fill", 0, shoulderY + 1.5, 7, 3)
  lg.pop()

  -- arms: shoulder -> elbow -> hand; the far arm first
  local function armPoints(A, lateral)
    local lx, ly = lat(lateral)
    local sxp, syp = lx + lxf * 0.95, shoulderY + 4 + ly + lyf * 0.95
    local ef, ev = math.sin(A.sh) * upperArm, math.cos(A.sh) * upperArm
    local ea = A.sh + A.el
    local hf, hv = ef + math.sin(ea) * lowerArm, ev + math.cos(ea) * lowerArm
    local efx, efy = fwd(ef); local hfx, hfy = fwd(hf)
    return sxp, syp, sxp + efx, syp + efy + ev, sxp + hfx, syp + hfy + hv
  end
  -- in profile both shoulders project to the same spot, so the near arm is
  -- nudged forward and the far one back to keep them readable
  local arms = { { A = armL, lat = -bw / 2, nudge = -side * 3 }, { A = armR, lat = bw / 2, nudge = side * 3 } }
  if fy < 0 then arms[1], arms[2] = arms[2], arms[1] end
  local function drawArm(arm)
    local s1x, s1y, ex, ey, hx1, hy1 = armPoints(arm.A, arm.lat)
    local nx, ny = fwd(arm.nudge)
    s1x, ex, hx1 = s1x + nx, ex + nx, hx1 + nx
    s1y, ey, hy1 = s1y + ny, ey + ny, hy1 + ny
    limb(s1x, s1y, ex, ey, 7.5, shirt, outline)
    limb(ex, ey, hx1, hy1, 6.5, skin, mix(skin, 0.5))
    setColor(mix(skin, 0.5)); lg.circle("fill", hx1, hy1, 4.6)
    setColor(skin); lg.circle("fill", hx1, hy1, 3.6)
  end
  drawArm(arms[1])

  -- neck + head
  local hx, hy = lxf * 1.2, shoulderY - r * 0.95 + lyf * 1.2
  setColor(mix(skin, 0.5)); lg.rectangle("fill", lxf * 1.1 - 5.5, shoulderY - 7.5, 11, 10, 3, 3)
  setColor(skin); lg.rectangle("fill", lxf * 1.1 - 4.5, shoulderY - 7, 9, 9, 3, 3)
  lg.push()
  lg.translate(hx, hy); lg.rotate(headTilt); lg.translate(-hx, -hy)
  setColor(mix(skin, 0.45)); headShape(a, hx, hy, r * 1.06, "fill")          -- outline
  setColor(mix(skin, 0.82)); headShape(a, hx, hy, r, "fill")                  -- shaded base
  setColor(skin); headShape(a, hx - r * 0.07, hy - r * 0.07, r * 0.94, "fill") -- lit face
  -- ears
  setColor(mix(skin, 0.5)); lg.circle("fill", hx - r * 0.98 * (1 - side * 0.1), hy + r * 0.05, r * 0.18); lg.circle("fill", hx + r * 0.98 * (1 - side * 0.1), hy + r * 0.05, r * 0.18)
  setColor(skin); lg.circle("fill", hx - r * 0.98 * (1 - side * 0.1), hy + r * 0.05, r * 0.14); lg.circle("fill", hx + r * 0.98 * (1 - side * 0.1), hy + r * 0.05, r * 0.14)
  if not back then
    local blink = (math.floor((t + seed) * 0.7) % 7 == 0) and ((t + seed) % 1.4 < 0.1)
    local glance = (math.floor((t + seed) * 0.23) % 5 == 0) and 1 or 0
    face(a, hx, hy, r, fx, side, blink, glance)
  end
  hair(a, hx, hy, r, fx, back)
  lg.pop()

  accessory(a, hx, hy, r, chestX, chestY, bw, fx, back)
  drawArm(arms[2])

  lg.pop()
  lg.setColor(1, 1, 1, 1)
  lg.setLineWidth(1)
end

-- Height of the drawn figure in px for the given scale (feet to top of hair).
function M.height(scale) return 96 * (scale or 1) end

return M
