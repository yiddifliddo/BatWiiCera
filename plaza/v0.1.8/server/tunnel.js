'use strict';
/*
 * BatWiiCera Plaza - RetroArch netplay relay ("tunnel server")
 * Version 0.1.8 | Author: yiddifliddo | Licence: MIT
 *
 * Lets Batocera players host and join netplay games without opening ports
 * at home. It speaks the relay protocol that RetroArch's netplay uses for
 * its "relay server" option (the RATS / RATL / RATA / RATP handshake,
 * read from RetroArch's network/netplay/netplay_frontend.c):
 *
 *   host    -> relay : RATS + 12 zero bytes          "give me a session"
 *   relay   -> host  : RATS + 12 random bytes        the session id; this
 *                                                    connection stays open as
 *                                                    the host's control channel
 *   client  -> relay : RATS + session id             "link me to that host"
 *   relay   -> host  : RATL + link id                on the control channel
 *   host    -> relay : RATA + link id                "what is the peer's address"
 *   relay   -> host  : RATA + link id + 16 bytes     IPv6, or ::ffff:a.b.c.d
 *   host    -> relay : new connection, RATL + link id  -> paired with the
 *                                                    client; bytes are piped
 *                                                    both ways from then on
 *   relay   -> host  : RATP (4 bytes) every so often; host answers RATP
 *
 * One listening port serves everything, which is what a platform such as
 * Railway can expose through a single TCP proxy. The host announces the
 * relay's address and the session id to the netplay lobby, so friends join
 * from Batocera's netplay list without touching a setting.
 */

const net = require('net');
const crypto = require('crypto');

const MAGIC_SESSION = 0x52415453; // RATS
const MAGIC_LINK    = 0x5241544C; // RATL
const MAGIC_ADDR    = 0x52415441; // RATA
const MAGIC_PING    = 0x52415450; // RATP
const ID_LEN = 16;                // 4 bytes magic + 12 bytes unique

const PING_EVERY_MS = 20000;
const PING_TIMEOUT_MS = 15000;
const LINK_TIMEOUT_MS = 20000;
const HANDSHAKE_TIMEOUT_MS = 10000;
const MAX_SESSIONS = parseInt(process.env.PLAZA_TUNNEL_MAX || '64', 10);
const MAX_LINKS_PER_SESSION = 16;

function idBuffer(magic, unique) {
  const b = Buffer.alloc(ID_LEN);
  b.writeUInt32BE(magic, 0);
  if (unique) unique.copy(b, 4, 0, 12);
  return b;
}

// 16-byte address block: IPv6 bytes, or ::ffff:a.b.c.d for IPv4.
function addressBlock(ip) {
  const out = Buffer.alloc(16);
  if (!ip) return out;
  const v4 = ip.match(/(\d+)\.(\d+)\.(\d+)\.(\d+)$/);
  if (v4) {
    out[10] = 0xff; out[11] = 0xff;
    for (let i = 0; i < 4; i++) out[12 + i] = parseInt(v4[i + 1], 10) & 0xff;
    return out;
  }
  // IPv6: expand "::"
  const halves = ip.split('::');
  const head = halves[0] ? halves[0].split(':') : [];
  const tail = halves[1] ? halves[1].split(':') : [];
  const groups = head.concat(new Array(Math.max(0, 8 - head.length - tail.length)).fill('0'), tail).slice(0, 8);
  groups.forEach((g, i) => out.writeUInt16BE(parseInt(g || '0', 16) & 0xffff, i * 2));
  return out;
}

