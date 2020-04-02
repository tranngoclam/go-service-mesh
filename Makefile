gen:
	protoc --go_out=plugins=grpc:. ./proto/*.proto
	cp ./proto/*.go ./gateway/
	cp ./proto/*.go ./resource/
.PHONY: gen

up:
	@COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose -f docker-compose.yml up -d --build
.PHONY: up

down:
	@COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose -f docker-compose.yml down -v
.PHONY: down

ps:
	@docker-compose ps
.PHONY: ps

register:
	@docker exec sm-consul-client /bin/sh -c "echo '{\"service\": {\"name\": \"gateway\", \"tags\": [\"go\"], \"port\": 3000}}' >> /consul/config/gateway.json"
.PHONY: register

reload:
	@docker exec sm-consul-client consul reload
.PHONY: reload

members:
	@docker exec sm-consul-server consul members
.PHONY: members
