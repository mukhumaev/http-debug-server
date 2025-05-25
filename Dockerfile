FROM golang:1.20 AS builder

WORKDIR /app

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build http-debug-server.go 

FROM scratch

LABEL \
    org.opencontainers.image.title="HTTP Debug Server" \
    org.opencontainers.image.description="A simple HTTP debug server written in Go that logs incoming requests and returns request details in JSON format." \
    org.opencontainers.image.version="1.0.0" \
    org.opencontainers.image.revision="latest" \
    org.opencontainers.image.created="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    org.opencontainers.image.authors="$(git config --local user.name) <$(git config --local user.email)>" \
    org.opencontainers.image.licenses="GPL-3.0"

COPY --from=builder /app/http-debug-server /http-debug-server

EXPOSE 5000

ENTRYPOINT ["/http-debug-server"]

