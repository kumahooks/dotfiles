---
description: Enforce TigerBeetle's Tiger Style on Zig code
agent: build
---

# Tiger Style

Apply these rules to every line of Zig you write or modify. This command is opt-in: use it when the user invokes it or the project declares Tiger Style.

Read the root `*.md` files of the project first. If the project has its own style document, that document wins. Otherwise these rules override `/zig` wherever they conflict.

Upstream source, read it when a rule below is ambiguous:
https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/TIGER_STYLE.md

## Precedence

1. Local project style.
2. Tiger Style, as written here.
3. Idiomatic Zig (`/zig`, Zig Style Guide, `zig fmt`).

Tiger Style deliberately diverges from idiomatic Zig. Do not blend the two:

| Topic | `/zig` default | Tiger Style |
| --- | --- | --- |
| Functions and variables | `camelCase` | `snake_case` |
| File names | `snake_case` | `snake_case` (never `CamelCase.zig`) |
| Types | `TitleCase` | `TitleCase` with proper acronyms (`VSRState`) |
| Allocation | Explicit `Allocator` parameter | Static allocation at startup, no allocation after init |
| Dependencies | Justify a dependency | Zero dependencies |
| Function length | Preference | Hard limit, 70 lines |
| Line length | `zig fmt` | Hard limit, 100 columns |
| Recursion | Allowed | Forbidden |

Do not retrofit existing code to Tiger Style unless asked. Apply it to the code you touch.
Regarding "Function length" and "Line length", as a personal user-chosen style, even when following the Tiger Style, we shall prefer the Zig's default.

## Design Posture

- Optimize for safety, then performance, then developer experience. In that order. Every style decision must advance one of these without regressing an earlier one.
- Treat style as design, not cosmetics. Ask whether a change makes the code more or less safe, more or less performant, easier or harder to operate.
- Hold a zero technical debt policy. Fix a known defect at design or implementation time. Do not ship a known memcpy latency spike, unbounded algorithm, or leaky abstraction to fix later.
- Pay for design upfront. An hour of design is worth weeks of production debugging.
- Reach for the simplest design that satisfies all constraints, then revise it. Simplicity is the last draft, not the first.
- Always state why. Every non-obvious decision gets a comment explaining the rationale, so the reader can evaluate the decision instead of guessing at it.

## Safety

- Use only simple, explicit control flow. Centralize control flow in the parent function and keep leaf helpers free of it. Push `if`s up and `for`s down.
- Never use recursion. Bounded execution must be provable by reading the call graph.
- Put a bound on everything: every loop, queue, buffer, retry, and worker pool gets a fixed upper limit. Fail fast when the limit is violated.
- Assert that event loops and other intentionally non-terminating loops cannot terminate by design.
- Do not react to external events directly. Run at your own pace, batch external work, and bound the work done per unit of time. This keeps control flow in your hands and amortizes cost.
- Keep every function non-suspending so precondition assertions hold for the whole call.
- Treat every compiler warning as an error at the strictest setting.
- Declare variables in the smallest possible scope. Minimize the number of live variables.
- Do not introduce a variable before it is needed. Compute it close to its use. This prevents place-of-check to place-of-use bugs.
- Do not duplicate a variable or alias another one. Duplicated state drifts.
- Shrink function signatures and return types to reduce call-site dimensionality. Prefer `void` over `bool`, `bool` over `u64`, `u64` over `?u64`, and `?u64` over `!u64`.
- Split compound booleans into nested `if`/`else` so each case is visible. Split complex `else if` chains into `else { if { ... } }` trees.
- Give every `if` a matching `else` when the negative space is meaningful, or assert it.
- State invariants positively. Write `if (index < count) ... else ...`, not `if (index >= count)`.
- Zero all padding and fully initialize every buffer. A partially written buffer is a buffer bleed, and it is both a disclosure bug and a determinism bug.
- Apply the inverse-hourglass shape: few parameters, one simple return type, substantial logic in the body.

## Assertions

