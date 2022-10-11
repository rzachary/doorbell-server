APP=doorbell-server
APP_EXECUTABLE="./out/$(APP)"
ALL_PACKAGES=$(shell go list ./... | grep -v "vendor")

GOARCH =$(shell go env GOARCH)


# Use bash syntax
SHELL := /bin/bash

#
#	Actions
#
.PHONY:  build test clean lint

TAG := not set
tag_app_image:
	if [ ! -f build/app_image ]; then echo "build/app_image not present"; exit 1; fi;
	docker tag $(shell cat build/app_image | tr '\n' ' ') $(TAG)

# Run all golang tests
test_local:
	go test -short -count=1 ./...

.PHONY: test
test:
	go clean -testcache
	go test `go list ./... | grep -v "contract_test\|integration_test"`
	#gotestsum --format=testname  --packages ./... --junitfile report.xml -- -coverprofile=coverage.out ./...

test_long:
	go test -count=1 ./...

test_qa:
	kubectl -n nats-io --context qa port-forward pod/crypto-qa-nats-1 4222:4222 &
	sleep 2
	go test -json -test.count=1 -tags=integration -test.v -test.run '.*QA' ./... | go run ./util/testutil/tjson
	killall kubectl

# Clean everything
clean:
	rm -rf out/
	echo "Clean done"


build:
	go build -o $(APP_EXECUTABLE)doorbell-server
#
#	Docker
#
.PHONY: build/builder_image

# Builder docker image; build/builder_image contains the id of the image
build/builder_image:
	mkdir -p build
	docker build --platform linux/amd64 -f docker/dockerfile -t builder -q . | tee $@


lint:
	golangci-lint  run