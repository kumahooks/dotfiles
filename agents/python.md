---
description: Load Python specific skill
agent: build
---

# Python
You will internalize the rules below. Then, you will pull the current tree of the project we're at (depth at most 4), and internalize the repository's structure. You will not read any file for now, except the `*.md`s in the root of the project, enough to contextualize yourself with it.

Python is explicit, readable, and batteries-included. The Zen of Python (PEP 20) is the standard: explicit over implicit, simple over complex, readability counts. Prefer the standard library, then small focused libraries, then frameworks only when the domain demands them. Modern Python is typed, packaged, and formatted by a single consistent toolchain.

## Hard Standard

- Target Python 3.11 or newer as the baseline. Set `requires-python = ">=3.11"` in `pyproject.toml`. Use 3.12, 3.13, and 3.14 features where the project's floor and deployment allow.
- Follow PEP 8 for style. Let `ruff format` and `ruff check` be the formatting and linting authority; add `--fix` in CI.
- Follow PEP 621 and PEP 517 for packaging. `pyproject.toml` is the single source of project metadata and build configuration.
- Type-annotate all public interfaces. Run `pyright` in strict mode, or `mypy --strict`, as part of CI.
- Manage environments and dependencies with `uv`. Keep a committed lockfile.
- Follow the project's existing style and tooling. Local project style wins when contributing to an existing codebase.
- Prefer modern syntax the baseline supports: `X | None`, `list[int]`, PEP 695 type parameters, `match`, `Self`, `override`.
- Know what each version unlocked: 3.11 brought exception groups, `except*`, `tomllib`, `TaskGroup`, `asyncio.timeout`, and `typing.Self`. 3.12 brought PEP 695 (`class C[T]`, `type X = ...`), `typing.override`, and `itertools.batched`. 3.13 brought free-threaded mode and an improved REPL. 3.14 brought PEP 649/749 deferred annotations, PEP 750 t-strings, PEP 734 subinterpreters, and `compression.zstd`.

## Design Rules

- Keep modules focused. A module is a unit of cohesion, not a junk drawer.
- Make imports explicit. Avoid wildcard imports (`from x import *`) outside `__init__` re-exports that are deliberate and typed.
- Prefer `dataclasses` (or `attrs` when its features fit) for data-holding types. Distinguish mutable (`@dataclass`) from immutable (`@dataclass(frozen=True, slots=True)`).
- Prefer plain functions and small classes over deep inheritance. Use `Protocol` for structural interfaces and ABCs only when runtime enforcement matters.
- Use `match` for structural dispatch, not as a glorified `if`/`elif`.
- Use `Literal`, `Enum`, and `StrEnum` for closed sets instead of bare strings and ints.
- Compose with context managers and iterators. Prefer generators over materialized lists when streaming.
- No premature abstraction. Three similar blocks before a helper or a base class.
- Keep side effects out of import time unless the side effect is the point of the module.
- Avoid mutable module-level state. If process-wide state is required, make it explicit and thread-safe.
- Keep `__main__` thin. Put logic in importable functions and modules.

## Types And Soundness

- Annotate public functions, methods, and data structures. Let local variables infer where obvious.
- Use `X | None` rather than `Optional[X]`, and built-in generics (`list`, `dict`, `tuple`) rather than `typing.List` and friends.
- Use PEP 695 syntax on 3.12+: `class Stack[T]:`, `type Alias = ...`, and `def first[T](items: list[T]) -> T:`.
- Prefer `Protocol` and `runtime_checkable`-free structural typing over inheritance for interfaces.
- Use `TypedDict` for dictionary-shaped records crossing a boundary, `NamedTuple` for lightweight immutable tuples with names.
- Use `Literal` for a fixed set of values. Use `Final` for constants and `ClassVar` for class-level attributes.
- Use `Self` for methods returning the instance type, and `@override` to make overrides explicit.
- Avoid bare `Any`. At untyped boundaries use `object`, then narrow, or `cast` with a comment explaining the invariant. `cast` is an assertion, not a conversion.
- Never silence the type checker with `# type: ignore` without a code and a reason (`# type: ignore[arg-type]  # vendor stub is wrong`).
- Keep `from __future__ import annotations` only when the project needs it for older runtimes. Python 3.14 defers annotation evaluation by default (PEP 649/749); on earlier versions annotations are evaluated eagerly unless quoted or imported from `__future__`.

