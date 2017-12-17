# HadoopSwarmCluster

Docker configuration for hadoop cluster

## Table of contents

1. [Overview](#overview)
2. [Docker Swarm](#docker-swarm)
   1. [Usage](#usage)
   2. [Scaling](#scaling)
3. [Data & Code](#data_&_code)

## Overview
This Docker container contains a full Spark distribution with the following components:

* Defaul JDK 7
* Hadoop 2.7.5

## Docker Swarm
A `docker-compose.yml` file is provided to run the spark-cluster in the [Docker Swarm](https://docs.docker.com/engine/swarm/) environment

### Usage
Run the following command to run the Stack provided with the `docker-compose.yml`. It contains a spark master service and a worker instance. 
```bash
docker stack deploy -c docker-compose.yml <stack-name>
```

To stop the container:
```bash
docker stack rm <stack-name>
```

### Scaling
If you need more worker instances, consider to scale the number of instances by typing the following command:
```bash
docker service scale <stack-name>_worker=<num_of_task>
```

## Data & Code
If you need to inject data and code into the containers use `data` and `code` volumes respectively in `/home/data` and `/home/code`.




