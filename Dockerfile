FROM mirror.gcr.io/library/golang:1.26-alpine AS builder
RUN apk add --no-cache gcc musl-dev
WORKDIR /src
# Copy everything first because this repo uses local replace directives in go.mod
COPY . .
# Fix the non-standard 'ignore' directive in go.mod
RUN sed -i '/^ignore /d' go.mod
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /app/loki ./cmd/loki

FROM mirror.gcr.io/library/alpine:3.20
RUN apk add --no-cache ca-certificates tini
COPY --from=builder /app/loki /app/loki
# Copy examples to ensure we have a base config
COPY --from=builder /src/examples /etc/loki/examples
# Ensure the config file exists; use the local-config as a base
RUN if [ -f /etc/loki/examples/loki-local-config.yaml ]; then cp /etc/loki/examples/loki-local-config.yaml /etc/loki/config.yaml; else echo "# Default Config" > /etc/loki/config.yaml; fi

EXPOSE 3100
# Loki v3 requires a valid config and often crashes if it cannot find its storage/config
# We use -target=all for the single-binary mode to ensure it starts as a monolithic instance
ENTRYPOINT ["/sbin/tini", "--", "/bin/sh", "-c", "/app/loki -config.file=/etc/loki/config.yaml -target=all"]