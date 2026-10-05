-- BatWiiCera Plaza - avatar model and procedural renderer
-- Version 0.1.3 | Author: Dan Lee | Licence: MIT
--
-- An original, simple cartoon figure built from a handful of numbered parts
-- so a whole avatar fits in a few integers (which is what travels over the
-- network). Everything is drawn with primitives: no image assets, no
-- resemblance to any console maker's characters.

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
-- Draws the avatar standing with its feet at (x, y). `scale` 1 = ~96 px tall.
-- `dir` is 1 (facing right) or -1. `anim` is "idle", "run", "jump" or "hit";
-- `t` is a running time used for bobbing and leg swing.
local lg

local function setColor(c, a) lg.setColor(c[1], c[2], c[3], a or 1) end

local function head(a, hx, hy, r)
  local shape = a.head
  if shape == 0 then lg.circle("fill", hx, hy, r)
  elseif shape == 1 then lg.ellipse("fill", hx, hy, r * 0.88, r * 1.08)
  elseif shape == 2 then lg.rectangle("fill", hx - r * 0.92, hy - r * 0.92, r * 1.84, r * 1.84, r * 0.35, r * 0.35)
  else -- heart-ish: wide top, narrower chin
    lg.circle("fill", hx, hy - r * 0.1, r * 0.98)
    lg.polygon("fill", hx - r * 0.95, hy, hx + r * 0.95, hy, hx, hy + r * 1.05)
  end
end

local function hair(a, hx, hy, r, dir)
  if a.hair == 7 then return end -- bald
  setColor(M.hairColors[a.hairColor + 1])
  local s = a.hair
  if s == 0 then       -- short: cap over the top half
    lg.arc("fill", hx, hy - r * 0.05, r * 1.02, math.pi, 2 * math.pi)
  elseif s == 1 then   -- spiky
    lg.arc("fill", hx, hy, r * 1.0, math.pi, 2 * math.pi)
    for i = -2, 2 do
      local bx = hx + i * r * 0.42
      lg.polygon("fill", bx - r * 0.22, hy - r * 0.75, bx + r * 0.22, hy - r * 0.75, bx + i * r * 0.1, hy - r * 1.45)
    end
  elseif s == 2 then   -- bob
    lg.arc("fill", hx, hy, r * 1.08, math.pi, 2 * math.pi)
    lg.rectangle("fill", hx - r * 1.08, hy - r * 0.05, r * 0.32, r * 1.0, r * 0.1, r * 0.1)
    lg.rectangle("fill", hx + r * 0.76, hy - r * 0.05, r * 0.32, r * 1.0, r * 0.1, r * 0.1)
  elseif s == 3 then   -- long
    lg.arc("fill", hx, hy, r * 1.08, math.pi, 2 * math.pi)
    lg.rectangle("fill", hx - r * 1.08, hy - r * 0.1, r * 0.36, r * 1.9, r * 0.15, r * 0.15)
    lg.rectangle("fill", hx + r * 0.72, hy - r * 0.1, r * 0.36, r * 1.9, r * 0.15, r * 0.15)
  elseif s == 4 then   -- curly
    for i = -3, 3 do lg.circle("fill", hx + i * r * 0.32, hy - r * 0.78 + math.abs(i) * r * 0.12, r * 0.34) end
    lg.circle("fill", hx - r * 0.98, hy - r * 0.2, r * 0.3)
    lg.circle("fill", hx + r * 0.98, hy - r * 0.2, r * 0.3)
  elseif s == 5 then   -- bun
    lg.arc("fill", hx, hy, r * 1.02, math.pi, 2 * math.pi)
    lg.circle("fill", hx, hy - r * 1.15, r * 0.36)
  elseif s == 6 then   -- cap
    lg.arc("fill", hx, hy - r * 0.08, r * 1.04, math.pi, 2 * math.pi)
    lg.rectangle("fill", hx - r * 0.2 * dir, hy - r * 0.18, r * 1.3 * dir, r * 0.16, r * 0.08, r * 0.08)
  end
end