- Assert every function argument, every return value, every precondition, postcondition, and invariant. A function must never operate blindly on unchecked data.
- Keep assertion density at a minimum of two assertions per function, averaged across the codebase.
- Pair assertions. For each property you enforce, find at least two independent code paths that check it, for example before writing to disk and immediately after reading from disk.
- Split compound assertions. Write `assert(a); assert(b);` instead of `assert(a and b);`. Separate assertions read better and localize the failure.
- Assert implications with a single-line `if`: `if (a) assert(b);`.
- Assert relationships between compile-time constants and type sizes. Compile-time assertions validate design integrity before the program runs.
- Assert both the positive space you expect and the negative space you do not. Bugs live at the boundary where data crosses from valid to invalid.
- Use a blatantly true assertion instead of a comment when the condition is critical and surprising. An assertion enforces; a comment does not.
- Treat assertions as programmer-error detection and crash on failure. Handle operating errors, which are expected, as recoverable. Assertion failures are corrupt state and must not be recovered.
- Do not trust fuzzing. A fuzzer proves the presence of bugs, never their absence. Build the mental model, encode it in assertions, then let simulation testing attack the model.
- Write tests that exercise valid data, invalid data, and the transitions between them. Cover error paths, not just happy paths.

## Memory

- Allocate all memory statically at startup. Allocate nothing and free nothing after initialization. This removes allocator failure modes, use-after-free, and unpredictable latency.
- Size the memory budget for the worst case during design. Design the memory usage pattern before implementation, not after profiling.
- Construct large structs in place through an out pointer, and assume pointer stability. In-place initialization is viral: if one field is initialized in place, initialize the whole container in place.
- Pass arguments larger than 16 bytes as `*const` when the callee must not copy. This catches accidental stack copies at the call site.
- Group resource acquisition and release with blank lines, before the acquire and after the matching `defer`, so leaks are visually obvious.
- Name allocators by role, `gpa`, `arena`, `buffer`, so the reader knows whether `deinit` is required. This applies only where allocation is still permitted, such as startup.
- Keep ownership explicit. Document who owns a pointer and how long it stays valid.

## Types And Arithmetic

- Use explicitly sized types (`u8`, `u32`, `u64`) for everything. Do not use `usize` as a domain type; it makes code depend on the target architecture.
- Treat `index`, `count`, and `size` as distinct concepts even though all three are integers. Define and follow explicit conversion rules: index to count adds one, count to size multiplies by the unit.
- Make rounding intent explicit with `@divExact`, `@divFloor`, and `div_ceil`. A bare division hides which rounding behavior is required.
- Know the size and alignment of every type crossing an ABI, serialization, or persistence boundary.

## Naming

- Use `snake_case` for functions, variables, fields, and file names. The underscore separates words and discourages abbreviation. Do not use `CamelCase.zig` file names.
- Use `TitleCase` for types. Capitalize acronyms correctly: `VSRState`, `ProcessID`, `IoUring`.
- Never abbreviate a name unless it is a primitive integer in a sort or matrix routine. Use full words in scripts and flags: `--force`, not `-f`.
- Put units and qualifiers last, ordered by descending significance, so related names align: `latency_ms_max`, then `latency_ms_min`. Sort every group of related names so the shared prefix lines up.
- Choose names with the same character count for related variables. `source` and `target` beat `src` and `dest`, and keep `source_offset` and `target_offset` aligned in expressions.
- Infuse names with meaning: `gpa`, `arena`, `buffer` instead of a bare `allocator`, so ownership and lifetime are visible at the call site.
- Prefix a helper or callback with its calling function: `read_sector()`, then `read_sector_callback()`.
- Put callbacks last in the parameter list. Callbacks are invoked last.
- Use nouns over adjectives or participles. A noun composes into derived identifiers and reads directly in documentation: `replica.pipeline`, not `replica.preparing`.
- Do not overload one name with two meanings across subsystems. Name the concept once.
- Use the options-struct pattern whenever arguments can be confused. A function taking two `u64`s must take an options struct. Name nullable arguments so `null` reads clearly at the call site. Thread singleton dependencies such as an allocator positionally, from most general to most specific.
- Order declarations for the first top-down read. `main` goes first in the file. In a struct, order fields, then types, then methods, and close the type section with `const Tracer = @This();`. Alphabetize when no better order exists.
- Promote a nested type to a top-level struct when it becomes complex.

