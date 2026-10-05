#!/usr/bin/env node
/*
 * BatWiiCera Plaza - room server
 * Version 0.1.0
 * Author: Dan Lee
 * Licence: MIT
 *
 * One process, two listeners, no dependencies beyond Node itself:
 *
 *   TCP  (default port 7777)  - game clients. Newline-delimited JSON, one
 *                               message per line, both directions.
 *   HTTP (default port 7778)  - presence hook (POST /presence), health
 *                               check (GET /health) and a plain stats page.
 *
 * The server is authoritative for who is in the room, slaps and the world
 * size. Clients own their own movement and send it ~15 times a second; the
 * server rebroadcasts a compact snapshot at the same rate.
 *
 * Environment variables:
 *   PLAZA_TCP_PORT   default 7777
 *   PLAZA_HTTP_PORT  default 7778
 *   PLAZA_BIND       default 0.0.0.0
 *   PLAZA_MAX        max players, default 200
 *   PLAZA_NAME_MAX   max nickname length, default 14
 */

'use strict';

const net = require('net');
const http = require('http');
const crypto = require('crypto');

const TCP_PORT = parseInt(process.env.PLAZA_TCP_PORT || '7777', 10);
const HTTP_PORT = parseInt(process.env.PLAZA_HTTP_PORT || '7778', 10);
const BIND = process.env.PLAZA_BIND || '0.0.0.0';
const MAX_PLAYERS = parseInt(process.env.PLAZA_MAX || '200', 10);
const NAME_MAX = parseInt(process.env.PLAZA_NAME_MAX || '14', 10);

const PROTOCOL_VERSION = 1;
const SNAPSHOT_HZ = 15;
const IDLE_TIMEOUT_MS = 60 * 1000;      // no message at all for a minute -> drop
const MAX_LINE = 4096;                  // bytes per message
const MOVE_RATE_LIMIT = 40;             // moves per second tolerated
const SLAP_RANGE = 70;                  // world units
const SLAP_COOLDOWN_MS = 600;
const PRESENCE_TTL_MS = 12 * 60 * 60 * 1000; // remember "last game" this long

// World: a top-down plaza (x,y on the ground, z for hops). It grows with the crowd.
const WORLD_BASE_W = 1400;
const WORLD_BASE_H = 800;

// Ball: simulated here so everyone sees the same ball.
const BALL_R = 14;
const BALL_TICK_HZ = 30;
const KICK_RANGE = 64;
const KICK_SPEED = 560;
const TOUCH_RANGE = 34;
const TOUCH_SPEED = 220;

// ---------------------------------------------------------------------------
// Nickname filter: a short, deliberately tame list. Owners can extend it
// through PLAZA_BLOCKED_WORDS (comma separated) without editing code.
// ---------------------------------------------------------------------------
const blockedWords = ['fuck', 'shit', 'cunt', 'nigg', 'fag', 'bitch', 'cock', 'dick', 'pussy', 'whore', 'slut', 'rape', 'nazi', 'hitler']
  .concat((process.env.PLAZA_BLOCKED_WORDS || '').split(',').map(s => s.trim().toLowerCase()).filter(Boolean));

function cleanName(raw) {
  let name = String(raw || '').replace(/[^\x20-\x7E]/g, '').trim().slice(0, NAME_MAX);
  if (!name) name = 'Player';
  const lower = name.toLowerCase().replace(/[^a-z]/g, '');
  for (const w of blockedWords) {
    if (w && lower.includes(w)) return 'Player';
  }
  return name;
}

function cleanGame(raw) {
  if (raw === null || raw === undefined) return null;
  const g = String(raw).replace(/[^\x20-\x7E]/g, '').trim().slice(0, 40);
  return g || null;
}

// Avatars are a small bag of integers and colours; validate shape and ranges
// so a hostile client cannot make others render garbage.
const AVATAR_LIMITS = {
  head: 4, skin: 8, hair: 8, hairColor: 10, eyes: 6, brows: 4, mouth: 6, shirt: 12, accessory: 4
};
function cleanAvatar(raw) {
  const out = {};
  const src = (raw && typeof raw === 'object') ? raw : {};
  for (const k of Object.keys(AVATAR_LIMITS)) {
    let v = parseInt(src[k], 10);
    if (!Number.isFinite(v) || v < 0) v = 0;
    if (v >= AVATAR_LIMITS[k]) v = AVATAR_LIMITS[k] - 1;
    out[k] = v;
  }
  return out;
}

function clampNum(v, lo, hi, dflt) {
  v = Number(v);
  if (!Number.isFinite(v)) return dflt;
  return Math.min(hi, Math.max(lo, v));
}

