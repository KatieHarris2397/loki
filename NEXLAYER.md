# Nexlayer — loki

<!-- nexlayer:meta version=1 analyzed=2026-07-08T17:48:39Z repo=https://github.com/KatieHarris2397/loki branch=nexlayer -->

> **For AI agents (Claude Code, Cursor, Gemini CLI, Copilot):**
> This file is the **project context** for this Nexlayer deployment — tech stack, env vars, secrets, live URL.
> For full platform detail (nexlayer.yaml schema, Dockerfile rules, CI/CD, task recipes) read **`nexlayer.skills`** in this repo.
>
> **Critical rules (full detail in `nexlayer.skills`):**
> - Inter-pod refs: `${podName:port}` only — never `localhost` or bare hostnames
> - Docker Hub images: prefix with `mirror.gcr.io/library/` — bare tags fail on the cluster
> - Secrets: set in the Nexlayer dashboard — never commit to `nexlayer.yaml` or Dockerfile
>
> **This file:** `agent-managed` sections update automatically. `user-editable` sections (Local Development Setup, Nexlayer Deployment Plan, Build Notes) are yours — preserved across re-analysis.

## Project Summary
<!-- nexlayer:section agent-managed=project_summary -->
Loki is a horizontally-scalable, multi-tenant log aggregation system inspired by Prometheus. It stores compressed, unstructured logs and indexes metadata labels rather than full-text content to ensure cost-effectiveness and operational simplicity.
<!-- nexlayer:end -->

## Technology Stack
<!-- nexlayer:section agent-managed=tech_stack -->
| Name | Kind | Version | Detected From |
|------|------|---------|---------------|
| Go | language | 1.26.4 | go.mod |
| Loki | infra | v3 | go.mod, README.md |
| Nix | build | latest | flake.nix |
<!-- nexlayer:end -->

## Repository Structure
<!-- nexlayer:section agent-managed=structure_map -->
- cmd/ — Main entry points for Loki binaries
- pkg/ — Core business logic and internal library packages
- operator/ — Kubernetes operator logic for Loki deployment
- clients/ — Client libraries for interacting with Loki
- integration/ — Integration tests for validating system behavior
- loki-build-image/ — Dockerfile and configuration for building Loki images
<!-- nexlayer:end -->

## External Services Required
<!-- nexlayer:section agent-managed=external_deps -->
Services that must be configured separately (not deployed by Nexlayer):

- Object Storage (S3, GCS, Azure Blob, etc.) for log chunks
- KV Store (etcd, Consul) for index and ring management
- Grafana (for visualization)
<!-- nexlayer:end -->

## Local Development Setup
<!-- nexlayer:section user-editable=local_setup -->
### Prerequisites

- Go >= 1.26.4
- Make
- Nix (optional, for flake-based environment)

### Environment variables

Copy `.env.example` to `.env.local` and fill in:

```
LOKI_CONFIG_FILE=configs/local-config.yaml
```

### Steps

1. `make build` — Compile the Loki binary
2. `./loki -config.file=configs/local-config.yaml` — Start Loki in single-binary mode

<!-- nexlayer:end -->

## Nexlayer Setup
<!-- nexlayer:section agent-managed=nexlayer_setup -->
### Pod Environment Variables

| Pod | Variable | Value | Kind |
|-----|----------|-------|------|
| `loki` | `LOKI_CONFIG_FILE` | `"/etc/loki/config.yaml"` | plain |
| `loki` | `LOKI_TARGET` | `"all"` | plain |

### nexlayer.yaml

```yaml
application:
  name: loki
  pods:
    - name: loki
      image: "registry.nexlayer.io/user_01kna6j8vrcfj9q0wjtq5qsq3n/loki:9f42d82-fix4"
      path: /
      servicePorts:
        - 3100
      vars:
        LOKI_CONFIG_FILE: "/etc/loki/config.yaml"
        LOKI_TARGET: "all"
```
<!-- nexlayer:end -->

## Nexlayer Deployment Plan
<!-- nexlayer:section user-editable=deployment_plan -->
### Pod Topology

| Pod | Image | Port | Role |
|-----|-------|------|------|
| loki-distributor | mirror.gcr.io/library/golang:1.26-alpine | 3100 | web |
| loki-ingester | mirror.gcr.io/library/golang:1.26-alpine | 3100 | worker |
| loki-querier | mirror.gcr.io/library/golang:1.26-alpine | 3100 | web |
| etcd | mirror.gcr.io/library/etcd:3.5-alpine | 2379 | database |

### Deployment notes

- Loki components communicate via the ring mechanism using etcd.pod:2379
- Each Loki microservice (distributor, ingester, querier) is deployed as a separate pod per Nexlayer rule 1
- Log storage requires an external object store or a separate MinIO pod (not listed in core topology but required for persistence)

<!-- nexlayer:end -->

## Build Notes
<!-- nexlayer:section user-editable=build_notes -->
<!-- Add notes for future builds here — preserved across re-analysis -->
<!-- nexlayer:end -->

## Nexlayer Configuration
<!-- nexlayer:section agent-managed=nexlayer_config -->
**Last deployed:** 2026-07-08T18:11:38Z  
**Live URL:** https://kitbear-studio-loki.cloud.nexlayer.ai  
**Runtime:**  · **Port:** auto-detected  
**Deploy branch:** nexlayer  

```yaml
application:
  name: loki
  pods:
    - name: loki
      image: "registry.nexlayer.io/user_01kna6j8vrcfj9q0wjtq5qsq3n/loki:9f42d82-fix4"
      path: /
      servicePorts:
        - 3100
      vars:
        LOKI_CONFIG_FILE: "/etc/loki/config.yaml"
        LOKI_TARGET: "all"
```
<!-- nexlayer:end -->

## Build History
<!-- nexlayer:section agent-managed=build_history -->
| Date | Status | Notes |
|------|--------|-------|
| 2026-07-08T17:48:39Z | analyzed | initial repo analysis |
| 2026-07-08T18:11:38Z | success | deployed https://kitbear-studio-loki.cloud.nexlayer.ai |
<!-- nexlayer:end -->

