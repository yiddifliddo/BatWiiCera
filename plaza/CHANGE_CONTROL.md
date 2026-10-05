# BatWiiCera Plaza - Change Control Register

Process reference: ISO/IEC 27001:2022 Annex A, control 8.32 (Change management).
Same rules as the BatWiiCera theme repository: records are appended, never
deleted; every change to the product produces a new `vX.Y.Z/` folder; each
record carries author, company, risk, test evidence and rollback.

## Register summary

| Change ID | Date | Version | Type | Title | Branch | Status |
| --- | --- | --- | --- | --- | --- | --- |
| PCR-0001 | 2026-10-05 | 0.1.0 | New product | Initial creation of the Plaza channel (server, client, hook, installer) | `release/plaza-v0.1.0` (BatWiiCera repository, `plaza/` folder) | Submitted for approval |

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
