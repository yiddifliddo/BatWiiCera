#!/usr/bin/env node
/*
 * BatWiiCera Plaza - room server
 * Version 0.1.8
 * Author: yiddifliddo
 * Licence: MIT
 *
 * One process, two listeners, no dependencies beyond Node itself:
 *
 *   TCP  (default port 7777)  - game clients. Newline-delimited JSON, one
 *                               message per line, both directions.
 *   HTTP (default port 7778)  - presence hook (POST /presence), health
 *                               check (GET /health) and a plain stats page.
 *   TCP  (default port 55435) - RetroArch netplay relay (tunnel.js), so
 *                               Batocera players can host and join netplay
 *                               without opening ports at home.
 *
 * The server is authoritative for who is in the room, their names (generated
 * from the install token, never typed), slaps, the ball, goals and the
 * stadium size. Clients own their own movement and send position, velocity
 * and facing ~15 times a second; the server rebroadcasts a compact snapshot
 * at the same rate so clients can interpolate and predict.
 *
 * Environment variables:
 *   PLAZA_TCP_PORT   default 7777 (expose through a TCP proxy on PaaS hosts)
 *   PLAZA_HTTP_PORT  default 7778; PORT, if set by the host, takes precedence
 *   PLAZA_TUNNEL_PORT default 55435; 0 disables the netplay relay
 *   PLAZA_TUNNEL_MAX  relay sessions at once, default 64
 *   PLAZA_BIND       default 0.0.0.0
 *   PLAZA_MAX        max players, default 200
 */

'use strict';

const net = require('net');
const http = require('http');
const crypto = require('crypto');
const names = require('./names.js');
const { createTunnel } = require('./tunnel.js');

// Ports. PLAZA_TCP_PORT / PLAZA_HTTP_PORT, when set, always win. Otherwise
// the HTTP side takes PORT, which hosts such as Railway inject for the
// listener behind the public domain. Railway also sets PORT to the TCP
// proxy's port once one exists, which would put both listeners on 7777;
// in that case the HTTP side moves to PLAZA_HTTP_FALLBACK_PORT (default
// 8080, the port the public domain was generated with).
function resolvePorts(env) {
  const tcp = parseInt(env.PLAZA_TCP_PORT || '7777', 10);
  let http = parseInt(env.PLAZA_HTTP_PORT || env.PORT || '7778', 10);
  let note = '';
  if (http === tcp) {
    http = parseInt(env.PLAZA_HTTP_FALLBACK_PORT || '8080', 10);
    note = `PORT=${env.PORT} clashes with the game port ${tcp}; http side moved to ${http} (set PLAZA_HTTP_PORT to choose)`;
  }
  return { tcp, http, note };
}
const PORTS = resolvePorts(process.env);
const TCP_PORT = PORTS.tcp;
const HTTP_PORT = PORTS.http;
const BIND = process.env.PLAZA_BIND || '0.0.0.0';
const TUNNEL_PORT = parseInt(process.env.PLAZA_TUNNEL_PORT || '55435', 10);
const MAX_PLAYERS = parseInt(process.env.PLAZA_MAX || '200', 10);

const PROTOCOL_VERSION = 1;
// Public URL of the HTTP side, handed to clients so their presence hook knows
// where to post without anyone typing it. Railway sets RAILWAY_PUBLIC_DOMAIN
// once a domain is generated; any host can set PLAZA_PUBLIC_URL explicitly.
const PUBLIC_URL = (process.env.PLAZA_PUBLIC_URL || (process.env.RAILWAY_PUBLIC_DOMAIN ? 'https://' + process.env.RAILWAY_PUBLIC_DOMAIN : '')).replace(/\/+$/, '');
const SNAPSHOT_HZ = 15;
const IDLE_TIMEOUT_MS = 60 * 1000;      // no message at all for a minute -> drop
const MAX_LINE = 4096;                  // bytes per message
const MOVE_RATE_LIMIT = 40;             // moves per second tolerated
const SLAP_RANGE = 76;                  // world units
const SLAP_COOLDOWN_MS = 600;
const PRESENCE_TTL_MS = 12 * 60 * 60 * 1000; // remember "last game" this long

// Stadium: a football pitch (x,y on the ground, z for hops) with an apron
// of track and stands around it that players may run onto. The pitch grows
// with the crowd. Goals sit on the goal lines, centred.
const PITCH_BASE_W = 2400;
const PITCH_BASE_H = 1500;
const APRON = 320;
const GOAL_W = 300;
const GOAL_DEPTH = 70;
const GOAL_RESET_MS = 2600;
const ANIMS = ['idle', 'run', 'jump', 'hit', 'slap', 'kick', 'skid'];

// Ball: simulated here so everyone sees the same ball.
const BALL_R = 14;
const BALL_TICK_HZ = 30;
const KICK_RANGE = 64;
const KICK_SPEED = 560;
const TOUCH_RANGE = 34;
const TOUCH_SPEED = 220;

