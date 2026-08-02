# IPTVBoss Docker Images

This repo builds Docker images for running [IPTVBoss](https://github.com/walrusone/iptvboss-release/releases/latest):

- VNC desktop images (stable + beta)
- Headless XC images (stable + beta)
- Xpra browser-window images (stable + beta)

IPTVBoss is pre-installed via apt in the `/usr/lib/iptvboss` directory. rclone is included in the VNC, Headless, and Xpra images to sync IPTVBoss data to a cloud storage provider, and Cronitor can optionally monitor the container-managed cron job.

## Prerequisites

- Docker installed on your machine. See [Docker documentation](https://docs.docker.com/get-docker/) for installation instructions.
- Docker-compose. See [Docker Compose documentation](https://docs.docker.com/compose/install/) for installation instructions.
- A Linux or Mac computer to build the Docker image. Windows users should use WSL2.
- Cronitor.io account and API key (optional) to monitor your cron jobs.

## Features

- Debian-based VNC image, Ubuntu-based headless image.
- IPTVBoss application pre-installed.
- XC Server starting on boot only when setting the `XC_SERVER=true` variable, otherwise it won't start.
- Run the container as a non-root user with the desired `PUID` and `PGID` set up.
- Pre-configured VNC server with a default password (VNC images only). Override via environment variables — see [VNC Stable](VNC-Stable).
- Xpra browser-window images for lightweight GUI access without a full desktop — see [Xpra Stable](Xpra-Stable).
- Optional container-managed cron scheduling for EPG updates via `CRON_SCHEDULE`.
- If you use IPTVBoss internal scheduling instead, leave `CRON_SCHEDULE` unset.
- Cronitor monitors container-managed cron jobs only; it does not monitor IPTVBoss internal scheduling.
- Cronitor.io integration for monitoring the cron job (optional).
- rclone support to sync IPTVBoss data to a cloud storage provider (VNC, Headless, and Xpra images).
- ARM support for Raspberry Pi and other ARM devices.

## Documentation

| Image | Description | Docs |
| --- | --- | --- |
| VNC — Stable | Full XFCE desktop, Firefox/Chromium, VNC + noVNC | [VNC Stable](VNC-Stable) |
| VNC — Beta | Same as above, tracks a beta IPTVBoss release | [VNC Beta](VNC-Beta) |
| Headless — Stable | XC server + cron only, no GUI | [Headless Stable](Headless-Stable) |
| Headless — Beta | Same as above, tracks a beta IPTVBoss release | [Headless Beta](Headless-Beta) |
| Xpra — Stable | Browser access to IPTVBoss app windows over Xpra HTML5 | [Xpra Stable](Xpra-Stable) |
| Xpra — Beta | Same Xpra setup, tracks a beta IPTVBoss release | [Xpra Beta](Xpra-Beta) |
| Cronitor integration | Optional cron job monitoring, applies to all six images | [Cronitor Integration](Cronitor-Integration) |
| User announcement, upgrade guidance, and developer notes | [RELEASE_NOTES.md](https://github.com/groenator/iptvboss-docker/blob/master/RELEASE_NOTES.md) |

## If you are unable to connect to your IPTVBoss instance

1. Running the container using root and not using a non-root user — DO NOT run the container using the ROOT user, it won't work.
2. The container volumes are not mounted correctly, or the volume permissions are incorrect — define your own user and set the correct permissions for your volume using your user UID/GID details.

## Security recommendations if running on a VPS

If you are running any image variant on a VPS or another host with a public IP, do not leave application ports open to the whole internet.

- VNC images expose VNC + noVNC (`5901`, `6901`) and XC (`8001`).
- Headless images expose XC (`8001`) with no built-in authentication.
- Xpra images expose the Xpra web/socket endpoint (`5454`), commonly used without strong edge auth by default.

- Set up a firewall on the VPS (e.g. `ufw`, `iptables`, or your provider's security group/firewall) and block all inbound access by default.
- Only allow access from trusted/known IP addresses if you need direct access to exposed ports (`5454`, `5901`, `6901`, `8001`).
- Better yet, do not publish these ports publicly at all. Put the host on a private overlay network such as [Tailscale](https://tailscale.com/) (or WireGuard), close the ports on the public firewall entirely, and connect only through the VPN.
- For VNC images, change the default VNC password (`VNC_PW`, see [VNC Stable](VNC-Stable)) instead of relying on the default.
- If internet exposure is unavoidable, place a reverse proxy with TLS and authentication in front of web endpoints (noVNC/Xpra) and restrict source IPs at the firewall.
- Keep the image and host OS up to date to pick up security patches.
