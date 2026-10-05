/*
 * BatWiiCera Plaza - server smoke test
 * Author: yiddifliddo
 *
 * Starts the server on spare ports, connects three fake clients, checks
 * join/leave, snapshots, slap targeting, generated names, goals, the presence
 * hook and the version gate. Exits non-zero on the first failure.
 */
'use strict';

process.env.PLAZA_TCP_PORT = '17777';
process.env.PLAZA_HTTP_PORT = '17778';
delete process.env.PORT; // PORT (PaaS) would override PLAZA_HTTP_PORT
process.env.PLAZA_BIND = '127.0.0.1';
process.env.PLAZA_PUBLIC_URL = 'https://plaza.example.test/';

// Port resolution (Railway sets PORT to the TCP proxy port once one exists).
{
  const { resolvePorts } = require('../index.js');
  const a = resolvePorts({});
  if (a.tcp !== 7777 || a.http !== 7778) throw new Error('default ports');
  const b = resolvePorts({ PORT: '8080' });
  if (b.http !== 8080) throw new Error('PORT taken for http');
  const c = resolvePorts({ PORT: '7777' });
  if (c.tcp !== 7777 || c.http !== 8080 || !c.note) throw new Error('PORT clash should move http to 8080');
  const d = resolvePorts({ PORT: '7777', PLAZA_HTTP_PORT: '9000' });
  if (d.http !== 9000) throw new Error('PLAZA_HTTP_PORT wins over PORT');
  const e = resolvePorts({ PORT: '7777', PLAZA_HTTP_FALLBACK_PORT: '9090' });
  if (e.http !== 9090) throw new Error('fallback port honoured');
  console.log('port resolution: ok');
}

const net = require('net');
const http = require('http');
const assert = require('assert');
const server = require('../index.js');

function client() {
  const sock = net.connect(17777, '127.0.0.1');
  const inbox = [];
  const waiters = [];
  let buf = '';
  sock.on('data', (c) => {
    buf += c.toString();
    let i;
    while ((i = buf.indexOf('\n')) >= 0) {
      const line = buf.slice(0, i); buf = buf.slice(i + 1);
      if (!line.trim()) continue;
      const m = JSON.parse(line);
      const w = waiters.findIndex(x => x.pred(m));
      if (w >= 0) { const [{ resolve }] = waiters.splice(w, 1); resolve(m); } else inbox.push(m);
    }
  });
  return {
    sock,
    send: (o) => sock.write(JSON.stringify(o) + '\n'),
    expect: (pred, ms = 2000, label = '') => new Promise((resolve, reject) => {
      const i = inbox.findIndex(pred);
      if (i >= 0) return resolve(inbox.splice(i, 1)[0]);
      const entry = { pred, resolve: (m) => { clearTimeout(timer); resolve(m); } };
      const timer = setTimeout(() => {
        const k = waiters.indexOf(entry); if (k >= 0) waiters.splice(k, 1);
        reject(new Error('timeout waiting for message ' + (label || pred.toString().slice(0, 80))));
      }, ms);
      waiters.push(entry);
    }),
    ready: () => new Promise((r) => sock.once('connect', r)),
    close: () => sock.destroy()
  };
}

function post(path, body) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(body);
    const req = http.request({ host: '127.0.0.1', port: 17778, path, method: 'POST', headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(data) } }, (res) => {
      let d = ''; res.on('data', c => d += c); res.on('end', () => resolve({ status: res.statusCode, body: JSON.parse(d) }));
    });
    req.on('error', reject); req.write(data); req.end();
  });
}
function get(path) {
  return new Promise((resolve, reject) => {
    http.get({ host: '127.0.0.1', port: 17778, path }, (res) => { let d = ''; res.on('data', c => d += c); res.on('end', () => resolve(JSON.parse(d))); }).on('error', reject);
  });
}

