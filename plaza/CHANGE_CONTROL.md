# BatWiiCera Plaza - Change Control Register

Process reference: ISO/IEC 27001:2022 Annex A, control 8.32 (Change management).
Same rules as the BatWiiCera theme repository: records are appended, never
deleted; every change to the product produces a new `vX.Y.Z/` folder; each
record carries author, company, risk, test evidence and rollback.

## Register summary

| Change ID | Date | Version | Type | Title | Branch | Status |
| --- | --- | --- | --- | --- | --- | --- |
| PCR-0001 | 2026-10-05 | 0.1.0 | New product | Initial creation of the Plaza channel (server, client, hook, installer) | `release/plaza-v0.1.0` (BatWiiCera repository, `plaza/` folder) | Submitted for approval |
| PCR-0002 | 2026-10-05 | 0.1.1 | Standard change | Theme palette and automatic light/dark matching | `release/plaza-v0.1.1` | Submitted for approval |
| PCR-0003 | 2026-10-05 | 0.1.2 | Standard change | Railway hosting support (PORT, presence URL, host:port) | `release/plaza-v0.1.2` | Submitted for approval |
| PCR-0004 | 2026-10-05 | 0.1.3 | Standard change | Terminal-free install from the client; presence URL from the server | `release/plaza-v0.1.3` | Submitted for approval |
| PCR-0005 | 2026-10-05 | 0.1.4 | Standard change | Public server built in, one-file Ports installer, automatic EmulationStation restart, author credit | `release/plaza-v0.1.4`, merged to `main` | Approved by author instruction, implemented |
| PCR-0006 | 2026-10-05 | 0.1.5 | Emergency change | Server crashed on Railway: PORT equals the TCP proxy port | `release/plaza-v0.1.5`, merged to `main` | Approved by author instruction (error report), implemented |
| PCR-0007 | 2026-10-05 | 0.1.6 | Corrective change | Channel did not start on Batocera (no LÖVE engine): bundled runtime, one launcher, game-screen artwork | `release/plaza-v0.1.6`, merged to `main` | Implemented; device test passed (author, "The plaza works") |
| PCR-0008 | 2026-10-05 | 0.1.7 | Standard change | Football stadium with goals, new avatar renderer and movement, smooth remote players, generated names | `release/plaza-v0.1.7`, merged to `main` | Approved by author ("build the stadium and look"), implemented |
| PCR-0009 | 2026-10-05 | 0.1.8 | Standard change | RetroArch netplay relay built into the server (one port, Railway-friendly) | `release/plaza-v0.1.8`, merged to `main` | Approved by author ("I want netplay server to be added to the railway server"), implemented |

---

## PCR-0001 - Initial creation of the Plaza channel

| Field | Value |
| --- | --- |
| Change ID | PCR-0001 |
| Date raised | 2026-10-05 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera Plaza (companion to the BatWiiCera theme) |
| Version produced | 0.1.0 (folder `v0.1.0`) |
| Previous version | None (new product) |
| Change type | New product, phase one |
| Branch | `release/plaza-v0.1.0` in the BatWiiCera repository, under `plaza/` (a separate repository could not be created by the tooling; the author asked for the code to be added alongside the theme instead) |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

Author request: a channel where players make an avatar and join one big room
with everyone using BatWiiCera, with the game they are playing shown above
their head, the view zooming out as people join, running around, slapping
with A, jumping with X, an avatar editor, and (added during the build) a
ball to kick around.

Delivered in phase one:

* **Server** (`server/index.js`, Node.js, no dependencies): TCP game port
  with newline-delimited JSON, HTTP port for the presence hook, health and
  stats. Validates nicknames (length, printable, word filter extendable by
  environment variable), avatars (nine bounded integers) and game names.
  Authoritative slap targeting with cooldown, server-side ball physics
  (gravity, bounce, friction, walls, walk-into nudges, kicks within range),
  plaza that grows with the crowd, 15 Hz snapshots, idle and rate limits,
  presence memory for 12 hours. Systemd unit included.
* **Client** (`client/`, LÖVE 11.x): start menu, controller-driven avatar
  editor with on-screen keyboard, the plaza scene (top-down tiled floor,
  depth-sorted figures, name and "Playing" bubbles that stay readable when
  zoomed out, hop, slap knockback, ball with prediction, camera that frames
  everyone), reconnecting network layer, profile and config storage, demo
  mode for screenshots.
