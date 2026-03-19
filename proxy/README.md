# Proxy Management

Nginx Proxy Manager (NPM) provides HTTPS access to all homelab services — on your local network and optionally from the internet.

## Navigation

- [Apps](https://github.com/TechHutTV/homelab/tree/main/apps)
- [Home Assistant](https://github.com/TechHutTV/homelab/tree/main/homeassistant)
- [Media Server](https://github.com/TechHutTV/homelab/tree/main/media)
- [Server Monitoring](https://github.com/TechHutTV/homelab/tree/main/monitoring)
- [Surveillance System](https://github.com/TechHutTV/homelab/tree/main/surveillance)
- [Storage](https://github.com/TechHutTV/homelab/tree/main/storage)
- [__Proxy Management__](https://github.com/TechHutTV/homelab/tree/main/proxy)

## What's in the compose file

| Service | Required | Purpose |
| --- | --- | --- |
| `proxy` (NPM) | __Yes__ | Reverse proxy + HTTPS termination |
| `ddns` (Cloudflare) | No | Keeps your public DNS A record updated — only needed for internet access |
| `netbird` | No | VPN mesh for remote access to LAN services from outside your network |
| `helloworld` | No | Test container to verify the proxy works before adding real services |

Optional services are commented out. Uncomment and set the relevant `.env` vars to enable them.

## Setup

### 1. Configure .env

Copy `.env.example` to `.env` and set at minimum:

```ini
HOST_IP=10.0.0.x       # LAN IP of this machine
CONFIG_DIR=/mnt/media/configs
LAN_TLD=lan            # must match Pi-hole domain name setting
```

### 2. Start NPM

```bash
docker compose up -d proxy
```

NPM admin UI: `http://HOST_IP:NPM_ADMIN_PORT` (default `8181`) — default login `admin@example.com` / `changeme`.

### 3. LAN HTTPS with Pi-hole (local-only, no public domain needed)

Pi-hole handles DNS (resolving `jellyfin.lan` → `HOST_IP`) and NPM handles routing (forwarding the request to the right container). You need both.

```text
Browser → Pi-hole (DNS lookup) → NPM (routes by hostname) → Container
```

#### 3a. Pi-hole DNS setup

In Pi-hole _Local DNS → DNS Records_, add one A record for the host:

```text
homelab.lan  →  HOST_IP
```

In Pi-hole _Local DNS → CNAME Records_, add one entry per service pointing to that A record:

```text
jellyfin.lan     →  homelab.lan
sonarr.lan       →  homelab.lan
radarr.lan       →  homelab.lan
lidarr.lan       →  homelab.lan
bazarr.lan       →  homelab.lan
prowlarr.lan     →  homelab.lan
qbittorrent.lan  →  homelab.lan
nzbget.lan       →  homelab.lan
jellyseerr.lan   →  homelab.lan
jellystat.lan    →  homelab.lan
```

Set your router's DNS server to Pi-hole's IP so all devices use it.

> __LAN_TLD:__ set `LAN_TLD=lan` in `.env` to match Pi-hole's domain setting (_Settings → DNS → Pi-hole domain name_).

#### 3b. NPM proxy hosts

NPM receives all requests at `HOST_IP` and routes them to the right container by hostname. The `npm-init` service in `compose.yaml` creates these automatically — start it alongside NPM:

```bash
docker compose up -d proxy npm-init
```

Or create them manually in NPM _Hosts → Proxy Hosts_:

| Proxy host | Forward to |
| --- | --- |
| `sonarr.lan` | `http://HOST_IP:8989` |
| `radarr.lan` | `http://HOST_IP:7878` |
| `lidarr.lan` | `http://HOST_IP:8686` |
| `bazarr.lan` | `http://HOST_IP:6767` |
| `prowlarr.lan` | `http://HOST_IP:9696` |
| `qbittorrent.lan` | `http://HOST_IP:8083` |
| `nzbget.lan` | `http://HOST_IP:6789` |
| `jellyfin.lan` | `http://HOST_IP:8096` |
| `jellyseerr.lan` | `http://HOST_IP:5055` |
| `jellystat.lan` | `http://HOST_IP:3000` |

#### 3c. SSL certificate

Generate a wildcard cert for `*.lan` — see [SSL Certificate Options](#ssl-certificate-options) below — then on the SSL tab of each proxy host select it and enable _Force SSL_.

> __Jellyfin note:__ add `HOST_IP` as an approved proxy in Jellyfin _Dashboard → Networking_. See [Jellyfin nginx docs](https://jellyfin.org/docs/general/networking/nginx/#nginx-proxy-manager) for advanced config needed in the proxy host's Advanced tab.

### SSL Certificate Options

Let's Encrypt __does not issue certificates for local TLDs__ like `home.arpa` or `.lan` — they aren't publicly resolvable. Choose one of the options below.

#### Option A: Local CA (recommended — no browser warnings after one-time setup)

Create your own CA, sign a wildcard cert with it, and install the CA on each device once.

```bash
# 1. Create the CA
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 \
  -out ca.crt -subj "/CN=Homelab CA"

# 2. Create the wildcard cert
openssl genrsa -out wildcard.key 4096
openssl req -new -key wildcard.key -out wildcard.csr \
  -subj "/CN=*.home.arpa"

# 3. Sign it with your CA
openssl x509 -req -in wildcard.csr -CA ca.crt -CAkey ca.key \
  -CAcreateserial -out wildcard.crt -days 3650 -sha256 \
  -extfile <(printf "subjectAltName=DNS:*.home.arpa,DNS:home.arpa")
```

In NPM: _SSL Certificates → Add SSL Certificate → Custom_ — upload `wildcard.crt` and `wildcard.key`.

Install `ca.crt` as a trusted root CA on each device:

- __Linux:__ `sudo cp ca.crt /usr/local/share/ca-certificates/ && sudo update-ca-certificates`
- __Windows:__ double-click `ca.crt` → _Install Certificate → Local Machine → Trusted Root Certification Authorities_
- __Android/iOS:__ transfer the file and install via _Settings → Security → Install Certificate_

#### Option B: Self-signed cert (simplest — browser warning on every device)

```bash
openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
  -keyout wildcard.key -out wildcard.crt \
  -subj "/CN=*.home.arpa" \
  -addext "subjectAltName=DNS:*.home.arpa,DNS:home.arpa"
```

Upload to NPM as above. Browsers will warn about an untrusted issuer unless you manually trust the cert on each device.

#### Option C: Public domain pointed at a private IP (most compatible — no CA install needed)

If you own any public domain, create an A record pointing a subdomain to your `HOST_IP` (a private IP is valid in DNS). Then use Let's Encrypt with a DNS challenge in NPM normally — all devices trust it automatically. This is the same flow as [Public Access with Cloudflare DDNS](#4-public-access-with-cloudflare-ddns-optional), just with a private IP instead of your public one.

---

### 4. Public Access with Cloudflare DDNS (optional)

Only needed if you want services reachable from outside your network.

1. [Add your domain to Cloudflare](https://developers.cloudflare.com/fundamentals/setup/manage-domains/add-site/) and [create an API token](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/) with _Zone: DNS: Edit_.
2. In Cloudflare, create an A record for your domain pointing to any IP — the DDNS container will update it automatically.
3. In `.env`, set `CLOUDFLARE_API_TOKEN` and `DDNS_DOMAINS`, then uncomment the `ddns` service in `compose.yaml`.
4. Forward ports 80 and 443 on your router to `HOST_IP`.
5. In NPM, generate a Let's Encrypt certificate using the DNS challenge with your Cloudflare API token.

> __Streaming services (Jellyfin, Plex):__ disable the Cloudflare proxy (orange cloud → grey) for their DNS records. Proxying video streams [violates Cloudflare's ToS](https://www.cloudflare.com/service-specific-terms-application-services/#content-delivery-network-terms) on the free plan.
> __Too many redirects:__ if you see redirect loops after enabling Force SSL, disable the Cloudflare proxy on that record. See [this issue](https://github.com/NginxProxyManager/nginx-proxy-manager/issues/852).

### 5. Remote Access with NetBird (optional)

NetBird creates a zero-trust VPN mesh so you can reach LAN services from anywhere without port forwarding.

1. [Create a NetBird account](https://app.netbird.io) or self-host, then generate a setup key.
2. Set `NB_SETUP_KEY` in `.env` and uncomment the `netbird` service and its volume in `compose.yaml`.
3. In the NetBird dashboard, create a network resource pointing to `HOST_IP` with `*.lan` (or your `LAN_TLD`) as an alias.

Once connected via the NetBird client on any device, your local proxy hosts are accessible as if you were on the LAN.

For installation on Linux (outside Docker):

```bash
curl -fsSL https://pkgs.netbird.io/install.sh | sh
netbird up --setup-key <SETUP KEY>
```
