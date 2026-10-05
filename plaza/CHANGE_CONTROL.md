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