* **Presence hook** (`hook/`): Batocera game-start/stop script posting the
  cleaned ROM name and system to the server, honouring the player's
  "Show my game" setting.
* **Installer** (`installer/`): copies the client to `roms/plaza`, adds the
  custom `plaza` system (launched through Batocera's LÖVE launcher), installs
  the hook, writes the server address, drops the channel logo into installed
  BatWiiCera theme folders, writes a friendly gamelist entry.
* Documentation: repository and version READMEs, MIT licence, this register.

Design decisions recorded:

* A theme cannot host this (no logic or networking), so it is a separate
  launchable game plus a server.
* Avatars are an original cartoon design drawn in code. The author's Mii
  Editor reference was used for the editor flow only (parts list with live
  preview); no Mii characters, artwork or names are reproduced.
* Top-down plaza view chosen after the author's reference photo of a crowd on
  a tiled floor; "jump" is therefore a hop and the ball rolls in two
  dimensions.
* A kicks the ball when within range, otherwise slaps, so one button serves
  both without a mode switch.
* The two Plaza screenshots the author supplied as references are not
  included in the repository.

### Reason for change

Author request for a social feature that makes the theme feel alive.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Abuse through nicknames | Medium | Offensive text visible to all | Server-side filter, length limit, printable ASCII only; owner can extend the word list; no free-text chat in phase one |
| Spoofed presence or movement | Low-Medium | Wrong labels, teleporting | Positions clamped to the world, moves rate-limited, slaps and kicks validated by distance and cooldown, avatars bounded; tokens are random per install |
| Server exposed on the internet | Medium | Resource abuse | No dependencies, 4 KB message cap, idle timeout, player cap, runs as an unprivileged service with systemd hardening; firewall only the two ports |
| LÖVE build differences on Batocera versions | Medium | Client fails to start | Conf targets 11.x features only, LuaSocket presence checked at runtime with a clear error; first device test required |
| Custom system command path differs between Batocera versions | Medium | Channel does not launch | Command mirrors Batocera's own `love` system entry; documented how to adjust |
| Privacy expectations | Low | Players surprised their game is visible | Opt-out setting, random tokens, no accounts, documented |

Overall risk rating: **Medium** until the first device test; low afterwards.

### Impact

New repository content only. The BatWiiCera theme is untouched; the
installer only adds a logo file to an installed theme copy. A follow-up
theme change (new version) will bundle the Plaza logo properly.

### Testing and verification performed

| Check | Result |
| --- | --- |
| `node --check` and server smoke test (`npm test`) covering cleaners, version gate, join/leave, snapshots, clamping, slap targeting and cooldown, kick range and ball physics, presence hook (online and remembered), profile update, health and stats | Pass |
| Client self-test under Lua 5.1 with a stub engine (`lua5.1 test/run.lua`) | Pass, 51 checks |
| Client rendering under LÖVE 11.5 on a virtual framebuffer (`love . --demo`): plaza with 13 avatars, ball and labels, editor and menu drawn without error; screenshots saved to `previews/` | Pass |
| Shell scripts parsed with `bash -n`; custom system XML and logo SVG well-formed | Pass |
| Presence hook end to end against a local server: `gameStart` with `Super Metroid (USA) [!].sfc` reaches the server as `Super Metroid (snes)` and is applied on the next connect; `gameStop` clears it | Pass (a sed bracket-expression bug in tag stripping was found and fixed during this test) |
| Packages built: `dist/BatWiiCera-Plaza.love` (15 files) and `dist/BatWiiCera-Plaza-server.tar.gz` | Pass |
| First test on a Batocera device with the author's VPS | **Not performed** - required before approval |

### Rollback plan

Remove the custom system file, the hook script, the `roms/plaza` folder and
the Plaza save folder from the Batocera machine; stop and disable the service
on the VPS. The theme is unaffected.

### Post-implementation review

To be completed after the device test.

---

## PCR-0002 - Theme palette and automatic light/dark matching

| Field | Value |
| --- | --- |
| Change ID | PCR-0002 |
| Date raised | 2026-10-05 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera Plaza |
| Version produced | 0.1.1 (folder `plaza/v0.1.1`) |
| Previous version | 0.1.0 (folder `plaza/v0.1.0`, left unchanged) |
| Change type | Standard change (low risk) |
| Branch | `release/plaza-v0.1.1` (branched from `release/plaza-v0.1.0`) |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

The author asked that the Plaza match the theme, colours included.

* `client/src/ui.lua`: two palettes with the exact hex values from the
  theme's `classic.xml` and `dark.xml` (backdrop, stripe lines, panel,
  border, three text greys, three blues) plus floor, tile and bubble tints
  derived from them; `setPalette()` and `detectThemeMode()`, which reads
  `subset.colorset` from EmulationStation's `es_settings.cfg`.
