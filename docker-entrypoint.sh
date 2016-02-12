#!/bin/bash
set -e

# If only specifying a flag, assume we want to run against btsync
if [ "${1:0:1}" = '-' ]; then
    set -- btsync "$@"
fi

if [ "$1" = 'btsync' ]; then
    # Make sure we always call with --nodaemon
    set -- "$@" --nodaemon

    # Initialize required directories
    mkdir -p sync/folders
    mkdir -p sync/config
    chown -R btsync .

    # drop down to btsync user
    exec gosu btsync "$@"
fi

exec "$@"
