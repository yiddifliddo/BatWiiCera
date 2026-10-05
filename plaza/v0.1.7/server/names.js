'use strict';
/*
 * BatWiiCera Plaza - generated player names (server side)
 * Version 0.1.7 | Author: yiddifliddo | Licence: MIT
 *
 * Mirror of client/src/names.lua: same wordlists, same hash, same result.
 * Keep the two files identical in content; the client self-test and the
 * server smoke test both check known values.
 */

const adjectives = [
  'Brave', 'Swift', 'Sunny', 'Clever', 'Mighty', 'Gentle', 'Happy', 'Lucky', 'Jolly', 'Nimble',
  'Quiet', 'Rapid', 'Shiny', 'Tidy', 'Witty', 'Zesty', 'Bold', 'Calm', 'Daring', 'Eager',
  'Fancy', 'Giant', 'Humble', 'Icy', 'Jazzy', 'Keen', 'Lively', 'Merry', 'Noble', 'Odd',
  'Plucky', 'Quick', 'Rosy', 'Snappy', 'Tiny', 'Upbeat', 'Vivid', 'Wild', 'Young', 'Zany',
  'Amber', 'Breezy', 'Cosmic', 'Dizzy', 'Electric', 'Frosty', 'Golden', 'Hazel', 'Indigo', 'Jumpy',
  'Kind', 'Lunar', 'Misty', 'Neon', 'Orange', 'Pixel', 'Quirky', 'Retro', 'Silver', 'Turbo',
];

const animals = [
  'Otter', 'Panda', 'Tiger', 'Koala', 'Falcon', 'Badger', 'Rabbit', 'Walrus', 'Gecko', 'Heron',
  'Lemur', 'Moose', 'Newt', 'Osprey', 'Puffin', 'Quokka', 'Raccoon', 'Seal', 'Toucan', 'Urchin',
  'Viper', 'Wombat', 'Yak', 'Zebra', 'Alpaca', 'Bison', 'Cheetah', 'Dolphin', 'Eagle', 'Ferret',
  'Giraffe', 'Hedgehog', 'Iguana', 'Jaguar', 'Kiwi', 'Llama', 'Meerkat', 'Narwhal', 'Ocelot', 'Penguin',
  'Quail', 'Robin', 'Sloth', 'Turtle', 'Owl', 'Fox', 'Wolf', 'Lynx', 'Beaver', 'Camel',
  'Donkey', 'Emu', 'Flamingo', 'Gorilla', 'Hippo', 'Ibis', 'Jackal', 'Kestrel', 'Mantis', 'Parrot',
];

const MOD = 1000000007;

function hash(str) {
  let h = 7;
  for (let i = 0; i < str.length; i++) h = (h * 31 + str.charCodeAt(i)) % MOD;
  return h;
}

function generate(token, seed) {
  seed = Math.floor(Number(seed));
  if (!Number.isFinite(seed) || seed < 0) seed = 0;
  const h = hash(String(token) + ':' + String(seed));
  const h2 = (h * 31 + 17) % MOD;
  const adj = adjectives[h % adjectives.length];
  const animal = animals[h2 % animals.length];
  const num = (Math.floor(h2 / animals.length) % 99) + 1;
  return adj + ' ' + animal + ' ' + num;
}

module.exports = { adjectives, animals, hash, generate };