* Plaza floor, tiles, bubbles and HUD, the editor and the menu all draw from
  the active palette; the window background follows it.
* Profile gains `colors` = auto, light or dark (auto by default); the
  editor gains a **Colours** row; `main.lua` applies the palette on start and
  after editing. Demo mode gains `--dark`.
* Self-test extended to 55 checks. Light and dark previews rendered.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| `es_settings.cfg` unreadable or in a different place on some builds | Low | Falls back to light | Manual Colours override in the editor |
| Future theme palette changes drift from the Plaza | Medium | Cosmetic | Palette values are in one table with the source files named |

Overall risk rating: **Negligible**.

### Testing and verification performed

| Check | Result |
| --- | --- |
| Client self-test (`lua5.1 test/run.lua`) | Pass, 55 checks |
| Server smoke test (unchanged server, re-run) | Pass |
| Light and dark renders under LÖVE on a virtual framebuffer (`--demo`, `--demo --dark`) | Pass, six previews |
| Packages rebuilt | Pass |
| On a Batocera device | **Not performed** |

### Rollback plan

Install `plaza/v0.1.0`. In the repository, revert the merge of
`release/plaza-v0.1.1`.

---

## PCR-0003 - Railway hosting support

| Field | Value |
| --- | --- |
| Change ID | PCR-0003 |
| Date raised | 2026-10-05 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera Plaza |
| Version produced | 0.1.2 (folder `plaza/v0.1.2`) |
| Previous version | 0.1.1 (folder `plaza/v0.1.1`, left unchanged) |
| Change type | Standard change |
| Branch | `release/plaza-v0.1.2` (branched from `release/plaza-v0.1.1`) |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

The author attached the repository to a Railway service (first build failed:
Railway built the repository root of the default branch, where there is no
Node project). Railway exposes one HTTP listener on `PORT` behind an HTTPS
domain and raw TCP only through its TCP Proxy, which has a different host and
port. Changes:

* Server: HTTP listener uses `PORT` when set, else `PLAZA_HTTP_PORT`;
  `server/railway.json` with start command, `/health` check and restart policy.
* Client: `config.json` gains `presenceUrl`; `config.parseHostPort()` and
  `config.presenceBase()`; the menu's Server address accepts `host:port` and
  the status card shows the port and presence mode.
* Hook: posts to `presenceUrl` when set (curl `-sL`, HTTPS), else
  `http://host:httpPort`.
* Installer: third argument is a port number or a full presence URL; usage
  examples for VPS and Railway.
* `RAILWAY-SETUP.md`: root directory, branch, public domain, TCP Proxy,
  variables, installer command, costs, updating, troubleshooting.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Railway TCP Proxy adds latency or rate limits | Low-Medium | Slightly laggier movement | Snapshots are 15 Hz and interpolated; VPS remains the alternative |
| Operators give the installer the public domain as the game host | Medium | Client cannot connect | Documented order and examples; status card shows the game address |
| `PORT` set on a VPS by accident | Low | HTTP side moves port | Documented |

Overall risk rating: **Low**.

### Testing and verification performed

| Check | Result |
| --- | --- |
| Server smoke test | Pass |
| Server started with `PORT=17999`: `/health` answered on that port, version 0.1.2 | Pass |
| Client self-test | Pass, 59 checks |
| Hook end to end with `presenceUrl` set to a local URL: game applied on next connect | Pass |
| `bash -n` on hook and installer; `node --check` on the server | Pass |
| Packages rebuilt | Pass |
| Deployment on the author's Railway service and a Batocera device | **Not performed** - required before approval |

### Rollback plan