// ---------------------------------------------------------------------------
// Names are generated, never typed: see names.js. The client sends a small
// seed it can roll again; anything else it says about its name is ignored.
// ---------------------------------------------------------------------------
function cleanSeed(raw) {
  let v = parseInt(raw, 10);
  if (!Number.isFinite(v) || v < 0) v = 0;
  return v % 1000000;
}
function nameFor(token, seed) { return names.generate(token, seed); }
// Kept for the smoke test and older callers: a generated name is always clean.
function cleanName(raw) { return String(raw || '').replace(/[^\x20-\x7E]/g, '').trim().slice(0, 24) || 'Player'; }

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

function pitchScale() { return Math.min(2.0, 1 + Math.max(0, players.size - 10) * 0.03); }
function worldWidth() { return Math.round(PITCH_BASE_W * pitchScale()); }
function worldHeight() { return Math.round(PITCH_BASE_H * pitchScale()); }
function pitchInfo() { return { w: worldWidth(), h: worldHeight(), apron: APRON, goalW: GOAL_W, goalDepth: GOAL_DEPTH }; }
const score = { left: 0, right: 0 };
function worldMsg() {
  return { t: 'world', w: worldWidth(), h: worldHeight(), apron: APRON, n: players.size, score: { left: score.left, right: score.right } };
}

