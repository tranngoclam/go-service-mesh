COMPOSE_FILE := backend/docker-compose.yml:haproxy/docker-compose.yml:mariadb/docker-compose.yml:redis/docker-compose.yml:consul/docker-compose.yml

gen:
	protoc --go_out=plugins=grpc:. ./proto/*.proto
	cp ./proto/*.go ./gateway/
	cp ./proto/*.go ./resource/

up:
	@COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose up -d --build

down:
	@COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose down -v

ps:
	@COMPOSE_FILE=$(COMPOSE_FILE) docker-compose ps

register:
	@docker exec sm-consul-client /bin/sh -c "echo '{\"service\": {\"name\": \"gateway\", \"tags\": [\"go\"], \"port\": 3000}}' >> /consul/config/gateway.json"

reload:
	@COMPOSE_FILE=$(COMPOSE_FILE) docker-compose exec consul-client consul reload

members:
	@COMPOSE_FILE=$(COMPOSE_FILE) docker-compose exec consul-client consul members

consul-up:
	@docker-compose -f consul/docker-compose.yml up

consul-down:
	@docker-compose -f consul/docker-compose.yml down -v

consul-members:
	@docker-compose -f consul/docker-compose.yml exec consul-client consul members