## Errors

- Handle every error. Do not swallow, ignore, or log-and-continue past an error you cannot recover from.
- Test error handling code. Most catastrophic production failures are incorrect handling of explicitly signaled, non-fatal errors.
- Recover only from operating errors, at the boundary that owns the recovery. Crash on programmer errors.
- Preserve distinct error values so callers can branch on cause.

## Performance

- Treat performance as a design constraint, not a later optimization. The 1000x wins happen before measurement is possible.
- Sketch performance against the four resources (network, disk, memory, CPU) and their two properties (bandwidth, latency) before writing code. Aim to land within 90 percent of the global maximum.
- Optimize the slowest resource first, in the order network, disk, memory, CPU, adjusted by how often each is used. A cached-miss memory access repeated often can cost as much as a disk flush.
- Separate the control plane from the data plane. Batch both, so assertion coverage stays dense without costing throughput.
- Batch network, disk, memory, and CPU work to amortize per-operation cost.
- Feed the CPU large contiguous chunks of predictable work. Do not make it branch between lanes.
- Extract hot loops into stand-alone functions that take primitives and no `self`. The compiler then needs no proof about struct field caching, and a reader can spot redundant work.
- Be explicit rather than trusting the compiler to infer intent. Pass every option at the call site, for example `@prefetch(a, .{ .cache = .data, .rw = .read, .locality = 3 });` instead of `@prefetch(a, .{});`. Defaults change; explicit options do not.

## Formatting

- Run `zig fmt`. It is non-negotiable.
- Use 4 spaces of indentation. This is `zig fmt` output and also the Tiger Style requirement.
- Hard limit every line to 100 columns with no exceptions. Use the full 100 and never exceed it. To wrap a signature, call, or literal, add a trailing comma and let `zig fmt` break it.
- Add braces to every `if` unless the whole statement fits on one line. This defends against `goto fail` class editing mistakes.
- Comments are prose sentences: a space after the slash, a capital letter, and a full stop, or a colon when they introduce what follows. End-of-line comments may be fragments.
- Comment the why, and also the how. A test starts with a description of its goal and method so a reader can skip it deliberately.
- Write descriptive commit messages. A pull request description is not stored in the repository and does not appear in `git blame`, so it is not a substitute.

## Dependencies And Tooling

- Hold a zero dependency policy. Add a dependency only when the user explicitly accepts the supply chain, safety, performance, and install-time cost, and say so in the change.
- Prefer Zig over a new tool. Write scripts as `scripts/*.zig`, not `scripts/*.sh`, so they are portable and type checked.
- Standardize on a small toolbox. Each additional tool carries maintenance cost.
- Pin the Zig toolchain and match it in CI.

## Review Checklist

- Does every function fit in 70 lines, and does every line fit in 100 columns?
- Is every loop, queue, buffer, and retry explicitly bounded, and are non-terminating loops asserted?
- Is there any recursion, and is every call path provably bounded?
- Does each function assert its arguments, return values, preconditions, postconditions, and invariants, averaging at least two assertions?
- Are assertions paired across independent code paths, split into simple conditions, and covering both positive and negative space?
- Are tests exhaustive over valid data, invalid data, and valid-to-invalid transitions, including error paths?
- Is all allocation done at startup, with no allocation or free after initialization?
- Are structs initialized in place through an out pointer, and are arguments over 16 bytes passed as `*const` when a copy is not intended?
- Is every buffer fully initialized, with no readable padding?
- Are `index`, `count`, and `size` used as distinct concepts, with explicit conversion and explicit rounding?
- Are functions, variables, fields, and files `snake_case`, types `TitleCase` with correct acronyms, and units placed last?
- Are names unabbreviated, non-overloaded, aligned across related variables, and free of context-dependent meaning?
- Are compound booleans split, `else if` chains flattened, and invariants stated positively?
- Is every error handled or deliberately propagated, and is the error path tested?
- Are options passed explicitly at every library call site instead of relying on defaults?
- Are hot loops extracted with primitive arguments and no `self`?
- Does the change add a dependency, and was that cost explicitly justified?
- Does every non-obvious decision carry a comment explaining why?

