# IPTVBoss Docker Images

This repo builds Docker images for running [IPTVBoss](https://github.com/walrusone/iptvboss-release/releases/latest) — a full VNC desktop image and a lightweight headless (no GUI) image, each available in a stable and a beta flavor.

- IPTVBoss is pre-installed via apt in the `/usr/lib/iptvboss` directory. You can customize its configuration and settings.
- It includes the option to configure Cronitor to monitor the local cron jobs.
- rclone is also installed in the VNC image to allow users to sync their IPTVBoss data to a cloud storage provider.

## Documentation

| Image | Description | Docs |
| --- | --- | --- |
| VNC — Stable | Full XFCE desktop, Firefox/Chromium, VNC + noVNC | [docs/vnc-stable.md](docs/vnc-stable.md) |
| VNC — Beta | Same as above, tracks a beta IPTVBoss release | [docs/vnc-beta.md](docs/vnc-beta.md) |
| Headless — Stable | XC server + cron only, no GUI | [docs/headless-stable.md](docs/headless-stable.md) |
| Headless — Beta | Same as above, tracks a beta IPTVBoss release | [docs/headless-beta.md](docs/headless-beta.md) |
| Cronitor integration | Optional cron job monitoring, applies to all four images | [docs/cronitor.md](docs/cronitor.md) |

## If you are unable to connect to your cloud provider, this is likely because of

1. Running the container using root and not using a non-root user

- DO NOT RUN the container using ROOT user, it won't work.

1. The container volumes are not mounted correctly, the volume permissions are incorrect

- Define your own user and set the correct permissions for your volume using your user UID/GID details.

## Security recommendations if running on a VPS

The VNC image exposes a VNC server and noVNC web client with only a simple password, and the headless image exposes the XC server with no authentication at all. If you are running any of these images on a VPS or another host with a public IP, do not leave those ports open to the whole internet.

- Set up a firewall on the VPS (e.g. `ufw`, `iptables`, or your provider's security group/firewall) and block all inbound access by default.
- Only allow access from trusted/known IP addresses if you need direct access to the exposed ports (`5901`, `6901`, `8001`).
- Better yet, don't publish these ports publicly at all. Put the host on a private overlay network such as [Tailscale](https://tailscale.com/) (or WireGuard), close the ports on the public firewall entirely, and connect to the container only through the VPN.
- Change the default VNC password (`VNC_PW`, see [docs/vnc-stable.md](docs/vnc-stable.md)) instead of relying on the default.
- Keep the image and host OS up to date to pick up security patches.

## Prerequisites

- Docker installed on your machine. See [Docker documentation](https://docs.docker.com/get-docker/) for installation instructions.
- Docker-compose. See [Docker Compose documentation](https://docs.docker.com/compose/install/) for installation instructions.
- A Linux or Mac computer to build the Docker image. I don't use Windows, for Windows I recommend using WSL2.
- Cronitor.io account and API key (optional).

## Features

- Debian-based VNC image, Ubuntu-based headless image.
- IPTVBoss application pre-installed.
- XC Server starting on boot only when setting the `XC_SERVER=true` variable, otherwise it won't start.
- Run the container as a non-root user with the desired `PUID` and `PGID` set up.
- Pre-configured VNC server with a default password (VNC image only). Override via environment variables — see [docs/vnc-stable.md](docs/vnc-stable.md).
- Automatically configuring the cron job for updating the EPG.
- Cronitor.io integration for monitoring the cron job (optional).
- rclone support to sync IPTVBoss data to a cloud storage provider (VNC image only).
- ARM support for Raspberry Pi and other ARM devices. Use the `ghcr.io/groenator/iptvboss-docker:latest` image.

## Tasks list

- [x] Create a Docker image with IPTVBoss running as a simple cli without GUI and VNC.
- [x] Configure IPTVBoss XC to start on boot.
- [x] Pushing the docker image to an actual docker registry.
- [x] Allow user to configure the cron job with it's own schedule. At the moment the cron is configured to run every 12h.
- [x] Start the container defining your own user.
- [x] Creating a script to configure the cronitor jobs automatically without duplicating the job if is already available in the account.
