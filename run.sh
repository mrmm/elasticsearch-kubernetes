#!/bin/bash

# Script Path
TIME=$(date)
# Directory containg ES files
ES_DIR="/elasticsearch"

# provision elasticsearch user
echo "[$TIME] Creating group sudo"
addgroup sudo
echo "[$TIME] Creating user Elasticsearch"
adduser -D -g '' elasticsearch
echo "[$TIME] Adding Elasticsearch to sudo users"
adduser elasticsearch sudo
echo "[$TIME] Changing ownership of [$ES_DIR] to elasticsearch user"
chown -R elasticsearch $ES_DIR
echo "[$TIME] Enabling sudo without password"
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# allow for memlock
echo "[$TIME] Enabling memlock"
ulimit -l unlimited

# Fetching the node type (If Master)
if [[ $NODE_TYPE == *"MASTER"* ]]
then
  export NODE_MASTER=true
  export HTTP_ENABLE=false
else
  export NODE_MASTER=false

fi
# Fetching the node type (If Data)
if [[ $NODE_TYPE == *"DATA"* ]]
then
  export NODE_DATA=true
  export HTTP_ENABLE=false
else
  export NODE_DATA=false
  export HTTP_ENABLE=false
fi
# Fetching the node type (If Client)
if [[ $NODE_TYPE == *"CLIENT"* ]]
then
  export NODE_CLIENT=true
  export HTTP_ENABLE=true
else
  export NODE_CLIENT=false
  export HTTP_ENABLE=false
fi

# Updating clustername and namespaces
KUBERNETES_NAMESPACE=${KUBERNETES_NAMESPACE:-default}
CLUSTER_NAME=${CLUSTER_NAME:-$KUBERNETES_NAMESPACE}

# Setting up ES Path configuration
DATA_PATH=${DATA_PATH:-/data}
LOGS_PATH=${LOGS_PATH:-/logs}

# running ES
echo "[$TIME] Running ES"
chmod +x /elasticsearch/bin/elasticsearch
sudo -u elasticsearch /elasticsearch/bin/elasticsearch