Use `plaza/v0.1.1` on a VPS. In the repository, revert the merge of
`release/plaza-v0.1.2`.

---

## PCR-0004 - Terminal-free install from the client; presence URL from the server

| Field | Value |
| --- | --- |
| Change ID | PCR-0004 |
| Date raised | 2026-10-05 |
| Requested by | Dan Lee ("I do not want to run that from Batocera") |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera Plaza |
| Version produced | 0.1.3 (folder `plaza/v0.1.3`) |
| Previous version | 0.1.2 (folder `plaza/v0.1.2`, left unchanged) |
| Change type | Standard change |
| Branch | `release/plaza-v0.1.3` (branched from `main` after CR-0020) |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

The author does not want to run shell commands on the Batocera machine.
Since the Plaza client runs with full rights on Batocera, it now installs
itself:

* `client/src/setup.lua`: detects Batocera (`/userdata`), reports install
  status, and `install()` copies the running `.love` to `/userdata/roms/plaza`,
  writes `gamelist.xml`, the `es_systems_plaza.cfg` overlay and the presence
  hook (`chmod 755`), and adds the channel logo to installed BatWiiCera copies
  that lack it. `uninstall()` reverses it.
* `client/src/embedded.lua` is generated by `build.sh` from `hook/` and
  `installer/`, so the shell installer and the self-installer share one
  source. `installer/gamelist.xml` split out for the same reason.
* Menu: on Batocera an item "Install Plaza channel on this Batocera" (or
  "Repair ...") appears, with a result list and a notice to restart
  EmulationStation.
* Server: welcome carries `presence`, the public HTTP URL from
  `PLAZA_PUBLIC_URL` or Railway's `RAILWAY_PUBLIC_DOMAIN`; the client saves it
  into `config.json`, so the hook knows where to post without typing a URL on
  the TV.
* Documentation: terminal-free procedure is now the primary one.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| LÖVE on Batocera lacks `io`/`os` rights to write outside its save folder | Low (runs as root, standard Lua libs) | Install fails with a message | Result list shows which step failed; shell installer remains |
| `love.filesystem.getSource()` not a `.love` path (run from a folder) | Low | Client not copied | Detected and reported; other steps still done |
| Writing into the theme folder | Low | Only adds a missing logo | Skipped when present |

Overall risk rating: **Low**.

### Testing and verification performed

| Check | Result |
| --- | --- |
| Client self-test (embedded files, presence hand-over) | Pass, 64 checks |
| Server smoke test (presence URL in welcome) | Pass |
| `build.sh` generates `src/embedded.lua`; shell installer and server syntax checks | Pass |
| Self-install on a Batocera device | **Not performed** - required before approval |

### Rollback plan

Use `plaza/v0.1.2`; the menu item does not appear off Batocera and the
shell installer still works. In the repository, revert the merge.

---

## PCR-0005 - Public server built in, one-file Ports installer, automatic restart, author credit

| Field | Value |
| --- | --- |
| Change ID | PCR-0005 |
| Date raised | 2026-10-05 |
| Requested by | yiddifliddo ("this needs to be automated"; attribution to the GitHub name) |
| Author | yiddifliddo |
| Company / project | yiddifliddo (personal project) |
| Product | BatWiiCera Plaza |
| Version produced | 0.1.4 (folder `plaza/v0.1.4`) |
| Previous version | 0.1.3 (folder `plaza/v0.1.3`, left unchanged) |
| Change type | Standard change |
| Branch | `release/plaza-v0.1.4`, merged to `main` (Railway follows `main`) |
| Status | Approved by author instruction, implemented |
| Approver | yiddifliddo |
| Approval date | 2026-10-05 |

### Description of change

The install procedure still asked a person to copy a file, start it, type the
server address and restart EmulationStation. A theme cannot run code, so one
file must be placed outside the theme folder once; everything after that is
now automatic.

* **Built-in public server.** `client/src/config.lua` defaults to the public
  BatWiiCera server (game `maglev.proxy.rlwy.net:28071`, presence
  `https://batwiicera-production.up.railway.app`, see theme CR-0023). The
  presence hook falls back to the same values when no `config.json` exists,
  and the shell installer uses them when called without arguments.
  **Server address** in the menu still overrides for private servers.
