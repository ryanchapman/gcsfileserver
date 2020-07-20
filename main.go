package main

import (
	"net/http"

	"github.com/srlightbody/gcsfileserver/server"
	"google.golang.org/appengine"
)

func main() {
	s := gcsfileserver.Server{
		DirListPageSize: 100,
	}
	http.Handle("/", &s)
	appengine.Main()
}
