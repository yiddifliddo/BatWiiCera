-- BatWiiCera Plaza - start menu
-- Version 0.1.1 | Author: Dan Lee | Licence: MIT

local ui = require("src.ui")
local avatar = require("src.avatar")
local config = require("src.config")

local M = {}
M.__index = M

function M.new(opts)
  local m = setmetatable({}, M)
  m.profile = opts.profile
  m.config = opts.config
  m.onEnter = opts.onEnter
  m.onEdit = opts.onEdit
  m.onQuit = opts.onQuit
  m.items = { "Enter the plaza", "Edit avatar", "Server address", "Quit" }
  m.sel = 1
  m.time = 0
  m.keyboard = nil
  m.notice = opts.notice
  return m
end

function M:action(a)
  if self.keyboard then
    self.keyboard:input(a)
    if self.keyboard.done then
      self.config.host = self.keyboard.value:lower():gsub("%s+", "")
      config.saveConfig()
      self.keyboard = nil
    elseif self.keyboard.cancelled then
      self.keyboard = nil
    end
    return
  end
  if a == "up" then self.sel = (self.sel - 2) % #self.items + 1
  elseif a == "down" then self.sel = self.sel % #self.items + 1
  elseif a == "a" or a == "start" then
    if self.sel == 1 then
      if self.config.host == "" then
        self.notice = "Set the server address first"
      elseif self.onEnter then self.onEnter() end
    elseif self.sel == 2 then if self.onEdit then self.onEdit() end
    elseif self.sel == 3 then
      self.keyboard = ui.newKeyboard(self.config.host, 40)
      self.keyboard.lower = true
    elseif self.sel == 4 then if self.onQuit then self.onQuit() end
    end
  elseif a == "b" then
    if self.onQuit then self.onQuit() end
  end
end

function M:update(dt) self.time = self.time + dt end

function M:draw()
  local lg = love.graphics
  local sw, sh = lg.getWidth(), lg.getHeight()
  ui.backdrop(sw, sh)

  ui.text("Plaza", 40, 24, sw - 80, "left", ui.fonts.big)
  ui.text("Meet everyone running BatWiiCera", 42, 76, sw - 80, "left", ui.fonts.body, ui.colors.text2)

  -- menu panel
  local px, py, pw = 40, 130, math.floor(sw * 0.42)
  local rowH = 52
  ui.panel(px, py, pw, #self.items * rowH + 30)
  for i, label in ipairs(self.items) do
    local y = py + 15 + (i - 1) * rowH
    if i == self.sel then ui.col(ui.colors.accent); lg.rectangle("fill", px + 12, y, pw - 24, rowH - 6, 12, 12) end
    ui.text(label, px + 30, y + 13, pw - 60, "left", ui.fonts.body, i == self.sel and ui.colors.white or ui.colors.text)
  end

  -- status card
  local sy = py + #self.items * rowH + 50
  ui.panel(px, sy, pw, 96, 18)
  local host = (self.config.host ~= "" and self.config.host) or "not set"
  ui.text("Server: " .. host, px + 24, sy + 16, pw - 48, "left", ui.fonts.small, ui.colors.text2)
  ui.text("Nickname: " .. self.profile.name, px + 24, sy + 40, pw - 48, "left", ui.fonts.small, ui.colors.text2)
  ui.text("Show my game: " .. (self.profile.share and "yes" or "no"), px + 24, sy + 64, pw - 48, "left", ui.fonts.small, ui.colors.text2)

  -- avatar preview
  local ax, ay, aw, ah = px + pw + 30, 130, sw - (px + pw + 30) - 40, sh - 220
  ui.panel(ax, ay, aw, ah)
  avatar.draw(self.profile.avatar, ax + aw / 2, ay + ah * 0.72, math.min(3, ah / 150), 1, "idle", self.time)
  ui.bubble(self.profile.name, ax + aw / 2, ay + 50, ui.fonts.body)

  if self.notice then
    ui.bubble(self.notice, sw / 2, sh - 70, ui.fonts.body, ui.colors.accent, ui.colors.white)
  end

  if self.keyboard then
    ui.col({ 0, 0, 0, 0.35 }); lg.rectangle("fill", 0, 0, sw, sh)
    self.keyboard:draw(sw / 2 - 300, sh / 2 - 190, 600)
    ui.prompts({ { "A", "Type" }, { "B", "Delete" }, { "X", "Case" }, { "START", "Done" } }, sh - 34, sw)
  else
    ui.prompts({ { "A", "Choose" }, { "B", "Quit" } }, sh - 34, sw)
  end
end

return M
