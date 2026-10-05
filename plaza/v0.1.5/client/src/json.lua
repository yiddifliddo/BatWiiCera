-- BatWiiCera Plaza - minimal JSON encoder/decoder (pure Lua 5.1 / LuaJIT)
-- Version 0.1.5 | Author: yiddifliddo | Licence: MIT
--
-- Covers what the Plaza protocol needs: objects, arrays, strings with
-- escapes, numbers, booleans and null. Arrays are Lua tables with
-- consecutive integer keys starting at 1; an empty table encodes as [].
-- JSON null decodes to json.null (a unique sentinel) so it survives in tables.

local json = {}
json.null = setmetatable({}, { __tostring = function() return "null" end })

local escapes = { ['"'] = '\\"', ['\\'] = '\\\\', ['\b'] = '\\b', ['\f'] = '\\f', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t' }

local function encodeString(s)
  return '"' .. s:gsub('[%c"\\]', function(c)
    return escapes[c] or string.format('\\u%04x', c:byte())
  end) .. '"'
end

local function isArray(t)
  local n = 0
  for k in pairs(t) do
    if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then return false end
    n = n + 1
  end
  return n == #t
end

local function encode(v, out)
  local tv = type(v)
  if v == json.null or v == nil then out[#out + 1] = "null"
  elseif tv == "boolean" then out[#out + 1] = v and "true" or "false"
  elseif tv == "number" then
    if v ~= v or v == math.huge or v == -math.huge then out[#out + 1] = "null"
    elseif math.floor(v) == v and math.abs(v) < 1e15 then out[#out + 1] = string.format("%d", v)
    else out[#out + 1] = string.format("%.6g", v) end
  elseif tv == "string" then out[#out + 1] = encodeString(v)
  elseif tv == "table" then
    if isArray(v) then
      out[#out + 1] = "["
      for i = 1, #v do
        if i > 1 then out[#out + 1] = "," end
        encode(v[i], out)
      end
      out[#out + 1] = "]"
    else
      out[#out + 1] = "{"
      local first = true
      for k, val in pairs(v) do
        if not first then out[#out + 1] = "," end
        first = false
        out[#out + 1] = encodeString(tostring(k))
        out[#out + 1] = ":"
        encode(val, out)
      end
      out[#out + 1] = "}"
    end
  else
    error("json: cannot encode " .. tv)
  end
end

function json.encode(v)
  local out = {}
  encode(v, out)
  return table.concat(out)
end

-- Decoder ------------------------------------------------------------------
local function decodeError(str, pos, msg)
  error(string.format("json: %s at position %d (%s)", msg, pos, str:sub(math.max(1, pos - 10), pos + 10)))
end

local function skipWs(str, pos)
  local _, e = str:find("^[ \n\r\t]*", pos)
  return e + 1
end

local unescape = { ['"'] = '"', ['\\'] = '\\', ['/'] = '/', b = '\b', f = '\f', n = '\n', r = '\r', t = '\t' }

local function utf8char(cp)
  if cp < 0x80 then return string.char(cp)
  elseif cp < 0x800 then return string.char(0xC0 + math.floor(cp / 0x40), 0x80 + cp % 0x40)
  elseif cp < 0x10000 then return string.char(0xE0 + math.floor(cp / 0x1000), 0x80 + math.floor(cp / 0x40) % 0x40, 0x80 + cp % 0x40)
  else return string.char(0xF0 + math.floor(cp / 0x40000), 0x80 + math.floor(cp / 0x1000) % 0x40, 0x80 + math.floor(cp / 0x40) % 0x40, 0x80 + cp % 0x40) end
end

local decodeValue

local function decodeString(str, pos)
  local out, i = {}, pos + 1
  while true do
    local c = str:sub(i, i)
    if c == "" then decodeError(str, i, "unterminated string") end
    if c == '"' then return table.concat(out), i + 1 end
    if c == "\\" then
      local n = str:sub(i + 1, i + 1)
      if n == "u" then
        local hex = str:sub(i + 2, i + 5)
        if not hex:match("^%x%x%x%x$") then decodeError(str, i, "bad unicode escape") end
        local cp = tonumber(hex, 16)
        i = i + 6
        if cp >= 0xD800 and cp <= 0xDBFF and str:sub(i, i + 1) == "\\u" then
          local lo = tonumber(str:sub(i + 2, i + 5), 16)
          if lo and lo >= 0xDC00 and lo <= 0xDFFF then
            cp = 0x10000 + (cp - 0xD800) * 0x400 + (lo - 0xDC00)
            i = i + 6
          end
        end
        out[#out + 1] = utf8char(cp)
      else
        local u = unescape[n]
        if not u then decodeError(str, i, "bad escape") end
        out[#out + 1] = u
        i = i + 2
      end
    else
      out[#out + 1] = c
      i = i + 1
    end
  end
end

local function decodeNumber(str, pos)
  local s, e = str:find("^-?%d+%.?%d*[eE]?[+-]?%d*", pos)
  if not s then decodeError(str, pos, "bad number") end
  local n = tonumber(str:sub(s, e))
  if not n then decodeError(str, pos, "bad number") end
  return n, e + 1
end

decodeValue = function(str, pos)
  pos = skipWs(str, pos)
  local c = str:sub(pos, pos)
  if c == "{" then
    local obj = {}
    pos = skipWs(str, pos + 1)
    if str:sub(pos, pos) == "}" then return obj, pos + 1 end
    while true do
      pos = skipWs(str, pos)
      if str:sub(pos, pos) ~= '"' then decodeError(str, pos, "expected key") end
      local key
      key, pos = decodeString(str, pos)
      pos = skipWs(str, pos)
      if str:sub(pos, pos) ~= ":" then decodeError(str, pos, "expected ':'") end
      local val
      val, pos = decodeValue(str, pos + 1)
      obj[key] = val
      pos = skipWs(str, pos)
      local d = str:sub(pos, pos)
      if d == "}" then return obj, pos + 1 end
      if d ~= "," then decodeError(str, pos, "expected ',' or '}'") end
      pos = pos + 1
    end
  elseif c == "[" then
    local arr = {}
    pos = skipWs(str, pos + 1)
    if str:sub(pos, pos) == "]" then return arr, pos + 1 end
    while true do
      local val
      val, pos = decodeValue(str, pos)
      arr[#arr + 1] = val
      pos = skipWs(str, pos)
      local d = str:sub(pos, pos)
      if d == "]" then return arr, pos + 1 end
      if d ~= "," then decodeError(str, pos, "expected ',' or ']'") end
      pos = pos + 1
    end
  elseif c == '"' then
    return decodeString(str, pos)
  elseif c == "-" or c:match("%d") then
    return decodeNumber(str, pos)
  elseif str:sub(pos, pos + 3) == "true" then return true, pos + 4
  elseif str:sub(pos, pos + 4) == "false" then return false, pos + 5
  elseif str:sub(pos, pos + 3) == "null" then return json.null, pos + 4
  end
  decodeError(str, pos, "unexpected character")
end

function json.decode(str)
  if type(str) ~= "string" then error("json: expected string") end
  local v, pos = decodeValue(str, 1)
  pos = skipWs(str, pos)
  if pos <= #str then decodeError(str, pos, "trailing data") end
  return v
end

-- Convenience: treat json.null and nil alike.
function json.isNull(v) return v == nil or v == json.null end

return json
