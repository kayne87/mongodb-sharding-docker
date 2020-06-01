# A very basic test script in order to verify mongos connection and insert some records in the cluster.
#
# If you have already sharded the collection test, you can check the sharded distribution after the current script execution 

import pymongo
from pymongo import MongoClient

#if you have changed ports exposition in docker-compose.yml please align this script.
client = MongoClient('localhost', 27027)
db = client.shardedDB

for i in range(1500):
  db.shardedCollection.insert_one({"x": i});