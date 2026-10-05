-- Runs the client self-test under plain Lua 5.1 / LuaJIT with a stub `love`.
-- Usage (from the client folder):  lua5.1 test/run.lua
package.path = "./?.lua;./?/init.lua;" .. package.path

local noop = function() end
local stubGraphics = setmetatable({}, { __index = function() return noop end })
stubGraphics.getWidth = function() return 1280 end
stubGraphics.getHeight = function() return 720 end
stubGraphics.newFont = function() return { getWidth = function() return 10 end, getHeight = function() return 12 end } end

love = {
  graphics = stubGraphics,
  timer = { getTime = function() return os.clock() end },
  math = { random = math.random },
  keyboard = { isDown = function() return false end },
  joystick = { getJoysticks = function() return {} end },
  filesystem = {
    _store = {},
    getInfo = function(name) return love.filesystem._store[name] and {} or nil end,
    read = function(name) return love.filesystem._store[name] end,
    write = function(name, data) love.filesystem._store[name] = data; return true end,
    getSaveDirectory = function() return "/tmp" end,
  },
  event = { quit = noop },
}

local ok, result = pcall(function()
  local n = require("test.selftest").run()
  -- config module: token generation and round trip through the stub filesystem
  local config = require("src.config")
  local cfg, prof = config.load()
  assert(#prof.token == 32, "token generated")
  assert(cfg.tcpPort == 7777, "default port")
  prof.name = "Dan"; config.saveProfile()
  local again = select(2, config.load())
  assert(again.name == "Dan" and again.token == prof.token, "profile persisted")
  local h, pt = config.parseHostPort("shuttle.proxy.rlwy.net:15140"); assert(h == "shuttle.proxy.rlwy.net" and pt == 15140, "host:port parsed")
  h, pt = config.parseHostPort("203.0.113.5"); assert(h == "203.0.113.5" and pt == nil, "bare host parsed")
  config.config.host = "1.2.3.4"; config.config.presenceUrl = ""; assert(config.presenceBase() == "http://1.2.3.4:7778", "presence from host:port")
  config.config.presenceUrl = "https://x.up.railway.app"; assert(config.presenceBase() == "https://x.up.railway.app", "presence from url")
  return n + 7
end)

if ok then
  print("client selftest: " .. result .. " checks passed")
  os.exit(0)
else
  print("client selftest FAILED: " .. tostring(result))
  os.exit(1)
end
