#!/bin/bash

exec /usr/local/bin/replicaset.sh &
exec /usr/local/bin/docker-entrypoint.sh "$@"