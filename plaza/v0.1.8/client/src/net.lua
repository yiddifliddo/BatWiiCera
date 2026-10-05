-- BatWiiCera Plaza - network client (TCP, newline-delimited JSON)
-- Version 0.1.8 | Author: yiddifliddo | Licence: MIT
--
-- Uses LuaSocket, which ships inside LÖVE. The connect itself blocks for at
-- most `connectTimeout` seconds (done when the player presses Enter Plaza, so
-- a short pause is acceptable); after that the socket is non-blocking and
-- polled from love.update. Reconnects with a growing back-off.

local json = require("src.json")

local M = {}
M.__index = M

local hasSocket, socket = pcall(require, "socket")

function M.new(host, port, hello)
  local self = setmetatable({}, M)
  self.host, self.port = host, port
  self.hello = hello               -- table sent as the first message
  self.sock = nil
  self.state = "idle"              -- idle | connecting | connected | failed
  self.error = nil
  self.buffer = ""
  self.inbox = {}
  self.backoff = 1
  self.retryAt = 0
  self.connectTimeout = 3
  self.autoReconnect = true
  self.rtt = nil
  self.lastPing = 0
  self.stats = { sent = 0, received = 0 }
  return self
end

function M.available() return hasSocket end

function M:connect()
  if not hasSocket then
    self.state, self.error = "failed", "LuaSocket not available in this LÖVE build"
    return false
  end
  if self.host == nil or self.host == "" then
    self.state, self.error = "failed", "No server configured"
    return false
  end
  self.state, self.error = "connecting", nil
  local s = socket.tcp()
  s:settimeout(self.connectTimeout)
  local ok, err = s:connect(self.host, self.port)
  if not ok then
    s:close()
    self.state, self.error = "failed", tostring(err)
    self.retryAt = (love and love.timer and love.timer.getTime() or os.time()) + self.backoff
    self.backoff = math.min(self.backoff * 2, 20)
    return false
  end
  s:settimeout(0)
  s:setoption("tcp-nodelay", true)
  s:setoption("keepalive", true)
  self.sock = s
  self.state = "connected"
  self.buffer = ""
  self.backoff = 1
  if self.hello then self:send(self.hello) end
  return true
end

function M:close()
  self.autoReconnect = false
  if self.sock then self.sock:close(); self.sock = nil end
  self.state = "idle"
end

function M:disconnected(reason)
  if self.sock then self.sock:close(); self.sock = nil end
  self.state, self.error = "failed", reason
  self.retryAt = (love and love.timer and love.timer.getTime() or os.time()) + self.backoff
  self.backoff = math.min(self.backoff * 2, 20)
end

function M:send(tbl)
  if self.state ~= "connected" or not self.sock then return false end
  local line = json.encode(tbl) .. "\n"
  local sent, err, partial = self.sock:send(line)
  if not sent then
    if err == "timeout" then
      -- Non-blocking send could not take the whole line: keep the rest.
      self.pending = (self.pending or "") .. line:sub((partial or 0) + 1)
      return true
    end
    self:disconnected(tostring(err))
    return false
  end
  self.stats.sent = self.stats.sent + 1
  return true
end

local function flushPending(self)
  if not self.pending or self.pending == "" then return end
  local sent, err, partial = self.sock:send(self.pending)
  if sent then self.pending = nil
  elseif err == "timeout" then self.pending = self.pending:sub((partial or 0) + 1)
  else self:disconnected(tostring(err)) end
end

-- Pulls everything the socket has, splits into lines, decodes into inbox.
function M:update(now)
  if self.state == "failed" and self.autoReconnect and self.host ~= "" and now >= self.retryAt then
    self:connect()
  end
  if self.state ~= "connected" or not self.sock then return end
  flushPending(self)
  while true do
    local data, err, partial = self.sock:receive(8192)
    local chunk = data or partial
    if chunk and #chunk > 0 then
      self.buffer = self.buffer .. chunk
      if #self.buffer > 1024 * 1024 then self:disconnected("server flooded the connection"); return end
    end
    if err == "closed" then self:disconnected("connection closed"); return end
    if not data then break end -- timeout: nothing more right now
  end
  while true do
    local nl = self.buffer:find("\n", 1, true)
    if not nl then break end
    local line = self.buffer:sub(1, nl - 1)
    self.buffer = self.buffer:sub(nl + 1)
    if #line > 0 then
      local ok, msg = pcall(json.decode, line)
      if ok and type(msg) == "table" then
        self.stats.received = self.stats.received + 1
        if msg.t == "pong" and msg.at then
          self.rtt = (now - tonumber(msg.at)) * 1000
        else
          self.inbox[#self.inbox + 1] = msg
        end
      end
    end
  end
  if now - self.lastPing > 10 then
    self.lastPing = now
    self:send({ t = "ping", at = now })
  end
end

-- Returns and clears queued messages.
function M:poll()
  local msgs = self.inbox
  self.inbox = {}
  return msgs
end

return M
