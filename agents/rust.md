---
description: Load Rust specific skill
agent: build
---

# Rust
You will internalize the rules below. Then, you will pull the current tree of the project we're at (depth at most 4), and internalize the repository's structure. You will not read any file for now, except the `*.md`s in the root of the project, enough to contextualize yourself with it.

Rust trades a garbage collector for the borrow checker. Ownership, borrowing, and lifetimes are the core mental model, and the compiler enforces it. There is no null, no unchecked exception, no data race in safe code, and no hidden allocation beyond what the type signatures show. Zero-cost abstractions mean generic and iterator code compiles down to what you would write by hand. Prefer the standard library and small, focused crates over frameworks. Make illegal states unrepresentable and let the type system carry the invariants. Editions let the language change without breaking old code, and Cargo is the build system, package manager, and test runner.

## Hard Standard

Treat idiomatic Rust as the default model.

- Follow `rustfmt` as the hard formatting standard. It implements the Rust Style Guide; do not hand-format against it.
- Follow The Rust Reference for language semantics. Follow the Rustonomicon for what `unsafe` actually promises.
- Follow the Rust API Guidelines for public API design.
- Run Clippy with warnings denied. Treat `clippy::pedantic` as advisory, not as law; fix what is right and `#[allow]` the rest with a reason.
- Pin the edition in `Cargo.toml` and declare a Minimum Supported Rust Version (`rust-version`). Do not rely on unstable features on stable.
- Cargo is the build, dependency, and test system. `Cargo.toml` is the manifest, `Cargo.lock` pins application builds.
- Local project style wins when contributing to an existing Rust project.

Rust is strongest when ownership and types make the wrong thing hard to write. Prefer the standard library and small crates before frameworks.

## Design Rules

- Keep crates and modules small and named after what they provide.
- Keep public APIs narrow. Export only what callers need. Everything public is a compatibility promise.
- Use newtypes to separate meaning from representation. A `UserId(u64)` is not a `u64`.
- Use enums to model alternatives and make illegal states unrepresentable. Replace boolean flag pairs and nullable sentinel fields with sum types.
- Define traits at the consumer boundary. Implement for concrete types; take `impl Trait` or generics for static dispatch.
- Use trait objects (`dyn Trait`) only when runtime polymorphism is genuinely required. Prefer static dispatch otherwise.
- Mark evolving public enums and structs `#[non_exhaustive]`. Seal traits meant to be implemented only internally.
- Derive only what is correct: `Debug` widely, `Clone`/`Copy` deliberately, `PartialEq`/`Eq`/`Hash`/`Ord` when they carry meaning.
- Prefer composition and small functions over inheritance-like layers. No premature abstraction. Three similar blocks before a generic helper or a macro.
- Avoid macros for anything a generic function or trait can express. Macros are for genuine syntax needs.
- Keep `main` thin. Put logic in library code and ordinary functions.
- Prefer descriptive names. Follow `snake_case` for functions, methods, variables, locals, and modules; `UpperCamelCase` for types and enum variants; `SCREAMING_SNAKE_CASE` for constants and statics.

## Ownership And Memory

- Borrow, do not clone. Add `#[derive(Clone)]` and `.clone()` calls only when they express real intent. `Copy` is for small, plain value types.
- Take the least powerful reference that works: prefer `&T` over `&mut T` over owned `T` in parameters. Accept `&str`, `&[T]`, and `impl AsRef<Path>` rather than `String`, `Vec<T>`, and `PathBuf`.
- Use `Cow<'_, T>` when a value is borrowed in the common case and owned only in some branches.
- Reach for `Rc`/`Arc` only when ownership is genuinely shared. Use `Weak` to break cycles. Shared ownership is a design signal, not a default.
- Use interior mutability (`Cell`, `RefCell`, `Mutex`, `RwLock`, atomics) only when mutation through a shared handle is required, and pick the cheapest one that is correct.
- Use `Box` for recursion, large values, and trait objects. Use `Vec`/`String`/`Box` for heap allocation; avoid manual allocators until profiling proves it.
- Use `Pin` only where a type contract requires address stability. Do not pin by habit.
- Let lifetimes be elided when the compiler infers them. Write them explicitly only when they clarify a real relationship.
- Prefer iterators and combinators over index loops. They are as fast and carry bounds safety.
- Reserve `unsafe` for genuine needs (FFI, proven performance, an abstraction that cannot be expressed safely). See below.

