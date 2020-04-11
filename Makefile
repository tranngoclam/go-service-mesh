COMPOSE_FILE := docker-compose.yml
COMPOSE_PROJECT_NAME := sm

fmt:
	@echo "==> Formatting source code..."
	@go fmt `go list ./... | grep -v /vendor/`
	@goimports -w `go list -f {{.Dir}} ./... | grep -v /vendor/`

lint:
	@echo "==> Running lint check..."
	@golangci-lint --config docker/.golangci.yml run
	@golint `go list ./... | grep -v /vendor/`

test:
	@echo "==> Running tests..."
	@go clean -testcache ./...
	@go test ./... -race -p 1

gen:
	@echo "==> Generating proto files"
	@protoc --go_out=plugins=grpc:. ./proto/*.proto
	@cp ./proto/*.go ./gateway/
	@cp ./proto/*.go ./resource/

up:
	@echo "==> Deploying services..."
	@COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) \
		COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose up -d --build

down:
	@echo "==> Destroy services..."
	@COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) \
		COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose down -v

ps:
	@COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) docker-compose ps

ips:
	@COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) docker-compose ps -q | xargs -n 1 docker inspect --format '{{ .Name }} {{range .NetworkSettings.Networks}} {{.IPAddress}}{{end}}' | sed "s#^/##";

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
