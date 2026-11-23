---
description: Load C specific skill
agent: build
---

# Modern C
You will internalize the rules below. Then, you will pull the current tree of the project we're at (depth at most 4), and internalize the repository's structure. You will not read any file for now, except the `*.md`s in the root of the project, enough to contextualize yourself with it.

C is small, explicit, and unforgiving in the right way. Idiomatic C reads like the machine, minus only the noise the compiler can already handle. Prefer standard C plus one good library over frameworks. raylib is the reference ecosystem for games in C.

## Hard Standard

- Target C17 as the default baseline. Use C23 where toolchains support it (`auto` type inference, `nullptr`, attributes, `[[noreturn]]`, digit separators).
- Compile with `-Wall -Wextra -Wpedantic` at minimum. Treat warnings as errors in CI.
- Follow the project's style when one exists. Otherwise default to a single convention: `snake_case` for functions and variables, `SCREAMING_SNAKE` for macros and constants, `_t` suffix reserved for typedef names (POSIX).
- One header per module, one `.c` per header. Headers declare the API; the `.c` hides internal helpers in `static`.
- `clang-format` is the formatting authority when a `.clang-format` exists.
- Local project style wins when contributing to an existing codebase.

## Design Rules

- Small modules, no inheritance. Functions and structs over class patterns. Polymorphism through vtable structs or tagged unions when genuinely needed.
- Hide internals: `static` for file-scope functions and globals, opaque structs for types whose fields callers never touch.
- No premature abstraction. Three similar blocks before a helper.
- Avoid macros for anything a function, enum, or `static inline` can do. Macros are for conditionals (`#ifdef`), platform code compilation, and X-macros, not for logic.
- Prefer `const` correctness everywhere. Annotate pointer parameters with `const` whenever the pointee is not mutated.
- Fixed-width integer types (`uint32_t`, `int64_t`) in interfaces. `int` and `size_t` for loop indices and byte counts. Never rely on `char` signedness.
- Structs passed by value must be small. Otherwise pass by pointer.
- Avoid single-use getters and setters over plain public structs. Keep things plain unless an invariant needs enforcing.

## Memory

- Every heap allocation answers to one owner. Ownership transfers are explicit in the API contract.
- Free on every exit path, not only the successful one. `goto cleanup` is the accepted C pattern for multi-exit unwinding.
- Prefer arena (region) allocation for game/app data with a shared lifetime: allocate per frame or per level, reset wholesale, free the arena at shutdown. Per-object `malloc/free` only for long-lived or external-facing resources.
- Check every `malloc`, `realloc`, and `calloc` result. Handle failure at the boundary, not six frames up.
- Never `realloc` into a caller's data without handling the failure case: assign to a temporary first.
- Prefer pointer + length (`ptr`, `len`) inside engine and game code. Reserve `NULL`-terminated strings for genuine string boundaries.
- Zero-initialized `calloc` or `memset` beats manual field-by-field init for large struct setup. Static initialization to `= {0}` is idiomatic.

## Undefined Behavior And Correctness

- UB is the enemy. `-fsanitize=undefined` in debug builds is not optional for new code.
- No signed overflow, no shift past width, no null deref, no use-after-free, no OOB indexing, no strict-aliasing violations, no uninitialized reads. Each of these can and will break in the next compiler version instead of this one.
- `-fno-strict-aliasing` or careful `memcpy` when aliasing is intentional; never rely on type punning through unions in production code.
- `volatile` is for hardware access, not for synchronization.
- Atomics and threads come from C11 `<threads.h>` or pthreads. Do not improvise synchronization with `volatile`.

## Error Handling

- Return error codes (`int`/`enum`) or success flags; do not fake exceptions with `setjmp/longjmp` outside genuine stack jump problems.
- Log error context at the point you have the most information. `[package:Function]` prefix applies here too:
  `fprintf(stderr, "[engine:world_init] failed to load map: %s\n", path);`
