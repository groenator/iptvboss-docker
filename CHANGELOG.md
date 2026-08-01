# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

This is a major container release: IPTVBoss can now run as a lightweight Xpra browser session in addition to the existing VNC desktop and headless XC server options. See [RELEASE_NOTES.md](RELEASE_NOTES.md) for user announcements, upgrade guidance, maintainer notes, and validation status.

### Added

- **Xpra stable and beta images**: Added lightweight browser-window images that expose IPTVBoss through the Xpra HTML5 client on port `5454`, without requiring a full XFCE desktop.
- **Xpra browser audio forwarding**: Added a dedicated per-user PulseAudio daemon and virtual speaker sink so IPTVBoss/VLC audio can be forwarded to the Xpra HTML5 client. Microphone forwarding remains disabled.
- **Xpra media support**: Added VLC, `libvlc-dev`, FFmpeg codec packages, and the required GStreamer/X11 libraries for IPTVBoss stream video and audio playback.
- **Xpra helper applications**: Added GNOME Terminal, Nautilus, Gedit, Zenity, and desktop menu integration while keeping the application menu limited to useful entries.
- **rclone in every image family**: Added rclone to VNC, headless, and Xpra stable/beta images for external storage synchronization.
- **Six-image multi-platform publishing**: CI now builds stable and beta variants for VNC, headless, and Xpra on both `amd64` and `arm64`, including pull-request image tags in the `pr-<number>` format.

### Changed (3.11.16)

- **VNC base OS**: Migrated the VNC image (`Dockerfile`) to Debian `trixie`; builds now perform a full `dist-upgrade` so TigerVNC/Xvnc and the underlying OS use currently supported packages.
- **Headless base OS**: Migrated `Dockerfile.headless` from Ubuntu 20.04 to Ubuntu 24.04 and updated renamed runtime libraries.
- **Shared IPTVBoss installer**: Consolidated stable/beta package download, verification, and install logic into `install_iptvboss.sh`, used by VNC, headless, and Xpra images.
- **Direct tag-driven builds**: Standardized image installs to use `LATEST_TAG` and `BETA_TAG` build arguments directly, while preserving channel-specific package sources.
- **Consistent runtime identity**: Improved `PUID`/`PGID`, home-directory, cache, configuration, cron-file, and mounted-volume ownership handling across the image variants.
- **Centralized cron monitoring setup**: Moved the shared Cronitor configuration call into `configure_cron_schedule.sh`, so VNC, headless, and Xpra use the same cron/Cronitor path and default monitor naming behavior.
- **Selective CI builds**: Updated the Docker workflow to detect affected stable/beta image families, build native platform images, merge multi-platform manifests, and publish PR-specific tags without replacing release tags.

### Fixed

- **Chromium desktop launcher not opening**: The base image's `/dockerstartup/chrome-init.sh` generated a `CHROMIUM_FLAGS` string containing a bare `--user-data-dir` with no path value, which current Chromium builds silently refuse to start with. Added a repo-local [`chrome-init.sh`](chrome-init.sh) that sets `--user-data-dir=$HOME/.config/chromium-browser`.
- **Desktop launcher trust not surviving restarts**: The VNC image now continuously backs up the `gvfs-metadata` trust record to persistent IPTVBoss storage. Users still approve each launcher once on a fresh volume, but that decision can survive container restarts and redeployments.
- **VNC clipboard state**: Explicitly enabled `AcceptCutText`, `SendCutText`, `SendPrimary`, and `SetPrimary` on the TigerVNC server command line.
- **Xpra home-directory and UID conflict**: Removed the Ubuntu base image's default user and consistently use the `iptvboss` account with `/headless` as `HOME`, preventing Xpra from storing sockets and configuration under `/home/ubuntu`.
- **Xpra application launch behavior**: IPTVBoss is started when a browser client connects, while duplicate application processes are avoided.
- **Xpra runtime warnings and permissions**: Added the required UTF-8 locale, D-Bus, XKB library, writable cache/configuration directories, and an owned `XDG_RUNTIME_DIR`.
- **Xpra production logging**: Removed verbose sound/GStreamer debug logging after audio validation so normal container logs remain focused on operational events and errors.
- **Xpra stream playback**: Resolved missing native VLC library errors and enabled video/audio playback from IPTVBoss.
- **Cronitor installation in Xpra**: Added `sudo` and consolidated Cronitor invocation so monitored cron commands are created consistently.
- **Cron log consistency**: Xpra now writes scheduled IPTVBoss output to `/var/log/cron.log`, matching the other image families.
- **Non-root cache access**: Ensured `.cache` and relevant configuration directories are writable by the runtime IPTVBoss user.

### Security

- Refreshed the VNC and headless base operating systems to supported Debian and Ubuntu releases with current upstream security packages.
- Added build-time IPTVBoss package integrity validation by checking the downloaded `.deb` SHA256 against the channel release `Packages` metadata before installation.
- Added Xpra repository trust checks by validating the Xpra signing key SHA256 and fingerprint, and validating the downloaded Xpra `sources` file SHA256 before `apt-get update`.
- Added documentation warning against exposing ports `5454`, `5901`, `6901`, or `8001` directly to the internet and recommending a firewall, VPN/private overlay, or authenticated TLS reverse proxy.

### Documentation

- Restructured `README.md` into an image index with dedicated guides for VNC, headless, Xpra, and Cronitor.
- Added stable and beta Xpra build, Compose, CLI, access, volume, scheduling, and security guidance.
- Documented the headless image build and runtime configuration for the first time.
- Added separate user-facing and maintainer/staff release notes in [RELEASE_NOTES.md](RELEASE_NOTES.md).

## Prior release (3.11.16, base image refresh)

### Changed

- Fixed `.cache` directory ownership so it is writable by the non-root `PUID`/`PGID` user ([#234](https://github.com/groenator/iptvboss-docker/issues/234)).
