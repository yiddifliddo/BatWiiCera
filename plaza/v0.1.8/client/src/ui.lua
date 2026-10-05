-- BatWiiCera Plaza - small UI toolkit (panels, prompts, on-screen keyboard)
-- Version 0.1.8 | Author: yiddifliddo | Licence: MIT
--
-- Visual language borrowed from the BatWiiCera theme: light striped
-- backdrop, white rounded panels with a soft grey border, sky-blue accents.

local M = {}

local function hex(h)
  return { tonumber(h:sub(1, 2), 16) / 255, tonumber(h:sub(3, 4), 16) / 255, tonumber(h:sub(5, 6), 16) / 255 }
end

-- Palettes copied from the BatWiiCera theme colour sets (classic.xml / dark.xml)
-- so the Plaza matches whichever set the player uses in EmulationStation.
M.palettes = {
  light = {
    bg = hex("ECECEC"), bgLine = hex("DFDFDF"), floor = hex("F5F5F5"), tile = hex("E6E6E7"),
    panel = hex("FFFFFF"), border = hex("C9C9C9"),
    text = hex("4A4A4A"), text2 = hex("7A7A7A"), muted = hex("9A9A9A"),
    accent = hex("4FB8F4"), accentL = hex("7CCDF8"), accentD = hex("2E95D8"),
    white = hex("FFFFFF"), shadow = { 0, 0, 0, 0.12 }, bubble = hex("FFFFFF"), myBubble = hex("EDF7FE"),
    -- stadium (day)
    grass1 = hex("5FAE4E"), grass2 = hex("57A347"), line = hex("F4F8F0"), track = hex("C8745A"), trackLine = hex("E9C9BD"),
    concrete = hex("D9D9D9"), stand1 = hex("CFCFD2"), stand2 = hex("BDBEC3"), standEdge = hex("A9AAB0"), roof = hex("E8E8EA"),
    net = hex("F2F2F2"), post = hex("FFFFFF"), scoreBg = hex("2C3440"), scoreFg = hex("F7F7F7"), sky = hex("E3EEF6"),
    crowd = { hex("E2473B"), hex("3B8BE2"), hex("F2B705"), hex("FFFFFF"), hex("34495E"), hex("3DB34A"), hex("F28C28"), hex("8E44AD") },
  },
  dark = {
    bg = hex("2A2A2A"), bgLine = hex("232323"), floor = hex("343434"), tile = hex("3C3C3D"),
    panel = hex("3A3A3A"), border = hex("5A5A5A"),
    text = hex("E6E6E6"), text2 = hex("B8B8B8"), muted = hex("8E8E8E"),
    accent = hex("4FB8F4"), accentL = hex("7CCDF8"), accentD = hex("6EC4F6"),
    white = hex("FFFFFF"), shadow = { 0, 0, 0, 0.35 }, bubble = hex("444444"), myBubble = hex("27455A"),
    -- stadium (evening, under the lights)
    grass1 = hex("3E8A3F"), grass2 = hex("377F38"), line = hex("E6EEE2"), track = hex("8F5543"), trackLine = hex("B99287"),
    concrete = hex("4A4A4D"), stand1 = hex("55565B"), stand2 = hex("47484D"), standEdge = hex("3A3B3F"), roof = hex("5E5F64"),
    net = hex("D8D8D8"), post = hex("F2F2F2"), scoreBg = hex("15191F"), scoreFg = hex("F7F7F7"), sky = hex("1E2430"),
    crowd = { hex("E2473B"), hex("3B8BE2"), hex("F2B705"), hex("E6E6E6"), hex("9AA7B5"), hex("3DB34A"), hex("F28C28"), hex("8E44AD") },
  },
}

M.colors = M.palettes.light
M.mode = "light"

function M.setPalette(name)
  M.colors = M.palettes[name] or M.palettes.light
  M.mode = M.palettes[name] and name or "light"
end

-- Reads EmulationStation's settings to find the theme colour set in use.
-- Returns "dark" or "light"; nil if the file cannot be read.
function M.detectThemeMode(path)
  path = path or "/userdata/system/configs/emulationstation/es_settings.cfg"
  local f = io.open(path, "r")
  if not f then return nil end
  local data = f:read("*a") or ""
  f:close()
  local v = data:match('name="subset%.colorset"%s+value="([^"]*)"')
  if not v then return "light" end
  return (v == "dark") and "dark" or "light"
end

M.fonts = {}

function M.load()
  local lg = love.graphics
  local function font(size) return lg.newFont(size) end
  M.fonts.small = font(14)
  M.fonts.body = font(18)
  M.fonts.title = font(30)
  M.fonts.big = font(44)
  M.fonts.label = font(13)
end

local function col(c, a)
  love.graphics.setColor(c[1], c[2], c[3], a or c[4] or 1)
end
M.col = col

-- Striped light backdrop like the theme.
function M.backdrop(w, h)
  local lg = love.graphics
  col(M.colors.bg)
  lg.rectangle("fill", 0, 0, w, h)
  col(M.colors.bgLine)
  for y = 0, h, 4 do lg.rectangle("fill", 0, y, w, 1) end
end

function M.panel(x, y, w, h, r)
  local lg = love.graphics
  r = r or 22
  col(M.colors.shadow)
  lg.rectangle("fill", x + 3, y + 5, w, h, r, r)
  col(M.colors.border)
  lg.rectangle("fill", x, y, w, h, r, r)
  col(M.colors.panel)
  lg.rectangle("fill", x + 3, y + 3, w - 6, h - 6, r - 3, r - 3)
