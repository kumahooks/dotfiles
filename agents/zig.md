---
description: Load Zig specific skill
agent: build
---

# Zig
You will internalize the rules below. Then, you will pull the current tree of the project we're at (depth at most 4), and internalize the repository's structure. You will not read any file for now, except the `*.md`s in the root of the project, enough to contextualize yourself with it.

Zig is explicit, minimal, and comptime-driven. There is no hidden control flow, no hidden allocation, no preprocessor, no operator overloading, and no exceptions. The compiler is the specification. Zig is pre-1.0: releases break source compatibility, so pin a toolchain instead of tracking `master`. Prefer the standard library and small packages over frameworks. The Zig Zen is the default model: communicate intent precisely, edge cases matter, favor reading code over writing code, there is an idiomatic way to do it, runtime crashes are better than bugs, compile errors are better than runtime crashes, resource allocation may fail, resource deallocation must succeed.

## Hard Standard

Treat idiomatic Zig as the default model.

- Follow `zig fmt` as the hard formatting standard. It has no configuration surface; there is nothing to debate.
- Follow the Zig Language Reference for language semantics. There is no committee spec; the compiler is the authority.
- Follow Zig Zen and the shipped Style Guide for idiom and naming.
- Pin one Zig version per project. Record it in `build.zig.zon` (`minimum_zig_version`) and match it in CI.
- `build.zig` is the build system. `build.zig.zon` is the package manifest and dependency lock (names, URLs, hashes).
- Know the recent breakpoints: async functions regressed in 0.11.0 and are being redesigned as a low-level primitive; the `std.io` streams were replaced by the `std.Io` interface; general-purpose allocators were renamed. Read the release notes for the pinned version before upgrading.
- Local project style wins when contributing to an existing Zig project.

Zig is strongest when code is explicit about allocation, error handling, and comptime. Prefer the standard library and small modules before frameworks.

## Tiger Style (Opt-In)

TigerBeetle's Tiger Style is a deliberate alternative to idiomatic Zig, not a refinement of it. Do not apply it by default.

- Load `/tigerstyle` when the user asks for Tiger Style, when the project declares it, or when the project is TigerBeetle itself.
- Precedence once loaded: local project style, then Tiger Style, then the rest of this document.
- Expect direct conflicts, and resolve them in Tiger Style's favor: `snake_case` for functions and variables instead of `camelCase`, static allocation at startup instead of threaded `Allocator` parameters, no recursion, zero dependencies, a 70-line function limit, a 100-column line limit, and a minimum of two assertions per function.
- Never retrofit Tiger Style onto a project that has not adopted it. Apply it to new or touched code only.
- Source: https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/TIGER_STYLE.md

## Design Rules

- A module is a file, and every file is implicitly a struct. Use `@import` to wire namespaces; export only what callers need with `pub`.
- `pub` is the only visibility control. There are no private fields, so name and document invariants instead of hiding them behind underscore prefixes.
- Use `comptime` for generics (`anytype`, `comptime T: type`) only when it removes real duplication across types.
- Prefer plain structs, functions, and tagged unions (`union(enum)`) with exhaustive `switch` over vtables. Reach for function-pointer tables only when runtime polymorphism is genuinely required.
- Make layout explicit at boundaries: `extern` struct/union/enum for C ABI and FFI, `packed` for serialization. Know `@sizeOf`, `@alignOf`, and `@offsetOf` for the types you pass across a boundary.
- Avoid global mutable state. If process-wide state is required, make it explicit and pass it. Use `threadlocal` only when the state is truly per-thread.
- Keep `main` thin. Put logic in importable modules and ordinary structs.
- No premature abstraction. Three similar blocks before a helper.
- Prefer descriptive names. Follow the Style Guide: `camelCase` for functions and variables, `TitleCase` for types and type-returning functions, `snake_case` for namespaces, file names, and directories.

## Comptime

