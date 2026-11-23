---
description: Load TypeScript specific skill
agent: build
---

# TypeScript
You will internalize the rules below. Then, you will pull the current tree of the project we're at (depth at most 4), and internalize the repository's structure. You will not read any file for now, except the `*.md`s in the root of the project, enough to contextualize yourself with it.

TypeScript is JavaScript that scales. Types exist to be checked and then erased; they do not exist at runtime. The compiler is the tool, not the architecture. Prefer the platform and standard runtime APIs, then small libraries, then frameworks only when the domain demands them.

## Hard Standard

- Target TypeScript 7 as the default baseline. TypeScript 7 is the native port: `tsc` is a fast multithreaded binary, and any project compiling under TypeScript 6.0 (with `stableTypeOrdering` on) compiles identically under 7.0.
- Know that TypeScript 7.0 ships no programmatic compiler API. Tooling that imports the compiler (typescript-eslint, Volar, framework language services, bundler plugins) must run TypeScript 6.0 side-by-side via `@typescript/typescript6` (`tsc6`) until 7.1 lands.
- Keep `strict: true`. TypeScript 7 defaults it on; do not turn it off to silence errors.
- Follow the project's `tsconfig.json`, formatter, and linter. Where none exist, default to `tsc --strict`, Prettier or Biome for formatting, and typescript-eslint or Biome for linting.
- Local project style wins when contributing to an existing codebase.
- Prefer `tsc --noEmit` for type checking and a dedicated bundler or the runtime for emit. Do not use `tsc` as a bundler.
- Pin the toolchain in `package.json` devDependencies. Run `tsc` from the local install (`npx tsc`), never a global.

### TypeScript 7 Defaults And Removals

Internalize these; they change how new `tsconfig.json` files are written.

- `strict` is `true` by default.
- `module` defaults to `esnext`; `target` defaults to the stable ECMAScript version preceding `esnext`.
- `noUncheckedSideEffectImports` is `true` by default.
- `rootDir` defaults to `./`; inner source directories must be set explicitly (for example `"rootDir": "./src"`).
- `types` defaults to `[]`; list global declaration packages explicitly (for example `"types": ["node"]`).
- `stableTypeOrdering` is `true` and cannot be disabled.
- `libReplacement` is `false` by default.
- Removed with hard errors: `target: es5`, `downlevelIteration`, `moduleResolution: node`/`node10`/`classic`, `module: amd`/`umd`/`systemjs`/`none`, `baseUrl`, `esModuleInterop: false`, `allowSyntheticDefaultImports: false`, `alwaysStrict: false`, the `module` keyword in namespace declarations.
- Use `import ... with { type: "json" }` (import attributes). The `assert` keyword is no longer supported.
- Use `moduleResolution: nodenext` for Node and `bundler` for bundled browser or tooling projects.
- Parallelism controls: `--checkers`, `--builders`, and `--singleThreaded`. Default checkers is 4. Vary these only with measurement.

## Design Rules

- Types model the domain. Name them after the domain, not after their shape.
- Prefer `interface` for object contracts that can be extended, `type` for unions, tuples, and mapped or conditional types. Do not fight over which when the choice is cosmetic.
- Model state with discriminated unions tagged by a literal field, not with optional fields that can contradict each other.
- Use `satisfies` to check a value against a type without widening it.
- Prefer plain functions and plain data over classes. Reach for classes only for identity, encapsulated mutable state, or framework requirements.
- Avoid `enum`. Prefer `const` objects with `as const` and derived union types.
- Avoid namespace and module patterns. Use ES modules.
- Keep `any` out of application code. `unknown` at boundaries, narrowed before use.
- Prefer `readonly` arrays and properties for data that is not meant to mutate.
- Use branded (nominal-ish) types for IDs and units when two `string`s or two `number`s can be confused.
- No premature abstraction. Three similar blocks before a generic helper.
- Keep modules cohesive and side-effect free at import time unless the side effect is the point.
- Do not create `utils`, `helpers`, or `types` dumping grounds by default. Split by domain.

