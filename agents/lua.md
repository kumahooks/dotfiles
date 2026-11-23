---
description: Load Lua specific skill
agent: build
---

# Lua
You will internalize the rules below. Then, you will pull the current tree of the project we're at (depth at most 4), and internalize the repository's structure. You will not read any file for now, except the `*.md`s in the root of the project, enough to contextualize yourself with it.

Lua is small, embeddable, and built on one data structure. Tables are arrays, maps, records, sets, and modules. Metatables are the extension mechanism: there are no classes, no exceptions, no threads, and no runtime types beyond the eight basic types. Functions are values, closures carry upvalues, and coroutines carry their own stacks. The host application usually owns the language version, the standard library surface, and the sandbox, so the host wins over the newest release. Prefer plain tables and plain functions over object systems. Lua is strongest when the data is a table, the control flow is explicit, and the C boundary stays thin.

## Hard Standard

Treat idiomatic Lua as the default model.

- Target the Lua the host actually runs. Greenfield standalone or embedded code defaults to Lua 5.5 (5.5.1 is current, 5.4 is end of line at 5.4.9). Neovim and OpenResty ship LuaJIT (Lua 5.1). Roblox ships Luau. Never use 5.5 syntax in a 5.1 host.
- Pin one interpreter per project and record it. There is no ABI compatibility across Lua versions: precompiled chunks do not load across 5.4 and 5.5, and C modules must be recompiled per version. Lua 5.5 also changed the signature of `lua_newstate` and the GC parameter API.
- Follow the reference manual for the pinned version. The manual is the specification; there is no separate standard.
- Format with StyLua, configured in `.stylua.toml`. Set `syntax` explicitly when 5.2 labels and Luau type assertions can be confused. StyLua 2.6 parses 5.1 through 5.4, LuaJIT, and Luau, but not 5.5 `global` declarations.
- Lint with selene, configured in `selene.toml`. luacheck is effectively unmaintained. selene is built on full-moon and also lags 5.5 syntax; do not lint files the parser cannot read.
- Type-check with lua-language-server annotations (`---@class`, `---@field`, `---@param`, `---@return`, `---@generic`) and `.luarc.json`. LuaLS supports 5.5. Annotations are erased; they catch mistakes in the editor and CI, not at runtime.
- Use LuaRocks for dependencies. Commit the rockspec. LuaRocks 3.13 supports Lua 5.5.
- Local project style wins when contributing to an existing Lua project.

Lua is strongest when the table is the data structure, the metatable is the only abstraction, and the host boundary is small. Prefer the standard library and small pure-Lua modules before C extensions and frameworks.

### Lua 5.5 Changes And Incompatibilities

Internalize these; they change how new 5.5 code is written and how 5.4 code migrates.

- `global` is a reserved word. A chunk starts with an implicit `global *`, which declares all free names as read-write globals. `global x` declares one name. `global<const> *` declares every not-yet-declared name as a read-only global. Inside any other global declaration there is no default: every free name must be declared.
- Global declarations are syntactic. `_ENV.X = 1` and `_G.X = 1` still write through the environment table.
- `global function f` translates to `global f; global f = function ...`, so it raises if `f` already holds a non-nil value. `local function f` does not.
- For-loop control variables are read-only. Declare a local with the same name in the body when it must be mutated.
- Named vararg tables: `function f(...args)`. Positional values sit at `1..n` and the count sits at `args.n`. Use `args.n` or `select("#", ...)` for the count; `#args` is a sequence length and is not reliable when the arguments contain `nil`.
- `table.create(nseq [, nrec])` returns an empty table with preallocated capacity. It is a hint, not a limit, and `#` stays 0.
- Major collections in generational mode are now incremental. The `incremental` and `generational` options no longer set parameters; a single `param` option does. There are corresponding C API changes (`LUA_GCPARAM`) and deprecated `lua_resetthread` and `lua_setcstacklimit`.
- `error(nil)` now produces a string message instead of a `nil` error object.
- A `__call` chain is capped at 15 objects.
- `lua_call` and related functions cap `nresults` at 250. Use `LUA_MULTRET` and adjust the stack for more.
- Tooling lags: StyLua and selene, both built on full-moon, do not parse 5.5 `global` declarations as of late 2026. LuaLS does. If the project standardizes on `global`, skip those files in the formatter and linter until the parser catches up; otherwise stay on the implicit `global *` and 5.4-compatible syntax.