local function face(a, hx, hy, r, dir, blink)
  local ex = hx + dir * r * 0.05
  local ey = hy - r * 0.05
  local gap = r * 0.36
  lg.setColor(0.13, 0.11, 0.1)
  local e = a.eyes
  if blink then
    lg.setLineWidth(r * 0.08)
    lg.line(ex - gap - r * 0.14, ey, ex - gap + r * 0.14, ey)
    lg.line(ex + gap - r * 0.14, ey, ex + gap + r * 0.14, ey)
  elseif e == 0 then
    lg.circle("fill", ex - gap, ey, r * 0.09); lg.circle("fill", ex + gap, ey, r * 0.09)
  elseif e == 1 then
    lg.setColor(1, 1, 1); lg.circle("fill", ex - gap, ey, r * 0.2); lg.circle("fill", ex + gap, ey, r * 0.2)
    lg.setColor(0.13, 0.11, 0.1); lg.circle("fill", ex - gap + dir * r * 0.05, ey, r * 0.1); lg.circle("fill", ex + gap + dir * r * 0.05, ey, r * 0.1)
  elseif e == 2 then
    lg.setLineWidth(r * 0.08)
    lg.arc("line", "open", ex - gap, ey + r * 0.05, r * 0.16, math.pi, 2 * math.pi)
    lg.arc("line", "open", ex + gap, ey + r * 0.05, r * 0.16, math.pi, 2 * math.pi)
  elseif e == 3 then
    lg.setLineWidth(r * 0.08)
    lg.arc("line", "open", ex - gap, ey - r * 0.05, r * 0.16, 0, math.pi)
    lg.arc("line", "open", ex + gap, ey - r * 0.05, r * 0.16, 0, math.pi)
  elseif e == 4 then
    lg.circle("fill", ex - gap, ey, r * 0.09)
    lg.setLineWidth(r * 0.08); lg.line(ex + gap - r * 0.14, ey, ex + gap + r * 0.14, ey)
  else -- glasses
    lg.circle("fill", ex - gap, ey, r * 0.08); lg.circle("fill", ex + gap, ey, r * 0.08)
    lg.setLineWidth(r * 0.06)
    lg.circle("line", ex - gap, ey, r * 0.24); lg.circle("line", ex + gap, ey, r * 0.24)
    lg.line(ex - gap + r * 0.24, ey, ex + gap - r * 0.24, ey)
  end
  -- brows
  local b = a.brows
  if b ~= 3 then
    lg.setColor(0.13, 0.11, 0.1)
    lg.setLineWidth(r * 0.07)
    local by = ey - r * 0.32
    if b == 0 then
      lg.line(ex - gap - r * 0.16, by, ex - gap + r * 0.16, by); lg.line(ex + gap - r * 0.16, by, ex + gap + r * 0.16, by)
    elseif b == 1 then
      lg.line(ex - gap - r * 0.16, by + r * 0.05, ex - gap + r * 0.16, by - r * 0.08); lg.line(ex + gap - r * 0.16, by - r * 0.08, ex + gap + r * 0.16, by + r * 0.05)
    else
      lg.line(ex - gap - r * 0.16, by - r * 0.08, ex - gap + r * 0.16, by + r * 0.06); lg.line(ex + gap - r * 0.16, by + r * 0.06, ex + gap + r * 0.16, by - r * 0.08)
    end
  end
  -- mouth
  local m = a.mouth
  local my = hy + r * 0.45
  lg.setColor(0.45, 0.16, 0.16)
  lg.setLineWidth(r * 0.07)
  if m == 0 then lg.arc("line", "open", hx, my - r * 0.08, r * 0.26, 0.15 * math.pi, 0.85 * math.pi)
  elseif m == 1 then lg.arc("fill", hx, my - r * 0.05, r * 0.3, 0, math.pi); lg.setColor(1, 1, 1); lg.rectangle("fill", hx - r * 0.22, my - r * 0.05, r * 0.44, r * 0.09)
  elseif m == 2 then lg.line(hx - r * 0.2, my, hx + r * 0.2, my)
  elseif m == 3 then lg.ellipse("fill", hx, my + r * 0.02, r * 0.16, r * 0.2)
  elseif m == 4 then lg.line(hx - r * 0.18, my + r * 0.04, hx + r * 0.2 * dir, my - r * 0.06)
  else lg.circle("fill", hx + dir * r * 0.05, my, r * 0.09) end
end

