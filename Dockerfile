ARG BUILDPLATFORM="linux/amd64"
ARG BUILDERIMAGE="golang:1.18"
ARG BASEIMAGE="knative-dev-registry.cn-hangzhou.cr.aliyuncs.com/distroless/static:nonroot"

FROM --platform=$BUILDPLATFORM $BUILDERIMAGE as builder

ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT=""
ARG LDFLAGS

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH} \
    GOARM=${TARGETVARIANT}

WORKDIR /go/src/github.com/developer-guy/cosign-gatekeeper-provider

COPY go.mod go.sum *.go ./

# Too slow to download the module dependencies
COPY vendor vendor
RUN go build -mod=vendor -o provider provider.go

FROM $BASEIMAGE

WORKDIR /

COPY --from=builder /go/src/github.com/developer-guy/cosign-gatekeeper-provider .

USER 65532:65532

ENTRYPOINT ["/provider"]
