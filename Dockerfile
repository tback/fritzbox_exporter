# syntax=docker/dockerfile:1

# Build Image
FROM golang:1.25.5-alpine3.23 AS builder

WORKDIR /usr/src/app

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
COPY go.mod go.sum ./
RUN go mod download

RUN mkdir -p /usr/local/bin/app

COPY . .
RUN CGO_ENABLED=0 go build -ldflags '-extldflags "-static"' -o /usr/local/bin/app -v 

# Runtime Image
FROM scratch

ARG REPO=tback/fritzbox_exporter

LABEL org.opencontainers.image.source https://github.com/${REPO}

ENV USERNAME username
ENV PASSWORD password
ENV GATEWAY_URL http://fritz.box:49000
ENV GATEWAY_LUAURL http://fritz.box
ENV LISTEN_ADDRESS 0.0.0.0:9042

COPY --from=builder /usr/local/bin/app /
COPY metrics.json metrics-lua.json /

USER nobody

EXPOSE 9042

ENTRYPOINT [ "/fritzbox_exporter" ]