## Error Handling

- Return `Result<T, E>` for recoverable failure and `Option<T>` for absence. Do not hide failure in sentinel values, booleans, or logs.
- Propagate with `?` and `From` conversions. Add context at the boundary that can explain the operation.
- Use `thiserror` to define typed, matchable library errors. Use `anyhow` (or `eyre`) at application boundaries where callers only report and exit.
- Add the `[package:Function]` context prefix when constructing messages or configuring log/error context: `thiserror::Error`/`anyhow::Context` with `"[config:Load] read config: {0}"`.
- Preserve error identity: prefer typed errors over stringly-typed ones when callers must branch.
- Do not `unwrap` or `expect` on fallible input in library code. Use `expect` with a reason only at true invariants, or where the type system has already proven it.
- Mark fallible-but-ignorable APIs `#[must_use]`. Never discard a `Result` silently.
- Do not `panic!` for ordinary invalid input, I/O, network, or dependency failure. Reserve `panic!` for programmer errors and impossible states.
- Use `catch_unwind` only at boundaries that must not unwind (FFI, thread pools, servers). Do not use exceptions as control flow.
- Prefer early returns over nested control flow.

## Concurrency

- The type system proves data-race freedom: `Send` and `Sync` are the contracts. Reason about them; do not fight them with `unsafe impl`.
- Use `std::thread` for OS threads and scoped threads (`std::thread::scope`) when threads borrow stack data.
- Use channels (`std::sync::mpsc`, `crossbeam-channel`) for ownership transfer and pipeline boundaries. Use `Mutex`/`RwLock` for shared memory. Do not force channels where a lock is simpler.
- Use `std::sync::atomic` and `std::sync::Arc` for shared lock-free state that is justified, ordered with explicit `Ordering`.
- Use `rayon` for data parallelism over collections. Bound worker pools, queues, fan-out, and retries.
- Async: `async`/`await` builds `Future`s; a runtime drives them. Use `tokio`, `async-std`, or `smol`. Never block on a runtime worker thread; use the runtime's blocking or spawn-blocking facility.
- Select on multiple futures with `tokio::select!` or `futures::select!`. Bound concurrency with `Semaphore` or a stream adapter.
- Beware `Mutex` poisoning, deadlocks from lock ordering, and `RwLock` writer starvation. Treat logic races and deadlocks as correctness bugs.
- Do not leak tasks, handles, timers, or threads. Every spawned task has an owner and a shutdown path.
- The user runs tests. You wire them up and keep them green, including under `--release` and with the Miri or sanitizer runs the project configures.

## Unsafe And FFI

- `unsafe` is a contract you uphold, not an escape hatch. Prefer safe abstractions. Reach for it only for FFI, proven performance, or an invariant the type system cannot express.
- Document every `unsafe` block with a `// SAFETY:` comment stating why the preconditions hold.
- Keep `unsafe` in small, auditable modules behind a safe API. Do not leak unsafety into callers.
- Soundness is the bar: an abstraction must not let safe code cause undefined behavior. Read the Unsafe Code Guidelines Reference and the Rustonomicon before writing it.
- Use `#[repr(C)]` for FFI structs and `#[repr(transparent)]` for newtype wrappers over FFI types.
- Bind C with `bindgen`, expose Rust with `cbindgen`. Confine FFI to a single boundary and never trust C-provided lengths or null terminators.
- Do not use `transmute`, `MaybeUninit`, `ptr::read`/`write`, or raw pointer arithmetic without a documented, reviewed reason.
- Run Miri on the `unsafe` code and `cargo-fuzz` where parsing is involved.

## Security

- Treat all external input as hostile until parsed and validated. Validate sizes and lengths before allocation, decode, buffering, and recursion.
- Randomness: use `getrandom` or the `rand` crate with an OS-backed CSPRNG (`OsRng`, `rand::rngs::OsRng`) for tokens, keys, IDs, and nonces. Never use a non-cryptographic generator for secrets.
- Compare secrets in constant time with the `subtle` crate. Zeroize secret buffers with `zeroize` on drop.
- Use `rustls` (or a verified TLS stack) for TLS. Do not disable certificate verification except in local test code.
- Avoid string concatenation for SQL, shell commands, HTML, and URLs. Use `sqlx` placeholders, `diesel` or `sea-orm` query builders, structured `serde` parsing and encoding, and `url::Url` for URLs.
- Prefer parameterized everything. Never build a shell command by string interpolation; pass arguments as a slice.
- Audit dependencies with `cargo audit` and constrain them with `cargo deny`. Pin intentional versions in `Cargo.lock`.
- Do not vendor or patch crates without a project-level reason.