(async () => {
  await new Promise(r => server.tcpServer.listen(17777, '127.0.0.1', r));
  await new Promise(r => server.httpServer.listen(17778, '127.0.0.1', r));

  // Unit-level cleaners and the name generator (values shared with the client self-test)
  assert.strictEqual(server.nameFor('abc', 0), 'Calm Panda 1');
  assert.strictEqual(server.nameFor('tok-x', 424242), 'Fancy Kestrel 44');
  assert.strictEqual(server.cleanSeed('-5'), 0);
  assert.strictEqual(server.cleanSeed(1234567), 234567);
  assert.ok(/^[A-Z][a-z]+ [A-Z][a-z]+ \d+$/.test(server.nameFor('x', 9)));
  assert.deepStrictEqual(server.cleanAvatar({ head: 99, hair: -3, shirt: 'abc' }).head, 3);
  assert.strictEqual(server.cleanAvatar({}).eyes, 0);
  assert.strictEqual(server.cleanGame('   '), null);

  // Version gate
  const old = client(); await old.ready();
  old.send({ t: 'hello', v: 0, token: 'old' });
  const err = await old.expect(m => m.t === 'error');
  assert.strictEqual(err.code, 'version');
  old.close();

  // Three players
  const a = client(), b = client(), c = client();
  await Promise.all([a.ready(), b.ready(), c.ready()]);
  a.send({ t: 'hello', v: 1, token: 'tok-a', nameSeed: 3, name: 'Alice', avatar: { head: 1 }, game: 'Sonic' });
  const wa = await a.expect(m => m.t === 'welcome');
  const nameA = server.nameFor('tok-a', 3);
  assert.strictEqual(wa.you.name, nameA, 'name is generated from token and seed, the typed one is ignored');
  assert.strictEqual(wa.you.game, 'Sonic');
  assert.strictEqual(wa.players.length, 0);
  assert.strictEqual(wa.pitch.w, server.worldWidth(), 'welcome carries the pitch');
  assert.strictEqual(wa.pitch.goalW, server.GOAL_W);
  assert.deepStrictEqual(wa.score, { left: 0, right: 0 });
  assert.strictEqual(wa.presence, 'https://plaza.example.test', 'welcome carries the public presence URL without trailing slash');

  b.send({ t: 'hello', v: 1, token: 'tok-b', nameSeed: 0, share: false, game: 'Secret' });
  const wb = await b.expect(m => m.t === 'welcome');
  const nameB = server.nameFor('tok-b', 0);
  assert.strictEqual(wb.players.length, 1);
  assert.strictEqual(wb.you.game, null, 'share=false hides the game');
  const joinB = await a.expect(m => m.t === 'join');
  assert.strictEqual(joinB.player.name, nameB);

  c.send({ t: 'hello', v: 1, token: 'tok-c' });
  const wc = await c.expect(m => m.t === 'welcome');
  const nameC = server.nameFor('tok-c', 0);
  assert.strictEqual(wc.you.name, nameC, 'missing seed means seed 0');
  await a.expect(m => m.t === 'join' && m.player.name === nameC);

  // Snapshots flow and carry velocity and facing
  const st = await a.expect(m => m.t === 'state');
  assert.strictEqual(st.p.length, 3);
  assert.strictEqual(st.p[0].length, 7, 'rows are id,x,y,dir,anim,vx,vy');

  // Movement is clamped to the stands, facing wraps, velocity and anim pass through
  a.send({ t: 'move', x: -5000, y: 99999, vx: 123, vy: -45, dir: 450, anim: 'skid' });
  await new Promise(r => setTimeout(r, 120));
  const st2 = await a.expect(m => m.t === 'state' && m.p.find(p => p[0] === wa.id)[1] === -server.APRON);
  const rowA = st2.p.find(p => p[0] === wa.id);
  assert.strictEqual(rowA[2], server.worldHeight() + server.APRON, 'y clamped to the far stand');
  assert.strictEqual(rowA[3], 90, 'facing wraps to 0-359');
  assert.strictEqual(rowA[4], 'skid'); assert.strictEqual(rowA[5], 123); assert.strictEqual(rowA[6], -45);
  assert.ok(Array.isArray(st2.b) && st2.b.length === 7, 'snapshots carry the ball');

  // Slap targets the nearest player in the facing cone
  const ax = 300, ay = 300;
  a.send({ t: 'move', x: ax, y: ay, dir: 0, anim: 'idle' });
  b.send({ t: 'move', x: ax + 40, y: ay, dir: 180, anim: 'idle' });
  c.send({ t: 'move', x: ax - 40, y: ay, dir: 0, anim: 'idle' });
  await new Promise(r => setTimeout(r, 150));
  a.send({ t: 'slap' });
  const slap = await b.expect(m => m.t === 'slap');
  assert.strictEqual(slap.from, wa.id);
  assert.strictEqual(slap.to, wb.id, 'Bob is in front of Alice, Carol is behind');
  assert.strictEqual(slap.angle, 0, 'slap carries the facing angle');
  // cooldown: a second slap straight away is ignored
  a.send({ t: 'slap' });
  let second = null;
  try { second = await c.expect(m => m.t === 'slap' && m !== slap, 400); } catch (e) { /* expected */ }
  assert.ok(second === null || second.from === wa.id && second.to === wb.id);

  // Ball: a kick from far away is ignored, a kick next to it moves it
  assert.strictEqual(wa.ball.length, 7, 'welcome carries the ball');
  a.send({ t: 'kick', dx: 1, dy: 0 });
  let farKick = null;
  try { farKick = await b.expect(m => m.t === 'kick', 300); } catch (e) { /* expected */ }
  assert.strictEqual(farKick, null, 'kick out of range ignored');
  const bx = server.ball.x, by = server.ball.y;
  a.send({ t: 'move', x: bx - 30, y: by, dir: 0, anim: 'idle' });
  await new Promise(r => setTimeout(r, 120));
  a.send({ t: 'kick', dx: 1, dy: 0.2, power: 1 });
  const kick = await b.expect(m => m.t === 'kick');
  assert.strictEqual(kick.id, wa.id);
  assert.ok(kick.ball[3] > 300, 'ball got horizontal speed');
  // physics: ball slows and stays inside the pitch
  for (let i = 0; i < 600; i++) server.stepBall(1 / 60);
  assert.ok(server.ball.x >= 0 && server.ball.x <= server.worldWidth());
  assert.ok(Math.hypot(server.ball.vx, server.ball.vy) < 300, 'friction slows the ball');
  // a shot along the goal line outside the mouth bounces; one through the mouth scores
  server.ball.x = 60; server.ball.y = 40; server.ball.z = 0; server.ball.vx = -400; server.ball.vy = 0; server.ball.vz = 0;
  for (let i = 0; i < 30; i++) server.stepBall(1 / 60);
  assert.ok(server.ball.x >= 0 && server.ball.vx > 0, 'ball bounced off the goal line beside the goal');
  server.ball.x = 60; server.ball.y = server.worldHeight() / 2; server.ball.vx = -500; server.ball.vy = 0; server.ball.vz = 0; server.ball.lastKicker = wa.id;
  for (let i = 0; i < 30; i++) server.stepBall(1 / 60);
  const goal = await a.expect(m => m.t === 'goal');
  assert.strictEqual(goal.side, 'left'); assert.strictEqual(goal.by, wa.id); assert.strictEqual(goal.score.left, 1);
  assert.ok(server.ball.frozenUntil > Date.now(), 'ball waits in the net before the reset');
  server.ball.frozenUntil = Date.now() - 1; server.stepBall(1 / 60);
  assert.strictEqual(server.ball.x, server.worldWidth() / 2, 'ball back on the centre spot');
  a.send({ t: 'move', x: ax, y: ay, dir: 0, anim: 'idle' });

  // Presence hook updates an online player and is remembered for offline ones
  const pr = await post('/presence', { token: 'tok-c', event: 'start', game: 'Street Fighter II' });
  assert.strictEqual(pr.body.ok, true);
  assert.strictEqual(pr.body.online, true);
  const gm = await a.expect(m => m.t === 'game' && m.game === 'Street Fighter II');
  assert.ok(gm.id, 'game update names the player');
  const pr2 = await post('/presence', { token: 'tok-offline', event: 'start', game: 'Tetris' });
  assert.strictEqual(pr2.body.online, false);
  const d = client(); await d.ready();
  d.send({ t: 'hello', v: 1, token: 'tok-offline', nameSeed: 1 });
  const wd = await d.expect(m => m.t === 'welcome');
  assert.strictEqual(wd.you.game, 'Tetris', 'remembered game is applied on connect');
  d.close();

  // Profile update broadcast: a new seed gives a new generated name, typed names are ignored
  b.send({ t: 'update', nameSeed: 77, name: 'Bobby', share: true });
  const up = await a.expect(m => m.t === 'player' && m.player.id === wb.id);
  assert.strictEqual(up.player.name, server.nameFor('tok-b', 77));
  assert.notStrictEqual(up.player.name, 'Bobby');
  assert.strictEqual(up.player.game, 'Secret');

  // Health and stats
  const h = await get('/health');
  assert.strictEqual(h.ok, true);
  assert.ok(h.players >= 3);

  // Leave
  c.close();
  const lv = await a.expect(m => m.t === 'leave');
  assert.ok(lv.id, 'leave names the player');
  await new Promise(r => setTimeout(r, 50));
  assert.strictEqual((await get('/stats')).list.length, 2);

  a.close(); b.close();
  await new Promise(r => setTimeout(r, 100));
  server.tcpServer.close(); server.httpServer.close();
  console.log('smoke test: all checks passed');
  process.exit(0);
})().catch((e) => { console.error('smoke test FAILED:', e); process.exit(1); });
