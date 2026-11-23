---
description: Load JavaScript specific skill
agent: build
---

# JavaScript
You will internalize the rules below. Then, you will pull the current tree of the project we're at (depth at most 4), and internalize the repository's structure. You will not read any file for now, except the `*.md`s in the root of the project, enough to contextualize yourself with it.

JavaScript is the language of the web platform and of a growing share of servers and tooling. Modern JavaScript is modules, promises, iterators, and Web-standard APIs. It is not ES5 plus a library. Prefer the platform and the standard runtime, then small focused libraries, then frameworks only when the domain demands them.

This command owns plain JavaScript: the language, ECMAScript modules, runtimes, and no-build workflows. When a project adds types or a compiler, defer to the TypeScript rules. When a project touches the DOM, defer to the Web UI rules.

## Hard Standard

- Target ES2024 as the default baseline for broad browser and runtime support. Use ES2025 and ES2026 features where the target runtime allows and the project does not need to support older engines.
  - ES2025: `RegExp.escape`, `Promise.try`, iterator helpers, `Set` methods (`union`, `intersection`, `difference`, `symmetricDifference`, `isSubsetOf`, `isSupersetOf`, `isDisjointFrom`), `Float16Array`, RegExp modifiers, duplicate named capture groups, import attributes, JSON modules.
  - ES2026 (expected): `Error.isError`, `Math.sumPrecise`, `Array.fromAsync`, `Uint8Array` base64/hex helpers, `JSON.parse` source text access, `Map.prototype.upsert`, iterator sequencing.
  - ES2027 and beyond (not yet standard): explicit resource management (`using`), `Temporal`, iterator chunking and joining, `Atomics.pause`, joint iteration. Do not depend on these in shipped code without a fallback.
- Use ECMAScript modules everywhere. Set `"type": "module"` in `package.json` for Node projects. Do not mix `require` and `import` in the same module graph.
- Modules are strict by default. Do not add `"use strict"` to module files.
- Declare the runtime floor: `engines` in `package.json`, a `.nvmrc` or `.node-version`, and matching CI. Node.js LTS is the baseline.
- Follow the project's linter and formatter. Where none exist, default to ESLint with flat config or Biome for linting, and Prettier or Biome for formatting.
- Local project style wins when contributing to an existing codebase.
- Prefer no build step for servers and libraries. Add a bundler only when shipping to the browser or consuming non-ESM dependencies requires it.
- Pin the toolchain in `devDependencies`. Run tools from the local install (`npx` or package-manager equivalent), never a global.

## Design Rules

- Prefer modules over globals. Named exports over default exports, except where a framework or a single-purpose module makes a default natural.
- Use `const` by default and `let` when reassignment is required. Never `var`.
- Use `===` and `!==`. Avoid the coercing `==` except for the deliberate `x == null` null/undefined check when the project allows it.
- Prefer arrow functions for callbacks and small pure helpers. Use `function` declarations when hoisting or a named stack frame matters.
- Do not rely on `this` outside classes and methods. Capture context in a `const` or use arrow functions bound at the call site.
- Use classes for identity, encapsulated mutable state, or framework requirements. Otherwise prefer plain objects, plain functions, and data.
- Use `#private` fields and methods for real encapsulation. The `_` prefix is a convention, not privacy.
- Avoid `arguments`. Use rest parameters.
- Prefer immutable data: `const` bindings, `Object.freeze` at boundaries, spread for copies, and `structuredClone` for deep copies.
- Do not mutate function parameters or objects you do not own.
- No premature abstraction. Three similar blocks before a helper.
- Keep modules cohesive. Do not create `utils`, `helpers`, or `common` dumping grounds by default.

## Runtime And Memory

- Know your runtime. Node.js LTS for servers, Deno or Bun when their standard library, permissions model, or tooling is a deliberate choice, browsers for the client. Confirm Web and platform API availability per runtime, version, and environment.
- The event loop is single-threaded for JavaScript. Never block it with synchronous CPU work or synchronous I/O on a request path.
- Offload CPU-bound work to `worker_threads` (Node), Web Workers (browser/Deno), or a separate process.
- Stream data instead of buffering it whole. Respect backpressure for streams, `fetch` bodies, and file handles.
- Close what you open: servers, sockets, file handles, timers, intervals, watchers, and subscriptions. Clear `setInterval` and `clearTimeout`.
- Keep long-lived structures bounded: caches, maps, queues, and listener sets. Do not grow without a cap or eviction.
- Avoid retaining references across request boundaries. Long-lived closures and module-level arrays keep objects alive.
- On Node, prefer `node:` prefixed imports (`node:fs`, `node:path`, `node:crypto`) to make built-in usage explicit.
- Use Web-standard APIs where they exist (`fetch`, `URL`, `TextEncoder`, `AbortController`, `structuredClone`, `crypto`) to keep code portable across runtimes.

## Error Handling

