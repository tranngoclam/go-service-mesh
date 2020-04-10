COMPOSE_FILE := docker-compose.yml
COMPOSE_PROJECT_NAME := sm

gen:
	protoc --go_out=plugins=grpc:. ./proto/*.proto
	cp ./proto/*.go ./gateway/
	cp ./proto/*.go ./resource/

up:
	@COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) \
		COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose up -d --build

down:
	@COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) \
		COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose down -v

ps:
	@COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) docker-compose ps

ips:
	@COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) docker-compose ps -q | xargs -n 1 docker inspect --format '{{ .Name }} {{range .NetworkSettings.Networks}} {{.IPAddress}}{{end}}' | sed "s#^/##";

register:
	@docker exec sm-consul-client /bin/sh -c "echo '{\"service\": {\"name\": \"gateway\", \"tags\": [\"go\"], \"port\": 3000}}' >> /consul/config/gateway.json"

reload:
	@COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) \
		docker-compose exec consul-client consul reload

members:
	@COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) \
		docker-compose exec consul-client consul members

consul-up:
	@docker-compose -f consul/docker-compose.yml up

consul-down:
	@docker-compose -f consul/docker-compose.yml down -v

consul-members:
	@docker-compose -f consul/docker-compose.yml exec consul-client consul members
