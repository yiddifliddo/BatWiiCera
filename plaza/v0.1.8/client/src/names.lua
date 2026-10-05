-- BatWiiCera Plaza - generated player names
-- Version 0.1.8 | Author: yiddifliddo | Licence: MIT
--
-- Nobody types a name. Every player is "<Adjective> <Animal> <number>",
-- picked by a hash of the install token and a small "seed" the player can
-- roll again from the avatar editor. The server runs the same code
-- (server/names.js) and ignores anything else a client sends, so the
-- wordlists below are the whole universe of names.
--
-- The hash is a plain polynomial over the bytes modulo a prime: only + * %
-- so Lua 5.1, LuaJIT and JavaScript all agree exactly.

local M = {}

M.adjectives = {
  "Brave", "Swift", "Sunny", "Clever", "Mighty", "Gentle", "Happy", "Lucky", "Jolly", "Nimble",
  "Quiet", "Rapid", "Shiny", "Tidy", "Witty", "Zesty", "Bold", "Calm", "Daring", "Eager",
  "Fancy", "Giant", "Humble", "Icy", "Jazzy", "Keen", "Lively", "Merry", "Noble", "Odd",
  "Plucky", "Quick", "Rosy", "Snappy", "Tiny", "Upbeat", "Vivid", "Wild", "Young", "Zany",
  "Amber", "Breezy", "Cosmic", "Dizzy", "Electric", "Frosty", "Golden", "Hazel", "Indigo", "Jumpy",
  "Kind", "Lunar", "Misty", "Neon", "Orange", "Pixel", "Quirky", "Retro", "Silver", "Turbo",
}

M.animals = {
  "Otter", "Panda", "Tiger", "Koala", "Falcon", "Badger", "Rabbit", "Walrus", "Gecko", "Heron",
  "Lemur", "Moose", "Newt", "Osprey", "Puffin", "Quokka", "Raccoon", "Seal", "Toucan", "Urchin",
  "Viper", "Wombat", "Yak", "Zebra", "Alpaca", "Bison", "Cheetah", "Dolphin", "Eagle", "Ferret",
  "Giraffe", "Hedgehog", "Iguana", "Jaguar", "Kiwi", "Llama", "Meerkat", "Narwhal", "Ocelot", "Penguin",
  "Quail", "Robin", "Sloth", "Turtle", "Owl", "Fox", "Wolf", "Lynx", "Beaver", "Camel",
  "Donkey", "Emu", "Flamingo", "Gorilla", "Hippo", "Ibis", "Jackal", "Kestrel", "Mantis", "Parrot",
}

local MOD = 1000000007

function M.hash(str)
  local h = 7
  for i = 1, #str do
    h = (h * 31 + str:byte(i)) % MOD
  end
  return h
end

-- Deterministic name for an install token and a seed (non-negative integer).
function M.generate(token, seed)
  seed = math.floor(tonumber(seed) or 0)
  if seed < 0 then seed = 0 end
  local h = M.hash(tostring(token) .. ":" .. tostring(seed))
  local h2 = (h * 31 + 17) % MOD
  local adj = M.adjectives[(h % #M.adjectives) + 1]
  local animal = M.animals[(h2 % #M.animals) + 1]
  local num = (math.floor(h2 / #M.animals) % 99) + 1
  return adj .. " " .. animal .. " " .. tostring(num)
end

-- A fresh random seed for a new install or a "new name" roll.
function M.newSeed(rand)
  rand = rand or math.random
  return rand(0, 999999)
end

return M