end

function M.pill(x, y, w, h, filled)
  local lg = love.graphics
  local r = h / 2
  if filled then
    col(M.colors.accentD); lg.rectangle("fill", x, y, w, h, r, r)
    col(M.colors.accent); lg.rectangle("fill", x + 3, y + 3, w - 6, h - 6, r - 3, r - 3)
  else
    col(M.colors.border); lg.rectangle("fill", x, y, w, h, r, r)
    col(M.colors.panel); lg.rectangle("fill", x + 3, y + 3, w - 6, h - 6, r - 3, r - 3)
  end
end

function M.text(str, x, y, w, align, font, color)
  local lg = love.graphics
  lg.setFont(font or M.fonts.body)
  col(color or M.colors.text)
  lg.printf(str, x, y, w, align or "left")
end

-- Text with a soft dark edge, for banners over busy backgrounds.
function M.textOutlined(str, x, y, w, align, font, color, edge)
  local lg = love.graphics
  lg.setFont(font or M.fonts.title)
  col(edge or { 0, 0, 0, 0.45 })
  for dx = -2, 2, 2 do for dy = -2, 2, 2 do if dx ~= 0 or dy ~= 0 then lg.printf(str, x + dx, y + dy, w, align or "center") end end end
  col(color or M.colors.white)
  lg.printf(str, x, y, w, align or "center")
end

-- A row of "button: label" prompts along the bottom, centred.
function M.prompts(list, y, w)
  local lg = love.graphics
  local f = M.fonts.small
  lg.setFont(f)
  local total = 0
  local gap = 26
  for _, p in ipairs(list) do total = total + f:getWidth(p[1]) + 10 + f:getWidth(p[2]) + gap end
  local x = (w - total) / 2
  for _, p in ipairs(list) do
    local bw = f:getWidth(p[1]) + 12
    M.pill(x, y - 2, bw, 22, true)
    col(M.colors.white); lg.print(p[1], x + 6, y + 1)
    x = x + bw + 6
    col(M.colors.text2); lg.print(p[2], x, y + 1)
    x = x + f:getWidth(p[2]) + gap
  end
end

-- Same prompts with white labels, for dark strips over the pitch.
function M.promptsLight(list, y, w)
  local keep = M.colors.text2
  M.colors.text2 = M.colors.white
  M.prompts(list, y, w)
  M.colors.text2 = keep
end

-- Speech-bubble style label above a head.
function M.bubble(str, cx, y, font, bg, fg)
  local lg = love.graphics
  font = font or M.fonts.small
  lg.setFont(font)
  local tw = font:getWidth(str) + 16
  local th = font:getHeight() + 8
  local x = cx - tw / 2
  col(bg or M.colors.bubble)
  lg.rectangle("fill", x, y - th, tw, th, th / 2, th / 2)
  col(M.colors.border)
  lg.rectangle("line", x, y - th, tw, th, th / 2, th / 2)
  col(fg or M.colors.text)
  lg.print(str, x + 8, y - th + 4)
end

-- On-screen keyboard -------------------------------------------------------
local Keyboard = {}
Keyboard.__index = Keyboard

local rows = {
  { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J" },
  { "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T" },
  { "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3" },
  { "4", "5", "6", "7", "8", "9", "-", "_", ".", " " },
}

function M.newKeyboard(initial, maxLen)
  local k = setmetatable({}, Keyboard)
  k.value = initial or ""
  k.maxLen = maxLen or 14
  k.row, k.col = 1, 1
  k.lower = false
  k.done = false
  k.cancelled = false
  return k
end

function Keyboard:current()
  local c = rows[self.row][self.col]
  if self.lower and c:match("%a") then c = c:lower() end
  return c
end

function Keyboard:input(action)
  if action == "up" then self.row = (self.row - 2) % #rows + 1
  elseif action == "down" then self.row = self.row % #rows + 1
  elseif action == "left" then self.col = (self.col - 2) % #rows[1] + 1
  elseif action == "right" then self.col = self.col % #rows[1] + 1
  elseif action == "a" then
    if #self.value < self.maxLen then self.value = self.value .. self:current() end
  elseif action == "b" then
    if #self.value > 0 then self.value = self.value:sub(1, -2) else self.cancelled = true end
  elseif action == "x" then self.lower = not self.lower
  elseif action == "y" then
    if #self.value < self.maxLen then self.value = self.value .. " " end
  elseif action == "start" then
    self.done = true
  end
end

function Keyboard:draw(x, y, w)
  local lg = love.graphics
  local cell = math.floor((w - 20) / #rows[1])
  local h = cell * #rows + 20
  M.panel(x, y, w, h + 70)
  M.text(self.value .. "_", x + 20, y + 16, w - 40, "left", M.fonts.title)
  for r, row in ipairs(rows) do
    for c, ch in ipairs(row) do
      local cx = x + 10 + (c - 1) * cell
      local cy = y + 64 + (r - 1) * cell
      local sel = (r == self.row and c == self.col)
      if sel then col(M.colors.accent) else col(M.colors.bg) end
      lg.rectangle("fill", cx + 3, cy + 3, cell - 6, cell - 6, 8, 8)
      local label = (ch == " ") and "sp" or ((self.lower and ch:match("%a")) and ch:lower() or ch)
      lg.setFont(M.fonts.body)
      col(sel and M.colors.white or M.colors.text)
      lg.printf(label, cx, cy + cell / 2 - 10, cell, "center")
    end
  end
  return h + 70
end

M.Keyboard = Keyboard
return M
