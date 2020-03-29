package main

import (
	"context"
	res "github.com/tranngoclam/go-grpc-haproxy/resource"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"log"
	"net"
)

type server struct {
	resources []*res.Resource
}

func newServer() *server {
	return &server{
		resources: []*res.Resource{
			{Id: "1", Name: "iPhone XS"},
			{Id: "2", Name: "Macbook Pro"},
		}}
}

func (s *server) GetResource(_ context.Context, request *res.ResourceID) (*res.Resource, error) {
	log.Println(request)

	resourceID := request.GetValue()
	for _, resource := range s.resources {
		if resource.Id == resourceID {
			return resource, nil
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
	log.Printf("resource server is listening on %s", address)

	s := grpc.NewServer()

	res.RegisterResourceServiceServer(s, newServer())

	err = s.Serve(listener)
	if err != nil {
		panic(err)
	}
}
