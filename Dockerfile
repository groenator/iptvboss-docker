
# Use the official Debian base image
FROM  consol/debian-xfce-vnc:latest

# Set locale to avoid warnings
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ARG LATEST_TAG
# Switch to root temporarily to perform system updates
USER 0

# Set the working directory
WORKDIR /headless

# Update package list and upgrade installed packages
RUN apt-get update -y && apt-get upgrade -y

# Install necessary dependencies
RUN apt-get install -y --no-install-recommends \
    wget cron curl sudo dpkg-dev vlc alsa-oss alsa-utils libsndfile1-dev \
    python3 python3-pip jq rclone gosu \
    libgtk2.0-0 libavcodec-extra* &&  \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the Python script into the container
COPY cronitor.py /headless/scripts/

# Install Python dependencies
RUN pip3 install requests

# Retrieve the latest release tag from GitHub
RUN CPU=$(dpkg-architecture -q DEB_HOST_ARCH_CPU) \
    && wget https://github.com/walrusone/iptvboss-release/releases/download/${LATEST_TAG}/iptvboss_${LATEST_TAG#v}_${CPU}.deb \
    && apt install ./iptvboss_${LATEST_TAG#v}_${CPU}.deb && \
    cp /usr/share/applications/io.github.walrusone.iptvboss-release.desktop /headless/Desktop/iptvboss-release.desktop && \
    chmod 777 /headless/Desktop/iptvboss-release.desktop

# Create a new user with home directory set to /headless
RUN useradd -u 911 -U -d /headless -s /bin/bash iptvboss

# Copy the cron file to the cron.d directory
COPY iptvboss-cron /headless/iptvboss-cron

# Expose VNC port
EXPOSE 5901
EXPOSE 6901
EXPOSE 8001

# Copy the entrypoint script into the container and make it executable
COPY entrypoint.sh /headless/entrypoint.sh

# Run the entrypoint script
RUN chmod +x /headless/entrypoint.sh

# Set the entrypoint script to be executed when the container starts
ENTRYPOINT ["/headless/entrypoint.sh"]
