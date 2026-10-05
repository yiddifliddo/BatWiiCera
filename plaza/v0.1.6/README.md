# BatWiiCera Plaza - version 0.1.6

**Author:** yiddifliddo (personal project)
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
| `client/` | The game, written for the LÖVE engine | each Batocera box |
| `runtime/` | The LÖVE engine itself (official self-contained Linux build, x86_64), because Batocera does not ship one | each Batocera box |
| `hook/` | Game-start/stop script that reports what you are playing | each Batocera box |
| `installer/` | `Plaza.sh` (installs, repairs and launches; the channel entry and the Ports entry), shell installer, system definition, game list with artwork, channel logo | each Batocera box |
| `dist/` | Built packages: `BatWiiCera-Plaza.love` and the server tarball | |
| `previews/` | Rendered screens, light and dark (`plaza-plaza.png`, `plaza-plaza-dark.png`, editor and menu likewise) | |

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

### Nothing to type: the public server is built in

Version 0.1.4 ships with the public BatWiiCera Plaza server already configured
(game `maglev.proxy.rlwy.net:28071`, presence
`https://batwiicera-production.up.railway.app`). Players never enter an
address. **Server address** in the menu only matters for a private server.

### Each Batocera machine

Pick whichever is easier. Both end with the **Plaza** channel on the console
grid, with no typing and no terminal.

**A. Full-install zip (theme and Plaza together).** Extract
`BatWiiCera-full-vX.Y.Z.zip` (from the theme's release folder) onto the
Batocera network share `\\BATOCERA\share`, so that its `themes`, `roms` and
`system` folders merge with the ones already there. Reboot. The theme is
installed, the Plaza channel is on the grid and "Plaza" is also listed under
Ports.

**B. One file under Ports (theme already installed).** Copy
`installer/Plaza.sh` (also at `_plaza/installer/Plaza.sh` inside the theme)
into `share\roms\ports`. Refresh the game lists or restart EmulationStation,
open **Ports** and start **Plaza** once. It installs everything from the theme
folder and restarts EmulationStation by itself. From then on the Ports entry
simply opens the Plaza.

**C. From the client's menu.** Start `dist/BatWiiCera-Plaza.love` from the
LÖVE system (copied to `share\roms\love`) and choose **Install Plaza channel
on this Batocera**. It installs itself, adds the Ports entry and restarts
EmulationStation.

Prefer a terminal? As root over SSH:

```
bash /userdata/themes/BatWiiCera/_plaza/install-plaza.sh                       # public server
bash /userdata/themes/BatWiiCera/_plaza/install-plaza.sh <host> [port] [presence]   # your own server
```

On first entry choose **Edit avatar** to pick a nickname and look.

### Your own server (optional)

* **VPS** - see `SERVER-SETUP.md` in the theme's `_plaza/` folder (Node.js
  service, ports 7777 and 7778 open). Needs Node.js 18 or newer:

  ```
  tar -xzf BatWiiCera-Plaza-server.tar.gz
  cd server && node index.js            # try it
  # or install as a service: see server/batwiicera-plaza.service
  ```

  Check it with `curl http://<your-host>:7778/health`. Environment
  variables: `PLAZA_TCP_PORT`, `PLAZA_HTTP_PORT`, `PLAZA_BIND`, `PLAZA_MAX`
  (players, default 200), `PLAZA_NAME_MAX`, `PLAZA_BLOCKED_WORDS` (comma
  separated, added to the nickname filter).
* **Railway** - see `RAILWAY-SETUP.md`: the public server runs this way.

Then on each machine choose **Server address** in the Plaza menu and enter the
host, or `host:port`.

### Colours

The Plaza uses the BatWiiCera theme's own palette. By default it reads the
colour set chosen in EmulationStation (*Theme Colorset*) from
`es_settings.cfg`: the Dark grey set gives a dark Plaza, the others the light
one. The avatar editor has a **Colours** row to force Light or Dark instead.

### Privacy

