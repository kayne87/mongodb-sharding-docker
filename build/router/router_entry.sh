#!/bin/bash

exec /usr/local/bin/router.sh &
exec /usr/local/bin/docker-entrypoint.sh "$@"