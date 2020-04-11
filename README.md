# go-service-mesh

> This repository contains a set of practical use cases in distributed system, microservices, service mesh.

## Structure

- Backend:
    - Gateway: an API gateway using Restful.
    - Resource: a service provides products using gRPC/Protobuf.
- Caching: Redis.
- Database: MariaDB.
- Load Balancing: HAProxy / Nginx.
- Logging: ELK (Elasticsearch, Logstash, Kibana).
- Service Discovery: Consul.
- Key/Value Storage: Vault.

## Usage

### Deploy services

```bash
make up
```

### List services

```bash
make ps
```

### Sample requests

```bash
curl -X GET 'http://localhost/gateway?id=3'
{"data":{},"message":"Not Found"}

curl -X GET 'http://localhost/gateway?id=1'
{"data":{"id":"1","name":"iPhone XS"},"message":"OK"}

curl -X GET 'http://localhost/gateway/health'
{"data":{},"message":"OK"}
```

### Destroy services

```bash
make down
```

## TODO

- [x] Setup basic template.
- [x] Configure h2 for haproxy from rest to grpc service.
- [x] Setup Consul server and client.
- [x] Configure health check in Consul.
- [ ] Configure service discovery using Consul.
- [ ] Experiment Consul Template.
- [ ] Deploy services using Nomad through web ui.
- [ ] Traffic routing and splitting.
- [ ] Failover testing.
- [ ] Architect to multiple zones.