- Comptime is the generics mechanism. Use `comptime` parameters, `comptime` blocks, `inline for`, `inline switch`, and `@Type` to generate code and data.
- Fail builds early with `@compileError` when a contract is violated at compile time. Use `@compileLog` only while debugging, since it aborts the build.
- Keep comptime code comprehensible. Avoid unbounded `inline` expansion and unbounded recursion; `@setEvalBranchQuota` is a smell, not a default.
- Prefer guarantees enforced by the type system over runtime reflection. Use `@typeInfo` sparingly, and document why when you do.
- Compile-time constants and `const` declarations with comptime-known values live in global constant data. Treat that as immutability, not as a place for shared mutable state.

## Memory

- Allocation is always explicit. Every allocating function takes an `Allocator` parameter; there are no hidden allocations.
- Choose the allocator by lifetime and failure model:
  - Library code: accept an `Allocator` parameter and let the caller decide.
  - Linking libc: `std.heap.c_allocator` is a reasonable main allocator.
  - Bounded at comptime: `std.heap.FixedBufferAllocator` or `std.heap.BufferFirstAllocator`.
  - Run-once CLI, per-request, or per-frame: `std.heap.ArenaAllocator`, reset or `deinit` wholesale.
  - Debug and ReleaseSafe general purpose: `std.heap.SafeAllocator` for leak and use-after-free detection. `std.heap.DebugAllocator` is its deprecated predecessor.
  - ReleaseFast general purpose: `std.heap.smp_allocator`.
  - Tests: `std.testing.allocator`, and `std.testing.FailingAllocator` to exercise `error.OutOfMemory` paths.
- Use `defer` for normal cleanup and `errdefer` for failure paths. Balance every acquire. `deinit` must succeed.
- Slices carry a pointer and a length and are bounds-checked. Prefer them over raw pointers. Use sentinel-terminated slices (`[:0]u8`) only at C and string boundaries.
- Ownership and lifetime are the programmer's responsibility. Document who owns a returned pointer and how long it stays valid, for example `ArrayList.items` is valid until the next resize. Copy with `dupe` when you mean to own; never retain a caller's buffer otherwise.
- Alignment is part of the type. Use `@alignCast` only when the alignment is provably correct. Avoid `@ptrCast` and `@intFromPtr` outside of FFI or proven-correct boundaries.
- `undefined` means "bug if read". Debug and Safe modes fill undefined memory with `0xaa` to surface the bug.
- There is no garbage collector. Use object pools only when profiling proves allocation pressure.

## Error Handling

- Error unions are the mechanism: `ErrorSet!T`, `try`, `catch`, and `errdefer`.
- Define narrow error sets. Let the compiler infer `!T` where natural. Avoid `anyerror` at API boundaries.
- Preserve context by returning distinct error values, or by logging once at the boundary that owns recovery. Use `std.log` and `std.log.scoped` with the `[package:Function]` prefix:
  `std.log.err("[config:Load] missing key: database_url", .{});`
- `unreachable` is only for proven-impossible states. It is a safety panic in Debug and Safe modes, and unchecked Illegal Behavior in Fast and Small modes.
- Use `panic` or `@panic` only for programmer errors and impossible states, never for user input, I/O, or allocation failure. Handle `error.OutOfMemory` by convention.
- Use `assert` for invariants. In doc comments, use "assume" for invariants that cause unchecked Illegal Behavior when violated and "assert" for invariants that are safety-checked.
- Prefer early returns over nested control flow, and clean up with `defer` and `errdefer`.

## Concurrency

