gen:
	protoc --go_out=plugins=grpc:. ./proto/*.proto
	cp ./proto/*.go ./gateway/
	cp ./proto/*.go ./resource/

up:
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose up --build
.PHONE: up

down:
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose down -v
.PHONY: down

fmt:
	GO111MODULE=on go fmt `go list ./... | grep -v /vendor/`
	GO111MODULE=on goimports -w `go list -f {{.Dir}} ./... | grep -v /vendor/`
.PHONY: fmt

lint:
	golangci-lint run
	golint `go list ./... | grep -v /vendor/`
.PHONY: lint

test:
	go clean -testcache ./...
	go test ./... -race -p 1
.PHONY: test