## Design Rules

- One data structure: the table. Use it deliberately as array, record, set, queue, or module, and document the invariant the shape implies.
- A module returns a table (or a function) from `require`. Keep `require` free of side effects apart from building that table. Do not use `module()`; it is deprecated in 5.2 and gone from 5.3 onward.
- Prefer 1-based sequences with no holes. `#` is only defined for sequences; any `nil` hole makes it arbitrary.
- Model objects with a plain table plus a metatable for methods, or with functions that take the table explicitly. Skip class emulation unless the domain genuinely needs inheritance.
- Keep `__index` chains shallow. Every miss walks the chain, and a metatable that hides fields makes data flow invisible.
- Set metatables at construction time and keep the constructor local. Do not mutate a shared metatable at runtime to change the behavior of existing objects.
- Annotate object shapes with `---@class` and `---@field` instead of inventing a type system.
- Avoid `goto` except to break out of nested loops or to emulate `continue`. Keep labels local and short.
- Keep modules cohesive and named after what they provide. No `utils.lua` dumping ground.
- Keep the entry chunk thin: parse arguments, wire modules, call one function.
- Prefer descriptive names. Use `snake_case` for locals, functions, and fields; `PascalCase` or `SCREAMING_SNAKE_CASE` for constants.
- No premature abstraction. Three similar blocks before a helper. Closures and tables are cheap enough that deep indirection rarely pays.

## Tables, Metatables, And Values

- Table iteration order is unspecified. Never depend on `pairs` order. Use an explicit array when order matters.
- Do not add keys while iterating with `next` or `pairs`; that is undefined. Assigning to existing fields is allowed. To clear, replace the table or collect keys first.
- `pairs` honors `__pairs` from 5.2 onward. `ipairs` honors `__index` from 5.3 onward. Use `next` or `rawget` to bypass metamethods.
- `__eq` fires only when both operands are tables or both are full userdata and they are not primitively equal. Lua looks up the metamethod on the first operand, then the second, like the arithmetic events. The result is converted to a boolean. Do not depend on equality semantics for distinct metatables across versions; 5.1 and LuaJIT differ.
- `__len` is honored by `#` for tables from 5.2 onward. `rawlen` bypasses it.
- `__gc` runs after the object becomes unreachable, in reverse order of marking, and an error there becomes a warning you cannot catch. A metatable marked before it has a `__gc` field never finalizes, so set the metatable and the metamethods together after construction. Do not rely on finalizers for resource cleanup; use explicit close functions and, on 5.4+, `<close>`.
- Use `<const>` for values that must not be reassigned and `<close>` for resources with a `__close` metamethod. Both are enforced guarantees, not conventions.
- Know the number subtypes from 5.3 onward: `1` is an integer, `1.0` is a float, `/` always produces a float, `//` floors, and `math.type` distinguishes them. `t[1]` and `t[1.0]` are the same key. Do not mix them in arithmetic that must stay integral.
- Bitwise operators exist from 5.3. Lua 5.2 has `bit32`. Plain Lua 5.1 has no standard bit library, and LuaJIT exposes its own `bit` module.
- A multiple-return value truncates to one value except in the last position of an expression list, argument list, or table constructor. Use `select("#", ...)` or pack into a table when the count matters.
- `string.format("%q", string)` is the correct way to quote a Lua string for source and debug output. Do not hand-roll escaping.
- Lua patterns are not regular expressions: no alternation, no anchors beyond `^` and `$`, and no repetition of groups. `%` is the escape, and `%1` to `%9` are captures used as back-references. Keep patterns simple; a hand-written matcher beats a pathological pattern.
- Bound input size before `string.rep`, `string.gsub`, `string.format`, and table construction. Repetition and substitution allocate output proportional to the input.
- `os.date` formats in local time unless the format starts with `!`. `os.time` interprets a date table as local time. Be explicit about UTC at every boundary, and prefer epoch seconds internally.
- `tostring` on floats changed in 5.5 to print enough decimal digits to read back exactly. Do not snapshot float formatting in tests.