- Use `std.Thread` for OS threads, `std.Thread.Mutex` and `std.Thread.RwLock` for shared memory, and `std.atomic` or the `@atomicLoad`/`@atomicStore`/`@atomicRmw`/`@cmpxchg*` builtins for lock-free code that is justified. Treat data races as correctness bugs.
- Bound worker pools, queues, fan-out, and retries. Join every thread. There is no garbage collector to reclaim a forgotten thread.
- Use the `std.Io` interface for files, networking, processes, time, and randomness, and for structured async, concurrent, and cancel operations. Select the backend appropriate to the target: `Threaded`, `Uring` (io_uring), `Kqueue`, or `Dispatch`.
- Language-level `async fn` is not available: it regressed in 0.11.0 and is being reintroduced as a lower-level primitive. Do not write code that assumes it. `std.Io` is the supported path today.
- Runtime safety checks are disabled in Fast and Small modes and do not detect races. Exercise concurrent code under Debug and ReleaseSafe.
- Do not leak threads, handles, timers, or buffers. Every resource has an owner and a release path.

## Security

- Treat all external input as hostile until parsed and validated. Validate lengths, indices, and sizes before allocation, decode, buffering, and recursion.
- Randomness: use `io.random` for non-secret bytes and `io.randomSecure` for tokens, keys, IDs, and nonces. Never use `std.Random` or `DefaultPrng` for secrets.
- Compare secrets in constant time with `std.crypto.timing_safe.eql`. Use `std.crypto` primitives (AEAD, hashes, KDFs) rather than rolling your own.
- Use `std.fmt` and `std.json` with structured encoders. Avoid string concatenation for SQL, shell commands, HTML, and URLs. Prefer parameterized queries.
- Do not disable TLS verification except in local test code.
- Safety-checked operations such as `@intCast`, `@truncate`, `@intFromFloat`, and sentinel slicing panic in safe modes. Ship `ReleaseSafe` unless profiling justifies `ReleaseFast` or `ReleaseSmall`, and state the tradeoff when you do.
- C interop goes through `@cImport`, `zig translate-c`, and `zig cc`. Confine C to a single boundary, and never trust C-provided lengths or null termination.
- Dependency hashes are pinned in `build.zig.zon`. Do not hand-edit hashes or vendor code without a project-level reason.

## Tooling

- Build and run: `zig build`, `zig build run`, `zig build test`, `zig run`, `zig init`.
- Format and parse: `zig fmt`, `zig fmt --check` in CI, and `zig ast-check`.
- Optimize: `zig build -Doptimize=ReleaseSafe` for shipping by default; `ReleaseFast` and `ReleaseSmall` only when measurements justify them.
- Debug: Debug builds, `std.debug` stack traces, error return traces, `lldb` or `gdb`, and `@breakpoint`. Use `zig reduce` to minimize a crash or miscompile before reporting.
- Language server: `zls`.
- Interop and introspection: `zig cc`, `zig translate-c`, `zig libc`, `zig env`, and `zig std`.
- Testing uses `std.testing` only; there is no external framework to adopt. The testing allocator reports leaks. Use `--test-filter`, `error.SkipZigTest`, and `@import("builtin").is_test`.
- The user runs tests. You wire them up and keep them green.

## Reference Projects

Use these as domain references. Match the target project's local style before copying any pattern.

- Zig compiler and standard library: the canonical style, comptime idioms, and the source of truth for behavior.
  - https://github.com/ziglang/zig
- TigerBeetle: strict, correctness-first Zig, deterministic simulation, and exacting memory discipline.
  - https://github.com/tigerbeetle/tigerbeetle
- Bun: a large JavaScript runtime written in Zig, build tooling, and performance work.
  - https://github.com/oven-sh/bun
- Ghostty: a terminal emulator, platform integration, and `std.Io` usage.
  - https://github.com/ghostty-org/ghostty
- Mach: a Zig game engine and graphics stack, cross-platform tooling and native code.
  - https://github.com/hexops/mach
- zls: the Zig language server, and how Zig tooling itself is structured.
  - https://github.com/zigtools/zls
- ziglibs: reusable, idiomatic packages such as zig-zag and known-folders.
  - https://github.com/ziglibs
- ziglua: binding a large C library into idiomatic Zig.
  - https://github.com/natecraddock/ziglua
- libvaxis: terminal user interfaces and low-level terminal handling.
  - https://github.com/rockorager/libvaxis
- river: a Wayland compositor demonstrating comptime configuration and native system code.
  - https://github.com/riverwm/river