// ---------------------------------------------------------------------------
// Room state
// ---------------------------------------------------------------------------
const players = new Map();          // id -> player
const byToken = new Map();          // token -> player (connected)
const presence = new Map();         // token -> { game, at }  (last known, for offline players)
let nextId = 1;

function worldWidth() {
  return WORLD_BASE_W + Math.max(0, players.size - 8) * 80;
}
function worldHeight() {
  return WORLD_BASE_H + Math.max(0, players.size - 8) * 40;
}
function worldMsg() {
  return { t: 'world', w: worldWidth(), h: worldHeight(), n: players.size };
}

const ball = { x: WORLD_BASE_W / 2, y: WORLD_BASE_H / 2, z: 0, vx: 0, vy: 0, vz: 0, lastKicker: null, lastTouch: 0 };
function resetBall() {
  ball.x = worldWidth() / 2; ball.y = worldHeight() / 2; ball.z = 0;
  ball.vx = 0; ball.vy = 0; ball.vz = 0; ball.lastKicker = null;
}
function kickBall(player, dx, dy, power) {
  const len = Math.hypot(dx, dy) || 1;
  power = clampNum(power, 0.3, 1, 1);
  ball.vx = (dx / len) * KICK_SPEED * power;
  ball.vy = (dy / len) * KICK_SPEED * power;
  ball.vz = 180 + 160 * power;
  ball.lastKicker = player.id;
  ball.lastTouch = Date.now();
}
function stepBall(dt) {
  const w = worldWidth(), h = worldHeight();
  // ground friction (only when on the ground), air drag otherwise
  const onGround = ball.z <= 0.01;
  const drag = onGround ? 0.985 : 0.995;
  ball.vx *= Math.pow(drag, dt * 60);
  ball.vy *= Math.pow(drag, dt * 60);
  if (onGround && Math.hypot(ball.vx, ball.vy) < 4) { ball.vx = 0; ball.vy = 0; }
  ball.x += ball.vx * dt;
  ball.y += ball.vy * dt;
  // hop physics
  ball.vz -= 900 * dt;
  ball.z += ball.vz * dt;
  if (ball.z < 0) { ball.z = 0; ball.vz = Math.abs(ball.vz) > 60 ? -ball.vz * 0.55 : 0; }
  // walls
  if (ball.x < BALL_R) { ball.x = BALL_R; ball.vx = -ball.vx * 0.7; }
  if (ball.x > w - BALL_R) { ball.x = w - BALL_R; ball.vx = -ball.vx * 0.7; }
  if (ball.y < BALL_R) { ball.y = BALL_R; ball.vy = -ball.vy * 0.7; }
  if (ball.y > h - BALL_R) { ball.y = h - BALL_R; ball.vy = -ball.vy * 0.7; }
  // players walking into a slow ball nudge it along
  const now = Date.now();
  if (now - ball.lastTouch > 150 && Math.hypot(ball.vx, ball.vy) < 140 && ball.z < 20) {
    for (const p of players.values()) {
      const dx = ball.x - p.x, dy = ball.y - p.y;
      const d = Math.hypot(dx, dy);
      if (d < TOUCH_RANGE) {
        const nx = d > 0.001 ? dx / d : p.dir, ny = d > 0.001 ? dy / d : 0;
        ball.vx = nx * TOUCH_SPEED; ball.vy = ny * TOUCH_SPEED; ball.vz = 40;
        ball.lastKicker = p.id; ball.lastTouch = now;
        break;
      }
    }
  }
}
function ballSnapshot() {
  return [Math.round(ball.x), Math.round(ball.y), Math.round(ball.z), Math.round(ball.vx), Math.round(ball.vy), Math.round(ball.vz), ball.lastKicker];
}

function publicPlayer(p) {
  return {
    id: p.id, name: p.name, avatar: p.avatar, x: p.x, y: p.y, dir: p.dir,
    anim: p.anim, game: p.share ? p.game : null
  };
}

function broadcast(obj, exceptId) {
  const line = JSON.stringify(obj) + '\n';
  for (const p of players.values()) {
    if (p.id === exceptId) continue;
    if (p.socket.writable) p.socket.write(line);
  }
}

function send(p, obj) {
  if (p.socket.writable) p.socket.write(JSON.stringify(obj) + '\n');
}

function tokenHash(token) {
  return crypto.createHash('sha256').update(String(token)).digest('hex').slice(0, 16);
}

