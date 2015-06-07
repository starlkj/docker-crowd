FROM ubuntu:14.04

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
            git curl                                                              \
    && apt-get clean autoclean                                                    \
    && apt-get autoremove --yes                                                   \
    && rm -rf                  /var/lib/{apt,dpkg,cache,log}/





# Java Version
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 45
ENV JAVA_VERSION_BUILD 14
ENV JAVA_PACKAGE       jdk

# Download and unarchive Java
RUN curl -kLOH "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
  http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz && \
    tar -zxf ${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz -C /opt && \
    rm ${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz && \
    ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/jdk && \
    rm -rf /opt/jdk/*src.zip \
           /opt/jdk/lib/missioncontrol \
           /opt/jdk/lib/visualvm \
           /opt/jdk/lib/*javafx* \
           /opt/jdk/jre/lib/plugin.jar \
           /opt/jdk/jre/lib/ext/jfxrt.jar \
           /opt/jdk/jre/bin/javaws \
           /opt/jdk/jre/lib/javaws.jar \
           /opt/jdk/jre/lib/desktop \
           /opt/jdk/jre/plugin \
           /opt/jdk/jre/lib/deploy* \
           /opt/jdk/jre/lib/*javafx* \
           /opt/jdk/jre/lib/*jfx* \
           /opt/jdk/jre/lib/amd64/libdecora_sse.so \
           /opt/jdk/jre/lib/amd64/libprism_*.so \
           /opt/jdk/jre/lib/amd64/libfxplugins.so \
           /opt/jdk/jre/lib/amd64/libglass.so \
           /opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
           /opt/jdk/jre/lib/amd64/libjavafx*.so \
           /opt/jdk/jre/lib/amd64/libjfx*.so

# Set environment
ENV JAVA_HOME /opt/jdk
ENV PATH $PATH:$JAVA_HOME/bin
RUN update-alternatives --install \
  /usr/bin/java      java      "$JAVA_HOME/bin/java"  200 --slave \
  /usr/bin/jar       jar       "$JAVA_HOME/bin/jar"       --slave \
  /usr/bin/jarsigner jarsigner "$JAVA_HOME/bin/jarsigner" --slave \
  /usr/bin/javac     javac     "$JAVA_HOME/bin/javac"     --slave \
  /usr/bin/javadoc   javadoc   "$JAVA_HOME/bin/javadoc"   --slave \
  /usr/bin/javah     javah     "$JAVA_HOME/bin/javah"     --slave \
  /usr/bin/javap     javap     "$JAVA_HOME/bin/javap"     --slave \
  /usr/bin/javaws    javaws    "$JAVA_HOME/bin/javaws"    --slave \
  /usr/bin/keytool   keytool   "$JAVA_HOME/bin/keytool"

#https://github.com/atende/baseimage-jdk/blob/master/install_startssl-certs.sh
#COPY install_startssl-certs.sh /root/install_startssl-certs.sh
#RUN /root/install_startssl-certs.sh







RUN mkdir -p                             $CROWD_INSTALL


RUN curl -L --silent                     ${DOWNLOAD_URL}${CROWD_VERSION}.tar.gz | tar -xz --strip=1 -C "$CROWD_INSTALL" \
    && mkdir -p                          ${CROWD_INSTALL}                    \
    && chmod -R 700                      ${CROWD_INSTALL}                    \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${CROWD_INSTALL}


RUN echo "crowd.home=${CROWD_HOME}/crowd" >> "${CROWD_INSTALL}/crowd-webapp/WEB-INF/classes/crowd-init.properties"
RUN echo "crowd.openid.home=${CROWD_HOME}/openid" >> "${CROWD_INSTALL}/crowd-webapp/WEB-INF/classes/crowd-init.properties"

USER ${RUN_USER}:${RUN_GROUP}

VOLUME ["${CROWD_INSTALL}"]

# HTTP Port
EXPOSE 8095

# SSH Port
#EXPOSE 9901

WORKDIR $CROWD_INSTALL

# Run in foreground
#CMD ["./start_crowd.sh", "-fg"]
CMD ["/bin/bash", "-c", "${CROWD_INSTALL}/apache-tomcat/bin/catalina.sh run"]

