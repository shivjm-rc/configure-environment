#!/usr/bin/env bash

DRY_RUN=""
EXCLUDE_FILE=""

while getopts "x:d" opt; do
    case $opt in
        d)
            DRY_RUN="yes"
            ;;
        x)
            EXCLUDE_FILE=$OPTARG
            ;;
    esac
done

shift $((OPTIND-1))

if [ 2 -gt $# ]; then
    echo "Usage: $0 [-d] [-x file] SOURCE_DIRECTORY DESTINATION_SUBDIRECTORY"
    exit 1
fi

SOURCE_DIRECTORY="$1"
DESTINATION_DIRECTORY="/w/$2/"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

set -euxo pipefail

rsync -azvhi -P --stats --timeout=60 --no-o ${EXCLUDE_FILE:+--exclude-from "$EXCLUDE_FILE"} ${DRY_RUN:+--dry-run} "$SOURCE_DIRECTORY" "$DESTINATION_DIRECTORY" | tee "$2-$TIMESTAMP.log"
