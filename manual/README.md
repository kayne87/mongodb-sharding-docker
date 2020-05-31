# MongoDB Sharding with Docker

Deploy your sharded cluster with

```console
docker-compose up -d
```

You can check with **docker-compose ps** if all the cluster nodes are up.

Now proceed with the following steps.

# Config Servers in replica set


From **mongocfg1** (or from every node mongocfgx) mongo shell

```js
rs.initiate({_id: "cfg", configsvr: true, members: [{_id: 0, host: "mongocfg1"},{_id: 1, host: "mongocfg2"}, {_id: 2, host : "mongocfg3"}]})
```

Still from the mongocfg1 mongo shell, check the result with the following command. Sometimes it will takes some seconds in order to elect the primary node, so please be patient and ensure you have in the same list result the primary node.

```js
rs.status()
```

# Shard 1

From **mongoshard11** mongo shell we need now to initialize the replica set cluster for the first Shard.

```js
rs.initiate({_id : "shard1", members: [{ _id : 0, host : "mongoshard11" },{ _id : 1, host : "mongoshard12" },{ _id : 2, host : "mongoshard13" }]})
```

Still from the mongoshard11 mongo shell, check the result with the following command. Sometimes it will takes some seconds in order to elect the primary node, so please be patient and ensure you have in the same list result the primary node configured.

```js
rs.status()
```

# Shard 2

From **mongoshard21** mongo shell we need now to initialize the replica set cluster for the second Shard.

```js
rs.initiate({_id : "shard2", members: [{ _id : 0, host : "mongoshard21" },{ _id : 1, host : "mongoshard22" },{ _id : 2, host : "mongoshard23" }]})
```

Still from the mongoshard21 mongo shell, check the result with the following command. Sometimes it will takes some seconds in order to elect the primary node, so please be patient and ensure you have in the same list result the primary node configured.

```js
rs.status()
```

# Add Sharded Clusters

From **mongos** mongo shell

```js
sh.addShard("shard1/mongoshard11")
sh.addShard("shard2/mongoshard21")
```

You can check now the output again and find all the added Shards with

```js
sh.status()
```

# Test the architecture

Let's create the **sharded database**. So still from mongos instance

```js
use shardedDB
sh.enableSharding("shardedDB")
use config
db.databases.find()
```

If you see something like that, we are at a good point.

```js
{ "_id" : "shardedDB", "primary" : "shard2", "partitioned" : true, "version" : { "uuid" : UUID("14477fea-536a-47a7-9e9d-0201ea2b85f1"), "lastMod" : 1 } }
```

Now we can proceed to create the **sharded collection**. If your application will mostly perform write operations and it needs to execute simple read procedures, the Hashing Strategy is a good option, in this case you can adopt this by using the unique identifier in order to equal distribute the amount of data. In Ranged Strategy you can encounter unbalanced distributions given the optimization for read procedures ("similar data" are grouped). Refer to [Shard Keys](https://docs.mongodb.com/manual/core/sharding-shard-key/) guide for more informations.

```js
use shardedDB
db.shardedCollection.ensureIndex({_id: "hashed"})
sh.shardCollection("shardedDB.shardedCollection", {"_id": "hashed"})
```

Insert some records into the collection

```js
for(var i = 1; i <= 1500; i++) db.shardedCollection.insert({x: i})
```

And finally

```js
db.shardedCollection.getShardDistribution()
```

Enjoy your **sharded cluster** :)

```console
Shard shard1 at shard1/mongoshard11:27017,mongoshard12:27017,mongoshard13:27017
 data : 23KiB docs : 730 chunks : 2
 estimated data per chunk : 11KiB
 estimated docs per chunk : 365

Shard shard2 at shard2/mongoshard21:27017,mongoshard22:27017,mongoshard23:27017
 data : 24KiB docs : 770 chunks : 2
 estimated data per chunk : 12KiB
 estimated docs per chunk : 385

Totals
 data : 48KiB docs : 1500 chunks : 4
 Shard shard1 contains 48.66% data, 48.66% docs in cluster, avg obj size on shard : 33B
 Shard shard2 contains 51.33% data, 51.33% docs in cluster, avg obj size on shard : 33B
```


#### Cleaning tip

With the following command, from the docker-compose file folder, you can stop all the running containers and remove all of them.

```console
docker-compose rm -sv
```
