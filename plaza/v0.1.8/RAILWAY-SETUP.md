# Running the Plaza server on Railway

Author: yiddifliddo. For Plaza 0.1.8.

**The public BatWiiCera server already runs this way** and is built into the
client, so nobody needs to follow this guide to play. It is for running your
own copy.

| Public server | Address |
| --- | --- |
| Game (TCP proxy) | `maglev.proxy.rlwy.net:28071` |
| Presence and health (HTTPS) | `https://batwiicera-production.up.railway.app` |

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

Since CR-0020 the repository root carries a `package.json` and `railway.json`
whose start command runs the current Plaza server, so **a service attached
to the repository's `main` branch needs no settings at all**. Only if you
attach a release branch instead, set:

| Setting | Value |
| --- | --- |
| Source, **Root Directory** | `plaza/v0.1.4/server` |
| Build | leave on Railpack / Nixpacks (it detects `package.json`) |
| Start command | leave empty (`railway.json` sets `node index.js`) |
| Healthcheck path | `/health` (also set by `railway.json`) |

Save and let it redeploy. The deploy log should end with
`[plaza] game port 0.0.0.0:7777` and `[plaza] http port 0.0.0.0:<PORT>`.

## 2. Public HTTPS domain for presence and health

**Settings > Networking > Public Networking > Generate Domain.** When it asks
for the port, accept the value it proposes (8080 for the public server);
Railway sets `PORT` to it. You get something like
`https://<service>-production.up.railway.app`.
Open `https://<that domain>/health` in a browser: `{"ok":true,...}` means the
service is up.

## 3. TCP Proxy for the game connection

**Settings > Networking > TCP Proxy > Add**, and enter port **7777**. Railway
shows a proxy address such as `maglev.proxy.rlwy.net:28071`. Note both the
host and the port; the port is fixed for this proxy. No volume is needed:
the server keeps everything in memory.

## 3b. TCP Proxy for the netplay relay (0.1.8 and later)

**Settings > Networking > TCP Proxy > Add** again, this time port **55435**.
Railway shows a second proxy address. That `host:port` is what the hosting
Batocera enters under Netplay Settings > Relay server > Custom. Friends who
join need nothing: the lobby entry carries it.

## 4. Variables (optional)

None are required. If you want them, add under **Variables**:

| Variable | Purpose |
| --- | --- |
| `PLAZA_MAX` | player cap, default 200 |
| `PLAZA_BLOCKED_WORDS` | comma-separated extra words for the nickname filter |
| `PLAZA_TCP_PORT` | only if you used a different port for the TCP proxy |
| `PLAZA_TUNNEL_PORT` | netplay relay port, default 55435; `0` turns the relay off |
| `PLAZA_TUNNEL_MAX` | relay sessions at once, default 64 |
| `PLAZA_HTTP_PORT` | pin the HTTP side to the port the public domain targets (8080 for the public server); not needed since 0.1.5, which detects the clash below |
| `PLAZA_HTTP_FALLBACK_PORT` | where the HTTP side goes when `PORT` equals the game port (default 8080) |

Do **not** set `PORT` yourself; Railway manages it.

## 5. Point the Batocera machines at it

In the Plaza menu choose **Server address** and type the TCP proxy address as
`host:port`. The presence URL is sent by the server on the first connection
(Railway's `RAILWAY_PUBLIC_DOMAIN` is picked up automatically once you
generated the domain in step 2), so there is nothing else to type. To bake
your own server in instead, change `PUBLIC_HOST`, `PUBLIC_TCP_PORT` and
`PUBLIC_PRESENCE_URL` in `client/src/config.lua`, the matching defaults in
`hook/batwiicera-plaza-presence.sh` and `installer/install-batocera.sh`, and
rebuild with `build.sh`.

From a terminal the installer takes all three values at once:

```
bash /userdata/themes/BatWiiCera/_plaza/install-plaza.sh <proxy-host> <proxy-port> https://<domain>
```

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
| Deploy crashes with `EADDRINUSE ... :7777` | Railway set `PORT` to the TCP proxy port. Server 0.1.5 and later moves the HTTP side to 8080 by itself; on older servers set `PLAZA_HTTP_PORT` to the domain's port |
| Build failed, "no build plan" or similar | Root Directory not set to the server folder, or wrong branch |
| Health check fails after a successful build | Deploy log: the HTTP line should show the `PORT` value; make sure you did not override `PORT` |
| Plaza client says "Connecting..." forever | TCP Proxy missing, or installer given the public domain instead of the proxy host and port for the game address |
| Labels never show a game | Presence URL wrong, or the hook cannot reach HTTPS (it uses `curl -sL`); test with `curl -X POST https://<domain>/presence -d '{"token":"x","event":"stop"}'` |