- Do not double-log the same failure at multiple layers.
- `assert` for programmer errors and invariants only. Never for runtime failure the user can cause, and never for side effects inside the assert expression (asserts evaporate under `NDEBUG`).
- Prefer early returns over nested control flow.
- Close resources (`FILE*`, raylib textures, shaders, windows) at the scope that owns them.

## Security

- Treat every external input as hostile. Validate length before allocation, copy, or parse.
- Prefer `snprintf`, `memcpy` with explicit bounds, and careful index math over `sprintf`, `strcpy`, `strcat`, or `gets`.
- `strncpy` and `strncat` are not "safe strcpy": they do not guarantee null termination. Know what you call.
- Do not roll your own crypto. Use libsodium first, mbedTLS/OpenSSL second; prefer system libraries over vendored forks.
- Randomness: `/dev/urandom` or `getrandom()`, not `rand()`.
- Do not invoke `system()` for anything attacker-influenced. Use `execve`-style APIs with explicit argument vectors.

## Tooling

- Build: prefer a simple hand-rolled `Makefile` or `meson` for new projects. CMake only when ecosystem integration demands it.
- Static analysis: `-fanalyzer` (GCC), Clang Static Analyzer, `clang-tidy` with `bugprone-*` and `performance-*` checks.
- Dynamic analysis: AddressSanitizer, UndefinedBehaviorSanitizer, Valgrind/Memcheck for release-candidate correctness.
- Debugging: `gdb` (or `lldb`). Learn `bt`, `up/down`, `print`, `watch`, `info locals`. Debug symbols with `-g -O0` in debug builds.
- Release: `-O2`, LTO off unless profiling says otherwise, strip for shipping.
- LSP: `clangd`. Generate `compile_commands.json` with `Bear` or the build system itself.

# Game Development With raylib

raylib is the reference framework for C game development. Simple, flat API, no engine object graph, no data-driven configuration. The pattern is: handle input, update state, draw, repeat.

## raylib Principles

- Keep the main loop simple: `InitWindow`, `while (!WindowShouldClose())`, update, `BeginDrawing`/`EndDrawing`, `CloseWindow`. No engine classes, no scene graphs unless the game truly wants them.
- Prefer data-oriented design: struct arrays (SoA or AoS) over pointer graphs per entity. Iterate arrays, not object trees.
- Load resources once at startup into a pool, not per frame in the update path. Unload at the matching scope that owns them.
- Fixed timestep with accumulator when determinism or consistent physics matters (see "Fix Your Timestep" below).
- Entity pattern via plain struct arrays and a live count, not pointers into a heap, unless the game genuinely outgrows an array-with-holes layout.
- Camera state in a `Camera2D` or `Camera3D`, not custom matrices, until the game needs more than the built-in provides.
- Use `raygui` for debug overlays, level editors, and tooling UI inside the running game. Do not invent your own widget library.
- No game logic inside `BeginDrawing`/`EndDrawing`. Separate update and draw paths.

## Game Dev C Resources

- raylib docs, examples, and cheatsheet: https://www.raylib.com/
- raylib GitHub: https://github.com/raysan5/raylib
- raylib cheatsheet (single-page API reference): https://www.raylib.com/cheatsheet/cheatsheet.html
- raylib examples (in C, comprehensive): https://www.raylib.com/examples.html
- raylib game template (project skeleton starter): https://github.com/raysan5/raylib-game-template
- raygui - instant-mode GUI in pure C, pairs with raylib: https://github.com/raysan5/raygui
- Handmade Hero (Casey Muratori): full game from scratch in C, platform layer, renderer, memory, profiling. The reference for what is idiomatic game C: https://handmadehero.org/
- Game Programming Patterns (Robert Nystrom): free online book, the patterns that actually show up in game code (game loop, update method, component, event, spatial partition): https://gameprogrammingpatterns.com/
- Fix Your Timestep (Glenn Fiedler): canonical article on game loop timing determinism: https://gafferongames.com/post/fix_your_timestep/
- Data-Oriented Design (Richard Fabian): how game data layout drives performance: https://www.dataorienteddesign.com/dodbook/
- Mike Acton, CppCon 2014, "Data-Oriented Design and C++": classic talk on game code as data transformation: https://www.youtube.com/watch?v=rX0ItVEVjHc
- stb libraries (stb_image, stb_truetype, stb_vorbis, stb_ds): public domain single-header libraries. The standard way to handle assets in small C games: https://github.com/nothings/stb
- miniaudio: single-header audio engine, common raylib pairing: https://github.com/mackron/miniaudio
- Dear ImGui: immediate mode GUI for debug tools, level editors, inspectors: https://github.com/ocornut/imgui
- SDL: alternative to raylib when more low-level platform abstraction, windowing, audio, input is required. More manual, more flexible: https://libsdl.org/

