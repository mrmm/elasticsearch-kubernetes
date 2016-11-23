IMAGE_NAME=quay.io/mrmm/elasticsearch-kubernetes
IMAGE_TAG=2.4.1
REPO=$(IMAGE_NAME):$(IMAGE_TAG)

build:
	docker build -t $(REPO) .

push: build
	docker push $(REPO)
