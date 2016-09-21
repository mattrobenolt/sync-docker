#!/bin/bash
set -e

# If only specifying a flag, assume we want to run against rslsync
if [ "${1:0:1}" = '-' ]; then
    set -- rslsync "$@"
fi

if [ "$1" = 'rslsync' ]; then
    # Make sure we always call with --nodaemon
    set -- "$@" --nodaemon

    # Initialize required directories
    mkdir -p sync/folders
    mkdir -p sync/config
    chown -R rslsync .

    # drop down to rslsync user
    exec gosu rslsync "$@"
fi

exec "$@"
