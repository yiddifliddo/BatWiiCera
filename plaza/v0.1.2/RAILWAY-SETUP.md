# Running the Plaza server on Railway

Author: Dan Lee. For Plaza 0.1.2.

Railway can host the Plaza server. Two things differ from a VPS:

* Railway exposes **one HTTP listener** on the port it puts in the `PORT`
  variable and gives it a public `https://...up.railway.app` domain. The
  Plaza server (0.1.2 and later) uses `PORT` for its presence and health
  side automatically.
* The **game connection is raw TCP**, so it must go through Railway's
  **TCP Proxy**, which gives a separate host and port such as
  `shuttle.proxy.rlwy.net:15140`.

The Batocera installer takes both addresses.

## 1. Point the service at the server folder

Your repository holds many versions, so Railway must be told where the
server is. In the service, open **Settings**:

| Setting | Value |
| --- | --- |
| Source, branch | `release/plaza-v0.1.2` until the branch is merged, then `main` |
| Source, **Root Directory** | `plaza/v0.1.2/server` |
| Build | leave on Nixpacks (it detects `package.json`) |
| Start command | leave empty (`railway.json` sets `node index.js`) |
| Healthcheck path | `/health` (also set by `railway.json`) |

Without the Root Directory the build fails with "no build plan", which is the
"Build failed" you saw: Railway was looking at the repository root, where
there is no Node project.

Save and let it redeploy. The deploy log should end with
`[plaza] game port 0.0.0.0:7777` and `[plaza] http port 0.0.0.0:<PORT>`.

## 2. Public HTTPS domain for presence and health

**Settings > Networking > Public Networking > Generate Domain.** When it asks
for the port, enter the value Railway shows for `PORT` (or leave the
default). You get something like `https://batwiicera-production.up.railway.app`.
Open `https://<that domain>/health` in a browser: `{"ok":true,...}` means the
service is up.

## 3. TCP Proxy for the game connection

**Settings > Networking > TCP Proxy > Add**, and enter port **7777**. Railway
shows a proxy address such as `shuttle.proxy.rlwy.net:15140`. Note both the
host and the port; the port is fixed for this proxy.

## 4. Variables (optional)

None are required. If you want them, add under **Variables**:

| Variable | Purpose |
| --- | --- |
| `PLAZA_MAX` | player cap, default 200 |
| `PLAZA_BLOCKED_WORDS` | comma-separated extra words for the nickname filter |
| `PLAZA_TCP_PORT` | only if you used a different port for the TCP proxy |

Do **not** set `PORT` yourself; Railway manages it.

## 5. Point the Batocera machines at it

On each box, with the three values from steps 2 and 3:

```
bash /userdata/themes/BatWiiCera/_plaza/install-plaza.sh shuttle.proxy.rlwy.net 15140 https://batwiicera-production.up.railway.app
```

Order: game host, game port, presence URL. Then restart EmulationStation.

If you set it up from the Plaza menu instead of the installer, enter the
game address as `shuttle.proxy.rlwy.net:15140` under **Server address**; the
presence URL can only be set by the installer (it edits `config.json`).

## Costs and limits

Railway's hobby plan is a small monthly fee that includes a usage allowance;
the Plaza server idles at a few megabytes of memory and negligible CPU, so a
room of a few hundred players stays well inside it. TCP Proxy is available on
the hobby plan. Services sleep only if you enable app sleeping; leave it off
or players cannot connect while it sleeps.

## Updating

Push the new Plaza version, change **Root Directory** to the new
`plaza/vX.Y.Z/server` (or point the branch at `main` after merging), and
Railway redeploys. The TCP proxy address and the public domain stay the same.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Build failed, "no build plan" or similar | Root Directory not set to the server folder, or wrong branch |
| Health check fails after a successful build | Deploy log: the HTTP line should show the `PORT` value; make sure you did not override `PORT` |
| Plaza client says "Connecting..." forever | TCP Proxy missing, or installer given the public domain instead of the proxy host and port for the game address |
| Labels never show a game | Presence URL wrong, or the hook cannot reach HTTPS (it uses `curl -sL`); test with `curl -X POST https://<domain>/presence -d '{"token":"x","event":"stop"}'` |
