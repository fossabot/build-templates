#!/bin/bash
set -e

DEVID=$(id -u $APIUSER)
if [ "$DEVID" != "$CURRENT_UID" ]; then
    echo "Fixing user $APIUSER uid from $DEVID to $CURRENT_UID..."
    usermod -u $CURRENT_UID $APIUSER
fi

GROUPID=$(id -g $APIUSER)
if [ "$GROUPID" != "$CURRENT_GID" ]; then
    echo "Fixing user $APIUSER gid from $GROUPID to $CURRENT_GID..."
    usermod -g $CURRENT_GID $APIUSER
fi

# fix permissions of flower db dir
if [ -d "$CELERYUI_DBDIR" ]; then
    chown -R $APIUSER $CELERYUI_DBDIR
fi

# fix permissions of celery beat pid dir
if [ -d "/pids" ]; then
    chown -R $APIUSER /pids
fi

echo "waiting for services"
eval "$DEV_SU -c 'restapi wait'"

echo "Requested command: $@"

# $@
# exit 0

exec gosu $APIUSER $@ &
pid="$!"
# no success with wait...
# trap "echo Sending SIGTERM to process ${pid} && kill -SIGTERM ${pid} && wait {$pid}" INT TERM
trap "echo Sending SIGTERM to process ${pid} && kill -SIGTERM ${pid} && sleep 5" TERM
trap "echo Sending SIGINT to process ${pid} && kill -SIGINT ${pid} && sleep 5" INT
wait