## Tooling

- Build and run: `cargo build`, `cargo run`, `cargo test`, `cargo check`, `cargo doc --open`.
- Format and lint: `cargo fmt`, `cargo fmt --check` in CI, and `cargo clippy --all-targets --all-features -- -D warnings`.
- Dependencies: `cargo add`, `cargo tree`, `cargo update`, `cargo audit`, `cargo deny check`, `cargo machete` (unused deps), `cargo udeps` (nightly).
- Debug and introspect: `cargo expand` for macro output, `cargo tree -d` for duplicate deps, `dbg!` for local inspection, `rust-gdb`/`rust-lldb` for debuggers.
- Correctness tooling: `cargo miri test` for undefined behavior, `cargo-fuzz` for parser fuzzing, thread sanitizer via `-Zsanitizer` on nightly.
- Testing: built-in `#[test]` and `#[cfg(test)]`; `cargo nextest` for faster, parallel runs; `criterion` for benchmarks; `proptest`/`quickcheck` for property tests; `insta` for snapshot tests. Consider `rstest` for fixtures and parametrization.
- Coverage: `cargo llvm-cov` or `cargo tarpaulin`.
- Language server: `rust-analyzer`. Watch loop: `cargo watch` or `bacon`.
- The user runs tests. You wire them up and keep them green.

## Reference Projects

Use these as domain references. Match the target project's local style before copying any pattern.

- The Rust standard library and compiler: the canonical style, unsafe discipline, and the source of truth for behavior.
  - https://github.com/rust-lang/rust
  - https://doc.rust-lang.org/std/
- tokio: the dominant async runtime, structured concurrency, and networking primitives.
  - https://tokio.rs/
  - https://github.com/tokio-rs/tokio
- hyper: low-level HTTP client and server design.
  - https://github.com/hyperium/hyper
- serde: serialization framework, derive macros, and trait-based extensibility.
  - https://serde.rs/
  - https://github.com/serde-rs/serde
- clap: command-line parsing with derives and a typed builder API.
  - https://docs.rs/clap/
  - https://github.com/clap-rs/clap
- ripgrep: fast CLI tooling, memory-mapped I/O, and pragmatic crate structure.
  - https://github.com/BurntSushi/ripgrep
- regex: performance-sensitive library design and a large test corpus.
  - https://github.com/rust-lang/regex
- rayon: data parallelism with a minimal, safe API.
  - https://github.com/rayon-rs/rayon
- tracing: structured, span-based diagnostics and async instrumentation.
  - https://github.com/tokio-rs/tracing
- rust-analyzer: large-scale IDE tooling, incremental computation, error resilience.
  - https://rust-analyzer.github.io/
  - https://github.com/rust-lang/rust-analyzer
- alacritty: systems programming, GPU rendering, and terminal performance.
  - https://github.com/alacritty/alacritty
- Deno: a large Rust runtime embedding V8, module graph, and CLI surface.
  - https://deno.com/
  - https://github.com/denoland/deno
- Polars: columnar data processing and query engines.
  - https://github.com/pola-rs/polars
- sqlx: compile-time-checked SQL without an ORM.
  - https://github.com/launchbadge/sqlx

## Frameworks

Prefer the standard library for new Rust code. Use these when local project context, team familiarity, or domain complexity justifies the dependency.

- axum: modern web services on tokio and tower, with extractors and type-safe routing.
  - https://github.com/tokio-rs/axum
- actix-web: high-performance actor-based web framework.
  - https://actix.rs/
  - https://github.com/actix/actix-web
- Rocket: ergonomic, typed web framework with derives.
  - https://rocket.rs/
  - https://github.com/rwf2/Rocket
- poem: web framework built on tokio and hyper with OpenAPI support.
  - https://github.com/poem-web/poem
- tokio: async runtime, I/O, and synchronization primitives.
  - https://tokio.rs/
  - https://github.com/tokio-rs/tokio
- async-std: async standard library and runtime alternative.
  - https://async.rs/
  - https://github.com/async-rs/async-std
- serde: derive-based (de)serialization for JSON, YAML, TOML, and more.
  - https://serde.rs/
  - https://github.com/serde-rs/serde
