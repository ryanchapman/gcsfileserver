FROM golang:1.20-alpine as builder

WORKDIR /go/src/jus.tw.cx/gcsfileserver
ADD . /go/src/jus.tw.cx/gcsfileserver
RUN go build -o gcsfileserver .

FROM golang:1.20-alpine
COPY --from=builder /go/src/jus.tw.cx/gcsfileserver/gcsfileserver /usr/local/bin/gcsfileserver
ENTRYPOINT [ "/usr/local/bin/gcsfileserver" ]
