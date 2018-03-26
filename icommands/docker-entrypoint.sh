#!/bin/bash
set -e

# if [ "$1" != 'download' ]; then
#     echo "Requested custom command:"
#     echo "\$ $@"
#     $@
#     exit 0
# fi

######################################
#
# Entrypoint!
#
######################################

# Extra scripts
dedir="/docker-entrypoint.d"
for f in `ls $dedir`; do
    case "$f" in
        *.sh)     echo "running $f"; bash "$dedir/$f" ;;
        *)        echo "ignoring $f" ;;
    esac
    echo
done

###############
# DO THE COPY

if [ "$BATCH_SRC_PATH" == "" -o "$BATCH_DEST_PATH" == "" ]; then
    echo "Missing source and/or destination to be copied"
    exit 1
else
    if [ "$1" == 'download' ]; then
        IPATH=$BATCH_SRC_PATH
    elif [ "$1" == 'upload' ]; then
        IPATH=$BATCH_DEST_PATH
    fi
fi

# 1. check if IRODS_HOST variable exists
if [ "$IRODS_HOST" != "" ]; then

    # what you need is:
    # IRODS_HOST=172.20.0.2
    # IRODS_PORT=1247
    # IRODS_USER_NAME=irods
    # IRODS_ZONE_NAME=tempZone
    # IRODS_PASSWORD=some

    # env

    # 2. log out, try iinit and set password
    iexit full
    # https://docs.irods.org/4.1.2/manual/configuration/#irodsirodsa
    yes $IRODS_PASSWORD | iinit
    # exec yes $IRODS_PASSWORD | iinit 2> /dev/null
    if [ "$?" != "0" ]; then
        echo "FAILURE: not able to login to irods"
        exit 1
    else
        echo 'irods login completed'
    fi
    # 3. check with ils
    ils -A $IPATH
    if [ "$?" != "0" ]; then
        echo "FAILURE: not able to test ILS on batch path"
        exit 1
    fi

    if [ "$1" == 'download' ]; then
        # 4. copy the file into the destination directory
        # TODO: build, push and test it
        iget -f $BATCH_SRC_PATH $BATCH_DEST_PATH
        echo "File copied"

        # whoami
        # fix permissions
        # TODO: get to know which user should be mapped here
        chown 1000 -R $BATCH_DEST_PATH
    elif [ "$1" == 'upload' ]; then
        # the variable this time is a list
        for file in $FILES;
        do
            iput -f $BATCH_SRC_PATH/$file $BATCH_DEST_PATH
            echo "Deposited: $file into $BATCH_DEST_PATH"
        done
    fi

else
    echo "Please set IRODS minimum set of variables as described in:"
    echo "https://docs.irods.org/4.2.2/system_overview/configuration"
    exit 1
fi

# # what else?
# exec sleep infinity