## Memory And Data Model

- Understand the data model: everything is an object, names are bindings, assignment does not copy.
- Do not use mutable default arguments (`def f(x=[])`). Use `None` sentinels or `dataclasses.field(default_factory=...)`.
- Use `__slots__` (or `@dataclass(slots=True)`) for classes created in large numbers to cut per-instance memory.
- Prefer generators and iterators over building large lists. Use `itertools` and lazy comprehensions.
- Know that closures and module globals retain objects. Avoid long-lived references that prevent collection.
- Use `weakref` for caches and back-references that must not keep objects alive.
- Reference cycles through objects with `__del__` may not be collected promptly. Prefer context managers to finalizers.
- Use `copy.copy` or `copy.deepcopy` deliberately, and know which one you need. Deep copy is expensive; do not reach for it by reflex.
- Prefer immutable data (`tuple`, `frozenset`, frozen dataclasses) for values shared across code.

## Error Handling

- Raise specific exceptions. Define a small exception hierarchy rooted in a project or library base class.
- Catch specific exceptions. A bare `except:` or `except Exception:` hides real bugs; catch what you can handle.
- Chain exceptions with `raise NewError(...) from original` to preserve the cause.
- Use exception groups and `except*` (3.11+) for concurrent tasks with independent failures, and `ExceptionGroup` for aggregation.
- Add context at the point of most information. Use the `[package:Function]` prefix in messages and logs:
  `raise ConfigError("[config:Load] missing key: database_url")`
- Do not log and re-raise the same error at every layer. Log at the boundary that owns recovery.
- Use `contextlib.suppress` for expected, ignorable exceptions rather than an empty `except`.
- Prefer `try`/`except`/`else`/`finally` for clarity, and early returns over deeply nested handlers.
- Use EAFP (try the operation) over LBYL (check first) when a race is possible, but prefer explicit checks when the check is cheap and complete.

## Concurrency

- Choose the tool for the work: `asyncio` for I/O-bound concurrency, threads for blocking I/O, processes for CPU-bound work.
- The GIL serializes CPU-bound threads. Use `multiprocessing` or `concurrent.futures.ProcessPoolExecutor` for CPU parallelism, or free-threaded builds on 3.13+ where the ecosystem supports them.
- Use `asyncio.TaskGroup` and `asyncio.timeout` (3.11+) for structured concurrency and cancellation. Do not leave tasks un-awaited.
- Pass a shared client or connection across coroutines; do not create a new one per call.
- Bound concurrency with `asyncio.Semaphore` or a queue. Do not spawn unbounded tasks.
- Use `contextvars` for request-scoped context. `threading.local` is for threads only.
- Do not block the event loop with synchronous calls. Use `asyncio.to_thread` or an executor for blocking libraries.
- On 3.14, `concurrent.interpreters` and `InterpreterPoolExecutor` give isolation with parallelism in one process. Treat them as an emerging tool; verify third-party compatibility first.
- Treat leaked threads, tasks, and unclosed event loops as resource leaks.

## Packaging And Environments

- One `pyproject.toml` per project. No `setup.py` or `setup.cfg` unless a legacy build backend requires it.
- Use `uv` for environments, dependency resolution, and locking (`uv.lock`). Keep the lockfile committed.
- Use the `src/` layout to prevent accidental imports of uninstalled code.
- Separate runtime dependencies from development dependencies (`[dependency-groups]` or extras). Pin the toolchain.
- Build wheels with `hatchling`, `setuptools`, or `flit`. Choose one and stay with it.
- Follow semantic versioning for libraries. Keep public APIs stable within a major version.
- Never install packages into the system interpreter. Use a project environment.

## Security