// ---------------------------------------------------------------------------
// TCP: game clients
// ---------------------------------------------------------------------------
const tcpServer = net.createServer((socket) => {
  socket.setNoDelay(true);
  socket.setKeepAlive(true, 20000);

  let buffer = '';
  let player = null;
  let lastSeen = Date.now();
  let moveWindowStart = Date.now();
  let movesInWindow = 0;

  const idleTimer = setInterval(() => {
    if (Date.now() - lastSeen > IDLE_TIMEOUT_MS) socket.destroy();
  }, 10000);

  socket.on('data', (chunk) => {
    lastSeen = Date.now();
    buffer += chunk.toString('utf8');
    if (buffer.length > MAX_LINE * 4) { socket.destroy(); return; }
    let idx;
    while ((idx = buffer.indexOf('\n')) >= 0) {
      const line = buffer.slice(0, idx).trim();
      buffer = buffer.slice(idx + 1);
      if (!line) continue;
      if (line.length > MAX_LINE) { socket.destroy(); return; }
      let msg;
      try { msg = JSON.parse(line); } catch (e) { continue; }
      if (!msg || typeof msg !== 'object') continue;
      handle(msg);
    }
  });

  function handle(msg) {
    if (!player) {
      if (msg.t !== 'hello') return;
      if (msg.v !== PROTOCOL_VERSION) {
        send({ socket }, { t: 'error', code: 'version', message: 'Client protocol ' + msg.v + ' not supported; need ' + PROTOCOL_VERSION });
        socket.end();
        return;
      }
      if (players.size >= MAX_PLAYERS) {
        send({ socket }, { t: 'error', code: 'full', message: 'The plaza is full right now' });
        socket.end();
        return;
      }
      const token = String(msg.token || '').slice(0, 64);
      if (!token) { send({ socket }, { t: 'error', code: 'token', message: 'Missing token' }); socket.end(); return; }

      // Same install reconnecting: drop the old socket.
      const existing = byToken.get(token);
      if (existing) existing.socket.destroy();

      const remembered = presence.get(token);
      const w = worldWidth(), h = worldHeight();
      player = {
        id: String(nextId++),
        token,
        socket,
        name: cleanName(msg.name),
        avatar: cleanAvatar(msg.avatar),
        share: msg.share !== false,
        game: remembered && (Date.now() - remembered.at < PRESENCE_TTL_MS) ? remembered.game : cleanGame(msg.game),
        x: Math.round(w * 0.3 + Math.random() * w * 0.4),
        y: Math.round(h * 0.3 + Math.random() * h * 0.4),
        dir: 1,
        anim: 'idle',
        lastSlap: 0,
        joinedAt: Date.now()
      };
      players.set(player.id, player);
      byToken.set(token, player);

      send(player, {
        t: 'welcome',
        id: player.id,
        you: publicPlayer(player),
        players: Array.from(players.values()).filter(p => p.id !== player.id).map(publicPlayer),
        world: { w: worldWidth(), h: worldHeight() },
        ball: ballSnapshot(),
        serverVersion: '0.1.0'
      });
      broadcast({ t: 'join', player: publicPlayer(player) }, player.id);
      broadcast(worldMsg());
      return;
    }

    switch (msg.t) {
      case 'move': {
        const now = Date.now();
        if (now - moveWindowStart > 1000) { moveWindowStart = now; movesInWindow = 0; }
        if (++movesInWindow > MOVE_RATE_LIMIT) return;
        player.x = clampNum(msg.x, 0, worldWidth(), player.x);
        player.y = clampNum(msg.y, 0, worldHeight(), player.y);
        player.dir = msg.dir === -1 ? -1 : 1;
        player.anim = (['idle', 'run', 'jump', 'hit'].includes(msg.anim)) ? msg.anim : 'idle';
        break;
      }
      case 'jump':
        broadcast({ t: 'jump', id: player.id }, player.id);
        break;
      case 'slap': {
        const now = Date.now();
        if (now - player.lastSlap < SLAP_COOLDOWN_MS) return;
        player.lastSlap = now;
        // Nearest player in front of us within range.
        let target = null, best = SLAP_RANGE + 1;
        for (const o of players.values()) {
          if (o.id === player.id) continue;
          const dx = o.x - player.x, dy = o.y - player.y;
          if (Math.sign(dx) !== player.dir && Math.abs(dx) > 12) continue;
          const d = Math.hypot(dx, dy);
          if (d < best) { best = d; target = o; }
        }
        broadcast({ t: 'slap', from: player.id, to: target ? target.id : null, dir: player.dir });
        break;
      }
      case 'kick': {
        const d = Math.hypot(ball.x - player.x, ball.y - player.y);
        if (d > KICK_RANGE) return;
        let dx = Number(msg.dx), dy = Number(msg.dy);
        if (!Number.isFinite(dx) || !Number.isFinite(dy) || (dx === 0 && dy === 0)) { dx = player.dir; dy = 0; }
        kickBall(player, dx, dy, msg.power);
        broadcast({ t: 'kick', id: player.id, ball: ballSnapshot() });
        break;
      }
      case 'update': {
        if (msg.name !== undefined) player.name = cleanName(msg.name);
        if (msg.avatar !== undefined) player.avatar = cleanAvatar(msg.avatar);
        if (msg.share !== undefined) player.share = msg.share !== false;
        broadcast({ t: 'player', player: publicPlayer(player) });
        break;
      }
      case 'game': {
        player.game = cleanGame(msg.game);
        presence.set(player.token, { game: player.game, at: Date.now() });
        broadcast({ t: 'game', id: player.id, game: player.share ? player.game : null });
        break;
      }
      case 'ping':
        send(player, { t: 'pong', at: msg.at });
        break;
      default:
        break;
    }
  }

  socket.on('close', () => {
    clearInterval(idleTimer);
    if (player && players.get(player.id) === player) {
      players.delete(player.id);
      if (byToken.get(player.token) === player) byToken.delete(player.token);
      broadcast({ t: 'leave', id: player.id });
      broadcast(worldMsg());
      if (players.size === 0) resetBall();
    }
  });
  socket.on('error', () => { /* close follows */ });
});

