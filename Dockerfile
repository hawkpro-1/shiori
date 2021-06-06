FROM golang:1.16.4-alpine AS builder

WORKDIR /src

RUN adduser --disabled-password -u 1000 -g 1000 shiori

RUN apk --update add ca-certificates musl-dev gcc

COPY go.mod go.sum ./

RUN go env -w GO111MODULE=on && go env -w  GOPROXY=https://goproxy.io,direct

COPY . .

RUN go generate ./... && CGO_ENABLED=1 go build -a -ldflags '-linkmode external -extldflags "-static" -s -w' .




FROM alpine

COPY --from=builder /etc/passwd /etc/passwd

COPY --from=builder /src/shiori /usr/local/bin/

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

USER shiori

ENV SHIORI_DIR /srv/shiori/

EXPOSE 80

CMD ["/usr/local/bin/shiori", "serve"]
