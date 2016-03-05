#!/bin/bash
set -e

. docker-java-home

#echo "\$1=$1 UID=$UID GID=$GID whoami=`whoami` id=`id` \$@=$@"

# allow the container to be started with `--user`
if [ "$1" = 'apache-tomcat/bin/catalina.sh' -a "$(id -u)" = '0' ]; then
    if [ -f $CROWD_INST/.crowd-is-not-configured ]; then /configure; fi
    chown -R $UID:$UID $CROWD_INST
    chown -R $UID:$GID $CROWD_HOME
    exec gosu $UID "$BASH_SOURCE" "$@"
fi

exec "$@"
