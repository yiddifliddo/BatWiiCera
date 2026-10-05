# Plaza, embedded in the BatWiiCera theme

This folder carries the BatWiiCera Plaza (version 0.1.7), the online room
a football stadium where players running the theme meet as avatars, see what everyone is
playing, run around, hop, slap and kick a ball. Full details, controls and
privacy notes are in `PLAZA-README.md`.

The public BatWiiCera server is built in, so **nothing has to be typed**. A
theme cannot start programs by itself, so the Plaza is a channel that
EmulationStation launches like a game; one of the three routes below puts it
in place. Batocera has no LÖVE engine, so the Plaza brings its own
(`runtime/`, x86_64 PCs for now).

## Installing the Plaza channel (pick one)

**A. Full-install zip - nothing to launch.** Extract
`BatWiiCera-full-vX.Y.Z.zip` (next to the theme zip in the release folder)
onto the Batocera share `\\BATOCERA\share`, merging its `themes`, `roms` and
`system` folders with the existing ones. Reboot. Theme, Plaza channel and a
"Plaza" entry under Ports are all there.

**B. One file under Ports - theme already installed.** Copy
`installer/Plaza.sh` into `share\roms\ports`. Refresh the game lists or
restart EmulationStation, open **Ports**, start **Plaza** once. It installs
everything from this folder and restarts EmulationStation itself. Afterwards
the Ports entry just opens the Plaza.

**C. From the client's menu.** Copy `dist/BatWiiCera-Plaza.love` to
`share\roms\love`, start it from the **LÖVE** system and choose **Install
Plaza channel on this Batocera**. It installs itself, adds the Ports entry and
restarts EmulationStation.

Then open the **Plaza** channel on the console grid, **Edit avatar**, and
**Enter the plaza**.

Prefer a terminal? As root over SSH: `bash /userdata/themes/BatWiiCera/_plaza/install-plaza.sh`.

## Your own server (optional)

Either a VPS (`SERVER-SETUP.md`: Node.js service, ports 7777 and 7778 open)
or Railway (`RAILWAY-SETUP.md`). The server package is `server.tar.gz`;
Railway builds straight from the repository. Then choose **Server address**
in the Plaza menu on each machine.

## Contents

| File | Purpose |
| --- | --- |
| `installer/Plaza.sh` | installs, repairs and launches: the channel's entry and the Ports entry |
| `runtime/` | the LÖVE 11.5 engine (official Linux build, zlib licence), x86_64 |
| `installer/images/` | preview and logo shown on the channel's game screen and launch splash |
| `install-plaza.sh` | terminal installer (wrapper) |
| `installer/install-batocera.sh` | the installer proper |
| `installer/es_systems_plaza.cfg` | adds the Plaza system to EmulationStation |
| `installer/gamelist.xml` | names the channel's single entry |
| `installer/plaza.svg` | channel logo (also bundled in the theme's logo set) |
| `hook/batwiicera-plaza-presence.sh` | reports the game you start to the server |
| `dist/BatWiiCera-Plaza.love` | the Plaza client for the LÖVE engine |
| `server.tar.gz` | the room server (Node.js) |
| `SERVER-SETUP.md` | VPS walkthrough |
| `RAILWAY-SETUP.md` | Railway walkthrough (how the public server is hosted) |
| `PLAZA-README.md`, `LICENSE` | Plaza documentation and MIT licence |

The Plaza is MIT licensed; the theme is CC BY-NC-SA 4.0.
