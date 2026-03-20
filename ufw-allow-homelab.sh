#!/usr/bin/env bash
# UFW rules for all homelab services.
# Run once on the host:  sudo bash ufw-allow-homelab.sh
# Re-run after adding new services or changing ports.
# Source your .env files first if you want to use custom ports,
# otherwise the defaults listed here are used.
set -euo pipefail

# ── proxy/compose.yaml ────────────────────────────────────────────────────────
sudo ufw allow 80/tcp    comment "NPM HTTP"
sudo ufw allow 443/tcp   comment "NPM HTTPS"
sudo ufw allow 8181/tcp  comment "NPM admin UI"

# ── media/compose.yaml — VPN-tunneled (exposed via gluetun) ──────────────────
sudo ufw allow 8083/tcp  comment "qBittorrent WebUI (via gluetun)"
sudo ufw allow 6881/tcp  comment "qBittorrent torrent TCP"
sudo ufw allow 6881/udp  comment "qBittorrent torrent UDP"
sudo ufw allow 6789/tcp  comment "NZBGet WebUI (via gluetun)"
sudo ufw allow 9696/tcp  comment "Prowlarr WebUI (via gluetun)"

# ── media/compose.yaml — direct ───────────────────────────────────────────────
sudo ufw allow 8989/tcp  comment "Sonarr WebUI"
sudo ufw allow 7878/tcp  comment "Radarr WebUI"
sudo ufw allow 8686/tcp  comment "Lidarr WebUI"
sudo ufw allow 6767/tcp  comment "Bazarr WebUI"

# ── media/compose.yaml — optional (uncomment when enabled) ───────────────────
sudo ufw allow 8191/tcp  comment "FlareSolverr"

# ── media/jellyfin/compose.yaml ───────────────────────────────────────────────
sudo ufw allow 8096/tcp  comment "Jellyfin WebUI"
sudo ufw allow 7359/udp  comment "Jellyfin service discovery"
sudo ufw allow 1900/udp  comment "Jellyfin DLNA/client discovery"
sudo ufw allow 5055/tcp  comment "Jellyseerr WebUI"
sudo ufw allow 3000/tcp  comment "Jellystat WebUI"

echo "UFW rules applied. Current status:"
sudo ufw status numbered