- clap: command-line applications with subcommands, flags, help, and completion.
  - https://docs.rs/clap/
  - https://github.com/clap-rs/clap
- tracing: structured logging and distributed tracing.
  - https://github.com/tokio-rs/tracing
- reqwest: HTTP client with async and blocking APIs.
  - https://github.com/seanmonstar/reqwest
- sqlx: async SQL with compile-time query checking for Postgres, MySQL, SQLite.
  - https://github.com/launchbadge/sqlx
- diesel: synchronous ORM and query builder for teams that want an ORM.
  - https://diesel.rs/
  - https://github.com/diesel-rs/diesel
- sea-orm: async ORM for teams that deliberately choose ORM behavior.
  - https://www.sea-ql.org/SeaORM/
  - https://github.com/SeaQL/sea-orm
- thiserror: typed error enums for libraries.
  - https://github.com/dtolnay/thiserror
- anyhow: context-carrying errors for applications.
  - https://github.com/dtolnay/anyhow
- Bevy: entity-component-system game engine.
  - https://bevyengine.org/
  - https://github.com/bevyengine/bevy
- egui: immediate-mode GUI in pure Rust.
  - https://github.com/emilk/egui
- iced: Elm-inspired GUI framework.
  - https://github.com/iced-rs/iced
- Tauri: cross-platform desktop apps with a web frontend.
  - https://tauri.app/
  - https://github.com/tauri-apps/tauri
- testing: `proptest` for property tests, `criterion` for benchmarks, `nextest` for the runner.
  - https://github.com/proptest-rs/proptest
  - https://github.com/bheisler/criterion.rs
  - https://github.com/nextest-rs/nextest

## Standards And Documentation

- The Rust Programming Language (the Book): https://doc.rust-lang.org/book/
- The Rust Reference: https://doc.rust-lang.org/reference/
- The Rustonomicon (unsafe): https://doc.rust-lang.org/nomicon/
- Rust API Guidelines: https://rust-lang.github.io/api-guidelines/
- Rust Style Guide: https://doc.rust-lang.org/nightly/style-guide/
- Rust by Example: https://doc.rust-lang.org/rust-by-example/
- The Cargo Book: https://doc.rust-lang.org/cargo/
- The rustc Book: https://doc.rust-lang.org/rustc/
- The rustdoc Book: https://doc.rust-lang.org/rustdoc/
- Rust Edition Guide: https://doc.rust-lang.org/edition-guide/
- Clippy lint list: https://rust-lang.github.io/rust-clippy/master/
- Async Rust (the Async Book): https://rust-lang.github.io/async-book/
- The Embedded Rust Book: https://doc.rust-lang.org/embedded-book/
- Unsafe Code Guidelines Reference: https://rust-lang.github.io/unsafe-code-guidelines/
- Standard library: https://doc.rust-lang.org/std/
- The crates.io registry: https://crates.io/
- RustSec Advisory Database: https://rustsec.org/
- Google Rust Style Guide: https://google.github.io/styleguide/rust.html

## Review Checklist

- Is the code formatted by `rustfmt`, and does `cargo fmt --check` pass in CI?
- Does `cargo clippy --all-targets --all-features -- -D warnings` pass with no unjustified `#[allow]`?
- Is the edition pinned and an MSRV declared, and does the code build on it?
- Does the code follow local style, or idiomatic Rust when no local style exists?
- Are ownership and borrowing choices deliberate, with no gratuitous `clone()`, `Rc`/`Arc`, or interior mutability?
- Are public APIs minimal, documented, and marked `#[non_exhaustive]` where they may evolve?
- Are errors typed and context-carrying, with no `unwrap`/`expect` on fallible input in library code?
- Is `unsafe` justified, minimal, and documented with `// SAFETY:`, and does Miri pass?
- Are `Send`/`Sync` respected without `unsafe impl`, and are async bodies free of blocking calls?
- Are worker counts, queues, retries, and task lifetimes bounded and shut down cleanly?
- Is randomness from an OS-backed CSPRNG, with secrets zeroized and compared in constant time?
- Is external input validated before allocation, decode, buffering, or recursion?
- Are SQL, shell, HTML, and URLs built with parameterized, structured APIs rather than string concatenation?
- Are dependencies audited (`cargo audit`, `cargo deny`) and free of unnecessary duplication?
- Is the implementation simpler than the framework, generic helper, or macro it could have used?
