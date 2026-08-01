# Upcoming IPTVBoss Docker Release

These notes cover the container changes prepared for the upcoming release. The IPTVBoss application version remains controlled by the `release` and `beta-release` files; this release focuses on the container images, runtime, and publishing workflow.

## Announcement for users

This release adds a third way to run IPTVBoss: **Xpra browser-window images**. Alongside the existing full VNC desktop and headless XC server images, users can now open IPTVBoss directly in a web browser without running a complete XFCE desktop.

### Highlights

- New Xpra stable image: `ghcr.io/groenator/iptvboss-xpra-stable:<version>`
- New Xpra beta image: `ghcr.io/groenator/iptvboss-xpra-beta:<version>`
- Browser access to Xpra on port `5454`
- IPTVBoss stream video playback through VLC and the required media codecs
- Browser speaker audio forwarding through Xpra and PulseAudio
- GNOME Terminal, Nautilus, Gedit, and useful application-menu entries in Xpra
- Stable and beta VNC, headless, and Xpra images for both `amd64` and `arm64`
- rclone available in all image families
- Shared cron and optional Cronitor monitoring across all six images
- Updated VNC and headless base operating systems
- Improved VNC Chromium launch behavior, clipboard settings, and persistent launcher trust
- Improved non-root user, volume, cache, home-directory, and cron-log handling

## Choosing an image

| Image family | Best for | Browser/port |
| --- | --- | --- |
| VNC | A complete XFCE desktop with browser and desktop utilities | noVNC `6901`; VNC `5901` |
| Headless | Scheduled jobs and the XC server without a GUI | XC server `8001` |
| Xpra | A lightweight IPTVBoss GUI delivered as application windows | Xpra HTML5 `5454` |

Both stable and beta variants are available for each family. The beta images contain the beta IPTVBoss application and should use a backed-up data directory.

## Xpra quick start

```yaml
services:
  iptvboss-xpra:
    image: ghcr.io/groenator/iptvboss-xpra-stable:<version>
    environment:
      PUID: "1000"
      PGID: "1000"
      TZ: "US/Eastern"
      CRON_SCHEDULE: "0 0 * * *"
      CRONITOR_API_KEY: "<optional-api-key>"
      CRONITOR_SCHEDULE_NAME: "My IPTVBoss Job"
    ports:
      - "5454:5454"
    volumes:
      - <local-volume>:/headless/IPTVBoss
```

Open `http://<host-ip>:5454`. IPTVBoss starts when the browser client connects. Speaker audio is forwarded to the browser; microphone forwarding is intentionally disabled.

## Upgrade notes for users

- Back up the mounted IPTVBoss data directory before changing image families or testing a beta image.
- Keep the persistent mount at `/headless/IPTVBoss` and set `PUID`/`PGID` to the owner of the host directory.
- Podman users may need `--userns=keep-id` to prevent container UID/GID mapping from changing host-visible ownership.
- `CRON_SCHEDULE` enables container-managed scheduling. Leave it unset when using IPTVBoss internal scheduling.
- Cronitor monitors only container-managed cron jobs and requires both a valid API key and `CRON_SCHEDULE`.
- Close IPTVBoss normally before stopping or replacing a GUI container. Avoid forcing container removal while the application is running because an interrupted process can leave application/database locks behind.
- Xpra is an application-window session, not a complete desktop. Use the VNC image if you need the full XFCE environment.
- Do not expose Xpra, VNC/noVNC, or XC ports directly to the public internet. Prefer a firewall plus a VPN/private overlay, or an authenticated TLS reverse proxy.

More information is available in [docs/xpra-stable.md](docs/xpra-stable.md), [docs/xpra-beta.md](docs/xpra-beta.md), and [docs/cronitor.md](docs/cronitor.md).

## Maintainer and staff notes

### Image and runtime architecture

- `Dockerfile.xpra` is based on Ubuntu 24.04 and installs Xpra from its Noble repository.
- The Xpra image removes the base `ubuntu` account to prevent UID 1000 collisions and consistently runs applications as `iptvboss` with `HOME=/headless`.
- Runtime `PUID`/`PGID` remapping, writable cache/configuration directories, and an owned `XDG_RUNTIME_DIR` keep Xpra, PulseAudio, Mesa, cron, and the mounted volume under the same user identity.
- IPTVBoss starts on browser connection and an existing IPTVBoss process is reused instead of launching a duplicate.
- Xpra media support includes VLC, `libvlc-dev`, FFmpeg codec packages, GStreamer support supplied by Xpra, and the required X11/GTK libraries.
- Speaker forwarding uses a dedicated per-user PulseAudio daemon, an `Xpra-Speaker` null sink, and its monitor source. Xpra connects to that daemon while its own PulseAudio launcher remains disabled.
- D-Bus, XKB, UTF-8 locale, GNOME Terminal, Nautilus, and Gedit dependencies are included for a functional browser session.

### Cron and Cronitor

- `configure_cron_schedule.sh` is now the shared place that writes the IPTVBoss cron line, installs the user crontab, and invokes `cronitor.py` when an API key is supplied.
- The default cron target writes to `/var/log/cron.log` across image families.
- Xpra includes `sudo`, which is required by the Cronitor installer used by the entrypoint.
- Cronitor is optional. No monitor is configured when `CRONITOR_API_KEY` is absent, and no cron job is created when `CRON_SCHEDULE` is absent.

### VNC and headless maintenance

- The VNC image moves to Debian Trixie with a full distribution upgrade to keep TigerVNC/Xvnc and OS libraries current.
- The headless image moves from Ubuntu 20.04 to Ubuntu 24.04 with renamed `t64` libraries.
- VNC overrides the upstream Chromium initialization script with a valid profile path.
- TigerVNC clipboard options are explicitly enabled.
- VNC launcher trust metadata is copied back to persistent IPTVBoss storage so a user's approval can survive restarts.
- rclone is installed in VNC, headless, and Xpra images.

### CI and publishing

- The Docker workflow detects whether stable, beta, or shared image inputs changed.
- The matrix contains VNC, headless, and Xpra stable/beta images for native `amd64` and `arm64` runners.
- Platform images are published by digest and merged into multi-platform manifests.
- Push builds publish `latest` and application-version tags. Internal pull requests publish `pr-<number>` tags without replacing release tags.
- CodeQL remains a prerequisite for image builds.

### Validation status

- Initial startup validation was completed for all six `pr-254` image variants.
- Headless stable and beta started the XC server, cron, and Cronitor successfully.
- Xpra stable has been manually verified for browser access, IPTVBoss launch, stream video, and speaker audio.
- Cron and Cronitor runtime testing on the latest local Xpra stable build is in progress.
- Before release, repeat the final regression pass for Xpra beta and verify the current VNC Chromium/clipboard/launcher-trust behavior on both stable and beta images.

## Complete change history

See [CHANGELOG.md](CHANGELOG.md) for the categorized list of additions, changes, fixes, security updates, and documentation updates.
