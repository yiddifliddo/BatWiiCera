# BatWiiCera Plaza - version 0.1.0

**Author:** Dan Lee (personal project)
**Licence:** MIT (see `../LICENSE`)
**Companion to:** the BatWiiCera theme for Batocera

The Plaza is a channel for BatWiiCera: one shared online room where everyone
running the theme meets as a small cartoon avatar, sees what the others are
playing, runs around, hops, slaps and kicks a ball about. The room zooms out
as more people arrive.

## Parts

| Folder | What it is | Runs on |
| --- | --- | --- |
| `server/` | Room server, plain Node.js, no dependencies | your VPS |
| `client/` | The game, written for the LÖVE engine that Batocera ships | each Batocera box |
| `hook/` | Game-start/stop script that reports what you are playing | each Batocera box |
| `installer/` | One-shot installer, custom system definition, channel logo | each Batocera box |
| `dist/` | Built packages: `BatWiiCera-Plaza.love` and the server tarball | |
| `previews/` | Rendered screens (`plaza-plaza.png`, `plaza-editor.png`, `plaza-menu.png`) | |

## Controls

| Input | In the plaza | In menus |
| --- | --- | --- |
| Stick or d-pad | Walk | Move / change value |
| A | Kick the ball when it is near you, otherwise slap the player in front | Choose |
| X | Hop | Toggle letter case (keyboard) |
| Y | | Randomise avatar |
| START | Open the avatar editor | Save / finish typing |
| B | Leave the plaza | Back |

Keyboard works too: arrows or WASD, Enter or Z for A, Space for X, Escape
for B, P for START.

## Setting up

### 1. Server (once, on your VPS)

Needs Node.js 18 or newer. Open TCP ports 7777 (game) and 7778 (presence).

```
tar -xzf BatWiiCera-Plaza-server.tar.gz
cd server && node index.js            # try it
# or install as a service: see server/batwiicera-plaza.service
```

Check it with `curl http://<your-host>:7778/health`.

Environment variables: `PLAZA_TCP_PORT`, `PLAZA_HTTP_PORT`, `PLAZA_BIND`,
`PLAZA_MAX` (players, default 200), `PLAZA_NAME_MAX`, `PLAZA_BLOCKED_WORDS`
(comma separated, added to the nickname filter).

### 2. Each Batocera machine

Copy this version folder to the machine (or just `dist/`, `hook/` and
`installer/`) and run, as root over SSH:

```
bash installer/install-batocera.sh <your-host>
```

Then restart EmulationStation. A **Plaza** channel appears in the console
grid with one entry, "Enter the Plaza". The installer also drops the channel
logo into any installed BatWiiCera theme folder.

On first run choose **Edit avatar** to pick a nickname and look, then
**Enter the plaza**. The server address can also be typed in from the menu
if you did not use the installer.

### Privacy

Each install gets a random token; there are no accounts. Your nickname,
avatar and (if **Show my game** is on) the name of the game you are running
are visible to everyone in the room. Turn **Show my game** off in the avatar
editor to hide it. Nothing else leaves the machine.

## How it works

* The client talks to the server over one TCP connection using one JSON
  message per line. It sends its position 15 times a second; the server
  rebroadcasts a compact snapshot of everyone, plus the ball, 15 times a
  second. Jumps, slaps and kicks are events.
* The server is the referee: it validates names and avatars, decides who a
  slap lands on (nearest player in front, within 70 units, 0.6 s cooldown),
  simulates the ball (gravity, bounce, friction, walls) and widens the plaza
  as the crowd grows.
* The presence hook runs on every game start and stop (Batocera passes the
  system and ROM path) and POSTs to the server, which updates the label above
  your head immediately if you are in the plaza, or remembers it for up to
  12 hours so it shows when you next enter.
* Avatars are nine small integers (head, skin, hair, hair colour, eyes,
  brows, mouth, shirt, accessory) drawn with primitives. No image files, no
  third-party characters.

## Testing done for this version

| Check | Result |
| --- | --- |
| Server smoke test (`npm test`): cleaners, version gate, join/leave, snapshots, clamping, slap targeting and cooldown, kick range and physics, presence hook online and remembered, profile update, health and stats | Pass |
| Client self-test under plain Lua (`lua5.1 test/run.lua`): JSON, avatar validation, message handling, local physics, interpolation, ball prediction, camera framing, actions, keyboard widget, config persistence | Pass, 51 checks |
| Client rendering under LÖVE 11.5 on a virtual framebuffer (`love . --demo`): plaza, editor and menu screens drawn without error, screenshots in `previews/` | Pass |
| Presence hook end to end against a local server (tag stripping, system suffix, start and stop) | Pass |
| On a Batocera device with a controller | **Not performed** - first device test is the next step |

## Known limitations

* No chat, emotes or friends yet. Phase two material.
* One room for everyone. Regional rooms can follow if the crowd grows.
* The ball is server-side only; a laggy connection shows it a little behind.
* Pads without an SDL gamepad mapping fall back to buttons 1 to 4 as A, B, X, Y.

## Changes in this version (0.1.0)

Initial release: server, client (menu, avatar editor, plaza with movement,
hop, slap, ball kicking, labels, zoom-to-fit), presence hook, installer,
custom system definition, channel logo, self-tests and this document.
