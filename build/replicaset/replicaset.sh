#!/bin/bash

until /usr/bin/mongo --port 27017 --quiet --eval 'db.getMongo()'; do
    sleep 1
done

/usr/bin/mongo --port 27017 <<EOF
    rs.initiate({_id: "${REPLICA_SET}", members: [
        {_id: 0, host: "mongo${REPLICA_SET}1"},
        {_id: 1, host: "mongo${REPLICA_SET}2"},
        {_id: 2, host: "mongo${REPLICA_SET}3"}
    ]});
EOF