## Memory And GC

- Every table and string is a heap object. Reuse tables across frames and requests instead of allocating per call.
- Preallocate when the size is known: `table.create` on 5.5, or one table constructor with all elements. Repeated `t[#t + 1] = value` grows the array part and is fine, but preallocation avoids rehashing.
- Short strings are interned and immutable. Concatenation in a loop is quadratic; collect into a table and `table.concat` once.
- Use weak tables (`__mode = "k"`, `"v"`, or `"kv"`) for caches and back-references. Since 5.2 a weak-key table is ephemeron-like: a value is not kept alive only through its key.
- Bound every cache. A table used as a cache without eviction is a leak with extra steps.
- Drop references explicitly when a long-lived structure should not pin closures, coroutines, or upvalues.
- Call `collectgarbage("collect")` only in tests and shutdown. Do not tune GC parameters without measurement, and re-measure on 5.5.
- `collectgarbage("count")` is a diagnostic, not a budget. Enforce real limits with a custom allocator at `lua_newstate` in embedded code.

## Error Handling

- Raise with `error`, passing a string or a table that carries a `code` and `message` when callers must branch. Include a `[package:Function]` prefix: `error("[config:load] missing key: database_url", 2)`.
- Pass level `2` when the error should point at the caller and the default `1` when it should point at the raise site.
- Pick one convention per module: raise with `error`, or return `nil, err`. Mixing both is a bug factory. Document the choice.
- `pcall` catches everything, including programmer errors. Use it at the boundary that can recover, not as general control flow.
- `xpcall` with `debug.traceback` is the correct handler for logging an unexpected failure once at the top level.
- Never discard the error object from `pcall`. `local ok, result = pcall(f)` must log or return `result` on failure.
- `assert(condition, message)` is fine for preconditions on internal APIs. It is not input validation; it raises, and callers can catch it.
- Add context and traceback at one boundary. Do not log and re-raise the same error at every layer.
- Errors are values. Keep a module's error surface small, and make the shape of an error table consistent across the module.

## Coroutines And Concurrency

- Coroutines are cooperative, single-threaded, and not concurrency. They model generators, iterators, state machines, and producer-consumer pipelines.
- Use `coroutine.create` with `resume` and `status` when you need to inspect failure and state. `coroutine.close` (5.4+) releases a suspended coroutine. `coroutine.wrap` propagates errors to the caller and hides the resume protocol.
- A coroutine cannot yield across a C call boundary unless that C function uses `lua_yieldk` with a continuation. Do not yield from a metamethod or across a `pcall` on 5.1; yieldable metamethods and `pcall` arrived in 5.2.
- Give each coroutine one owner and one resume path. Do not resume the same coroutine from independent tasks.
- A `lua_State` is not thread-safe and belongs to one OS thread at a time. Use one state per thread, or serialize access with a lock. Never touch one state concurrently.
- Real parallelism means threads or processes, each with its own state. Lua has no shared-memory threading model.
- LuaJIT: `jit` is not thread-safe, and FFI callbacks run on the calling thread. Bound any pool built on top.
- OpenResty: `ngx.thread`, `ngx.socket`, cosockets, and timers are the concurrency model. Never block the event loop with `os.execute`, blocking sockets, or CPU-heavy Lua.
- The user runs tests. You wire them up and keep them green.

## C API And Embedding