## Reference Projects

Use these as domain references. Match the target project's local style before copying any pattern.

- raylib itself: flat API design, no abstraction layers, resource management, platform abstraction behind a uniform surface.
  - https://github.com/raysan5/raylib
- Doom (id Software, 1993): canonical game C, arena-style memory, fixed timestep, data tables, no malloc-heavy design.
  - https://github.com/id-Software/DOOM
- Quake (id Software, 1996): BSP rendering, networked game state determinism, console command system.
  - https://github.com/id-Software/Quake
- Quake III Arena: network model, fixed-point math, fast inverse square roots.
  - https://github.com/id-Software/Quake-III-Arena
- stb libraries: how to write small, self-contained, single-header C that compiles everywhere.
  - https://github.com/nothings/stb
- PostgreSQL: large-scale C, memory contexts (arena-like), error signaling (`ereport`), extensive invariants.
  - https://www.postgresql.org/
- Git: large-scale C, explicit ownership, no framework, careful string and path handling.
  - https://github.com/git/git
- SQLite: strict coding rules, exhaustive test discipline: https://sqlite.org/style.html
- curl: large-scale C, careful API design, fuzzing infrastructure, security-first engineering.
  - https://github.com/curl/curl
- Lua: minimal interpreter design, clean C API boundaries, garbage collector integration, register-based VM.
  - https://www.lua.org/
- FFmpeg: performance-oriented C, SIMD integration, data-layout-driven design, massive cross-platform test matrix.
  - https://github.com/FFmpeg/FFmpeg
- miniaudio: single-header audio engine, clean public API, callback architecture.
  - https://github.com/mackron/miniaudio

## Standards And Documentation

- cppreference (C section, not just C++): authoritative reference for libc, headers, and language rules: https://en.cppreference.com/w/c
- GCC manual (C dialects, warnings, sanitizers): https://gcc.gnu.org/onlinedocs/gcc/
- Clang manual and sanitizers: https://clang.llvm.org/docs/
- clang-format: https://clang.llvm.org/docs/ClangFormat.html
- clang-tidy checks: https://clang.llvm.org/extra/clang-tidy/
- POSIX reference (for system-level C): https://pubs.opengroup.org/onlinepubs/9799919799/
- CERT C Secure Coding Standard: https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88487970
- Valgrind: https://valgrind.org/
- Meson: https://mesonbuild.com/
- CMake: https://cmake.org/
- Bear (generate compile_commands.json for clangd from any build tool): https://github.com/rizsotto/Bear

## Review Checklist

- Compile with `-Wall -Wextra -Wpedantic`, zero warnings?
- Sanitizer runs clean (`-fsanitize=address,undefined`) on main code paths?
- Every allocation has a matching free on every exit path?
- Ownership explicit where pointer transfer happens?
- `const` correctness applied to pointer parameters?
- No macros where functions, enums, inlines would do?
- External input length-validated before allocation/copy?
- No UB on any path (signed overflow, OOB, aliasing, uninitialized)?
- Build simple (Makefile/meson) or justified CMake?
- If raylib: resources loaded once, unloaded at matching scope, no allocations per frame unless intentional and profiled?
- If raylib: frame loop simple, update and draw separated, no game logic inside `BeginDrawing`/`EndDrawing`?
