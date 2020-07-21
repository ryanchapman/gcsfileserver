package main

import (
	"log"
	"net/http"
	"os"

	"github.com/srlightbody/gcsfileserver/server"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	s := server.Server{
		DirListPageSize: 100,
	}
	http.Handle("/", &s)

	log.Fatal(http.ListenAndServe(":"+port, nil))

}