- Use `secrets` for tokens, keys, and passwords. Never `random` or the `time` seed.
- Do not use `eval`, `exec`, or `pickle` on untrusted data. Prefer `json`, `msgpack`, or another schema-validated format.
- Use `defusedxml` when parsing untrusted XML. The standard `xml` parsers are vulnerable to entity expansion.
- Never pass untrusted input to `subprocess` with `shell=True`. Pass argument lists, and validate inputs.
- Use parameterized queries for every database driver. Never build SQL by string formatting.
- Do not disable TLS verification (`verify=False`) outside local test code.
- Hash passwords with `hashlib.scrypt`, `argon2-cffi`, or `bcrypt`, never a bare `sha256`.
- Compare secrets with `hmac.compare_digest`. Use `hmac`/`hashlib` for signing, not ad-hoc constructions.
- Validate file paths against traversal. Resolve and confirm the target stays within the intended root.
- Audit dependencies: `pip-audit` or `uv`'s audit, `bandit` for static security checks. Avoid unpinned transitive dependencies.

## Tooling

- Environment and dependencies: `uv`. Fast, reproducible, and lockfile-first.
- Formatting and linting: `ruff format` and `ruff check`. One tool, configured in `pyproject.toml`.
- Type checking: `pyright` in strict mode, or `mypy --strict`. One checker, run in CI.
- Testing: `pytest`. Use `pytest-cov` for coverage and `hypothesis` for property-based tests.
- Test structure mirrors the package under `tests/`. Mark slow and integration tests explicitly.
- Debugging: `breakpoint()` and `pdb`/`pdb++`. Python 3.14 adds the zero-overhead external debugger interface (PEP 768) via `sys.remote_exec` and `python -m asyncio ps`.
- Profiling: `cProfile`, `py-spy`, `scalene`, and `timeit`. Measure before optimizing.
- CLI: `argparse` for the standard library path, `click` or `typer` when ergonomics justify it.
- Match the runtime in CI to the deployment runtime. Test on the oldest supported and the newest version.

## Reference Projects

Use these projects as domain references. Match the target project's local style before copying any pattern.

- CPython standard library: the canonical style, idiomatic use of the data model, and the source of truth for behavior.
  - https://github.com/python/cpython
  - https://docs.python.org/3/library/
- FastAPI and Starlette: async web services, dependency injection, Pydantic-driven validation, ASGI.
  - https://fastapi.tiangolo.com/
  - https://www.starlette.io/
- Pydantic: data validation and settings via type hints, v2 core in Rust.
  - https://docs.pydantic.dev/
  - https://github.com/pydantic/pydantic
- Django: batteries-included web framework, ORM, migrations, admin, and a long-lived, style-disciplined codebase.
  - https://www.djangoproject.com/
  - https://github.com/django/django
- SQLAlchemy: the SQL toolkit and ORM, Core and ORM in 2.0 style.
  - https://www.sqlalchemy.org/
  - https://github.com/sqlalchemy/sqlalchemy
- httpx: modern HTTP client with sync and async APIs, connection pooling.
  - https://www.python-httpx.org/
  - https://github.com/encode/httpx
- attrs and dataclasses: concise, correct data-holding types.
  - https://www.attrs.org/
  - https://docs.python.org/3/library/dataclasses.html
- Rich and Textual: terminal output and TUIs.
  - https://rich.readthedocs.io/
  - https://textual.textualize.io/
- Polars and pandas: columnar data processing and analysis.
  - https://pola.rs/
  - https://pandas.pydata.org/
- Jupyter and NumPy: interactive computing and the array model.
  - https://numpy.org/
  - https://jupyter.org/

## Frameworks

Prefer the standard library for new Python code. Use these when domain complexity, team familiarity, or ecosystem fit justifies the dependency.

- FastAPI: typed async APIs with automatic validation and OpenAPI docs.
  - https://fastapi.tiangolo.com/
  - https://github.com/fastapi/fastapi
- Django: full-stack framework with ORM, admin, auth, and migrations.
  - https://www.djangoproject.com/
  - https://github.com/django/django
- Flask: minimal WSGI framework, large extension ecosystem.
  - https://flask.palletsprojects.com/
  - https://github.com/pallets/flask
- Litestar: ASGI framework with strong typing, DI, and plugin architecture.
  - https://litestar.dev/
  - https://github.com/litestar-org/litestar
- Starlette: lightweight ASGI toolkit for building async services.
  - https://www.starlette.io/
  - https://github.com/encode/starlette
