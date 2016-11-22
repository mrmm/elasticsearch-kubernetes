# Elasticsearch Pet

This is an Elasticsearch docker image meant to be used with PetSets.

This image is using Fabric8's great work around the [kubernetes plugin](https://github.com/fabric8io/elasticsearch-cloud-kubernetes) for elasticsearch and their [image](https://hub.docker.com/r/fabric8/elasticsearch-k8s/) as parent.

## Env variables
- __CLUSTER_NAME__ : Elasticsearch Cluster name _(default : KUBERNETES_NAMESPACE)_
- __NODE_TYPE__ : Define the node type _(default : MASTER_CLIENT_DATA)_
⋅⋅* __MASTER__ : Node type will be set as Master
⋅⋅* __CLIENT__ : Node type will be set as Client
⋅⋅* __DATA__ : Node type will be set as Data
⋅⋅* __MASTER_CLIENT_DATA__ : Node type will be set as Master, Client and Data
- __DISCOVERY_SERVICE__ : Set the discovery service name for Kubernetes Plugin _(default : elasticsearch-discovery)_
- __KUBERNETES_NAMESPACE__ : Kubernetes namespace of the Pod _(default : default)_

## Immutable Elasticsearch Configs
- __ES_HEAP_SIZE__ : 512Mi
- __NETWORK_HOST__ : \_site_
- __Node Name__ : By default will be the hostname which is the Pod name in our case

## Installed Plugins
| Plugin name   | Version       |Purpose       |
| ------------- |:-------------:|:------------|
| [kopf](https://github.com/lmenezes/elasticsearch-kopf)      | v2.1.2        | ES UI       |
| [elasticsearch-cloud-kubernetes](https://github.com/fabric8io/elasticsearch-cloud-kubernetes)      | 2.4.1         | Kubernetes Discovery service |


## Changes for PetSet
- Handle downscales so that no data loss occurs (using lifecycle hooks) thanks to the work of @simonswine at @jetstack [elasticsearch-pet](https://github.com/jetstack/elasticsearch-pet)
