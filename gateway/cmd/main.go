package main

import (
	"context"
	"encoding/json"
	res "github.com/tranngoclam/go-grpc-haproxy/gateway"
	"google.golang.org/grpc"
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
		log.Printf("get resource failed %+v", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	// return response
	data := map[string]interface{}{"id": response.Id, "name": response.Name}
	bytes, _ := json.Marshal(data)

	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(bytes)
}

func main() {
	//creds, err := credentials.NewClientTLSFromFile("haproxy.crt", "")
	//if err != nil {
	//	panic(err)
	//}

	//cc, err := grpc.Dial(resourceAddress, grpc.WithTransportCredentials(creds))
	cc, err := grpc.Dial(resourceAddress, grpc.WithInsecure())
	if err != nil {
		panic(err)
	}
	log.Printf("dial %s successfully", resourceAddress)
	//defer func() {
	//	err := cc.Close()
	//	if err != nil {
	//		log.Fatal(err)
	//	}
	//}()

	resourceClient = res.NewResourceServiceClient(cc)

	//time.Sleep(10 * time.Second)
	//response, err := resourceClient.GetResource(context.Background(), &res.ResourceID{Value: "1"})
	//if err != nil {
	//	panic(err)
	//}
	//log.Println(response.Name)

	http.HandleFunc("/", resource)

	err = http.ListenAndServe(":3000", nil)
	if err != nil {
		panic(err)
	}
}
