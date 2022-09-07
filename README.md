# MongoDB Sharding with Docker

In this repository you can find a Compose configuration in order to deploy a Sharded Cluster.

The deployed cluster will have:

- 2 **Shard** clusters in replica set (3 nodes for each cluster)
  - *mongoshard11*, *mongoshard12*, *mongoshard13*, *mongoshard21*, *mongoshard22*, *mongoshard23* 
- 1 **Config** cluster in replica set (3 nodes)
  - *mongocfg1*, *mongocfg2*, *mongocfg3*
- 1 **Router** mongos instance
  - *mongos1*

This repository is only for experimental usage. Use it for development or testing purpose. If you are looking for a production architecture please consider the security, distribution and high-availability aspects in a deeper way.

For more advanced topics: **[Membership Authentication](https://docs.mongodb.com/manual/core/security-internal-authentication/), [RBAC Auth](https://docs.mongodb.com/manual/core/authorization/), [Mongo Sharding with Docker Swarm](https://stefanprodan.com/2018/bootstrap-mongo-clusters-docker-swarm/)**

After starting docker-compose, access to the containers as I wrote in this guide.

# Fastest configuration

Using the fastest configuration from this repository you can deploy your Sharded Cluster with only one command from the root folder.

```console
docker-compose up -d
```

After the execution of this command, all the nodes will be started and built with configuration scripts that will be executed automatically. The entire **one-off** process will take some time in order to build the images, initialize 3 Replica sets, elect primary nodes and add the Shards to the router. From the second time, you will only have to wait for the containers to start.

From **mongos** mongo shell

```console
mongo --port 27027 # or "docker exec -it mongos1 /bin/bash" and then "mongo" directly from the container terminal
> sh.status()
```

If you see shards attached the output report, then the process of deploy and configuration is terminated and you can continue with the **Test the architecture** paragraph.

# Step-by-Step Guide

If you are intereseted in a step-by-step guide, open the **./manual** folder in order to follow steps that illustrate you which are the basic procedures in order to configure a cluster of already deployed mondod and mongos nodes.

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
db.shardedCollection.createIndex({_id: "hashed"})
sh.shardCollection("shardedDB.shardedCollection", {"_id": "hashed"})
```

Insert some records into the collection

```js
for(var i = 0; i < 1500; i++) db.shardedCollection.insert({x: i})
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


# Cleaning tips

With the following command, from the docker-compose file folder, you can stop all the running containers and remove all of them.

```console
docker-compose rm -sv
```

If you want to update the .yml file and start from scratch the deployment and configuration (by resetting all the mongodb /data/db), you can remove the named volumes attached during the docker-compose initialization. You can list all the volumes with ```docker volume ls``` and then execute 

```console
docker volume rm <volume_1> <volume_2> <volume_3> <volume_4> ...
```

# Database tip

If you want to see all the [logs](https://docs.docker.com/engine/reference/commandline/logs/) from a particular node server (router, config node, shard node) you can execute 

```console
docker logs mongos1
```


### Infrastructure model

![Infrastructure model](.infragenie/infrastructure_model.png)