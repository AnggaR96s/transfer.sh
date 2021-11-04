# Default to Go 1.17
ARG GO_VERSION=1.17
FROM golang:${GO_VERSION}-alpine as build

# Necessary to run 'go get' and to compile the linked binary
RUN apk add git musl-dev

ADD . /go/src/github.com/AnggaR96s/transfer.sh

WORKDIR /go/src/github.com/AnggaR96s/transfer.sh

ENV GO111MODULE=on

# build & install server
RUN CGO_ENABLED=0 go build -tags netgo -ldflags "-X github.com/AnggaR96s/transfer.sh/cmd.Version=$(git describe --tags) -a -s -w -extldflags '-static'" -o /go/bin/transfersh

FROM scratch AS final
LABEL maintainer="Andrea Spacca <andrea.spacca@gmail.com>"

COPY --from=build  /go/bin/transfersh /go/bin/transfersh
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

ENTRYPOINT ["/go/bin/transfersh", "--listener", ":80", "--provider", "local", "--basedir", "/tmp/", "max-upload-size", "100000000"]

EXPOSE 80