const ball = { x: PITCH_BASE_W / 2, y: PITCH_BASE_H / 2, z: 0, vx: 0, vy: 0, vz: 0, lastKicker: null, lastTouch: 0, frozenUntil: 0 };
function resetBall() {
  ball.x = worldWidth() / 2; ball.y = worldHeight() / 2; ball.z = 0;
  ball.vx = 0; ball.vy = 0; ball.vz = 0; ball.lastKicker = null; ball.frozenUntil = 0;
}
function inGoalMouth(y, h) { return Math.abs(y - h / 2) < GOAL_W / 2; }
function scoreGoal(side) {
  // side = which goal the ball went into
  if (side === 'left') score.left++; else score.right++;
  ball.vx = 0; ball.vy = 0; ball.vz = 0;
  ball.frozenUntil = Date.now() + GOAL_RESET_MS;
  broadcast({ t: 'goal', side, by: ball.lastKicker, score: { left: score.left, right: score.right } });
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
  if (ball.frozenUntil) {
    if (Date.now() >= ball.frozenUntil) resetBall();
    return;
  }
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
  // touchlines bounce; goal lines bounce except through the goal mouth
  if (ball.y < BALL_R) { ball.y = BALL_R; ball.vy = -ball.vy * 0.7; }
  if (ball.y > h - BALL_R) { ball.y = h - BALL_R; ball.vy = -ball.vy * 0.7; }
  const mouth = inGoalMouth(ball.y, h) && ball.z < 52;
  if (ball.x < BALL_R) {
    if (mouth) {
      if (ball.x < -BALL_R) { ball.x = Math.max(-GOAL_DEPTH + BALL_R, ball.x); scoreGoal('left'); return; }
    } else { ball.x = BALL_R; ball.vx = -ball.vx * 0.7; }
  }
  if (ball.x > w - BALL_R) {
    if (mouth) {
      if (ball.x > w + BALL_R) { ball.x = Math.min(w + GOAL_DEPTH - BALL_R, ball.x); scoreGoal('right'); return; }
    } else { ball.x = w - BALL_R; ball.vx = -ball.vx * 0.7; }
  }
  // players walking into a slow ball nudge it along
  const now = Date.now();
  if (now - ball.lastTouch > 150 && Math.hypot(ball.vx, ball.vy) < 140 && ball.z < 20) {
    for (const p of players.values()) {
      const dx = ball.x - p.x, dy = ball.y - p.y;
      const d = Math.hypot(dx, dy);
      if (d < TOUCH_RANGE) {
        const nx = d > 0.001 ? dx / d : Math.cos(p.dir * Math.PI / 180), ny = d > 0.001 ? dy / d : Math.sin(p.dir * Math.PI / 180);
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
function playerBounds() {
  return { x0: -APRON, y0: -APRON, x1: worldWidth() + APRON, y1: worldHeight() + APRON };
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
      const seed = cleanSeed(msg.nameSeed);
      player = {
        id: String(nextId++),
        token,
        socket,
        nameSeed: seed,
        name: nameFor(token, seed),
        avatar: cleanAvatar(msg.avatar),
        share: msg.share !== false,
        game: remembered && (Date.now() - remembered.at < PRESENCE_TTL_MS) ? remembered.game : cleanGame(msg.game),
        x: Math.round(w * 0.3 + Math.random() * w * 0.4),
        y: Math.round(h * 0.3 + Math.random() * h * 0.4),
        vx: 0, vy: 0,
        dir: 0,
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
        pitch: pitchInfo(),
        score: { left: score.left, right: score.right },
        ball: ballSnapshot(),
        presence: PUBLIC_URL,
        serverVersion: '0.1.8'
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
        const b = playerBounds();
        player.x = clampNum(msg.x, b.x0, b.x1, player.x);
        player.y = clampNum(msg.y, b.y0, b.y1, player.y);
        player.vx = clampNum(msg.vx, -600, 600, 0);
        player.vy = clampNum(msg.vy, -600, 600, 0);
        player.dir = Math.round(clampNum(msg.dir, -360, 720, 0) + 720) % 360;
        player.anim = ANIMS.includes(msg.anim) ? msg.anim : 'idle';
        break;
      }
      case 'jump':
        broadcast({ t: 'jump', id: player.id }, player.id);
        break;
      case 'slap': {
        const now = Date.now();
        if (now - player.lastSlap < SLAP_COOLDOWN_MS) return;
        player.lastSlap = now;
        // Nearest player in front of us (within a 120 degree cone) in range.
        const fx = Math.cos(player.dir * Math.PI / 180), fy = Math.sin(player.dir * Math.PI / 180);
        let target = null, best = SLAP_RANGE + 1;
        for (const o of players.values()) {
          if (o.id === player.id) continue;
          const dx = o.x - player.x, dy = o.y - player.y;
          const d = Math.hypot(dx, dy);
          if (d > SLAP_RANGE) continue;
          if (d > 10 && (dx * fx + dy * fy) / d < 0.5) continue;
          if (d < best) { best = d; target = o; }
        }
        broadcast({ t: 'slap', from: player.id, to: target ? target.id : null, dir: fx >= 0 ? 1 : -1, angle: player.dir });
        break;
      }
      case 'kick': {
        const d = Math.hypot(ball.x - player.x, ball.y - player.y);
        if (d > KICK_RANGE) return;
        let dx = Number(msg.dx), dy = Number(msg.dy);
        if (!Number.isFinite(dx) || !Number.isFinite(dy) || (dx === 0 && dy === 0)) { dx = Math.cos(player.dir * Math.PI / 180); dy = Math.sin(player.dir * Math.PI / 180); }
        kickBall(player, dx, dy, msg.power);
        broadcast({ t: 'kick', id: player.id, ball: ballSnapshot() });
        break;
      }
      case 'update': {
        if (msg.nameSeed !== undefined) { player.nameSeed = cleanSeed(msg.nameSeed); player.name = nameFor(player.token, player.nameSeed); }
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
  for (const pl of players.values()) p.push([pl.id, Math.round(pl.x), Math.round(pl.y), pl.dir, pl.anim, Math.round(pl.vx), Math.round(pl.vy)]);
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
// Netplay relay
// ---------------------------------------------------------------------------
const tunnel = createTunnel({ log: (m) => console.log('[relay] ' + m) });

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
    res.end(JSON.stringify({ ok: true, players: players.size, version: '0.1.8', relay: tunnel.snapshot() }));
    return;
  }
  if (req.method === 'GET' && (req.url === '/' || req.url === '/stats')) {
    const list = Array.from(players.values()).map(p => ({ name: p.name, game: p.share ? p.game : null, since: p.joinedAt }));
    res.end(JSON.stringify({ players: players.size, pitch: pitchInfo(), score, ball: ballSnapshot(), relay: tunnel.snapshot(), list }, null, 2));
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
  if (PORTS.note) console.log('[plaza] ' + PORTS.note);
  const fatal = (what) => (err) => { console.error(`[plaza] cannot open the ${what} port: ${err.code || err.message}`); process.exit(1); };
  tcpServer.on('error', fatal('game'));
  httpServer.on('error', fatal('http'));
  tcpServer.listen(TCP_PORT, BIND, () => console.log(`[plaza] game port  ${BIND}:${TCP_PORT}`));
  httpServer.listen(HTTP_PORT, BIND, () => console.log(`[plaza] http port  ${BIND}:${HTTP_PORT}`));
  if (TUNNEL_PORT > 0) {
    tunnel.server.on('error', fatal('netplay relay'));
    tunnel.listen(TUNNEL_PORT, BIND, () => console.log(`[plaza] relay port ${BIND}:${TUNNEL_PORT}`));
  }
  const shutdown = () => { console.log('[plaza] shutting down'); tcpServer.close(); httpServer.close(); tunnel.close(); process.exit(0); };
  process.on('SIGINT', shutdown);
  process.on('SIGTERM', shutdown);
}

module.exports = { tcpServer, httpServer, tunnel, resolvePorts, cleanName, cleanSeed, nameFor, cleanAvatar, cleanGame, worldWidth, worldHeight, pitchInfo, players, ball, score, stepBall, resetBall, PROTOCOL_VERSION, GOAL_W, GOAL_DEPTH, APRON };
