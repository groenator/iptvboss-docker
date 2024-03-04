
# Use the official CentOS base image
FROM consol/debian-xfce-vnc

# Set locale to avoid warnings
ENV LC_ALL=C.UTF-8

# Switch to root temporarily to perform system updates
USER 0

# Set the working directory
WORKDIR /headless

# Update package list and upgrade installed packages
RUN apt-get update && apt-get upgrade -y

# Install necessary dependencies
RUN apt-get install --no-install-recommends wget cron curl sudo dpkg-dev rclone vlc -y jq libgtk2.0-0 libavcodec-extra* &&  \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Retrieve the latest release tag from GitHub
RUN CPU=$(dpkg-architecture -q DEB_HOST_ARCH_CPU) \
    && LATEST_TAG=$(wget -qO- https://api.github.com/repos/walrusone/iptvboss-release/releases/latest | jq -r .tag_name) \
    && wget https://github.com/walrusone/iptvboss-release/releases/download/${LATEST_TAG}/iptvboss_${LATEST_TAG#v}_${CPU}.deb \
    && apt install ./iptvboss_${LATEST_TAG#v}_${CPU}.deb && \
    cp /usr/share/applications/io.github.walrusone.iptvboss-release.desktop /headless/Desktop/iptvboss-release.desktop && \
    chmod 777 /headless/Desktop/iptvboss-release.desktop

# Install Cronitor by default
RUN curl https://cronitor.io/install-linux?sudo=1 | sh

# Create a new user with home directory set to /he  adless
RUN useradd -m -d /headless -s /bin/bash iptvboss

# Copy the cron file to the cron.d directory
COPY iptvboss-cron /etc/cron.d/iptvboss-cron

# Give execution rights on the cron job
RUN crontab -u iptvboss /etc/cron.d/iptvboss-cron &&  \
    chmod u+s /usr/sbin/cron && \
    touch /var/log/cron.log && \
    chown iptvboss:iptvboss /var/log/cron.log

ENV PATH="/usr/lib/iptvboss/bin:${PATH}"

# Switch back to the non-root user
USER 1000

# Expose VNC port
EXPOSE 5901
EXPOSE 6901

# Execute the shell script
COPY entrypoint.sh /headless/entrypoint.sh

ENTRYPOINT ["/headless/entrypoint.sh"]
