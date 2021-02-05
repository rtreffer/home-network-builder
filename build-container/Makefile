MAKE_FOLDER ?=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))

.PHONY: container
container: target/cloud-merge
	docker build -t home-network-builder .

target/cloud-merge: cloud-merge.go
	docker run --rm -t -i \
		-v $(MAKE_FOLDER):/srv \
		-w /srv \
		-e "CGO_ENABLED=0" \
		golang:1-buster \
		bash -c \
		"go build -a -installsuffix cgo -o target/cloud-merge cloud-merge.go && chown $(shell id -u):$(shell id -g) target/cloud-merge"
