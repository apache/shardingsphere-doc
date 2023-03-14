#!/bin/bin

ARGS=$@

if [ -z "${ARGS}" ]; then
    echo "ARGS is empty, use default ARGS '--cleanDestinationDir'"
    ARGS="--cleanDestinationDir"
fi

cd /opt/input/
hugo ${ARGS}