- Treat the C API as the boundary and keep it thin. Business logic belongs on one side, not smeared across both.
- Every `lua_State` has a stack. Track the top and restore it; `lua_gettop` and `lua_settop` are the discipline. A leaked slot is a leak.
- Check the status of `lua_pcall` and related calls. Use `lua_pcallk` with a continuation when the callee may yield.
- Use the registry (`luaL_ref`, `luaL_unref`) for long-lived Lua values held from C. Never hold a raw C pointer whose owner Lua may collect.
- Userdata owns its C memory and `__gc` frees it. Call `luaL_checkudata` on every entry point; never trust a user-supplied pointer.
- Build strings with `luaL_Buffer`. Never retain a Lua string pointer across an allocation or a call that can collect.
- Never call `lua_*` from a thread that does not own the state, and never from a signal handler.
- The C API is not ABI stable across versions. Pin the interpreter in the rockspec and rebuild C modules per version.
- Open only the libraries the host needs. `luaL_requiref` (5.2+) and `luaL_openselectedlibs` (5.5) let the host choose the surface instead of `luaL_openlibs` everywhere.

## Security

- Treat all external input as hostile: network, files, environment, arguments, and any chunk you did not write.
- Do not run untrusted Lua through `load`, `loadstring`, `dofile`, or `require`. `load` is not a sandbox.
- Load bytecode only from trusted sources. Malformed bytecode can crash the VM. Pass `mode = "t"` to reject bytecode entirely, and prefer source.
- A real sandbox needs a restricted `_ENV` without `os`, `io`, `package`, `debug`, `load`, or `require`; no `package.loadlib`, so no route to C; an allocation limit through a custom allocator; and an instruction budget through a debug hook. `lua_setcstacklimit` is deprecated in 5.5 and was never a memory budget. State plainly that a Lua sandbox is a project, not a flag.
- Randomness: use the host CSPRNG through the C API. Plain Lua has no secure source. `math.random` is not cryptographic, and `math.randomseed` is predictable.
- Never pass untrusted strings to `os.execute`, `io.popen`, or `load`. Use explicit argument vectors through the host API.
- Never assemble SQL by concatenation. Use the driver's parameter binding.
- Do not disable TLS verification in `ssl` or `socket` libraries outside local tests.
- Pin versions in the rockspec, audit dependencies, and prefer fewer rocks. LuaRocks runs rockspec build commands and can fetch arbitrary URLs.
- Validate sizes before building strings, tables, and recursion. The VM is memory-safe, but host code is not, and unbounded recursion still exhausts the C stack.

## Tooling

- Interpreter: `lua` or `luajit`, pinned. Use `lua -e`, `lua -l module`, and `lua -i` for inspection. Use `luac -p` to parse without executing.
- Version detection: LuaJIT reports `_VERSION` as `Lua 5.1`; test `jit ~= nil` instead.
- Formatting: `stylua --check .` in CI. Linting: `selene .` with `selene.toml`.
- Types: `lua-language-server --check .` in CI with a committed `.luarc.json`. The editor gets the same diagnostics live.
- Tests: `busted` (2.3 supports 5.5) for spec-style tests, or `luaunit` for a smaller surface. Use `luacov` for coverage.
- Benchmarks: `hyperfine` around the interpreter and `os.clock` inside. Measure before optimizing; tracing makes intuition unreliable.
- Profiling: `jit.p` and `-jv` on LuaJIT, `debug.sethook` sampling elsewhere, and `perf` for the C side.
- Debugging: `debug.traceback`, `print` at boundaries, and `gdb` or `lldb` against a debug-built interpreter. Do not leave `debug.*` calls in hot paths.
- Package manager: LuaRocks 3.13. Use `luarocks install`, `luarocks make` for a local rockspec, and `luarocks lint` to validate the rockspec. Commit the lock where the workflow supports one.
- The user runs tests. You wire them up and keep them green.

## Dialects

Lua's ecosystem is split by host. Identify the dialect first; these rules refine the ones above.

### LuaJIT (Lua 5.1)

- The performance target for OpenResty and Neovim. Lua 5.1 semantics plus selected 5.2 extensions, with `bit`, `ffi`, and `jit`.
- LuaJIT 2.1 is actively maintained. LuaJIT 3.0 is a long-running rearchitecture with no release date. Do not depend on 3.0 syntax.
- The FFI trades safety for speed. `ffi.cdef` declarations are not checked against the real ABI, and `ffi.cast` is unchecked. Fence FFI behind one small module, validate every pointer and length, and never let a C pointer outlive its allocation.
- Use `jit.off()` around cold or trace-hostile code. Do not build megamorphic call sites and then blame the JIT.
- `ffi.gc` and `__gc` finalizers are ordering hazards. Free explicitly when the lifetime is known.

