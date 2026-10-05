-- BatWiiCera Plaza - avatar editor and profile screen
-- Version 0.1.9 | Author: yiddifliddo | Licence: MIT
--
-- Controller driven. Left column lists the parts and settings; up/down
-- selects a row, left/right changes it, the big preview on the right updates
-- live. START saves, B goes back without saving, Y randomises the look.
-- Names are generated (see names.lua): the Name row rolls a new one.

local avatar = require("src.avatar")
local ui = require("src.ui")
local config = require("src.config")

local M = {}
M.__index = M

function M.new(opts)
  local e = setmetatable({}, M)
  e.profile = opts.profile
  e.onDone = opts.onDone          -- called with (saved:boolean)
  e.working = avatar.sanitize(opts.profile.avatar)
  e.name = opts.profile.name
  e.nameSeed = opts.profile.nameSeed
  e.previewT = 0
  e.share = opts.profile.share
  e.colors = opts.profile.colors or "auto"
  e.row = 1
  e.keyboard = nil
  e.time = 0
  e.rows = {}
  for _, p in ipairs(avatar.parts) do e.rows[#e.rows + 1] = { kind = "part", key = p.key, label = p.label, n = p.n } end
  e.rows[#e.rows + 1] = { kind = "name", label = "Name (press A for a new one)" }
  e.rows[#e.rows + 1] = { kind = "share", label = "Show my game" }
  e.rows[#e.rows + 1] = { kind = "colors", label = "Colours" }
  e.rows[#e.rows + 1] = { kind = "random", label = "Randomise" }
  e.rows[#e.rows + 1] = { kind = "save", label = "Save and return" }
  return e
end

function M:valueText(r)
  if r.kind == "part" then
    local v = self.working[r.key]
    return avatar.optionName(r.key, v)
  elseif r.kind == "name" then return self.name
  elseif r.kind == "share" then return self.share and "Yes" or "No"
  elseif r.kind == "colors" then return ({ auto = "Match theme", light = "Light", dark = "Dark" })[self.colors]
  end
  return ""
end

function M:rollName()
  local config = require("src.config")
  local keepSeed, keepName = self.profile.nameSeed, self.profile.name
  self.name = config.rollName()
  self.nameSeed = self.profile.nameSeed
  -- rollName works on the live profile; restore it until the player saves
  self.profile.nameSeed, self.profile.name = keepSeed, keepName
end

function M:change(r, delta)
  if r.kind == "name" then
    self:rollName()
  elseif r.kind == "part" then
    self.working[r.key] = (self.working[r.key] + delta) % r.n
  elseif r.kind == "share" then
    self.share = not self.share
  elseif r.kind == "colors" then
    local order = { "auto", "light", "dark" }
    local i = 1
    for k, v in ipairs(order) do if v == self.colors then i = k end end
    self.colors = order[(i - 1 + delta) % 3 + 1]
  end
end

function M:save()
  self.profile.avatar = avatar.sanitize(self.working)
  self.profile.nameSeed = self.nameSeed
  self.profile.name = self.name
  self.profile.share = self.share
  self.profile.colors = self.colors
  config.saveProfile()
  if self.onDone then self.onDone(true) end
end

function M:action(a)
  local r = self.rows[self.row]
  if a == "up" then self.row = (self.row - 2) % #self.rows + 1
  elseif a == "down" then self.row = self.row % #self.rows + 1
  elseif a == "left" then self:change(r, -1)
  elseif a == "right" then self:change(r, 1)
  elseif a == "a" then
    if r.kind == "name" then self:rollName()
    elseif r.kind == "random" then self.working = avatar.random(love.math.random)
    elseif r.kind == "save" then self:save()
    else self:change(r, 1) end
  elseif a == "y" then self.working = avatar.random(love.math.random)
  elseif a == "start" then self:save()
  elseif a == "b" then
    if self.onDone then self.onDone(false) end
  end
end

function M:update(dt) self.time = self.time + dt; self.previewT = self.previewT + dt end

function M:draw()
  local lg = love.graphics
  local sw, sh = lg.getWidth(), lg.getHeight()
  ui.backdrop(sw, sh)
  ui.text("Your avatar", 40, 26, sw - 80, "left", ui.fonts.title)

  -- settings list
  local lx, ly, lw = 40, 80, math.floor(sw * 0.46)
  local rowH = 40
  ui.panel(lx, ly, lw, #self.rows * rowH + 30)
  for i, r in ipairs(self.rows) do
    local y = ly + 15 + (i - 1) * rowH
    if i == self.row then
      ui.col(ui.colors.accent)
      lg.rectangle("fill", lx + 12, y, lw - 24, rowH - 4, 10, 10)
    end
    local fg = (i == self.row) and ui.colors.white or ui.colors.text
    ui.text(r.label, lx + 28, y + 9, lw * 0.5, "left", ui.fonts.body, fg)
    local v = self:valueText(r)
    if r.kind == "part" or r.kind == "share" or r.kind == "colors" then v = "<  " .. v .. "  >" end
    ui.text(v, lx + lw * 0.45, y + 9, lw * 0.5 - 30, "right", ui.fonts.body, fg)
  end

  -- preview
  local px, py, pw, ph = lx + lw + 30, 80, sw - (lx + lw + 30) - 40, sh - 160
  ui.panel(px, py, pw, ph)
  -- the preview turns slowly and jogs on the spot so the look can be judged in motion
  local scale = math.min(3.0, ph / 150)
  local facing = (self.previewT * 28) % 360
  local cycle = math.floor(self.previewT / 4) % 2 == 1
  avatar.draw(self.working, px + pw / 2, py + ph * 0.74, scale, facing, cycle and "run" or "idle", self.previewT, { speed = cycle and 0.8 or 0 })
  ui.bubble(self.name ~= "" and self.name or "Player", px + pw / 2, py + 54, ui.fonts.body)
  ui.text("Names are picked for you. Press A on the Name row for another.", px + 20, py + ph - 36, pw - 40, "center", ui.fonts.small, ui.colors.muted)

  ui.prompts({ { "<>", "Change" }, { "A", "Select" }, { "Y", "Random" }, { "START", "Save" }, { "B", "Back" } }, sh - 34, sw)
end

return M
