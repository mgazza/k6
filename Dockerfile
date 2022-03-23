FROM golang:1.17-alpine as builder
WORKDIR $GOPATH/src/go.k6.io/k6
RUN apk --no-cache add git
COPY go.mod go.sum ./
RUN go mod download
ADD . .
RUN CGO_ENABLED=0 go install -a -trimpath -ldflags "-s -w -X go.k6.io/k6/lib/consts.VersionDetails=$(date -u +"%FT%T%z")/$(git describe --always --long --dirty)"

FROM gcr.io/distroless/static:nonroot 
COPY --from=builder /go/bin/k6 /usr/bin/k6

WORKDIR /home/k6
ENTRYPOINT ["k6"]