function createTunnel(opts) {
  opts = opts || {};
  const log = opts.log || (() => {});
  const sessions = new Map();   // unique(hex) -> session
  const stats = { sessions: 0, links: 0, bytes: 0 };

  function closeSession(s, why) {
    if (!sessions.has(s.key)) return;
    sessions.delete(s.key);
    clearInterval(s.pingTimer);
    clearTimeout(s.pingDeadline);
    for (const link of s.links.values()) {
      clearTimeout(link.timer);
      if (link.client && !link.client.destroyed) link.client.destroy();
      if (link.host && !link.host.destroyed) link.host.destroy();
    }
    if (!s.control.destroyed) s.control.destroy();
    log(`session ${s.key.slice(0, 8)} closed (${why}); ${sessions.size} open`);
  }

  function startPings(s) {
    s.pingTimer = setInterval(() => {
      if (s.control.destroyed) return closeSession(s, 'control gone');
      const ping = Buffer.alloc(4); ping.writeUInt32BE(MAGIC_PING, 0);
      s.control.write(ping);
      clearTimeout(s.pingDeadline);
      s.pingDeadline = setTimeout(() => closeSession(s, 'ping timeout'), PING_TIMEOUT_MS);
    }, PING_EVERY_MS);
  }

  // Control-channel reader: RATA requests and RATP replies from the host.
  function attachControl(s) {
    let buf = Buffer.alloc(0);
    s.control.on('data', (chunk) => {
      buf = Buffer.concat([buf, chunk]);
      for (;;) {
        if (buf.length < 4) return;
        const magic = buf.readUInt32BE(0);
        if (magic === MAGIC_PING) {
          clearTimeout(s.pingDeadline);
          buf = buf.slice(4);
          continue;
        }
        if (buf.length < ID_LEN) return;
        const unique = buf.slice(4, ID_LEN);
        buf = buf.slice(ID_LEN);
        if (magic === MAGIC_ADDR) {
          const link = s.links.get(unique.toString('hex'));
          if (link && link.client) {
            s.control.write(Buffer.concat([idBuffer(MAGIC_ADDR, unique), addressBlock(link.client.remoteAddress)]));
          }
        }
        // anything else on the control channel is ignored
      }
    });
    s.control.on('close', () => closeSession(s, 'host left'));
    s.control.on('error', () => {});
  }

  function pipePair(a, b) {
    const count = (c) => { stats.bytes += c.length; };
    a.on('data', count); b.on('data', count);
    a.pipe(b); b.pipe(a);
    const end = () => { if (!a.destroyed) a.destroy(); if (!b.destroyed) b.destroy(); };
    a.on('close', end); b.on('close', end);
    a.on('error', end); b.on('error', end);
  }

  const server = net.createServer((sock) => {
    sock.setNoDelay(true);
    let buf = Buffer.alloc(0);
    const handshakeTimer = setTimeout(() => sock.destroy(), HANDSHAKE_TIMEOUT_MS);
    sock.on('error', () => {});

    const onData = (chunk) => {
      buf = Buffer.concat([buf, chunk]);
      if (buf.length < ID_LEN) return;
      sock.removeListener('data', onData);
      clearTimeout(handshakeTimer);
      const magic = buf.readUInt32BE(0);
      const unique = buf.slice(4, ID_LEN);
      const rest = buf.slice(ID_LEN);
      sock.pause();

      if (magic === MAGIC_SESSION && unique.every((b) => b === 0)) {
        // a host asking for a session
        if (sessions.size >= MAX_SESSIONS) { sock.destroy(); return; }
        const id = crypto.randomBytes(12);
        const s = { key: id.toString('hex'), id, control: sock, links: new Map(), createdAt: Date.now() };
        sessions.set(s.key, s);
        stats.sessions++;
        sock.write(idBuffer(MAGIC_SESSION, id));
        attachControl(s);
        startPings(s);
        sock.resume();
        log(`session ${s.key.slice(0, 8)} opened by ${sock.remoteAddress}; ${sessions.size} open`);
        return;
      }

      if (magic === MAGIC_SESSION) {
        // a client asking to be linked to a host's session
        const s = sessions.get(unique.toString('hex'));
        if (!s || s.links.size >= MAX_LINKS_PER_SESSION) { sock.destroy(); return; }
        const linkId = crypto.randomBytes(12);
        const link = { key: linkId.toString('hex'), client: sock, host: null, timer: null };
        s.links.set(link.key, link);
        link.timer = setTimeout(() => { s.links.delete(link.key); if (!sock.destroyed) sock.destroy(); }, LINK_TIMEOUT_MS);
        sock.on('close', () => { if (!link.host) { clearTimeout(link.timer); s.links.delete(link.key); } });
        s.control.write(idBuffer(MAGIC_LINK, linkId));
        // keep anything the client already sent for the host
        link.early = rest;
        return;
      }

      if (magic === MAGIC_LINK) {
        // the host's new connection for a pending link
        const key = unique.toString('hex');
        let found = null, owner = null;
        for (const s of sessions.values()) { const l = s.links.get(key); if (l) { found = l; owner = s; break; } }
        if (!found || found.host) { sock.destroy(); return; }
        clearTimeout(found.timer);
        found.host = sock;
        stats.links++;
        if (rest.length) found.client.write(rest);
        if (found.early && found.early.length) sock.write(found.early);
        found.client.resume();
        sock.resume();
        pipePair(sock, found.client);
        const cleanup = () => owner.links.delete(key);
        sock.on('close', cleanup); found.client.on('close', cleanup);
        log(`session ${owner.key.slice(0, 8)} linked ${found.client.remoteAddress}`);
        return;
      }

      sock.destroy();
    };
    sock.on('data', onData);
  });

  return {
    server,
    sessions,
    stats,
    listen(port, bind, cb) { server.listen(port, bind, cb); },
    close() { for (const s of Array.from(sessions.values())) closeSession(s, 'shutdown'); server.close(); },
    snapshot() { return { sessions: sessions.size, links: Array.from(sessions.values()).reduce((n, s) => n + s.links.size, 0), totalSessions: stats.sessions, totalLinks: stats.links, bytes: stats.bytes }; }
  };
}

module.exports = { createTunnel, addressBlock, MAGIC_SESSION, MAGIC_LINK, MAGIC_ADDR, MAGIC_PING, ID_LEN };