Each install gets a random token; there are no accounts. Your nickname,
avatar and (if **Show my game** is on) the name of the game you are running
are visible to everyone in the room. Turn **Show my game** off in the avatar
editor to hide it. Nothing else leaves the machine.

## How it works

* Batocera has no LÖVE engine, so the Plaza carries the official LÖVE 11.5
  Linux build (`runtime/`). The installer unpacks it once into
  `roms/plaza/runtime/x86_64/` and the channel's entry, `Plaza.sh`, starts the
  client with it. No FUSE, no system packages.
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
| Client self-test under plain Lua (`lua5.1 test/run.lua`): JSON, avatar validation, message handling, local physics, interpolation, ball prediction, camera framing, actions, palette detection, keyboard widget, config persistence, built-in public server, host:port and presence parsing, embedded install files including the Ports entry, presence hand-over | Pass, 67 checks |
| Client rendering under LÖVE 11.5 on a virtual framebuffer (`love . --demo`): plaza, editor and menu screens drawn without error, screenshots in `previews/` | Pass |
| Presence hook end to end against a local server (tag stripping, system suffix, start and stop, built-in default when no config) | Pass |
| Shell installer, Ports entry and hook: syntax check; installer dry run into a temporary root | Pass |
| Public server reachable: `GET /health` on the Railway domain | Pass (TCP proxy not testable from the build machine, see PCR-0005) |
| Installer upgrade over a 0.1.4 layout and a launch of the channel entry through the bundled runtime, on an x86_64 build machine with a virtual display | Pass (client ran until stopped) |
| On a Batocera device with a controller (install via Ports, full zip, and client menu; automatic restart) | **Not performed** - the 0.1.5 device test showed the channel closing at once (no LÖVE on Batocera, fixed here); retest required |

## Known limitations

* No chat, emotes or friends yet. Phase two material.
* One room for everyone. Regional rooms can follow if the crowd grows.
* The ball is server-side only; a laggy connection shows it a little behind.
* Pads without an SDL gamepad mapping fall back to buttons 1 to 4 as A, B, X, Y.
* x86_64 Batocera only for now: the bundled runtime is the x86_64 build.
  ARM boxes get a clear message in `/userdata/system/logs/plaza.log`; an ARM
  runtime can be added to `runtime/` later.

## Changes in this version (0.1.6)

* **The channel now actually starts on Batocera.** The first device test
  showed the Plaza closing immediately: Batocera does not ship the LÖVE
  engine, which every earlier version assumed. The Plaza now carries the
  official LÖVE 11.5 Linux build (`runtime/`, zlib licence, 5 MB). The
  installer unpacks it once; `Plaza.sh` starts the client with it.
* **One launcher script.** `installer/Plaza.sh` is now both the channel's
  entry in `roms/plaza` (the system definition lists `.sh` and runs
  `bash %ROM%`) and the Ports entry. Not installed yet: it installs from the
  theme folder and restarts EmulationStation. Installed: it launches,
  unpacking the runtime if needed and restoring permissions. Logs to
  `/userdata/system/logs/plaza.log`.
* **Proper game screen.** The channel's entry is named "Plaza" and ships
  artwork (`installer/images/`: plaza preview and logo), developer,
  publisher, release date, "1-200 players" and genre, so the theme's preview
  panel and Batocera's launch splash show the Plaza instead of placeholders.
* Client self-install copies the runtime and artwork from the theme folder
  and writes the launcher to both places. `conf.lua` targets LÖVE 11.5.
* Version 0.1.6 everywhere; packages rebuilt. Client gameplay unchanged.

## Changes in version 0.1.5

* **Server: port clash on Railway fixed.** Once a TCP proxy exists Railway
  sets `PORT` to the proxy's port (7777), the same one the game listener
  uses, so 0.1.4 crashed with `EADDRINUSE` on start. The server now resolves
  ports in one place (`resolvePorts`): `PLAZA_TCP_PORT` and
  `PLAZA_HTTP_PORT` always win; otherwise HTTP takes `PORT`, and if that
  equals the game port it moves to `PLAZA_HTTP_FALLBACK_PORT` (default 8080,
  the port the public domain was generated with) and says so in the log.
  Listen errors now print one clear line and exit instead of a stack trace.