* **One-file Ports entry** `installer/Plaza.sh`. Placed in
  `/userdata/roms/ports` it is listed under Ports as "Plaza". If the channel
  is not installed it finds the newest BatWiiCera theme copy with a `_plaza`
  folder, runs its installer and lets it restart EmulationStation. Otherwise
  it restores the hook's executable bit and launches the client through
  Batocera's emulator launcher (falls back to `love`). Logs to
  `/userdata/system/logs/plaza-ports.log`. Embedded in the client
  (`embedded.ports`) and written by both installers.
* **Automatic EmulationStation restart.** `setup.restartEmulationStation()`
  runs `batocera-es-swissknife --restart` detached after three seconds; the
  menu quits the client just before. The shell installer does the same
  (`--no-restart` skips it).
* **Channel launch command** in `es_systems_plaza.cfg` first runs `chmod +x`
  on the hook, so a copy made over a Windows share (which drops the bit)
  still reports games once the Plaza has been opened.
* **Author credit** changed from Dan Lee to yiddifliddo in every header,
  `server/package.json`, `installer/gamelist.xml`, `installer/plaza.svg` and
  `plaza/LICENSE`. Earlier version folders are left as released.
* Version 0.1.4 in all headers, `/health` and the welcome message; packages
  rebuilt. No gameplay or visual changes.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Public server address changes later | Low | Clients built with the old default cannot connect until updated or overridden | Menu override; new release with new default |
| `batocera-es-swissknife` missing or restart kills the installer early | Low | Channel appears only after a manual restart | Restart is detached and delayed; message says to restart manually when the tool is absent |
| Ports script run without the theme installed | Medium (user error) | Nothing installed, exit 1 | Message in the log names the cause; the full-install zip avoids the case |
| `python emulatorlauncher.py` arguments differ on a future Batocera | Low | Ports entry fails to launch after install (channel tile unaffected) | Falls back to `love`; channel tile uses Batocera's own command |

Overall risk rating: **Low**.

### Testing and verification performed

| Check | Result |
| --- | --- |
| Client self-test (`lua5.1 test/run.lua`): built-in server defaults, embedded Ports script, existing checks | Pass, 67 checks |
| Server smoke test (`node server/test/smoke.js`) and `node --check` | Pass |
| Shell syntax of installer, Ports entry and hook; XML of system file and gamelist | Pass |
| Ports entry dry run against a temporary `/userdata` tree on the build machine: first run installed client, system file, hook (executable), Ports copy, config with the public server, logo; second run restored a removed executable bit and reached the launch step | Pass |
| Hook with a profile and no config: POSTed `start` with the cleaned game name to the (locally redirected) presence endpoint | Pass |
| Public server `GET /health` | Pass |
| TCP proxy reachability from the build machine | **Not possible** (outbound raw TCP blocked there); device test required |
| On a Batocera device: Ports route, full zip route, client route, automatic restart, controller | **Not performed** - required before sign-off |

### Rollback plan

Install from `plaza/v0.1.3` (CR-0022 theme package) instead. On Railway
revert the merge on `main`; the server protocol is unchanged, so 0.1.3 and
0.1.4 clients and servers interoperate.

---

## PCR-0006 - Server crashed on Railway: PORT equals the TCP proxy port

| Field | Value |
| --- | --- |
| Change ID | PCR-0006 |
| Date raised | 2026-10-05 |
| Requested by | yiddifliddo (pasted the Railway deploy log) |
| Author | yiddifliddo |
| Company / project | yiddifliddo (personal project) |
| Product | BatWiiCera Plaza (server) |
| Version produced | 0.1.5 (folder `plaza/v0.1.5`) |
| Previous version | 0.1.4 (folder `plaza/v0.1.4`, left unchanged) |
| Change type | Emergency change (public service down) |
| Branch | `release/plaza-v0.1.5`, merged to `main` |
| Status | Approved by author instruction (error report), implemented |
| Approver | yiddifliddo |
| Approval date | 2026-10-05 |

### Incident

