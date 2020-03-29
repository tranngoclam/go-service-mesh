package main

import (
	"context"
	"encoding/json"
	res "github.com/tranngoclam/go-grpc-haproxy/gateway"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"log"
	"net/http"
	"os"
)

var resourceClient res.ResourceServiceClient

func resource(w http.ResponseWriter, r *http.Request) {
	id := r.URL.Query().Get("id")

	request := &res.ResourceID{Value: id}

	response, err := resourceClient.GetResource(context.Background(), request)
	if err != nil {
		if status.Code(err) == codes.NotFound {
			sendJSON(w, http.StatusNotFound, map[string]interface{}{})
			return
		}

		log.Printf("get resource failed %+v", err)
		sendJSON(w, http.StatusInternalServerError, map[string]interface{}{})
		return
	}

	resource := map[string]interface{}{"id": response.Id, "name": response.Name}
	sendJSON(w, http.StatusOK, resource)
}

func sendJSON(w http.ResponseWriter, status int, data map[string]interface{}) {
	body := map[string]interface{}{
		"message": http.StatusText(status),
		"data":    data,
	}
	bytes, _ := json.Marshal(body)
	w.WriteHeader(status)
	_, _ = w.Write(bytes)
}

func main() {
	cc, err := grpc.Dial(os.Getenv("RESOURCE_ADDRESS"), grpc.WithInsecure())
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
