# gcsfileserver

Want to serve non-public files off Google Cloud Storage over https to a select group of people?
Then Google Cloud Storage File Server may be for you.

- Uses App Engine to keep costs very low (as long as your request volume is low, which it usually is when serving files to a small group of people)
- Uses Google Cloud Identity Aware Proxy, which lets you specify which Google Apps or gmail emails should have access
- HTTPS provided by App Engine for no added cost
- If you have no requests in a month, your cost is probably $0.00 (excluding Google Cloud Storage costs to store your files)
- Your GCS bucket is not open to the public
- GCS files are read-only through gcsfileserver

**Caveat:** not intended for very high request rates.  That use case would require implementing caching of some objects to reduce the network round trips to GCS.

**Note:** This relies on Go 1.11. If you want to use a newer version of Go, you need to pull out all the appengine library usage and replace it with the libraries Google AppEngine supports for Go 1.12+ - https://cloud.google.com/appengine/docs/standard/go/go-differences

## Setup

1. Set up IAP
2. Optional, set up custom domain in App Engine > Settings.  This gets you free SSL to a custom domain name.
3. Create a app.yaml and specify the GCS bucket you want to serve files from:
```yaml
runtime: go114
main: ./
handlers:
- url: /.*
  script: auto

env_variables:
  BUCKET: "rchapman.appspot.com"
```

4. Make sure your bucket is created and is not publicly accessible.
5. Find your app engine service account in Google Cloud Console > IAM
   For this example, I'll use mine, rchapman@appspot.gserviceaccount.com
6. In the Google Cloud Console, go to your GCS bucket and give your app engine service account (rchapman@appspot.gserviceaccount.com in the previous example) the roles "Storage Object Viewer" and "Storage Legacy Bucket Reader"
7. Create main.go in the same directory as your app.yaml file:
```go
package main

import (
	"log"
	"net/http"
	"os"

	"github.com/rchapman/gcsfileserver/server"
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
```

8. Run go get ./... from the root of the project
9. Deploy the app with `gcloud app deploy --project=YOUR_GCP_PROJECT` (for example `gcloud app deploy --project=rchapman`)
10. Open web browser with `gcloud app browse --project=YOUR_GCP_PROJECT`