After PCR-0005 merged, Railway rebuilt the service. Its deploy log showed
`[plaza] game port 0.0.0.0:7777` followed by `EADDRINUSE 0.0.0.0:7777` and a
restart loop. Cause: once a TCP proxy exists Railway injects `PORT=7777`
(the proxy's port), and the server used `PORT` for its HTTP listener, so both
listeners wanted 7777. The crash loop also took the previous deployment
down: `/health` on the public domain timed out from about 12:47 UTC.

### Description of change

* `server/index.js`: `resolvePorts(env)` - explicit `PLAZA_*_PORT` values
  always win; otherwise HTTP takes `PORT`; if that equals the game port the
  HTTP side moves to `PLAZA_HTTP_FALLBACK_PORT` (default 8080, the port the
  public domain targets) and logs why. Listen errors print one line and exit
  1 instead of an unhandled exception.
* `server/test/smoke.js`: five port-resolution cases.
* Version 0.1.5 everywhere; packages rebuilt. Client code unchanged.
* Root `package.json` and `railway.json` start `plaza/v0.1.5/server`
  (theme CR-0025). Theme 0.1.15 keeps the embedded 0.1.4 copy: its client is
  identical and the bug only affects hosts that inject `PORT`.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Domain generated on a port other than 8080 | Low for the public server | Health check fails, deploy rolls back | `PLAZA_HTTP_PORT` or `PLAZA_HTTP_FALLBACK_PORT` variable |

Overall risk rating: **Low**.

### Testing and verification performed

| Check | Result |
| --- | --- |
| Smoke test incl. port resolution; `node --check` | Pass |
| Live simulation: `PORT` equal to the game port, HTTP answered on the fallback port, both listeners up | Pass |
| Client self-test | Pass, 67 checks |
| Public server `/health` reports 0.1.5 after Railway redeploys | Pass - `{"ok":true,"players":0,"version":"0.1.5"}` at 12:53 UTC, about 6 minutes after the outage began; `/stats` answering |

### Rollback plan

Set `PLAZA_HTTP_PORT=8080` in Railway and start `plaza/v0.1.4/server`; or
revert the merge.

---

## PCR-0007 - Channel did not start on Batocera: bundled runtime, one launcher, artwork

| Field | Value |
| --- | --- |
| Change ID | PCR-0007 |
| Date raised | 2026-10-05 |
| Requested by | yiddifliddo (device photos: placeholder game screen, stock launch splash, "closes immediately") |
| Author | yiddifliddo |
| Company / project | yiddifliddo (personal project) |
| Product | BatWiiCera Plaza |
| Version produced | 0.1.6 (folder `plaza/v0.1.6`) |
| Previous version | 0.1.5 (folder `plaza/v0.1.5`, left unchanged) |
| Change type | Corrective change |
| Branch | `release/plaza-v0.1.6`, merged to `main` |
| Status | Approved by author ("go"), implemented |
| Approver | yiddifliddo |
| Approval date | 2026-10-05 |

### Root cause

Every Plaza version to date assumed Batocera ships the LÖVE engine as its
`love` system. It does not: Batocera 42's system list and package tree have
no `love` system and no LÖVE package (checked in the batocera.linux
repository, branch `batocera-42`). The channel's command therefore failed at
once and EmulationStation returned to the menu. The assumption was never
verified before the first device test; that is the process failure behind
this record.

### Description of change

* `runtime/love-11.5-x86_64.AppImage`: the official LÖVE 11.5 Linux build
  (zlib licence, `runtime/LICENSE-love.txt`, SHA-256 recorded in
  `runtime/README.md`). The installer copies it to `roms/plaza/runtime/`
  and unpacks it once (`--appimage-extract`, no FUSE). x86_64 only for now;
  the launcher selects by `uname -m` and reports clearly otherwise.
* `installer/Plaza.sh`: one script that installs (when nothing is in place,
  from the newest theme copy with a `_plaza` folder, then restarts
  EmulationStation) or launches (`runtime/<arch>/AppRun Plaza.love`). It is
  the channel's single entry in `roms/plaza` and the Ports entry.
* `installer/es_systems_plaza.cfg`: extension `.sh`, command
  `chmod +x <hook>; bash %ROM%`; no emulator block. `installer/gamelist.xml`:
  name "Plaza", artwork (`installer/images/plaza-preview.png`, the 1280x720
  plaza render; `plaza-logo.png`, 600x240 from `plaza.svg`), developer,
  publisher, release date, players 1-200, genre, rating.
* `installer/install-batocera.sh`: copies and unpacks the runtime, the
  artwork and the launcher to both places. `client/src/setup.lua`: status
  includes launcher and runtime; copies runtime and artwork from the theme
  folder. `client/conf.lua`: LÖVE 11.5. Self-test updated.
* Version 0.1.6 everywhere; packages rebuilt. Server unchanged except the
  version string.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Runtime fails to start under Batocera's display stack (Wayland/KMS, Mesa) | Medium until tested | Channel still does not start | Launch is logged to `plaza.log`; SDL2 in the runtime supports Wayland and X11; device test required |
| ARM devices | Certain | No Plaza there yet | Clear log message; ARM build can be added to `runtime/` |
| Package growth (+5 MB) | Certain | Theme zip about 19 MB | Accepted by author |
| Unpacking fails on a read-only or full `/userdata` | Low | Launch fails with message | Logged; re-run repairs |

Overall risk rating: **Medium** until the device test passes.

### Testing and verification performed

| Check | Result |
| --- | --- |
| Client self-test (67 checks) and server smoke test | Pass |
| Shell syntax of `Plaza.sh` and the installer; XML of system file and game list | Pass |
| Runtime download verified by SHA-256; runs the unchanged client under a virtual display | Pass |
| Dry run in a temporary `/userdata` tree: `Plaza.sh` over a 0.1.4 layout reinstalled everything, unpacked the runtime for x86_64, wrote artwork and both launchers; second run started the client, which ran until stopped after 6 s | Pass |
| Artwork rendered and inspected | Pass |
| On a Batocera device: channel starts, controller works, room reachable | **Pass** - author, 2026-10-05: "The plaza works" (first successful end-to-end run; recorded here after the fact) |

### Rollback plan

None useful: 0.1.5 and earlier cannot start on Batocera. Removing the
channel is `Plaza.sh`'s uninstall counterpart in the client menu, or
deleting `roms/plaza`, `roms/ports/Plaza.sh`, the system file and the hook.

---

## PCR-0008 - Football stadium, new avatar renderer and movement, generated names

| Field | Value |
| --- | --- |
| Change ID | PCR-0008 |
| Date raised | 2026-10-05 |
| Requested by | yiddifliddo ("It looks so so basic. The arena needs to be bigger ... a giant football stadium ... name the player with a random name ... make the player movement look better ... more professional") |
| Author | yiddifliddo |
| Company / project | yiddifliddo (personal project) |
| Product | BatWiiCera Plaza |
| Version produced | 0.1.7 (folder `plaza/v0.1.7`) |
| Previous version | 0.1.6 (folder `plaza/v0.1.6`, left unchanged) |
| Change type | Standard change |
| Branch | `release/plaza-v0.1.7`, merged to `main` |
| Status | Approved by author ("build the stadium and look"), implemented |
| Approver | yiddifliddo |
| Approval date | 2026-10-05 |

### Description of change

See "Changes in this version" in `v0.1.7/README.md` for the player-facing
list. In summary: the room is a football stadium three times the old area
with goals that score; movement gained acceleration, braking, skids,
eight-way facing and impact squash; other players are interpolated between
velocity-bearing snapshots with a 100 ms render delay; the avatar renderer
was rewritten around a jointed body; names are generated from the install
token plus a seed by identical code on client (`client/src/names.lua`) and
server (`server/names.js`), the server ignoring any other name.

Files: `client/src/plaza.lua` (rewritten), `client/src/avatar.lua`
(renderer rewritten, data unchanged), `client/src/names.lua` (new),
`client/src/config.lua`, `client/src/editor.lua`, `client/src/menu.lua`,
`client/src/ui.lua` (stadium palette, outlined text, light prompts),
`client/main.lua` (hello/update carry the seed; demo adds a wide stadium
view and an avatar sheet), `server/index.js`, `server/names.js` (new),
both test suites, `previews/`.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Rendering load on weaker x86 boxes (stands as a sprite batch, particles capped at 320) | Low | Frame drops | Sprite batch is static; particle cap; device test |
| 0.1.6 clients against the 0.1.7 server read facings as degrees | Certain until the theme embed is installed | Mirrored figures for old clients | Theme 0.1.19 ships 0.1.7; only one device exists today |
| Generated-name collisions | Low (60 x 60 x 99 combinations, per token) | Two players share a name | Cosmetic; ids differ |
| Camera look-ahead or dead zone feels wrong on a pad | Medium | Tuning | Constants at the top of `plaza.lua`; device feedback |

Overall risk rating: **Low**.

### Testing and verification performed

| Check | Result |
| --- | --- |
| Client self-test, 86 checks (physics, facing, skid, interpolation, extrapolation, camera, goals, names, config seed) | Pass |
| Server smoke test (names, snapshots, clamping to stands, slap cone, goal-line bounce, goal and reset, update by seed) | Pass |
| Name generator cross-check: Lua and JavaScript produce identical names for the same inputs | Pass |
| Rendering under the bundled LÖVE 11.5 on a virtual framebuffer, light and dark: play view, wide stadium view, editor, menu, avatar sheet; inspected | Pass |
| On a Batocera device: look, feel and performance of the stadium, movement and names | **Not performed** - required |

### Rollback plan

Install the theme 0.1.18 package (Plaza 0.1.6) and start `plaza/v0.1.6/server`
on Railway; the 0.1.6 server and client interoperate.

---

## PCR-0009 - RetroArch netplay relay built into the server

| Field | Value |
| --- | --- |
| Change ID | PCR-0009 |
| Date raised | 2026-10-05 |
| Requested by | yiddifliddo ("I want netplay server to be added to the railway server so I can give to friends") |
| Author | yiddifliddo |
| Company / project | yiddifliddo (personal project) |
| Product | BatWiiCera Plaza (server) |
| Version produced | 0.1.8 (folder `plaza/v0.1.8`) |
| Previous version | 0.1.7 (folder `plaza/v0.1.7`, left unchanged) |
| Change type | Standard change |
| Branch | `release/plaza-v0.1.8`, merged to `main` |
| Status | Approved by author, implemented |
| Approver | yiddifliddo |
| Approval date | 2026-10-05 |

### Background and design decision

libretro's historical `netplay-mitm-server` opens a new TCP port per
session, which a Railway service cannot expose. Current RetroArch (and so
Batocera) uses a newer single-port "tunnel" protocol for its relay servers,
documented only in RetroArch's source (`network/netplay/netplay_frontend.c`,
`netplay_private.h`: magics RATS/RATL/RATA/RATP, 16-byte ids, 16-byte
address blocks). That protocol was implemented in Node inside the Plaza
server, so one more Railway TCP proxy is all that is needed. RetroArch's
custom relay setting accepts `host:port`, so Railway's assigned proxy port is
fine, and the host's lobby announcement carries the relay address and
session id, so joining players need no setting.

