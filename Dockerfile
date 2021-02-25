ARG package=github.com/tback/fritzbox_exporter

FROM golang:1.15-alpine as build
ARG package

RUN apk add --no-cache git
RUN go get -v $package
WORKDIR $GOPATH/src/$package
RUN CGO_ENABLED=0 GOOS=linux go build -a --installsuffix cgo -o fritzbox_exporter .

FROM scratch
ARG package

WORKDIR /
COPY --from=build /go/src/$package/fritzbox_exporter .
EXPOSE 9133

ENTRYPOINT ["/fritzbox_exporter"]
CMD [""]