- SQLAlchemy 2.0: Core and ORM with a typed, modern query API. Prefer Core or explicit SQL when control matters.
  - https://www.sqlalchemy.org/
  - https://github.com/sqlalchemy/sqlalchemy
- Pydantic v2: validation, serialization, and settings from type hints.
  - https://docs.pydantic.dev/
  - https://github.com/pydantic/pydantic
- pytest: the testing framework, with fixtures, plugins, and parametrization.
  - https://docs.pytest.org/
  - https://github.com/pytest-dev/pytest
- attrs: dataclasses with validators, converters, and slots.
  - https://www.attrs.org/
  - https://github.com/python-attrs/attrs
- httpx: sync and async HTTP client.
  - https://www.python-httpx.org/
  - https://github.com/encode/httpx
- Click and Typer: command-line interfaces, with Typer adding type-hint-driven ergonomics.
  - https://click.palletsprojects.com/
  - https://typer.tiangolo.com/
- structlog: structured logging with context binding.
  - https://www.structlog.org/
  - https://github.com/hynek/structlog
- Celery: distributed task queues and background work.
  - https://docs.celeryq.dev/
  - https://github.com/celery/celery
- Polars: fast columnar data frames with a lazy query engine.
  - https://pola.rs/
  - https://github.com/pola-rs/polars
- uv: package and project manager, environment, and Python toolchain management.
  - https://docs.astral.sh/uv/
  - https://github.com/astral-sh/uv

## Standards And Documentation

- Python documentation: https://docs.python.org/3/
- The Python Language Reference: https://docs.python.org/3/reference/
- PEP 8, Style Guide for Python Code: https://peps.python.org/pep-0008/
- PEP 20, The Zen of Python: https://peps.python.org/pep-0020/
- PEP 484, Type Hints: https://peps.python.org/pep-0484/
- PEP 604, `X | Y` union syntax: https://peps.python.org/pep-0604/
- PEP 695, Type Parameter Syntax: https://peps.python.org/pep-0695/
- PEP 649, Deferred Evaluation of Annotations: https://peps.python.org/pep-0649/
- PEP 750, Template String Literals: https://peps.python.org/pep-0750/
- PEP 703, Making the GIL Optional: https://peps.python.org/pep-0703/
- PEP 734, Multiple Interpreters: https://peps.python.org/pep-0734/
- PEP 621, Project metadata in `pyproject.toml`: https://peps.python.org/pep-0621/
- Python typing specification: https://typing.python.org/
- What's new in Python 3.11 through 3.14: https://docs.python.org/3/whatsnew/
- Ruff: https://docs.astral.sh/ruff/
- Pyright: https://microsoft.github.io/pyright/
- mypy: https://mypy.readthedocs.io/
- pytest: https://docs.pytest.org/
- uv: https://docs.astral.sh/uv/
- Google Python Style Guide: https://google.github.io/styleguide/pyguide.html
- Python Packaging User Guide: https://packaging.python.org/
- Python Security Best Practices: https://python.readthedocs.io/en/latest/library/security_warnings.html and https://bandit.readthedocs.io/

## Review Checklist

- Does it target Python 3.11+ with a matching `requires-python` and runtime in CI?
- Is `pyproject.toml` the single source of metadata, and does it use modern syntax the baseline supports?
- Are public interfaces fully annotated, and does the type checker pass in strict mode?
- Is bare `Any` absent, and is every `cast` and `type: ignore` justified and scoped?
- Are mutable default arguments and mutable module-level state absent?
- Are errors specific, chained with `from`, and do they carry `[package:Function]` context?
- Are exceptions caught specifically, with no bare `except` swallowing bugs?
- Is concurrency matched to the workload (async, threads, processes), bounded and cancellable?
- Are `TaskGroup`, timeouts, and shared clients used instead of unbounded task spawning?
- Is randomness from `secrets`, and are secrets compared with `hmac.compare_digest`?
- Are `eval`, `exec`, `pickle`, and `shell=True` avoided on untrusted data?
- Are SQL queries parameterized and untrusted paths validated against traversal?
- Are dependencies locked, pinned, and audited, and is the environment isolated from the system interpreter?
- Is the implementation simpler than the framework, base class, or abstraction it could have used?
