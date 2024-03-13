
# Use the official Debian base image
FROM consol/debian-xfce-vnc

# Set locale to avoid warnings
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# Switch to root temporarily to perform system updates
USER 0

# Set the working directory
WORKDIR /headless

# Update package list and upgrade installed packages
RUN apt-get update -y && apt-get upgrade -y

# Install necessary dependencies
RUN apt-get install -y --no-install-recommends \
    wget cron curl sudo dpkg-dev vlc alsa-oss alsa-utils libsndfile1-dev \
    python3 python3-pip jq supervisor \
    libgtk2.0-0 libavcodec-extra* &&  \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the Python script into the container
COPY cronitor.py /headless/scripts/

# Install Python dependencies
RUN pip3 install requests

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
RUN groupadd iptvboss && useradd -g iptvboss -m -d /headless -s /bin/bash iptvboss && \
    usermod -aG audio iptvboss && \
    chown -R iptvboss:iptvboss /var/log/supervisor/

# Copy Supervisor configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy the cron file to the cron.d directory
COPY iptvboss-cron /headless/iptvboss-cron

# Give execution rights on the cron job
RUN crontab -u iptvboss /headless/iptvboss-cron &&  \
    chmod u+s /usr/sbin/cron && \
    touch /var/log/cron.log && \
    chown iptvboss:iptvboss /var/log/cron.log

ENV PATH="/usr/lib/iptvboss/bin:${PATH}"

# Expose VNC port
EXPOSE 5901
EXPOSE 6901
EXPOSE 8001

# Switch back to the non-root user
USER iptvboss

# Execute the shell script
COPY entrypoint.sh /headless/entrypoint.sh

# Execute Supervisor as the entrypoint
CMD ["/bin/bash", "-c", "/headless/entrypoint.sh && /usr/bin/supervisord -c /etc/supervisor/supervisord.conf"]