## Types And Soundness

- Enable beyond strict where the project tolerates it: `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, `noImplicitOverride`, `noFallthroughCasesInSwitch`, `noPropertyAccessFromIndexSignature`.
- Understand that TypeScript is unsound by design. Index signatures, `any` through JS interop, `as` assertions, and mutation through aliases can all break guarantees. Treat the type system as an aid, not a proof.
- Validate untrusted data at the boundary and narrow to a type. A type assertion on network or file input is a lie until validated.
- Use type guards and assertion functions to narrow. Avoid double assertions (`as unknown as T`) except at genuine interop seams.
- Do not use non-null assertion (`!`) to skip handling. Narrow properly or fail explicitly.
- Prefer `readonly T[]` and `Readonly<T>` over documenting immutability in comments.
- Prefer `import type` for type-only imports to keep them erasable.
- Keep declaration files (`.d.ts`) accurate. If you lie there, you lie to every consumer.

## Runtime And Memory

- Know your runtime: Node.js LTS for servers, Bun or Deno when their compatibility or tooling is a deliberate choice. Confirm Web and Node API availability per runtime and version.
- The event loop is single-threaded for JavaScript. Do not block it with synchronous CPU work on a request path.
- Offload CPU-bound work to `worker_threads` (Node), Web Workers (browser/Deno), or a separate process.
- Stream data instead of buffering it whole. Respect backpressure in streams and `fetch` bodies.
- Close what you open: servers, sockets, file handles, timers, intervals, and subscriptions.
- Keep long-lived structures bounded. Bound caches, maps, queues, and listener sets.
- Avoid holding references that prevent garbage collection across request boundaries.

## Error Handling

- Throw `Error` (or a subclass), never strings or arbitrary objects.
- Preserve cause with the standard `cause` option: `new Error("...", { cause })`.
- Add context with the `[package:Function]` prefix: `throw new Error("[api:loadUser] user not found: " + id)`, or a logger line with the same prefix.
- In `catch`, the value is `unknown` under strict settings. Narrow before use.
- Do not swallow errors in empty `catch` blocks. Log at the boundary that owns recovery, or rethrow with context.
- Do not log and rethrow the same error at every layer.
- Prefer early returns and explicit failure over deeply nested `try`/`catch`.
- Clean up with `try`/`finally` when lifetime is scope-bound and the resource is not managed by `using`.

## Async And Concurrency

- Return promises; do not mix callbacks, promises, and event emitters in the same interface without cause.
- Pass an `AbortSignal` for cancellable operations and propagate it. Use `AbortController`.
- Do not leave promises unhandled. Await them or attach a rejection handler.
- Use `Promise.all` for independent work, `Promise.allSettled` when all outcomes matter, and avoid unbounded fan-out.
- Bound concurrency for network, filesystem, and database work. A queue or a semaphore, not `Promise.all` over ten thousand items.
- Understand that `async` functions cannot be cancelled by the caller once started; cancellation is cooperative through signals and checks.
- Avoid `await` inside loops when the iterations are independent. Batch or parallelize deliberately.
- Do not rely on event loop ordering across unrelated async work.

## Security

- Treat all external input as hostile: HTTP bodies, query params, headers, env, files, and third-party responses.
- Validate and parse at the boundary with a schema library (Zod, Valibot) and narrow to a type. Do not trust `JSON.parse` output.
- Never pass untrusted strings to `eval`, `new Function`, `child_process` shell strings, or `vm` code paths.
- Guard against prototype pollution: reject or sanitize `__proto__`, `constructor`, and `prototype` keys when merging untrusted objects.
- Use `node:crypto` for randomness and hashing. Do not use `Math.random` for tokens, secrets, or IDs.
- Use parameterized queries or a query builder with bound parameters. Never assemble SQL by string concatenation.
- Do not disable TLS verification outside local test code.
- Avoid `dangerouslySetInnerHTML` and equivalents. Sanitize HTML if it is truly required.
- Audit dependencies: `npm audit`, lockfiles committed, exact or pinned versions for critical paths, and watch for typosquatting and install scripts. Prefer fewer dependencies.

## Tooling

- Compiler: TypeScript 7 `tsc`. Use `--noEmit` for checking, `--watch` for iteration (rebuilt on a stable cross-platform watcher), and `--singleThreaded` to debug nondeterminism.
- Type-aware linting via typescript-eslint, or Biome or oxlint when speed matters more than type-aware rules.
- Formatting via Prettier or Biome. One formatter, configured once, run in CI.
- Bundlers and dev servers: Vite, esbuild, Rolldown, or the built-in runtimes (Bun, Deno). `tsdown` or `tsup` for libraries.
- Test runner: `vitest`, or the built-in `node:test`. Pick one and run it in CI.
- Runtime: Node.js LTS. Match the runtime target in `tsconfig` `lib` and `target` to the deployment runtime.
- Editor and LSP: the TypeScript 7 language server. Check editor support for embedded languages (Vue, Astro, Svelte, MDX) since those may still require TypeScript 6.0.
- Package manager: match the project (npm, pnpm, yarn, bun). Commit the lockfile. Do not mix package managers.

## Reference Projects

Use these projects as domain references. Match the target project's local style before copying any pattern.

- TypeScript (microsoft/TypeScript and microsoft/typescript-go): the compiler, its configuration surface, and the native port reference.
  - https://github.com/microsoft/TypeScript
  - https://github.com/microsoft/typescript-go
- VS Code: large-scale TypeScript application, extension host boundaries, workspace architecture.
  - https://github.com/microsoft/vscode
- tRPC: end-to-end type safety without code generation, inference-first API design.
  - https://trpc.io/
  - https://github.com/trpc/trpc
- Zod: schema-first validation and inference, the model for runtime-validated boundaries.
  - https://zod.dev/
  - https://github.com/colinhacks/zod
- Effect: typed effects, structured concurrency, and explicit error channels. Use deliberately, not by default.
  - https://effect.website/
  - https://github.com/Effect-TS/effect
- Playwright: typed test and automation API, large monorepo layout.
  - https://playwright.dev/
  - https://github.com/microsoft/playwright
- Prisma and Drizzle: typed database access, generated clients, schema-driven design.
  - https://www.prisma.io/
  - https://orm.drizzle.team/
- Deno standard library: standard-first, Web-compatible APIs, minimal dependencies.
  - https://deno.com/
  - https://github.com/denoland/deno
- Bun: fast runtime, bundler, test runner, and package manager in one tool.
  - https://bun.sh/
  - https://github.com/oven-sh/bun

## Frameworks

Prefer platform APIs and the standard runtime before adding a framework. Use these when domain complexity, team familiarity, or ecosystem fit justifies the dependency.

### Browser And UI

For DOM, accessibility, and CSS discipline, defer to the Web UI rules. The frameworks below are the application-level choices.

- React: component model with the broadest ecosystem. Pair with the current recommended tooling and keep server and client boundaries explicit.
  - https://react.dev/
  - https://github.com/facebook/react
- Solid and Svelte: fine-grained reactivity with compilation. Use when the reactive model fits.
  - https://www.solidjs.com/
  - https://svelte.dev/
- Vue: progressive framework with a gentle adoption curve.
  - https://vuejs.org/
  - https://github.com/vuejs/core
- Angular: opinionated platform with dependency injection, routing, and forms. Use where its structure is a feature.
  - https://angular.dev/
  - https://github.com/angular/angular
- Astro: content-focused, islands architecture, ships less JavaScript by default.
  - https://astro.build/
  - https://github.com/withastro/astro
- Next.js: full-stack React with routing, server components, and rendering strategies.
  - https://nextjs.org/
  - https://github.com/vercel/next.js

### Server And Full-Stack

- Node.js: the LTS runtime baseline. Standard `http`, `fetch`, `node:test`, and `worker_threads` first.
  - https://nodejs.org/
  - https://github.com/nodejs/node
- Hono: small, Web-standard, runtime-agnostic server framework.
  - https://hono.dev/
  - https://github.com/honojs/hono
- Fastify: performance-focused Node server with schema-based validation.
  - https://fastify.dev/
  - https://github.com/fastify/fastify
- Express: minimal, ubiquitous, and stable. Use when compatibility matters.
  - https://expressjs.com/
  - https://github.com/expressjs/express
- NestJS: opinionated, decorator-driven structure with dependency injection.
  - https://nestjs.com/
  - https://github.com/nestjs/nest
- tRPC: type-safe client/server API layer without generated stubs.
  - https://trpc.io/
  - https://github.com/trpc/trpc

### Data, Validation, Testing

- Zod and Valibot: runtime validation and static inference at boundaries.
  - https://zod.dev/
  - https://valibot.dev/
- Prisma and Drizzle: typed ORM and typed query builder respectively.
  - https://www.prisma.io/
  - https://orm.drizzle.team/
- Vitest: fast Vite-native test runner compatible with the Jest API.
  - https://vitest.dev/
  - https://github.com/vitest-dev/vitest
- Playwright: end-to-end and cross-browser testing.
  - https://playwright.dev/
  - https://github.com/microsoft/playwright
- Effect: typed effects and structured concurrency for teams that adopt it deliberately.
  - https://effect.website/
  - https://github.com/Effect-TS/effect

## Standards And Documentation

- TypeScript documentation: https://www.typescriptlang.org/docs/
- TypeScript `tsconfig` reference: https://www.typescriptlang.org/tsconfig/
- TypeScript release notes (7.0): https://devblogs.microsoft.com/typescript/announcing-typescript-7-0/
- TypeScript 6.0 transition (new defaults and removals): https://devblogs.microsoft.com/typescript/announcing-typescript-6-0/
- TypeScript migration notes (6.0 to 7.0 differences): https://github.com/microsoft/typescript-go/blob/main/CHANGES.md
- TypeScript language specification and handbook: https://www.typescriptlang.org/docs/handbook/intro.html
- ECMAScript specification (the language TypeScript targets): https://tc39.es/ecma262/
- MDN JavaScript reference: https://developer.mozilla.org/en-US/docs/Web/JavaScript
- Node.js documentation: https://nodejs.org/docs/latest-v22.x/api/
- Node.js releases and LTS schedule: https://nodejs.org/en/about/previous-releases
- typescript-eslint: https://typescript-eslint.io/
- Biome: https://biomejs.dev/
- Prettier: https://prettier.io/
- Vite: https://vite.dev/
- Vitest: https://vitest.dev/
- Defensively checking dependencies / supply chain: https://socket.dev/ and https://github.com/ossf/scorecard

## Review Checklist

- Does it compile under TypeScript 7 with `strict` and no `tsc --noEmit` errors?
- Is `tsconfig.json` free of removed options and using the new 7.0 defaults intentionally?
- Is `any` absent from application code, with `unknown` narrowed at boundaries?
- Is external input validated by a schema before being typed?
- Is state modeled with discriminated unions rather than contradictory optional fields?
- Are errors real `Error` instances with `cause` and a `[package:Function]` context?
- Are promises awaited or handled, with cancellation propagated through `AbortSignal`?
- Is concurrency bounded for network, filesystem, and database work?
- Are resources (servers, sockets, handles, timers, subscriptions) closed at the owning scope?
- Is CPU-bound work kept off the event loop?
- Are SQL, shell, HTML, and URL outputs built safely rather than by string concatenation?
- Are dependencies pinned, the lockfile committed, and the supply chain audited?
- Is the toolchain local to the project, with one formatter and one linter in CI?
- Is the implementation simpler than the framework or generic helper it could have used?
