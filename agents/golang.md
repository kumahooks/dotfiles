---
description: Load Golang specific skill
agent: build
---

# Go
You will internalize the rules below. Then, you will pull the current tree of the project we're at (depth at most 4), and internalize the repository's structuredYou will not read any file for now, except the `*.md`s in the root of the project, enough to contextualize yourself with it.

## Hard Standard

Treat idiomatic Go as the default model.

- Follow `gofmt` as the hard formatting standard.
- Follow the Go language specification for language semantics.
- Follow Effective Go for core idioms, but remember it predates modules and generics.
- Follow Go Code Review Comments for review-level style.
- Follow Go Modules for dependency management.
- Follow Go 1 compatibility rules for public APIs.
- Local project style wins when contributing to an existing Go project.

Go is strongest when code is boring, explicit, and easy to delete. Prefer the standard library and small packages before frameworks.

## Design Rules

- Keep packages small and named after what they provide.
- Keep package APIs narrow. Export only what callers need.
- Keep constructors simple. Return concrete types unless an interface is required by callers.
- Define interfaces at the consumer boundary, not next to the implementation by habit.
- Use interfaces only when there are multiple real implementations, a test seam that matters, or an external contract.
- Use generics only when they remove real duplication across types.
- Prefer plain structs, functions, and methods over framework patterns.
- Prefer composition over inheritance-like embedding.
- Avoid package-level mutable state. If process-wide state is required, make it explicit.
- Avoid `init` except for registration required by an imported package or immutable setup.
- Avoid `panic` outside programmer errors, impossible states, and process startup failure.
- Use descriptive names. Use short names only for tiny scopes and established Go conventions such as `err`, `ctx`, and index variables.
- Do not create `pkg`, `internal`, `cmd`, or `api` directories by template. Add them only when the project needs those boundaries.
- Keep `main` thin. Put business logic in ordinary packages.
- Prefer `net/http`, `database/sql`, `encoding/json`, `log/slog`, and other standard packages before dependencies.

## Memory

- Let values be values. Do not use pointers only to avoid copying small structs.
- Use pointers when mutation, identity, large copies, or optional state require them.
- Make zero values useful when practical.
- Do not store `context.Context` in structs.
- Do not retain slices or byte buffers from callers unless ownership is explicit.
- Copy maps and slices at package boundaries when mutation would surprise callers.
- Preallocate slices when size is known or cheaply bounded.
- Avoid object pools until profiling proves allocation pressure matters.
- Avoid `unsafe` unless interacting with operating system, runtime, serialization, or performance-critical code that cannot be solved safely.
- Treat goroutine leaks as memory leaks.

## Error Handling

- Return errors explicitly. Do not hide failure in logs, booleans, or zero values.
- Add context with `fmt.Errorf("[package:Function] operation: %w", err)`.
- Preserve error identity with `%w` when callers may inspect it.
- Use sentinel errors or typed errors only when callers need branching.
- Keep error strings lowercase and without trailing punctuation unless the project requires otherwise.
- Do not log and return the same error unless the boundary owns logging.
- Do not use `panic` for ordinary invalid input, network failure, filesystem failure, or dependency failure.
- Prefer early returns over nested control flow.
- Close resources with `defer` when lifetime is function-scoped.

## Concurrency

- Start goroutines only when their lifetime and cancellation path are clear.
- Pass `context.Context` as the first parameter for request-scoped, cancellable, or remote operations.
- Use `errgroup` or an equivalent local pattern when multiple goroutines share one operation.
- Use channels for ownership transfer, signaling, and pipeline boundaries.
- Use mutexes for shared memory. Do not force channels where a mutex is simpler.
- Bound worker pools, queues, fan-out, retries, and background work.
- Close channels from the sending side.
- Do not leak timers, tickers, response bodies, rows, files, or goroutines.
- Treat data races as correctness bugs.

## Security

- Treat all external input as hostile until parsed and validated.
- Validate sizes before allocation, decode, buffering, and recursion.
- Use `crypto/rand` for security randomness.
- Do not use `math/rand` for tokens, secrets, IDs, keys, or nonces.
- Do not disable TLS verification except in local test code.
- Avoid string concatenation for SQL, shell commands, HTML, and URLs.
- Prefer `database/sql` placeholders, `html/template`, `url.URL`, and structured encoders.
- Pin module major versions intentionally.
- Do not vendor or replace modules without a project-level reason.
- Prefer `go vet`, Staticcheck, `govulncheck`, fuzzing, and race detection in project tooling. User runs tests.

