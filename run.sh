#!/bin/sh

# Script Path
TIME=$(date)
# Directory containg ES files
ES_DIR="/elasticsearch"
env
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
if [[ $NODE_TYPE == "MASTER" ]]
then
  echo "[$TIME] $HOSTNAME is a ES Master node"
  export NODE_MASTER=true
  export HTTP_ENABLE=false
else
  export NODE_MASTER=false
  export HTTP_ENABLE=false
fi
# Fetching the node type (If Data)
if [[ $NODE_TYPE == "DATA" ]]
then
  echo "[$TIME] $HOSTNAME is a ES Data node"
  export NODE_DATA=true
  export HTTP_ENABLE=false
else
  export NODE_DATA=false
  export HTTP_ENABLE=false
fi
# Fetching the node type (If Client)
if [[ $NODE_TYPE == "CLIENT" ]]
then
  echo "[$TIME] $HOSTNAME is a ES Client node"
  export NODE_CLIENT=true
  export HTTP_ENABLE=true
else
  export NODE_CLIENT=false
  export HTTP_ENABLE=false
fi

# Updating clustername and namespaces
export KUBERNETES_NAMESPACE=${KUBERNETES_NAMESPACE:-default}
export CLUSTER_NAME=${CLUSTER_NAME:-$KUBERNETES_NAMESPACE}
echo "[$TIME] This node is deployed in Namespace $KUBERNETES_NAMESPACE"
echo "[$TIME] This node is deployed is part of Cluster $CLUSTER_NAME"

# Setting up ES Path configuration
export DATA_PATH=${DATA_PATH:-/data}
export LOGS_PATH=${LOGS_PATH:-/logs}


# running ES
echo "[$TIME] Running ES"
chmod +x /elasticsearch/bin/elasticsearch
sudo -E -u elasticsearch /elasticsearch/bin/elasticsearch
