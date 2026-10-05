# Running the Plaza server on your WordPress VPS

Author: Dan Lee. For Plaza 0.1.1.

The Plaza server is a single Node.js file with no dependencies. It can share
a VPS with WordPress: WordPress uses ports 80 and 443 through Apache or Nginx,
the Plaza uses 7777 (game) and 7778 (presence). Nothing in WordPress, PHP or
the database is touched.

**Requirement:** a VPS or dedicated server where you have SSH and root (or
sudo). Shared WordPress hosting without SSH cannot run it.

## 1. Connect and check Node.js

```
ssh root@YOUR-SERVER-IP
node --version
```

If that prints `v18` or newer, skip to step 2. Otherwise install Node 20:

```
# Ubuntu / Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# AlmaLinux / Rocky / CentOS
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs
```

## 2. Copy the server package up

From your PC, in the folder that holds this file:

```
scp server.tar.gz root@YOUR-SERVER-IP:/root/
```

(On Windows use WinSCP or the `scp` in PowerShell.) Back in the SSH session:

```
mkdir -p /opt/batwiicera-plaza
tar -xzf /root/server.tar.gz -C /opt/batwiicera-plaza --strip-components=1
ls /opt/batwiicera-plaza        # should show index.js, package.json, batwiicera-plaza.service
```

## 3. Try it once by hand

```
cd /opt/batwiicera-plaza && node index.js
```

You should see two lines, "game port 0.0.0.0:7777" and "http port
0.0.0.0:7778". Leave it running and, from your PC, open
`http://YOUR-SERVER-IP:7778/health` in a browser. If you get
`{"ok":true,...}` the server works and the port is reachable; go to step 5.
If the browser times out, the port is closed: do step 4, then retry.
Press Ctrl+C to stop the hand-run server.

## 4. Open the two ports

Ubuntu or Debian with ufw:

```
ufw allow 7777/tcp
ufw allow 7778/tcp
ufw status
```

AlmaLinux, Rocky, CentOS with firewalld:

```
firewall-cmd --permanent --add-port=7777/tcp
firewall-cmd --permanent --add-port=7778/tcp
firewall-cmd --reload
```

Many providers (DigitalOcean, Hetzner, Vultr, Linode, AWS, OVH) also have a
firewall in their control panel. Add inbound rules for TCP 7777 and 7778
there too, or the ports stay closed no matter what the server says.

## 5. Run it as a service so it survives reboots

```
useradd -r -s /usr/sbin/nologin plaza 2>/dev/null || true
chown -R plaza:plaza /opt/batwiicera-plaza
cp /opt/batwiicera-plaza/batwiicera-plaza.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now batwiicera-plaza
systemctl status batwiicera-plaza --no-pager
```

"active (running)" means done. Useful afterwards:

```
journalctl -u batwiicera-plaza -f      # live log
systemctl restart batwiicera-plaza     # after editing settings
```

Settings live in the service file as `Environment=` lines: player cap
(`PLAZA_MAX`), ports, and `PLAZA_BLOCKED_WORDS` (comma separated extra
words for the nickname filter). Edit, then `systemctl daemon-reload` and
restart.

## 6. Point the Batocera machines at it

On each Batocera box:

```
bash /userdata/themes/BatWiiCera/_plaza/install-plaza.sh YOUR-SERVER-IP
```

An IP address is fine. If you prefer a name, add an A record such as
`plaza.yourdomain.com` pointing at the VPS in your DNS and use that instead;
the server itself needs no change.

## Optional: a web address for the stats page

If you want `https://plaza.yourdomain.com/stats` instead of the bare port,
add a server block to the Nginx or Apache that already serves WordPress,
proxying to `http://127.0.0.1:7778`. This only covers the presence/stats
side; the game port 7777 is plain TCP and must stay open directly.

Nginx example:

```
server {
    listen 80;
    server_name plaza.yourdomain.com;
    location / { proxy_pass http://127.0.0.1:7778; }
}
```

Then `certbot --nginx -d plaza.yourdomain.com` if you want HTTPS for it.

## Updating later

Copy the new `server.tar.gz`, extract it over `/opt/batwiicera-plaza` the
same way, and `systemctl restart batwiicera-plaza`. Players reconnect
automatically.

## If something is off

| Symptom | Check |
| --- | --- |
| `/health` times out from outside | Provider firewall and `ufw`/`firewalld`; `ss -ltnp | grep 777` on the server shows whether Node is listening |
| Service fails to start | `journalctl -u batwiicera-plaza -n 50`; usually a port already in use or Node too old |
| Players connect but labels never show a game | The presence hook posts to port 7778; make sure that one is open too, and "Show my game" is on in the avatar editor |
| Only you appear | Everyone must point at the same server address |