## Reference Projects

Use these projects as domain references. Match the target project's local style before copying any pattern.

- Go standard library and runtime: package design, concurrency primitives, networking, encoding, documentation style.
  - https://pkg.go.dev/std
  - https://github.com/golang/go
- Go subrepositories: extended standard ecosystem, tools, crypto, sync, syscalls, language tooling.
  - https://github.com/golang
  - https://pkg.go.dev/golang.org/x
- Kubernetes: orchestration, API machinery, controllers, client libraries, large-scale Go project structure.
  - https://github.com/kubernetes/kubernetes
  - https://github.com/kubernetes/client-go
- etcd: distributed key-value storage, Raft, reliability, client/server APIs.
  - https://github.com/etcd-io/etcd
  - https://etcd.io/
- containerd: container runtime architecture, plugin boundaries, daemon APIs.
  - https://containerd.io/
  - https://github.com/containerd/containerd
- Moby: container engine components, modular architecture, long-lived infrastructure code.
  - https://mobyproject.org/
  - https://github.com/moby/moby
- Prometheus: metrics, time-series storage, service discovery, operational reliability.
  - https://prometheus.io/
  - https://github.com/prometheus/prometheus
- Grafana Loki: log aggregation, multi-tenant services, label-based storage design.
  - https://grafana.com/oss/loki/
  - https://github.com/grafana/loki
- NATS Server: messaging, protocol servers, high-performance concurrent networking.
  - https://nats.io/
  - https://github.com/nats-io/nats-server
- gRPC-Go: RPC transport, generated APIs, interceptors, HTTP/2 services.
  - https://grpc.io/docs/languages/go/
  - https://github.com/grpc/grpc-go
- Caddy: HTTP server design, TLS automation, modules, clean configuration surfaces.
  - https://caddyserver.com/
  - https://github.com/caddyserver/caddy
- chi: small idiomatic HTTP routing, standard `net/http` compatibility, composable middleware.
  - https://github.com/go-chi/chi
- Gin: high-performance web framework. Use as a framework reference, not as the default Go style.
  - https://gin-gonic.com/
  - https://github.com/gin-gonic/gin
- Cobra: command-line applications, subcommands, flags, shell completion.
  - https://cobra.dev/
  - https://github.com/spf13/cobra
- Hugo: static site generation, CLI design, content pipelines, fast single-binary tooling.
  - https://gohugo.io/
  - https://github.com/gohugoio/hugo
- Terraform: infrastructure as code, graph execution, plugin architecture. Mind its source-available license.
  - https://developer.hashicorp.com/terraform
  - https://github.com/hashicorp/terraform
- OpenTofu: open-source infrastructure as code, Terraform-compatible workflows.
  - https://opentofu.org/
  - https://github.com/opentofu/opentofu
- CockroachDB: distributed SQL database, storage engines, concurrency, correctness-oriented engineering.
  - https://www.cockroachlabs.com/
  - https://github.com/cockroachdb/cockroach
- MinIO: S3-compatible object storage, data paths, server performance. Mind its AGPL license.
  - https://min.io/
  - https://github.com/minio/minio
- Gitea: self-hosted Git service, web application structure, Git integration, CI/CD.
  - https://gitea.com/
  - https://github.com/go-gitea/gitea
- sqlc: type-safe SQL code generation, database boundaries without ORM abstraction.
  - https://sqlc.dev/
  - https://github.com/sqlc-dev/sqlc
- modernc.org/sqlite: CGO-free SQLite driver for `database/sql`.
  - https://pkg.go.dev/modernc.org/sqlite
- golang-migrate: database migrations, CLI plus library API, driver boundaries.
  - https://github.com/golang-migrate/migrate
- zap: structured logging, performance-sensitive API design, allocation-aware logging.
  - https://github.com/uber-go/zap

## Frameworks

Prefer the standard library for new Go code. Use these when local project context, team familiarity, or domain complexity justifies the dependency.

- chi: minimal HTTP routing that keeps `net/http` compatibility.
  - https://github.com/go-chi/chi
- Gin: high-performance REST APIs and web services. Use as a framework reference, not as default Go architecture.
  - https://gin-gonic.com/
  - https://github.com/gin-gonic/gin
