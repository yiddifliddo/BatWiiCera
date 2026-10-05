# Plaza, embedded in the BatWiiCera theme

This folder carries the BatWiiCera Plaza (version 0.1.2), the online room
where players running the theme meet as avatars, see what everyone is
playing, run around, hop, slap and kick a ball. Full details, controls and
privacy notes are in `PLAZA-README.md`.

A theme cannot start programs, so the Plaza is a channel that EmulationStation
launches like a game. Setting it up is one command on the Batocera machine
and one small server on a VPS.

## 1. Server (once)

Either a VPS (`SERVER-SETUP.md`: Node.js service, ports 7777 and 7778 open)
or Railway (`RAILWAY-SETUP.md`: root directory on the server folder, public
domain for presence, TCP Proxy on 7777). The server package is
`server.tar.gz`; Railway builds straight from the repository.

## 2. This machine (once per Batocera box)

SSH in as root and run:

```
# VPS
bash /userdata/themes/BatWiiCera/_plaza/install-plaza.sh <server-ip-or-host>
# Railway: TCP proxy host, TCP proxy port, public presence URL
bash /userdata/themes/BatWiiCera/_plaza/install-plaza.sh shuttle.proxy.rlwy.net 15140 https://your-app.up.railway.app
```

Then restart EmulationStation (Main Menu, Quit). A **Plaza** channel appears
in the console grid. Open it, choose **Edit avatar** to set a nickname and
look, then **Enter the plaza**.

## Contents

| File | Purpose |
| --- | --- |
| `install-plaza.sh` | one-command installer (wrapper) |
| `installer/install-batocera.sh` | the installer proper |
| `installer/es_systems_plaza.cfg` | adds the Plaza system to EmulationStation |
| `installer/plaza.svg` | channel logo (also bundled in the theme's logo set) |
| `hook/batwiicera-plaza-presence.sh` | reports the game you start to the server |
| `dist/BatWiiCera-Plaza.love` | the Plaza client for the LÖVE engine |
| `server.tar.gz` | the room server (Node.js) |
| `SERVER-SETUP.md` | VPS walkthrough |
| `RAILWAY-SETUP.md` | Railway walkthrough |
| `PLAZA-README.md`, `LICENSE` | Plaza documentation and MIT licence |

The Plaza is MIT licensed; the theme is CC BY-NC-SA 4.0.