* Smoke test covers the port resolution. Client unchanged apart from the
  version string; the theme's embedded copy stays at 0.1.4 until the next
  theme release.

## Changes in version 0.1.4

* **Nothing to type.** The public BatWiiCera server (Railway) is built into
  the client, the presence hook and the shell installer:
  `maglev.proxy.rlwy.net:28071` for the game, the Railway domain for presence.
  **Server address** in the menu still overrides it for a private server.
* **One-file install under Ports.** New `installer/Plaza.sh`: dropped into
  `roms/ports` it appears as "Plaza"; the first launch installs the channel
  from the BatWiiCera theme folder and restarts EmulationStation, later
  launches open the Plaza (repairing the hook's permissions on the way).
  Both installers now put it in place too.
* **Automatic EmulationStation restart.** The client's install item and the
  shell installer restart EmulationStation themselves (detached
  `batocera-es-swissknife --restart` after a short delay; `--no-restart`
  to skip in the shell installer). The client quits just before.
* **Hook works without a config file**, falling back to the built-in server,
  so a full-install zip that never ran the client still reports games.
* **Channel launch command restores the hook's executable bit**, which a
  copy over a Windows share drops.
* Shell installer arguments are optional (public server when omitted).
* Author credit changed to yiddifliddo throughout. Version 0.1.4 everywhere;
  packages rebuilt. No visual changes.

## Changes in version 0.1.3

* **Install without a terminal.** The client installs itself on Batocera:
  a new menu item copies the `.love` to `roms/plaza`, writes the Plaza system
  definition, installs the presence hook as executable and adds the channel
  logo to older theme copies. The files it writes are embedded at build time
  from the same `hook/` and `installer/` sources (`src/embedded.lua`,
  generated by `build.sh`).
* **Presence address comes from the server.** The welcome message carries
  the server's public HTTP URL (`PLAZA_PUBLIC_URL`, or Railway's
  `RAILWAY_PUBLIC_DOMAIN` automatically) and the client saves it, so only the
  game address is ever typed on the TV.
* `installer/gamelist.xml` split out so the shell installer and the client
  share it.
* Self-test extended to 64 checks; server test checks the presence URL.
* Version bumped to 0.1.3 everywhere; packages rebuilt. No visual changes.

## Changes in version 0.1.2

* **Railway and similar hosts supported.** The server's HTTP side listens on
  `PORT` when the host sets it (falling back to `PLAZA_HTTP_PORT`), and a
  `railway.json` sets the start command and `/health` check. New
  `RAILWAY-SETUP.md`.
* **Separate presence address.** `config.json` gains `presenceUrl`; the hook
  posts to it (following redirects, HTTPS fine) or to `host:httpPort` when it
  is empty. The installer's third argument is now either a port (VPS) or a
  full URL (Railway).
* **Game address as host:port.** The menu's Server address entry accepts
  `host:port`, needed for TCP proxies with non-default ports; the status card
  shows it.
* Self-test extended to 59 checks (host:port parsing, presence base); server
  test pins the port override; hook tested end to end against a URL.
* Version bumped to 0.1.2 everywhere; packages rebuilt. No visual changes.

## Changes in version 0.1.1

* **Matches the theme's colours.** Light and dark palettes copied from the
  theme's `classic.xml` and `dark.xml` (backdrop stripes, panels, borders,
  text, blue accents); plaza floor, tiles, bubbles and HUD all use them.
* **Follows the EmulationStation colour set.** On start the client reads
  `subset.colorset` from `es_settings.cfg` and picks dark or light to match;
  a **Colours** row in the avatar editor can force either.
* Demo mode gains `--dark` for previews; dark previews added.
* Self-test extended to 55 checks (palette detection and switching).
* Version bumped to 0.1.1 everywhere.

## Changes in version 0.1.0

Initial release: server, client (menu, avatar editor, plaza with movement,
hop, slap, ball kicking, labels, zoom-to-fit), presence hook, installer,
custom system definition, channel logo, self-tests and this document.