- zig-clap: command-line argument parsing with a small, typed API.
  - https://github.com/Hejsil/zig-clap

## Frameworks

Prefer the standard library for new Zig code. Zig's ecosystem is young and pre-1.0, so adopt a dependency only when domain complexity or ecosystem fit clearly justifies it, and verify it compiles against your pinned toolchain.

- zap: an HTTP server and framework with routing and middleware.
  - https://github.com/zigzap/zap
- http.zig: a small, focused HTTP server.
  - https://github.com/karlseguin/http.zig
- jetzig: a web framework with routing, views, and a database layer.
  - https://github.com/jetzig-framework/jetzig
- zig-clap: command-line argument parsing.
  - https://github.com/Hejsil/zig-clap
- ziglua: Lua bindings for scripting and configuration.
  - https://github.com/natecraddock/ziglua
- known-folders: cross-platform standard directory resolution.
  - https://github.com/ziglibs/known-folders
- zbench: benchmarking with a small, dependency-free API.
  - https://github.com/ziglibs/zbench
- Mach: graphics, windowing, and game development.
  - https://github.com/hexops/mach
- libvaxis: terminal user interfaces.
  - https://github.com/rockorager/libvaxis
- Testing: none needed. `std.testing` is the framework.

## Standards And Documentation

- Language Reference (0.17.0): https://ziglang.org/documentation/0.17.0/
- Standard Library documentation: https://ziglang.org/documentation/0.17.0/std/ (also `zig std`)
- Zig Zen: https://ziglang.org/documentation/0.17.0/#Zen
- Style Guide: https://ziglang.org/documentation/0.17.0/#Style-Guide
- Choosing an Allocator: https://ziglang.org/documentation/0.17.0/#Choosing-an-Allocator
- Illegal Behavior: https://ziglang.org/documentation/0.17.0/#Illegal-Behavior
- Optimization Mode: https://ziglang.org/documentation/0.17.0/#Optimization-Mode
- Zig Build System: https://ziglang.org/documentation/0.17.0/#Zig-Build-System
- C interop: https://ziglang.org/documentation/0.17.0/#C
- Compile variables: https://ziglang.org/documentation/0.17.0/#Compile-Variables
- Atomics: https://ziglang.org/documentation/0.17.0/#Atomics
- Async functions: https://ziglang.org/documentation/0.17.0/#Async-Functions
- Downloads and release notes: https://ziglang.org/download/
- zls: https://github.com/zigtools/zls
- Ziggit community forum: https://ziggit.dev/
- zig.guide: https://zig.guide/

## Review Checklist

- Is the code formatted by `zig fmt`, and does `zig fmt --check` pass in CI?
- Is the toolchain pinned in `build.zig.zon` and matched in CI?
- Does every allocation take an explicit `Allocator`, and is every `defer`/`errdefer` balanced with a working `deinit`?
- Are error sets narrow and context-carrying, with no `anyerror` at boundaries and no `unreachable` on reachable paths?
- Is `panic` confined to programmer errors and impossible states, never user input, I/O, or allocation failure?
- Is ownership and lifetime of pointers and slices explicit, and are `@ptrCast`, `@intFromPtr`, and `@alignCast` provably safe?
- Are there no hidden allocations, no surprising comptime side effects, and no unbounded `inline` or recursion?
- Is shared state guarded, are threads joined, and are pools and queues bounded and exercised under Debug or ReleaseSafe?
- Is randomness from `io.randomSecure` for secrets, and are secrets compared with `std.crypto.timing_safe.eql`?
- Is external input validated before allocation, decode, buffering, or recursion?
- Is `ReleaseSafe` used unless profiling justifies `ReleaseFast` or `ReleaseSmall`, and are dependencies pinned by hash?
- Is the implementation simpler than the framework, generic helper, or comptime abstraction it could have used?
- If Mach or graphics is involved: are resources loaded once and released at the matching scope, matching the target project's local style?

