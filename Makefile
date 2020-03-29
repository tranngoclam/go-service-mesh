gen:
	protoc --go_out=plugins=grpc:. ./proto/*.proto
	cp ./proto/*.go ./gateway/
	cp ./proto/*.go ./resource/
.PHONY: gen

up:
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose -f docker-compose.yml up --build
.PHONY: up

down:
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose -f docker-compose.yml down -v
.PHONY: down
