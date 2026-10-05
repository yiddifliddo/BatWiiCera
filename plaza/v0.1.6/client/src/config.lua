-- BatWiiCera Plaza - profile and settings storage
-- Version 0.1.6 | Author: yiddifliddo | Licence: MIT
--
-- Two files in the LÖVE save folder (~/.local/share/love/batwiicera-plaza,
-- which on Batocera is /userdata/system/.local/share/love/batwiicera-plaza):
--
--   config.json   server host/ports. Pre-filled with the public BatWiiCera
--                 server below, written by the installer or the client on
--                 first run, editable by the player from the menu.
--   profile.json  token, nickname, avatar, "share my game" flag. The presence
--                 hook script reads the token from here.

local json = require("src.json")
local avatar = require("src.avatar")

local M = {}

-- The public BatWiiCera Plaza server (Railway). Nothing has to be typed on
-- the TV; "Server address" in the menu overrides it for private servers.
M.PUBLIC_HOST = "maglev.proxy.rlwy.net"
M.PUBLIC_TCP_PORT = 28071
M.PUBLIC_PRESENCE_URL = "https://batwiicera-production.up.railway.app"

M.defaults = {
  config = { host = M.PUBLIC_HOST, tcpPort = M.PUBLIC_TCP_PORT, httpPort = 7778, presenceUrl = M.PUBLIC_PRESENCE_URL },
  profile = { token = "", name = "Player", avatar = avatar.default(), share = true, music = true, colors = "auto" }
}

local function copy(t)
  local o = {}
  for k, v in pairs(t) do o[k] = (type(v) == "table") and copy(v) or v end
  return o
end

local function readJson(name)
  if not love.filesystem.getInfo(name) then return nil end
  local data = love.filesystem.read(name)
  if not data or data == "" then return nil end
  local ok, obj = pcall(json.decode, data)
  if ok and type(obj) == "table" then return obj end
  return nil
end

local function writeJson(name, obj)
  return love.filesystem.write(name, json.encode(obj))
end

function M.newToken()
  local rnd = (love.math and love.math.random) or math.random
  local hex = "0123456789abcdef"
  local out = {}
  for i = 1, 32 do
    local n = rnd(1, 16)
    out[i] = hex:sub(n, n)
  end
  return table.concat(out)
end

function M.load()
  local cfg = copy(M.defaults.config)
  local saved = readJson("config.json")
  if saved then
    if type(saved.host) == "string" then cfg.host = saved.host end
    if tonumber(saved.tcpPort) then cfg.tcpPort = tonumber(saved.tcpPort) end
    if tonumber(saved.httpPort) then cfg.httpPort = tonumber(saved.httpPort) end
    if type(saved.presenceUrl) == "string" then cfg.presenceUrl = saved.presenceUrl end
  end

  local prof = copy(M.defaults.profile)
  local sp = readJson("profile.json")
  local dirty = false
  if sp then
    if type(sp.token) == "string" and #sp.token >= 16 then prof.token = sp.token end
    if type(sp.name) == "string" and sp.name ~= "" then prof.name = sp.name:sub(1, 14) end
    prof.avatar = avatar.sanitize(sp.avatar)
    if type(sp.share) == "boolean" then prof.share = sp.share end
    if type(sp.music) == "boolean" then prof.music = sp.music end
    if sp.colors == "auto" or sp.colors == "light" or sp.colors == "dark" then prof.colors = sp.colors end
  end
  if prof.token == "" then
    prof.token = M.newToken()
    dirty = true
  end
  M.config, M.profile = cfg, prof
  if dirty then M.saveProfile() end
  if not love.filesystem.getInfo("config.json") then M.saveConfig() end
  return cfg, prof
end

function M.saveConfig() return writeJson("config.json", M.config) end

-- "host", "host:port" or "[v6]:port" -> host, port (port nil if absent)
function M.parseHostPort(text)
  text = (text or ""):gsub("%s+", "")
  local h, p = text:match("^%[(.+)%]:(%d+)$")
  if h then return h, tonumber(p) end
  h, p = text:match("^([^:]+):(%d+)$")
  if h then return h, tonumber(p) end
  return text, nil
end

-- Where the presence hook posts: explicit URL (PaaS) or host:httpPort (VPS).
function M.presenceBase()
  local c = M.config
  if c.presenceUrl and c.presenceUrl ~= "" then return c.presenceUrl end
  return "http://" .. c.host .. ":" .. tostring(c.httpPort)
end
function M.saveProfile() return writeJson("profile.json", M.profile) end

function M.saveDirectory() return love.filesystem.getSaveDirectory() end

return M
