-- BatWiiCera Plaza - input mapping (gamepad + keyboard)
-- Version 0.1.2 | Author: Dan Lee | Licence: MIT
--
-- Actions: up/down/left/right (menus), a (confirm / kick / slap), b (back),
-- x (jump / shift), y (space), start (menu / save), select.
-- Gamepad names follow SDL's layout as exposed by LÖVE; Batocera maps every
-- configured pad to this layout automatically.

local M = {}

M.pad = nil
M.deadzone = 0.35

local keyToAction = {
  up = "up", down = "down", left = "left", right = "right",
  w = "up", s = "down", a = "left", d = "right",
  ["return"] = "a", z = "a", j = "a", space = "x", k = "x",
  escape = "b", backspace = "b", x = "b",
  lshift = "y", tab = "select", m = "start", p = "start",
}
local padToAction = {
  dpup = "up", dpdown = "down", dpleft = "left", dpright = "right",
  a = "a", b = "b", x = "x", y = "y", start = "start", back = "select", guide = "start",
}

function M.load()
  local sticks = love.joystick.getJoysticks()
  for _, j in ipairs(sticks) do
    if j:isGamepad() then M.pad = j; break end
  end
  if not M.pad and sticks[1] then M.pad = sticks[1] end
end

function M.joystickAdded(j) if not M.pad then M.pad = j end end
function M.joystickRemoved(j) if M.pad == j then M.pad = nil; M.load() end end

function M.keyAction(key) return keyToAction[key] end
function M.padAction(button) return padToAction[button] end

-- Continuous movement vector (-1..1 on each axis) from stick, d-pad or keys.
function M.axis()
  local x, y = 0, 0
  local kb = love.keyboard
  if kb.isDown("left") or kb.isDown("a") then x = x - 1 end
  if kb.isDown("right") or kb.isDown("d") then x = x + 1 end
  if kb.isDown("up") or kb.isDown("w") then y = y - 1 end
  if kb.isDown("down") or kb.isDown("s") then y = y + 1 end
  local p = M.pad
  if p then
    if p:isGamepad() then
      local ax, ay = p:getGamepadAxis("leftx"), p:getGamepadAxis("lefty")
      if math.abs(ax) > M.deadzone then x = x + ax end
      if math.abs(ay) > M.deadzone then y = y + ay end
      if p:isGamepadDown("dpleft") then x = x - 1 end
      if p:isGamepadDown("dpright") then x = x + 1 end
      if p:isGamepadDown("dpup") then y = y - 1 end
      if p:isGamepadDown("dpdown") then y = y + 1 end
    else
      local ax, ay = p:getAxis(1) or 0, p:getAxis(2) or 0
      if math.abs(ax) > M.deadzone then x = x + ax end
      if math.abs(ay) > M.deadzone then y = y + ay end
      local hat = p:getHatCount() > 0 and p:getHat(1) or "c"
      if hat:find("l") then x = x - 1 end
      if hat:find("r") then x = x + 1 end
      if hat:find("u") then y = y - 1 end
      if hat:find("d") then y = y + 1 end
    end
  end
  local len = math.sqrt(x * x + y * y)
  if len > 1 then x, y = x / len, y / len end
  return x, y
end

return M
