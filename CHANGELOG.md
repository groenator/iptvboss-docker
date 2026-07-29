# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Security

- **Migrated the VNC image (`Dockerfile`) to Debian `trixie` and performed a full `dist-upgrade`** to pull in the latest upstream security patches for the base OS packages.
- **Migrated the headless image (`Dockerfile.headless`) to Ubuntu 24.04** and adjusted package installations accordingly to pick up current security fixes.

### Fixed

- **Chromium desktop launcher not opening**: The base image's `/dockerstartup/chrome-init.sh` generated a `CHROMIUM_FLAGS` string containing a bare `--user-data-dir` with no path value, which current Chromium builds silently refuse to start with (no renderer/GPU process ever spawns). Added a repo-local [`chrome-init.sh`](chrome-init.sh) that overrides the base script and sets `--user-data-dir=$HOME/.config/chromium-browser`.
- **Desktop icon "Untrusted application launcher" prompt not persisting across restarts**: The gvfs-metadata trust checksum (`gvfs-metadata-home`) was restored from the persistent volume on container start, but never backed up again afterward, so any manual "Mark As Secure And Launch" decision was lost on the next container restart/redeploy. Added a continuous backup loop in [`entrypoint.sh`](entrypoint.sh) that copies the trust checksum back to the persistent volume every few seconds, matching the fix in the upstream [ConSol `docker-headless-vnc-container` PR #207](https://github.com/ConSol/docker-headless-vnc-container/pull/207). You still need to click "Mark As Secure And Launch" once per icon on a fresh volume, but the decision now survives restarts.
- **VNC clipboard checkboxes unticked by default**: Explicitly pinned `-AcceptCutText=1 -SendCutText=1 -SendPrimary=1 -SetPrimary=1` on the `vncserver` command line in the `Dockerfile` for consistency, even though these already default to "on" in current Xtigervnc builds.

### Documentation

- Restructured `README.md` into a concise index with a `docs/` folder containing dedicated pages: [docs/vnc-stable.md](docs/vnc-stable.md), [docs/vnc-beta.md](docs/vnc-beta.md), [docs/headless-stable.md](docs/headless-stable.md), [docs/headless-beta.md](docs/headless-beta.md), and [docs/cronitor.md](docs/cronitor.md).
- Documented the headless (`Dockerfile.headless`) image usage (build args, Docker Compose, `docker run` examples) for the first time.

## Prior release (3.11.16, base image refresh)

### Changed

- Fixed `.cache` directory ownership so it is writable by the non-root `PUID`/`PGID` user ([#234](https://github.com/groenator/iptvboss-docker/issues/234)).
