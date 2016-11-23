#!/bin/bash

# Script Path
TIME=$(date)
# Directory containg ES files
ES_DIR="/elasticsearch"

# provision elasticsearch user
echo "[$(date)] Creating group sudo"
addgroup sudo
echo "[$(date)] Creating user Elasticsearch"
adduser -D -g '' elasticsearch
echo "[$(date)] Adding Elasticsearch to sudo users"
adduser elasticsearch sudo
echo "[$(date)] Changing ownership of [$ES_DIR] to elasticsearch user"
chown -R elasticsearch $ES_DIR
echo "[$(date)] Enabling sudo without password"
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# allow for memlock
echo "[$(date)] Enabling memlock"
ulimit -l unlimited

# Fetching the node type (If Master)
if [[ $NODE_TYPE == *"MASTER"* ]]
then
  echo "[$(date)] $HOSTNAME is a ES Master node"
  export NODE_MASTER=true
  export HTTP_ENABLE=false
else
  export NODE_MASTER=false
  export HTTP_ENABLE=false
fi
# Fetching the node type (If Data)
if [[ $NODE_TYPE == *"DATA"* ]]
then
  echo "[$(date)] $HOSTNAME is a ES Data node"
  export NODE_DATA=true
  export HTTP_ENABLE=false
else
  export NODE_DATA=false
  export HTTP_ENABLE=false
fi
# Fetching the node type (If Client)
if [[ $NODE_TYPE == *"CLIENT"* ]]
then
  echo "[$(date)] $HOSTNAME is a ES Client node"
  export NODE_CLIENT=true
  export HTTP_ENABLE=true
else
  export NODE_CLIENT=false
  export HTTP_ENABLE=false
fi

# Updating clustername and namespaces
export KUBERNETES_NAMESPACE=${KUBERNETES_NAMESPACE:-default}
export CLUSTER_NAME=${CLUSTER_NAME:-$KUBERNETES_NAMESPACE}
echo "[$(date)] This node is deployed in Namespace $KUBERNETES_NAMESPACE"
echo "[$(date)] This node is deployed is part of Cluster $CLUSTER_NAME"

# Setting up ES Path configuration
export DATA_PATH=${DATA_PATH:-/data}
export LOGS_PATH=${LOGS_PATH:-/logs}
echo "[$(date)] Data Path $DATA_PATH"
echo "[$(date)] Logs Path $LOGS_PATH"
echo "[$(date)] Creating/Changing ownership of $LOGS_PATH to elasticsearch user"
mkdir -p $LOGS_PATH || true
chown -R elasticsearch $LOGS_PATH

# running ES
echo "[$(date)] Running ES"
chmod +x /elasticsearch/bin/elasticsearch
sudo -E -u elasticsearch /elasticsearch/bin/elasticsearch