- Echo: minimalist web framework with routing, middleware, binding, and centralized HTTP errors.
  - https://echo.labstack.com/
  - https://github.com/labstack/echo
- Fiber: Express-style web framework on `fasthttp`. Use when that ecosystem fit matters. Remember it is not built on `net/http`.
  - https://gofiber.io/
  - https://github.com/gofiber/fiber
- gRPC-Go: Protobuf RPC, streaming, HTTP/2, generated service APIs.
  - https://grpc.io/docs/languages/go/
  - https://github.com/grpc/grpc-go
- Connect-Go: Protobuf RPC over HTTP with simpler client and server surfaces.
  - https://connectrpc.com/
  - https://github.com/connectrpc/connect-go
- Cobra: command-line applications with subcommands, flags, help, completion, and man pages.
  - https://cobra.dev/
  - https://github.com/spf13/cobra
- Viper: configuration loading for applications that need layered config files, environment variables, and defaults.
  - https://github.com/spf13/viper
- Bubble Tea: terminal user interfaces using The Elm Architecture.
  - https://github.com/charmbracelet/bubbletea
- Fyne: cross-platform GUI applications written in Go.
  - https://fyne.io/
  - https://github.com/fyne-io/fyne
- GORM: full ORM for teams that deliberately choose ORM behavior. Prefer `database/sql`, `sqlc`, or explicit SQL when control matters.
  - https://gorm.io/
  - https://github.com/go-gorm/gorm
- Ent: schema-first entity framework and code generation for graph-shaped domain models.
  - https://entgo.io/
  - https://github.com/ent/ent
- sqlc: generated type-safe SQL. Prefer this over an ORM when SQL is part of the design.
  - https://sqlc.dev/
  - https://github.com/sqlc-dev/sqlc
- modernc.org/sqlite: SQLite through `database/sql` without CGO.
  - https://pkg.go.dev/modernc.org/sqlite
- golang-migrate: database migrations as CLI and Go library.
  - https://github.com/golang-migrate/migrate
- Fx: dependency injection and application lifecycle for large service graphs. Do not use it for small applications.
  - https://uber-go.github.io/fx/
  - https://github.com/uber-go/fx
- Go kit: microservice toolkit and architectural reference. Use the patterns selectively.
  - https://gokit.io/
  - https://github.com/go-kit/kit
- OpenTelemetry Go: tracing, metrics, logs, and instrumentation APIs.
  - https://opentelemetry.io/docs/languages/go/
  - https://github.com/open-telemetry/opentelemetry-go
- go-playground/validator: struct and field validation. Use when tag-based validation is acceptable.
  - https://github.com/go-playground/validator
- Testify: testing assertions and mocks that work with the standard `testing` package.
  - https://github.com/stretchr/testify

## Standards And Documentation

- Go language specification: https://go.dev/ref/spec
- Effective Go: https://go.dev/doc/effective_go
- Go Code Review Comments: https://go.dev/wiki/CodeReviewComments
- Go Modules Reference: https://go.dev/ref/mod
- How to Write Go Code: https://go.dev/doc/code
- Go 1 compatibility: https://go.dev/doc/go1compat
- Go Doc Comments: https://go.dev/doc/comment
- Standard library: https://pkg.go.dev/std
- Go blog, errors are values: https://go.dev/blog/errors-are-values
- Go blog, pipelines and cancellation: https://go.dev/blog/pipelines
- Go blog, context: https://go.dev/blog/context
- Go vulnerability management: https://go.dev/doc/security/vuln/
- Google Go Style Guide: https://google.github.io/styleguide/go/
- Uber Go Style Guide: https://github.com/uber-go/guide
- Staticcheck: https://staticcheck.dev/docs/

## Review Checklist

- Is the code formatted by `gofmt`?
- Does the code follow local style, or idiomatic Go when no local style exists?
- Are package boundaries small, clear, and named after behavior?
- Are exported APIs minimal and documented when public?
- Are interfaces defined only where they are consumed or required?
- Are errors wrapped with useful operation context?
- Is logging done at the right boundary?
- Are goroutine lifetimes, context cancellation, and channel ownership explicit?
- Are worker counts, queues, retries, and input sizes bounded?
- Are maps, slices, and pointers safe across API boundaries?
- Is the standard library enough before adding a dependency?
- Is the implementation simpler than an equivalent framework, generic helper, or abstraction?
