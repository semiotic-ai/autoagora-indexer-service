INDEXER_SERVICE_VERSION=v0.19.3

build: build-indexer-service
	docker build \
		-t autoagora-indexer-service:${INDEXER_SERVICE_VERSION} \
		.

prepare-submodules:
	git submodule init
	git submodule update

build-indexer-service: prepare-submodules
	docker build \
		-f indexer/Dockerfile.indexer-service \
		-t indexer-service:${INDEXER_SERVICE_VERSION}-querylogspatch \
		indexer
