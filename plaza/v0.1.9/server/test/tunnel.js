'use strict';
/*
 * BatWiiCera Plaza - netplay relay test
 * Author: yiddifliddo | Licence: MIT
 *
 * Plays a RetroArch host and a RetroArch client against tunnel.js using the
 * byte protocol from netplay_frontend.c: session request, link notice,
 * address request and reply, link connection, byte piping, ping/pong.
 */
const net = require('net');
const assert = require('assert');
const { createTunnel, addressBlock, MAGIC_SESSION, MAGIC_LINK, MAGIC_ADDR, MAGIC_PING, ID_LEN } = require('../tunnel.js');

const PORT = 15435;

function id(magic, unique) { const b = Buffer.alloc(ID_LEN); b.writeUInt32BE(magic, 0); if (unique) unique.copy(b, 4); return b; }
function connect() { return new Promise((res, rej) => { const s = net.connect(PORT, '127.0.0.1', () => res(s)); s.on('error', rej); }); }
function readExactly(sock, n, ms) {
  return new Promise((res, rej) => {
    let buf = Buffer.alloc(0);
    const t = setTimeout(() => rej(new Error('timeout waiting for ' + n + ' bytes, got ' + buf.length)), ms || 3000);
    const on = (c) => { buf = Buffer.concat([buf, c]); if (buf.length >= n) { clearTimeout(t); sock.removeListener('data', on); sock.pause(); const out = buf.slice(0, n); const rest = buf.slice(n); if (rest.length) sock.unshift(rest); res(out); } };
    sock.on('data', on); sock.resume();
  });
}

(async () => {
  // address encoding
  assert.deepStrictEqual(Array.from(addressBlock('203.0.113.9').slice(10)), [0xff, 0xff, 203, 0, 113, 9]);
  assert.deepStrictEqual(Array.from(addressBlock('::ffff:10.1.2.3').slice(10)), [0xff, 0xff, 10, 1, 2, 3]);
  assert.strictEqual(addressBlock('2001:db8::1').readUInt16BE(0), 0x2001);
  assert.strictEqual(addressBlock('2001:db8::1')[15], 1);

  const tunnel = createTunnel({});
  await new Promise((r) => tunnel.listen(PORT, '127.0.0.1', r));

  // host asks for a session
  const host = await connect();
  host.write(id(MAGIC_SESSION, Buffer.alloc(12)));
  const sess = await readExactly(host, ID_LEN);
  assert.strictEqual(sess.readUInt32BE(0), MAGIC_SESSION, 'session reply magic');
  const sessionId = sess.slice(4);
  assert.ok(sessionId.some((b) => b !== 0), 'session id is random, not zero');
  assert.strictEqual(tunnel.snapshot().sessions, 1);

  // an unknown session id is refused
  const stranger = await connect();
  stranger.write(id(MAGIC_SESSION, Buffer.from('000102030405060708090a0b', 'hex')));
  await new Promise((r) => stranger.on('close', r));

  // client joins the session; host gets a link notice
  const client = await connect();
  client.write(Buffer.concat([id(MAGIC_SESSION, sessionId), Buffer.from('early-bytes')]));
  const linkNotice = await readExactly(host, ID_LEN);
  assert.strictEqual(linkNotice.readUInt32BE(0), MAGIC_LINK, 'link notice magic');
  const linkId = linkNotice.slice(4);

  // host asks for the peer address, gets magic + id + 16 address bytes
  host.write(id(MAGIC_ADDR, linkId));
  const addrReply = await readExactly(host, ID_LEN + 16);
  assert.strictEqual(addrReply.readUInt32BE(0), MAGIC_ADDR);
  assert.ok(addrReply.slice(4, 16).equals(linkId), 'address reply names the link');
  assert.deepStrictEqual(Array.from(addrReply.slice(16 + 10)), [0xff, 0xff, 127, 0, 0, 1], 'client address as ::ffff:127.0.0.1');

  // host opens the link connection; bytes flow both ways, early bytes first
  const hostLink = await connect();
  hostLink.write(Buffer.concat([id(MAGIC_LINK, linkId), Buffer.from('hello-client')]));
  const early = await readExactly(hostLink, 'early-bytes'.length);
  assert.strictEqual(early.toString(), 'early-bytes', 'client bytes sent before linking are delivered');
  const toClient = await readExactly(client, 'hello-client'.length);
  assert.strictEqual(toClient.toString(), 'hello-client', 'host bytes reach the client');
  client.write(Buffer.from('input-frame'));
  const toHost = await readExactly(hostLink, 'input-frame'.length);
  assert.strictEqual(toHost.toString(), 'input-frame', 'client bytes reach the host');
  assert.strictEqual(tunnel.snapshot().links, 1);

  // a second link id is refused if nobody asked for it
  const bogus = await connect();
  bogus.write(id(MAGIC_LINK, Buffer.from('ffffffffffffffffffffffff', 'hex')));
  await new Promise((r) => bogus.on('close', r));

  // ping from the relay is answered by the host (simulate by writing RATP both ways)
  const ping = Buffer.alloc(4); ping.writeUInt32BE(MAGIC_PING, 0);
  host.write(ping);   // host-side reply form; the relay must swallow it without error
  await new Promise((r) => setTimeout(r, 50));
  assert.strictEqual(tunnel.snapshot().sessions, 1, 'session still open after a ping reply');

  // host leaves: session and its links are torn down
  host.destroy();
  await new Promise((r) => client.on('close', r));
  await new Promise((r) => setTimeout(r, 50));
  assert.strictEqual(tunnel.snapshot().sessions, 0, 'session closed with the host');

  tunnel.close();
  console.log('netplay relay test: all checks passed');
  process.exit(0);
})().catch((e) => { console.error('netplay relay test FAILED:', e); process.exit(1); });