- Throw `Error` or a subclass, never a string or an arbitrary object.
- Preserve cause with the standard cause option: `throw new Error("...", { cause })`.
- Add context with the `[package:Function]` prefix: `throw new Error("[api:loadUser] user not found: " + id)`, or a logger line with the same prefix.
- Use `AggregateError` for multiple failures and `error.errors` to inspect them.
- On ES2026 runtimes, prefer `Error.isError` over `instanceof Error` when values cross realms or come from other contexts.
- Do not swallow errors in empty `catch` blocks. Log at the boundary that owns recovery, or rethrow with context.
- Do not log and rethrow the same error at every layer.
- Prefer early returns and explicit failure over deeply nested `try`/`catch`.
- Clean up with `try`/`finally` when lifetime is scope-bound. Do not rely on `finally` control flow that overrides `return` or a thrown error.

## Async And Concurrency

- Return promises. Do not mix callbacks, promises, and event emitters in one interface without cause.
- Pass an `AbortSignal` for cancellable operations and propagate it. Use `AbortController`.
- Do not leave promises unhandled. Await them or attach a rejection handler. Treat unhandled rejections as bugs.
- Use `Promise.all` for independent work, `Promise.allSettled` when every outcome matters, and `Promise.any` for first success.
- `Promise.withResolvers` and `Promise.try` (ES2025) replace manual executor and sync-throw wrappers.
- Use `for await...of` for async iteration and `Array.fromAsync` (ES2026) to collect async sources.
- Bound concurrency for network, filesystem, and database work. A queue or semaphore, not `Promise.all` over ten thousand items.
- Cancellation is cooperative. An `async` function cannot be cancelled by the caller once started; check the signal at await boundaries.
- Do not `await` independent operations sequentially. Batch or parallelize deliberately.
- Do not rely on event loop ordering across unrelated async work.

## Iteration And Collections

- Use `Map` and `Set` for dynamic keys and membership. A plain object is for fixed, string-or-symbol keys, not an arbitrary map.
- Prefer `Set` methods (ES2025) for set algebra over manual loops.
- Prefer iterator helpers (ES2025) (`map`, `filter`, `take`, `drop`, `flatMap`, `reduce`, `toArray`) over building intermediate arrays.
- Use `for...of` over `forEach` when you need `break`, `continue`, `return`, or `await`.
- Use `Object.groupBy` and `Map.groupBy` (ES2024) instead of hand-rolled grouping.
- Use `Array.prototype.at`, `findLast`, `findLastIndex`, and `toSorted`/`toReversed`/`toSpliced`/`with` (ES2023) over index arithmetic and in-place mutation.
- Use `structuredClone` for deep copies over JSON round-trips, which lose types and reject cycles.
- Know that iteration over a `Map`/`Set` while mutating it is a bug. Snapshot first when needed.

## Security

- Treat all external input as hostile: HTTP bodies, query params, headers, environment, files, and third-party responses.
- Never pass untrusted strings to `eval`, `new Function`, `child_process` shell strings, or `vm` code paths.
- Guard against prototype pollution. Reject or sanitize `__proto__`, `constructor`, and `prototype` keys when merging untrusted objects. Use `Object.hasOwn` and null-prototype objects (`Object.create(null)`) where appropriate.
- Validate and bound sizes before allocation, parse, buffering, and recursion on untrusted input.
- Use the Web Crypto API `crypto` for randomness and hashing. Use `crypto.randomUUID` for identifiers. Never `Math.random` for tokens, secrets, or IDs.
- Compare secrets in constant time. Do not build your own crypto.
- Use parameterized queries or a query builder with bound parameters. Never assemble SQL by string concatenation.
- Do not disable TLS verification outside local test code.
- Do not assign untrusted data to `innerHTML`, `outerHTML`, or `insertAdjacentHTML`. Prefer `textContent` and `createElement`, or sanitize explicitly. See the Web UI rules for DOM specifics.
- Do not dynamically `import()` or `require` untrusted specifiers.
- Audit dependencies: commit the lockfile, pin critical paths, and watch for typosquatting and install scripts. Prefer fewer dependencies.

## Tooling

- Runtime: Node.js LTS. Keep `engines`, `.nvmrc`, and CI aligned with the deployment runtime.
- No-build path: run ES modules directly on modern Node, Deno, and Bun.
- Bundlers and dev servers: esbuild, Vite, or Rolldown for browsers; match the output targets to the supported browsers.
- Linting: ESLint with flat config, or Biome or oxlint when speed matters more. One linter, configured in the repo.
- Formatting: Prettier or Biome. One formatter, run in CI.
- Testing: the built-in `node:test` runner, or Vitest. Pick one and run it in CI.
- Debugging: `node --inspect` with Chrome DevTools, or the built-in inspector protocol. Use `--trace-warnings` to surface deprecations.
- Watch and scripts: the package manager's scripts, `node --watch`, or the bundler's dev server. Keep scripts in `package.json`, not in ad-hoc shell files.
- Package manager: match the project (npm, pnpm, yarn, bun). Commit the lockfile. Do not mix package managers.

## Reference Projects

Use these projects as domain references. Match the target project's local style before copying any pattern.