### Luau (Roblox)

- A typed, sandboxed derivative with incremental GC, `continue`, compound assignment, backtick string interpolation, and a real analyzer (`luau-analyze`).
- Use `--!strict` and annotate public functions. Luau types are checked and erased; they are not a runtime guarantee.
- `require` is path-based and instance-based, not `package.path`. The Roblox sandbox has no `io`, no filesystem or process access, and no `debug`.
- Use `luau-analyze` and StyLua with Luau syntax in CI. Do not apply 5.x idioms that Luau lacks.

### Neovim (LuaJIT, Lua 5.1, by default)

- `vim.*` is the API surface, and configuration plus every plugin share one state. Prefer `vim.api` and `vim.fn` deliberately; avoid building `vim.cmd` strings.
- Do not block the editor. Long work belongs in a job, a timer, or `vim.schedule`. Bound every loop that touches buffers.
- Validate option and API boundaries with `vim.validate`.
- Plugins are libraries: namespace global state, keep setup idempotent, and make teardown possible.

## Reference Projects

Use these as domain references. Match the target project's local style before copying any pattern.

- Lua itself: the canonical implementation, C API design, and the source of truth for semantics.
  - https://www.lua.org/source/5.5/
  - https://github.com/lua/lua
- LuaJIT: tracing JIT, FFI, and the 5.1 dialect used by OpenResty and Neovim.
  - https://luajit.org/
  - https://github.com/LuaJIT/LuaJIT
- OpenResty: Lua on nginx, cosockets, non-blocking I/O, and production HTTP gateways.
  - https://openresty.org/
  - https://github.com/openresty/lua-resty-core
- Kong: API gateway on OpenResty, plugin architecture, declarative configuration.
  - https://konghq.com/
  - https://github.com/Kong/kong
- Neovim: a large Lua codebase embedded in a C editor, with a plugin ecosystem and runtime library.
  - https://github.com/neovim/neovim
- LÖVE: a game framework with a small Lua-facing API over a C++ core.
  - https://love2d.org/
  - https://github.com/love2d/love
- lua-language-server: a Lua implementation of a language server for Lua, including annotation semantics and incremental analysis.
  - https://luals.github.io/
  - https://github.com/LuaLS/lua-language-server
- Penlight: the reference general-purpose Lua library, pure Lua, careful API design.
  - https://github.com/lunarmodules/Penlight
- Lapis: a web framework on OpenResty, with routing and its own ORM layer.
  - https://leafo.net/lapis/
  - https://github.com/leafo/lapis
- Tarantool: an in-memory database that uses Lua for stored procedures.
  - https://www.tarantool.io/
- Lite XL: a small text editor written in C and Lua, with a minimal footprint.
  - https://lite-xl.com/
  - https://github.com/lite-xl/lite-xl
- luarocks: dependency management and rockspec semantics.
  - https://luarocks.org/
  - https://github.com/luarocks/luarocks

## Libraries And Frameworks

Prefer the standard library and small pure-Lua modules. Use these when the host or the domain justifies the dependency.

- lua-resty-core and the `lua-resty-*` family: HTTP, sockets, shared dictionaries, and TLS on OpenResty.
  - https://github.com/openresty/lua-resty-core
- Lapis: web applications on OpenResty.
  - https://leafo.net/lapis/
- lua-cjson: fast JSON with a strict decoder. Prefer it over hand-rolled parsing in OpenResty.
  - https://github.com/openresty/lua-cjson
- dkjson: pure-Lua JSON for portability and forgiving input.
  - https://github.com/lunarmodules/dkjson
- luasocket: blocking sockets and networking outside OpenResty.
  - https://github.com/lunarmodules/luasocket
