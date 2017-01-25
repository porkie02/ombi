FROM mattsch/fedora-rpmfusion:latest
MAINTAINER Matthew Schick <matthew.schick@gmail.com>

COPY tpokorra-mono-fedora.repo /etc/yum.repos.d/tpokorra-mono-fedora.repo

# Run updates
RUN dnf upgrade -yq && \
    dnf clean all

# Install required packages
RUN dnf install -yq curl \
                    mono-core \
                    procps-ng \
                    sqlite \
                    unzip && \
    dnf clean all

# Set uid/gid (override with the '-e' flag), 1000/1000 used since it's the
# default first uid/gid on a fresh Fedora install
ENV LUID=1000 LGID=1000

# Create the plexreqs user/group
RUN groupadd -g $LGID ombi && \
    useradd -c 'Ombi User' -s /bin/bash -m -d /opt/Ombi \
    -g $LGID -u $LUID ombi

# Grab the installer, do the thing
RUN cd /tmp && \
    export URL=$(curl -qsX GET \
        https://github.com/tidusjar/Ombi/tree/dev \
        | awk '/browser_download_url/{print $4;exit}' FS='[""]') && \
    curl -qOL $URL && \
    cd /opt/ && \
    unzip -q -d Ombi /tmp/Ombi.zip && \
    rm /tmp/Ombi.zip && \
    chown -R ombi:ombi /opt/Ombi

# Need a config and storage volume, expose proper port
VOLUME /config
EXPOSE 3579

# Add script to copy default config if one isn't there and start plexreqs
COPY run-ombi.sh /bin/

# Run our script
CMD ["/bin/run-ombi.sh"]