local function accessory(a, hx, hy, r, bodyY, bw, dir)
  local acc = a.accessory
  if acc == 1 then
    lg.setColor(0.93, 0.2, 0.2); lg.rectangle("fill", hx - r * 1.02, hy - r * 0.45, r * 2.04, r * 0.18)
  elseif acc == 2 then
    lg.setColor(1, 0.84, 0.2)
    local sx, sy, sr = hx + dir * bw * 0.28, bodyY + r * 0.45, r * 0.16
    local pts = {}
    for i = 0, 9 do
      local ang = -math.pi / 2 + i * math.pi / 5
      local rad = (i % 2 == 0) and sr or sr * 0.45
      pts[#pts + 1] = sx + math.cos(ang) * rad; pts[#pts + 1] = sy + math.sin(ang) * rad
    end
    lg.polygon("fill", pts)
  elseif acc == 3 then
    lg.setColor(0.2, 0.6, 0.9)
    lg.rectangle("fill", hx - bw * 0.55, bodyY - r * 0.05, bw * 1.1, r * 0.26, r * 0.1, r * 0.1)
    lg.rectangle("fill", hx + dir * bw * 0.2 - r * 0.12, bodyY + r * 0.1, r * 0.24, r * 0.7, r * 0.08, r * 0.08)
  end
end

function M.draw(a, x, y, scale, dir, anim, t)
  lg = lg or love.graphics
  a = M.sanitize(a)
  scale = scale or 1; dir = dir or 1; anim = anim or "idle"; t = t or 0
  local r = 22 * scale                     -- head radius
  local bw = 36 * scale                    -- body width
  local bh = 34 * scale                    -- body height
  local legH = 18 * scale
  local bob = 0
  local swing = 0
  if anim == "run" then swing = math.sin(t * 14) ; bob = math.abs(math.sin(t * 14)) * 2 * scale
  elseif anim == "idle" then bob = math.sin(t * 2.2) * 1.2 * scale
  elseif anim == "jump" then swing = 0.6
  elseif anim == "hit" then swing = math.sin(t * 40) * 0.5 end

  local feetY = y
  local bodyY = feetY - legH - bh + bob     -- top of body
  local hx = x
  local hy = bodyY - r * 0.9 + bob * 0.3    -- head centre

  -- shadow
  lg.setColor(0, 0, 0, 0.12)
  lg.ellipse("fill", x, feetY + 2 * scale, bw * 0.7, 5 * scale)

  -- legs
  lg.setColor(0.2, 0.22, 0.3)
  local lw = 9 * scale
  local l1 = swing * 7 * scale
  if anim == "jump" then
    lg.rectangle("fill", x - lw * 1.5, feetY - legH * 0.75 - 4 * scale, lw, legH * 0.75, lw * 0.4, lw * 0.4)
    lg.rectangle("fill", x + lw * 0.5, feetY - legH * 0.75 - 4 * scale, lw, legH * 0.75, lw * 0.4, lw * 0.4)
  else
    lg.rectangle("fill", x - lw * 1.5 + l1, feetY - legH, lw, legH, lw * 0.4, lw * 0.4)
    lg.rectangle("fill", x + lw * 0.5 - l1, feetY - legH, lw, legH, lw * 0.4, lw * 0.4)
  end
  -- shoes
  lg.setColor(0.12, 0.12, 0.14)
  lg.ellipse("fill", x - lw + l1, feetY - 1 * scale, lw * 0.9, 3.5 * scale)
  lg.ellipse("fill", x + lw - l1, feetY - 1 * scale, lw * 0.9, 3.5 * scale)

  -- body (shirt)
  setColor(M.shirtColors[a.shirt + 1])
  lg.rectangle("fill", x - bw / 2, bodyY, bw, bh, 8 * scale, 8 * scale)
  -- arms
  local armSwing = -swing * 8 * scale
  lg.rectangle("fill", x - bw / 2 - 7 * scale, bodyY + 4 * scale + armSwing, 8 * scale, bh * 0.7, 4 * scale, 4 * scale)
  lg.rectangle("fill", x + bw / 2 - 1 * scale, bodyY + 4 * scale - armSwing, 8 * scale, bh * 0.7, 4 * scale, 4 * scale)
  -- hands
  setColor(M.skinTones[a.skin + 1])
  lg.circle("fill", x - bw / 2 - 3 * scale, bodyY + 4 * scale + bh * 0.7 + armSwing, 4.5 * scale)
  lg.circle("fill", x + bw / 2 + 3 * scale, bodyY + 4 * scale + bh * 0.7 - armSwing, 4.5 * scale)

  -- neck + head
  lg.rectangle("fill", x - 5 * scale, bodyY - 6 * scale, 10 * scale, 8 * scale)
  head(a, hx, hy, r)
  -- ears
  lg.circle("fill", hx - r * 0.95, hy + r * 0.05, r * 0.16)
  lg.circle("fill", hx + r * 0.95, hy + r * 0.05, r * 0.16)

  face(a, hx, hy, r, dir, (math.floor(t * 0.7 + x * 0.01) % 7 == 0) and (t % 1.4 < 0.1))
  hair(a, hx, hy, r, dir)
  accessory(a, hx, hy, r, bodyY, bw, dir)
  lg.setColor(1, 1, 1, 1)
  lg.setLineWidth(1)
end

-- Height of the drawn figure in px for the given scale (feet to top of hair).
function M.height(scale) return 96 * (scale or 1) end

return M