// Snapshot loop: compact positions for everyone, 15 times a second.
setInterval(() => {
  if (players.size === 0) return;
  const p = [];
  for (const pl of players.values()) p.push([pl.id, Math.round(pl.x), Math.round(pl.y), pl.dir, pl.anim]);
  broadcast({ t: 'state', p, b: ballSnapshot() });
}, Math.round(1000 / SNAPSHOT_HZ));

// Ball physics loop.
let lastBallTick = Date.now();
setInterval(() => {
  const now = Date.now();
  const dt = Math.min(0.1, (now - lastBallTick) / 1000);
  lastBallTick = now;
  if (players.size > 0) stepBall(dt);
}, Math.round(1000 / BALL_TICK_HZ));

// Forget stale presence entries.
setInterval(() => {
  const now = Date.now();
  for (const [token, v] of presence) if (now - v.at > PRESENCE_TTL_MS) presence.delete(token);
}, 10 * 60 * 1000);

// ---------------------------------------------------------------------------
// HTTP: presence hook, health, stats
// ---------------------------------------------------------------------------
function readBody(req, limit, cb) {
  let data = '';
  req.on('data', (c) => { data += c; if (data.length > limit) { req.destroy(); } });
  req.on('end', () => cb(data));
}

const httpServer = http.createServer((req, res) => {
  res.setHeader('Content-Type', 'application/json');
  if (req.method === 'GET' && req.url === '/health') {
    res.end(JSON.stringify({ ok: true, players: players.size, version: '0.1.0' }));
    return;
  }
  if (req.method === 'GET' && (req.url === '/' || req.url === '/stats')) {
    const list = Array.from(players.values()).map(p => ({ name: p.name, game: p.share ? p.game : null, since: p.joinedAt }));
    res.end(JSON.stringify({ players: players.size, world: { w: worldWidth(), h: worldHeight() }, ball: ballSnapshot(), list }, null, 2));
    return;
  }
  if (req.method === 'POST' && req.url === '/presence') {
    readBody(req, 4096, (data) => {
      let body;
      try { body = JSON.parse(data); } catch (e) { res.statusCode = 400; res.end('{"ok":false,"error":"bad json"}'); return; }
      const token = String(body.token || '').slice(0, 64);
      if (!token) { res.statusCode = 400; res.end('{"ok":false,"error":"missing token"}'); return; }
      const game = body.event === 'stop' ? null : cleanGame(body.game);
      presence.set(token, { game, at: Date.now() });
      const p = byToken.get(token);
      if (p) {
        p.game = game;
        broadcast({ t: 'game', id: p.id, game: p.share ? p.game : null });
      }
      res.end(JSON.stringify({ ok: true, online: !!p, player: tokenHash(token) }));
    });
    return;
  }
  res.statusCode = 404;
  res.end('{"ok":false,"error":"not found"}');
});

// ---------------------------------------------------------------------------
if (require.main === module) {
  tcpServer.listen(TCP_PORT, BIND, () => console.log(`[plaza] game port  ${BIND}:${TCP_PORT}`));
  httpServer.listen(HTTP_PORT, BIND, () => console.log(`[plaza] http port  ${BIND}:${HTTP_PORT}`));
  const shutdown = () => { console.log('[plaza] shutting down'); tcpServer.close(); httpServer.close(); process.exit(0); };
  process.on('SIGINT', shutdown);
  process.on('SIGTERM', shutdown);
}

module.exports = { tcpServer, httpServer, cleanName, cleanAvatar, cleanGame, worldWidth, worldHeight, players, ball, stepBall, PROTOCOL_VERSION };
