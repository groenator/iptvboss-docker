# Use the official Debian base image
FROM  consol/debian-xfce-vnc:v2.0.4

# Set locale to avoid warnings
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# Set the environment variables for the build
ARG LATEST_TAG
ARG BETA_TAG

USER 0

# Set the working directory
WORKDIR /headless

# Move the base OS to Debian trixie and perform a full dist-upgrade (not
# scoped to any single package). This is kept in place so every package in
# the image, including TigerVNC/Xvnc and the underlying X server, always
# gets rebuilt against trixie's currently-supported, patched versions.
RUN printf '%s\n' \
    'Types: deb' \
    'URIs: http://deb.debian.org/debian' \
    'Suites: trixie trixie-updates' \
    'Components: main' \
    'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' \
    '' \
    'Types: deb' \
    'URIs: http://deb.debian.org/debian-security' \
    'Suites: trixie-security' \
    'Components: main' \
    'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' \
    > /etc/apt/sources.list.d/debian.sources && \
    apt-get update && \
    apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --with-new-pkgs upgrade && \
    apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install necessary dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget cron curl sudo dpkg-dev vlc alsa-utils libsndfile1-dev \
    python3 python3-pip python3-requests jq rclone gosu \
    libgtk2.0-0 libavcodec-extra* libgdk-pixbuf-2.0-0 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the Python script into the container
COPY cronitor.py /headless/scripts/
COPY configure_cron_schedule.sh /headless/scripts/

# Retrieve the latest release tag from GitHub
RUN CPU=$(dpkg-architecture -q DEB_HOST_ARCH_CPU) && \
    # Build the latest release
    if [ -n "$LATEST_TAG" ]; then \
        wget https://github.com/walrusone/iptvboss-release/releases/download/${LATEST_TAG}/iptvboss_${LATEST_TAG#v}_${CPU}.deb && \
        if ! apt install -y ./iptvboss_${LATEST_TAG#v}_${CPU}.deb; then \
            dpkg -i ./iptvboss_${LATEST_TAG#v}_${CPU}.deb || true; \
            apt-get install -f -y; \
        fi && \
        cp /usr/share/applications/io.github.walrusone.iptvboss-release.desktop /headless/Desktop/iptvboss-release.desktop && \
        chmod 777 /headless/Desktop/iptvboss-release.desktop; \
    fi && \
    # Build the beta version
    if [ -n "$BETA_TAG" ]; then \
        wget https://github.com/walrusone/iptvboss-beta/releases/download/${BETA_TAG#v}/iptvboss_${BETA_TAG#v}_${CPU}.deb && \
        if ! apt install -y ./iptvboss_${BETA_TAG#v}_${CPU}.deb; then \
            dpkg -i ./iptvboss_${BETA_TAG#v}_${CPU}.deb || true; \
            apt-get install -f -y; \
        fi && \
        cp /usr/share/applications/io.github.walrusone.iptvboss-release.desktop /headless/Desktop/iptvboss-beta.desktop && \
        chmod 777 /headless/Desktop/iptvboss-beta.desktop; \
    fi

# Create a new user with home directory set to /headless
RUN useradd -u 911 -U -d /headless -s /bin/bash iptvboss && \
    touch /headless/iptvboss-cron && \
    chown iptvboss:iptvboss /headless/iptvboss-cron && \
    chmod 600 /headless/iptvboss-cron

# The base image creates /headless/.cache owned by root with mode 0700, but the
# iptvboss user runs the app and the graphics libraries it pulls in. Mesa fails
# to create its shader cache under $XDG_CACHE_HOME (/headless/.cache) as a
# result. The entrypoint only chowns /headless when PUID/PGID are set, so give
# the cache dir to iptvboss at build time. This also lets Chromium, dconf and
# the other user caches populate cleanly.
RUN mkdir -p /headless/.cache && \
    chown iptvboss:iptvboss /headless/.cache && \
    chmod 700 /headless/.cache

# The base image's /dockerstartup/chrome-init.sh generates a CHROMIUM_FLAGS
# entry with a bare `--user-data-dir` (no path). Newer Chromium (trixie's
# 150.x) never spawns a renderer/GPU process with that malformed flag, so the
# desktop icon does nothing. Replace it with a corrected version that points
# --user-data-dir at a real profile directory.
COPY chrome-init.sh /dockerstartup/chrome-init.sh
RUN chmod +x /dockerstartup/chrome-init.sh

# Explicitly pin the TigerVNC clipboard-sharing options on the server side.
# They already default to "on" in Xtigervnc, but the vncconfig applet's
# checkboxes don't reflect that until manually toggled once; passing them on
# the command line keeps the actual server-side behavior consistent.
RUN sed -i \
    's|vnc_cmd="vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION PasswordFile=$HOME/.vnc/passwd"|vnc_cmd="vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION PasswordFile=$HOME/.vnc/passwd -AcceptCutText=1 -SendCutText=1 -SendPrimary=1 -SetPrimary=1"|' \
    /dockerstartup/vnc_startup.sh

# Expose VNC port
EXPOSE 5901
EXPOSE 6901
EXPOSE 8001

# Copy the entrypoint script into the container and make it executable
COPY entrypoint.sh /headless/entrypoint.sh

# Run the entrypoint script
RUN chmod +x /headless/entrypoint.sh /headless/scripts/configure_cron_schedule.sh

# Set the entrypoint script to be executed when the container starts
ENTRYPOINT ["/headless/entrypoint.sh"]
