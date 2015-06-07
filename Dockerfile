FROM java:openjdk-7-jre

ENV CROWD_VERSION 2.8.3

ENV DOWNLOAD_URL        https://downloads.atlassian.com/software/crowd/downloads/atlassian-crowd-

# https://confluence.atlassian.com/display/CROWD/Specifying+your+Crowd+Home+Directory
ENV CROWD_HOME          /var/atlassian/application-data/crowd

# Install Atlassian Stash to the following location
ENV CROWD_INSTALL_DIR   /opt/atlassian/crowd


# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
ENV RUN_USER            daemon
ENV RUN_GROUP           daemon


# Install git, download and extract Stash and create the required directory layout.
# Try to limit the number of RUN instructions to minimise the number of layers that will need to be created.
RUN apt-get update -qq                                                            \
    && apt-get install -y --no-install-recommends                                 \
            git                                                                   \
    && apt-get clean autoclean                                                    \
    && apt-get autoremove --yes                                                   \
    && rm -rf                  /var/lib/{apt,dpkg,cache,log}/

RUN mkdir -p                             $CROWD_INSTALL_DIR


RUN curl -L --silent                     ${DOWNLOAD_URL}${CROWD_VERSION}.tar.gz | tar -xz --strip=1 -C "$CROWD_INSTALL_DIR" \
    && mkdir -p                          ${CROWD_INSTALL_DIR}                    \
    && chmod -R 700                      ${CROWD_INSTALL_DIR}                    \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${CROWD_INSTALL_DIR}

USER ${RUN_USER}:${RUN_GROUP}

VOLUME ["${CROWD_INSTALL_DIR}"]

# HTTP Port
EXPOSE 9001

# SSH Port
EXPOSE 9901

WORKDIR $CROWD_INSTALL_DIR

# Run in foreground
CMD ["./start_crowd.sh", "-fg"]

