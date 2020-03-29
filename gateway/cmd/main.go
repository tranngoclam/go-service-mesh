package main

import (
	"context"
	"encoding/json"
	res "github.com/tranngoclam/go-grpc-haproxy/gateway"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"log"
	"net/http"
	"os"
)

var resourceClient res.ResourceServiceClient
var resourceAddress = os.Getenv("RESOURCE_ADDRESS")

func resource(w http.ResponseWriter, r *http.Request) {
	// parse parameter
	id := r.URL.Query().Get("id")

	// build grpc request
	request := &res.ResourceID{
		Value: id,
	}

	// invoke grpc method
	response, err := resourceClient.GetResource(context.Background(), request)
	if err != nil {
		log.Println(err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	// return response
	data := map[string]interface{}{"id": response.Id, "name": response.Name}
	bytes, err := json.Marshal(data)
	if err != nil {
		log.Println(err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(bytes)
}

func main() {
	creds, err := credentials.NewClientTLSFromFile("haproxy.crt", "")
	if err != nil {
		panic(err)
	}

	cc, err := grpc.Dial(resourceAddress, grpc.WithTransportCredentials(creds))
	if err != nil {
		panic(err)
	}
	defer func() {
		err := cc.Close()
		if err != nil {
			log.Fatal(err)
		}
	}()

	resourceClient = res.NewResourceServiceClient(cc)

	http.HandleFunc("/", resource)

	err = http.ListenAndServe(":3000", nil)
	if err != nil {
		panic(err)
	}
}
