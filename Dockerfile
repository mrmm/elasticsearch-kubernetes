FROM quay.io/mrmm/docker-jre:jdk8-jre
MAINTAINER mr.maatoug@gmail.com

ENV ES_VERSION 2.4.1

# Install Elasticsearch.
RUN apk add --update bash curl ca-certificates sudo && \
  ( curl -Lskj https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/$ES_VERSION/elasticsearch-$ES_VERSION.tar.gz | \
  gunzip -c - | tar xf - ) && \
  mv /elasticsearch-$ES_VERSION /elasticsearch && \
  rm -rf $(find /elasticsearch | egrep "(\.(exe|bat)$)")

# Override elasticsearch.yml config, otherwise plug-in install will fail
ADD plugin_config.yaml /elasticsearch/config/elasticsearch.yml

RUN /elasticsearch/bin/plugin install lmenezes/elasticsearch-kopf/v2.1.2
RUN /elasticsearch/bin/plugin install io.fabric8/elasticsearch-cloud-kubernetes/$ES_VERSION

# Putting back the configuration
ADD elasticsearch.yml /elasticsearch/config/elasticsearch.yml

# pre-stop-hook.sh and dependencies
RUN apk add --update jq
COPY pre-stop-hook.sh /pre-stop-hook.sh

# Set environment variables defaults
ENV ES_JAVA_OPTS "-Xms512m -Xmx512m -Djava.net.preferIPv4Stack=true"

# Could be :
# MASTER, CLIENT, DATA, MASTER_CLIENT_DATA
ENV NODE_TYPE MASTER_CLIENT_DATA
ENV NETWORK_HOST _site_
ENV HTTP_CORS_ENABLE true
ENV HTTP_CORS_ALLOW_ORIGIN *
ENV NUMBER_OF_MASTERS 1
ENV NUMBER_OF_SHARDS 1
ENV NUMBER_OF_REPLICAS 0

# Defining the ES Discovery service
ENV DISCOVERY_SERVICE elasticsearch-discovery

# Storage path configuration
ENV DATA_PATH /data
ENV LOGS_PATH /logs

# Copy run script
COPY run.sh /

RUN chmod +x /run.sh

CMD ["/run.sh"]
