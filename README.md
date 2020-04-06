# go-service-mesh

> Service Mesh Experiment

## Structure

1. `Gateway`: is a http server which receives http requests, and sends tcp requests to another gRPC backend via HAProxy.
2. `Resource`: is a gRPC server which consumes unary requests from gRPC client.
3. `HAProxy`: sits between Gateway and Resource

```bash
.
├── Makefile
├── README.md
├── docker-compose.yml
├── gateway
│   ├── Dockerfile
│   ├── cmd
│   │   └── main.go
│   ├── go.mod
│   ├── go.sum
│   └── resource.pb.go
├── haproxy
│   └── haproxy.cfg
├── proto
│   ├── resource.pb.go
│   └── resource.proto
└── resource
    ├── Dockerfile
    ├── cmd
    │   └── main.go
    ├── go.mod
    ├── go.sum
    └── resource.pb.go
```

## Usage

### Start all services

```bash
make up
```

### Make API requests

```bash
curl --location --request GET 'http://localhost/gateway?id=3'
{"data":{},"message":"Not Found"}

curl --location --request GET 'http://localhost/gateway?id=1'
{"data":{"id":"1","name":"iPhone XS"},"message":"OK"}
```

### Stop and remove all services

```bash
make down
```

## References

1. <https://www.haproxy.com/blog/haproxy-1-9-2-adds-grpc-support>
2. <https://github.com/haproxytechblog/haproxy-grpc-sample>