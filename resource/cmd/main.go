package main

import (
	"context"
	res "github.com/tranngoclam/go-grpc-haproxy/resource"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/status"
	"log"
	"net"
)

var resources = []res.Resource{
	{Id: "1", Name: "iPhone XS"},
	{Id: "2", Name: "Macbook Pro"},
}

type server struct {
}

func (*server) GetResource(_ context.Context, req *res.ResourceID) (*res.Resource, error) {
	resourceID := req.Value
	for _, resource := range resources {
		if resource.Id == resourceID {
			return &resource, nil
		}
	}

	return nil, status.Error(codes.NotFound, "resource not found")
}

func main() {
	address := ":3002"

	listener, err := net.Listen("tcp", address)
	if err != nil {
		panic(err)
	}

	creds, err := credentials.NewServerTLSFromFile("server.crt", "server.key")
	if err != nil {
		log.Fatalf("Failed to load TLS keys")
	}

	s := grpc.NewServer(grpc.Creds(creds))
	defer s.GracefulStop()

	res.RegisterResourceServiceServer(s, &server{})

	err = s.Serve(listener)
	if err != nil {
		panic(err)
	}
}