- LPeg: PEG parsing and the standard way to write real parsers in Lua.
  - https://www.inf.puc-rio.br/~roberto/lpeg/
- Penlight: tables, strings, paths, and functional helpers.
  - https://github.com/lunarmodules/Penlight
- inspect and serpent: value serialization for debug output and fixtures.
  - https://github.com/kikito/inspect.lua
  - https://github.com/pkulchenko/serpent
- luaossl and lua-resty-openssl: TLS and crypto bindings.
  - https://github.com/zhaozg/lua-openssl
  - https://github.com/fffonion/lua-resty-openssl
- busted and luassert: the testing framework and its assertion library.
  - https://lunarmodules.github.io/busted/
- StyLua: formatting.
  - https://github.com/JohnnyMorganz/StyLua
- selene: linting.
  - https://kampfkarren.github.io/selene/
- lua-language-server: types, diagnostics, and editor integration.
  - https://luals.github.io/

## Standards And Documentation

- Lua 5.5 reference manual: https://www.lua.org/manual/5.5/
- What changed in Lua 5.5: https://www.lua.org/manual/5.5/readme.html
- Lua 5.4 reference manual: https://www.lua.org/manual/5.4/
- Lua 5.3 reference manual: https://www.lua.org/manual/5.3/
- Lua 5.1 reference manual (LuaJIT baseline): https://www.lua.org/manual/5.1/
- Lua version history and support status: https://www.lua.org/versions.html
- Programming in Lua (first edition, free): https://www.lua.org/pil/
- Lua source browser: https://www.lua.org/source/5.5/
- Lua C API: https://www.lua.org/manual/5.5/manual.html#4
- Lua users wiki: https://lua-users.org/wiki/
- Lua style guide (lua-users): https://lua-users.org/wiki/LuaStyleGuide
- Roblox Lua style guide: https://roblox.github.io/lua-style-guide/
- LuaJIT documentation: https://luajit.org/docs.html
- LuaJIT FFI semantics: https://luajit.org/ext_ffi_semantics.html
- Luau documentation: https://luau.org/
- Luau type checking: https://luau.org/typecheck
- LuaLS annotations: https://luals.github.io/wiki/annotations/
- StyLua: https://github.com/JohnnyMorganz/StyLua
- selene: https://kampfkarren.github.io/selene/
- busted: https://lunarmodules.github.io/busted/
- LuaRocks: https://luarocks.org/
- LPeg: https://www.inf.puc-rio.br/~roberto/lpeg/
- OpenResty Lua API: https://github.com/openresty/lua-nginx-module

## Review Checklist

- Is the target interpreter version pinned, matched by CI, and used for every syntax decision?
- Does the code avoid 5.5 syntax on LuaJIT, Neovim, and Luau hosts?
- Are global declarations consistent, or absent entirely, with no silent writes to undeclared globals?
- Is every table shape and its invariant explicit, with no reliance on unspecified `pairs` order?
- Are `__index` chains shallow and metatables set once at construction?
- Are object shapes annotated with `---@class` and checked by LuaLS in CI?
- Is the module's failure convention single: raise with `error`, or return `nil, err`, but not both?
- Are errors context-carrying with a `[package:Function]` prefix, and does `pcall` never discard the error?
- Are coroutines single-owner, kept from yielding across C without a continuation, and not used as threads?
- Is there exactly one state per OS thread, with no concurrent access to a `lua_State`?
- Is the C boundary thin, stack-balanced, and free of retained Lua pointers and untrusted userdata?
- Is external input validated before allocation, string building, pattern matching, `load`, and recursion?
- Is untrusted code never run through `load`, `dofile`, or `require`, and is the sandbox surface stated explicitly when one exists?
- Is randomness from the host CSPRNG rather than `math.random`?
- Are SQL, shell, and HTML outputs built with parameterized or structured APIs rather than concatenation?
- Are float formatting and GC behavior left to the pinned version and not asserted in tests?
- Are dependencies pinned in the rockspec, linted, audited, and kept minimal?
- Is the implementation simpler than the class emulation, metatable machinery, or C extension it could have used?