- Node.js standard library and its Web-standard APIs: the baseline for servers, streams, `fetch`, `node:test`, and `worker_threads`.
  - https://nodejs.org/docs/latest-v24.x/api/
  - https://github.com/nodejs/node
- Deno standard library: standard-first, Web-compatible modules, permissions model.
  - https://jsr.io/@std
  - https://github.com/denoland/deno
- Bun: fast runtime, bundler, test runner, and package manager in one tool.
  - https://bun.sh/
  - https://github.com/oven-sh/bun
- Hono: small, Web-standard, runtime-agnostic server framework that reads as idiomatic modern JS.
  - https://hono.dev/
  - https://github.com/honojs/hono
- Fastify: performance-focused Node server with schema-based validation.
  - https://fastify.dev/
  - https://github.com/fastify/fastify
- Express: minimal, ubiquitous, and stable. Use when compatibility matters.
  - https://expressjs.com/
  - https://github.com/expressjs/express
- lodash-es: the ES module build of a widely used utility library. Study it as a utility reference; prefer native methods first.
  - https://lodash.com/
  - https://github.com/lodash/lodash
- date-fns: immutable, tree-shakeable date utilities. Prefer `Temporal` when it lands and when the runtime supports it.
  - https://date-fns.org/
  - https://github.com/date-fns/date-fns
- Vite: dev server and build tool, ESM-native, the default for browser projects.
  - https://vite.dev/
  - https://github.com/vitejs/vite
- esbuild: fast bundler and minifier, the engine under many tools.
  - https://esbuild.github.io/
  - https://github.com/evanw/esbuild
- ESLint: pluggable linter, flat config, the de facto standard.
  - https://eslint.org/
  - https://github.com/eslint/eslint
- Biome and oxlint: fast, Rust-based formatter and linter tooling.
  - https://biomejs.dev/
  - https://oxc.rs/

## Frameworks

Prefer platform APIs and the standard runtime before adding a framework. This is a lean list; for the broader TypeScript and framework ecosystem, defer to the TypeScript rules, and for DOM, accessibility, and CSS discipline, defer to the Web UI rules.

- Browser UI: React, Vue, Svelte, Solid, and Astro. See the TypeScript rules and the Web UI rules for the DOM, accessibility, and CSS boundaries, if necessary.
  - https://react.dev/
  - https://vuejs.org/
  - https://svelte.dev/
- Server and full-stack: Hono, Fastify, Express, and NestJS.
  - https://hono.dev/
  - https://fastify.dev/
- Data and validation: Zod and Valibot for runtime validation at boundaries.
  - https://zod.dev/
  - https://valibot.dev/
- Testing: `node:test` and Vitest.
  - https://nodejs.org/docs/latest-v24.x/api/test.html
  - https://vitest.dev/

## Standards And Documentation

- ECMAScript specification: https://tc39.es/ecma262/
- TC39 proposals (active, finished, stage 0 through 3): https://github.com/tc39/proposals
- MDN JavaScript reference: https://developer.mozilla.org/en-US/docs/Web/JavaScript
- MDN JavaScript Guide: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide
- Node.js API documentation (v24 LTS): https://nodejs.org/docs/latest-v24.x/api/
- Node.js releases and LTS schedule: https://nodejs.org/en/about/previous-releases
- Deno documentation: https://docs.deno.com/
- Bun documentation: https://bun.sh/docs
- Web platform and WHATWG standards: https://html.spec.whatwg.org/ and https://fetch.spec.whatwg.org/
- Web Crypto API: https://developer.mozilla.org/en-US/docs/Web/API/Web_Crypto_API
- V8 blog (engine features and performance): https://v8.dev/blog
- ESLint: https://eslint.org/docs/latest/
- Prettier: https://prettier.io/docs/
- Biome: https://biomejs.dev/
- OWASP Cross Site Scripting Prevention Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html

## Review Checklist

- Does it target the declared runtime floor, with `engines`, `.nvmrc`, and CI aligned?
- Is the module graph consistently ECMAScript modules, with no mixed `require` and `import`?
- Are `var`, loose `==`, and reliance on `this` outside classes absent?
- Is external input validated and bounded before parse, allocation, or use?
- Is `eval`, `new Function`, `vm`, and shell string execution avoided on untrusted data?
- Is prototype pollution guarded when merging untrusted objects?
- Is randomness from `crypto`, never `Math.random`, for tokens and IDs?
- Are errors real `Error` instances with `cause` and a `[package:Function]` context?
- Are promises awaited or handled, with cancellation propagated through `AbortSignal`?
- Is concurrency bounded for network, filesystem, and database work?
- Are resources (servers, sockets, handles, timers, watchers, subscriptions) closed at the owning scope?
- Is CPU-bound work kept off the event loop?
- Are `Map`/`Set` used for dynamic keys and iterator helpers over intermediate arrays?
- Is the toolchain local to the project, with one linter and one formatter in CI?
- Is there no unnecessary build step for servers and libraries?
- Is the implementation simpler than the framework or utility library it could have used?