### Description of change

* `server/tunnel.js` (new): sessions, link notices, address replies, link
  pairing with early-byte handling, pings every 20 s with a 15 s deadline,
  20 s link timeout, caps (`PLAZA_TUNNEL_MAX` sessions, 16 links each).
* `server/index.js`: starts the relay on `PLAZA_TUNNEL_PORT` (default 55435,
  0 disables), reports it in `/health` and `/stats`, closes it on shutdown.
* `server/test/tunnel.js` (new) and `npm test` runs both server tests.
* Documentation: README "Netplay relay" section, Railway guide step 3b and
  variables. Version 0.1.8 everywhere; packages rebuilt; client unchanged.
* Root `package.json` and `railway.json` start `plaza/v0.1.8/server`. The
  theme embed stays at 0.1.7 (client identical); it will carry 0.1.8 or
  later with the next theme release.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Protocol detail misread (no public server source to compare) | Medium | Hosting through the relay fails | Test plays both sides from the RetroArch source; first real test is one Batocera hosting and one joining |
| Relay traffic through Railway's proxy adds latency | Certain | Input lag depends on region | Same as libretro's own relays; VPS option documented |
| Abuse of an open relay | Low | Bandwidth | Session and link caps; port can be disabled |

Overall risk rating: **Low to Medium** until the first live netplay test.

### Testing and verification performed

| Check | Result |
| --- | --- |
| `node server/test/tunnel.js` (protocol both sides) | Pass |
| `node server/test/smoke.js` (room unchanged) | Pass |
| Client self-test (86 checks) | Pass |
| Two Batocera boxes: host via the custom relay, join from the lobby | **Not performed** - required |

### Rollback plan

Set `PLAZA_TUNNEL_PORT=0` in Railway (relay off, room unaffected), or start `plaza/v0.1.7/server`.
