FROM base

ENV CROWD_VERSION 2.8.3

ENV DOWNLOAD_URL        https://downloads.atlassian.com/software/crowd/downloads/atlassian-crowd-

# https://confluence.atlassian.com/display/CROWD/Specifying+your+Crowd+Home+Directory
ENV CROWD_HOME          /var/atlassian/application-data/crowd

# Install Atlassian Stash to the following location
ENV CROWD_INSTALL   /opt/atlassian/crowd


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

RUN mkdir -p                             $CROWD_INSTALL

RUN curl -L --silent                     ${DOWNLOAD_URL}${CROWD_VERSION}.tar.gz | tar -xz --strip=1 -C "$CROWD_INSTALL"   \
    && chmod -R 700                      ${CROWD_INSTALL}                                                              \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${CROWD_INSTALL}

RUN echo "crowd.home=${CROWD_HOME}/crowd" >> "${CROWD_INSTALL}/crowd-webapp/WEB-INF/classes/crowd-init.properties"
RUN echo "crowd.openid.home=${CROWD_HOME}/openid" >> "${CROWD_INSTALL}/crowd-webapp/WEB-INF/classes/crowd-init.properties"

USER ${RUN_USER}:${RUN_GROUP}

VOLUME ["${CROWD_INSTALL}"]

# HTTP Port
EXPOSE 8095

# SSH Port
EXPOSE 22

WORKDIR $CROWD_INSTALL

# Run in foreground
#CMD ["./start_crowd.sh", "-fg"]
CMD ["/bin/bash", "-c", "${CROWD_INSTALL}/apache-tomcat/bin/catalina.sh run"]

