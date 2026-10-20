# Python

These are my baseline standards for any Python code you write or refactor for me. Follow them unless the surrounding project clearly establishes a different pattern — in which case match the project, but flag the divergence.

## Packaging & tooling

- Use `uv` + `pyproject.toml` (hatchling backend). No `requirements.txt`, no `setup.py`.
- Commit `uv.lock`. CI installs with `uv sync --frozen` and runs with `uv run …`.
- Keep `[tool.uv] exclude-newer = "1 week"` for the supply-chain cooldown (org policy).
- Pin `requires-python` to the actual minimum you're testing against — don't default to the system version.
- Even a small CLI is a package, not a flat folder of scripts: `pkg/`, `pkg/__init__.py`, `pkg/__main__.py`, sibling `tests/`. One CLI entrypoint with `argparse` subparsers — never a script-per-action shelling out to peer scripts.

## Tests

- pytest, never `unittest`. Configure `[tool.pytest.ini_options] testpaths = ["tests"]`.
- Tests live in `tests/`, not next to source.
- Only test public interfaces — private functions, methods, classes, etc should be fully tested by via the public interfaces that invoke them, but the developer must be able to refactor all private definitions without updating any tests
- Group related cases under bare `class TestThing:` blocks (no `TestCase` base). One class per behaviour cluster, methods describe the case.
- Use `@pytest.mark.parametrize` for table-driven cases. If the same fixture data appears in three tests, extract a local builder helper (`_pr(...)`, `_dt(...)`, `_changes_requested(...)`) — keep tests dense and readable.
- Mock with `mock.create_autospec(Client, instance=True)` (typed) — not bare `MagicMock()`.
- Stub module-level functions with `monkeypatch.setattr(module.submodule, "func", mock.Mock(...))` rather than reaching into `sys.modules` or patching by string path.

## Imports & typing

- `from __future__ import annotations` in every module — but only if the project targets Python < 3.14. On 3.14+, PEP 649 makes it unnecessary; omit it.
- **Always import modules, not the definitions inside them.** This is the most important import rule and applies in every direction:
  - Intra-package: `from . import github, slack` then call `github.Client(...)`, `slack.Message(...)`.
  - Cross-package: `from foo import bar` (module), then `bar.thing(...)` — not `from foo.bar import thing`.
  - Stdlib: `import datetime` then `datetime.datetime.now(...)` — not `from datetime import datetime, timedelta`.
  - Typing: `import typing as t` then `t.Any`, `t.Iterable`, `t.Iterator`, `t.Callable` — never `from typing import Any, Iterable, ...`.
  - **Why:** keeps every call site self-documenting about where a name lives, avoids name collisions, makes `monkeypatch.setattr(module.submodule, "func", ...)` patch the right reference (patching the imported name in the consuming module is brittle and a common source of mock-doesn't-take bugs), and avoids the churn of growing `from … import` lists as a module's needs evolve.
  - Narrow exception: a single canonical name used heavily in one module (e.g. a base class you subclass repeatedly) can be imported directly. Default to the rule; reach for the exception only when it makes the call sites materially clearer.
- Modern syntax only: `T | None` (not `Optional[T]`), `list[X]` / `dict[X, Y]` (not `List` / `Dict`), `type Alias = A | B` for sum types.
- Always annotate function signatures, including `-> None`.

## Domain modeling

- Replace stringly-typed states with `enum.StrEnum` + `enum.auto()`. A field whose values are a fixed vocabulary is an enum, not a `str`.
- Model "this is one of these N shapes" as a real sum type: a `type Foo = A | B` alias plus a frozen `@dataclasses.dataclass` per variant, dispatched by `isinstance`. Don't build one god-dataclass with optional fields and an `action: str` discriminator.
- Service objects (clients, classifiers, sweepers) are `@dataclasses.dataclass` classes with dependencies injected through the constructor. No globals, no module-level singletons.
- `@classmethod` factories for alternate construction (`Client.create(repo, token)`, `Message.from_pr(pr, …)`) — keep `__init__` minimal and dataclass-generated.
- Wrap third-party SDKs (e.g. `ghapi`, `boto3`) behind a thin client dataclass with named methods. Don't pass the raw SDK object around the codebase.

**Why:** sum types + enums catch shape errors at the boundary, dataclass clients make testing and dependency injection obvious, and free-function APIs over raw SDKs leak abstraction into every caller.

## I/O boundaries

- Separate pure modules (no I/O, no env, no side effects) from I/O modules. Pure modules should be trivially unit-testable without mocks.
- Read env vars exactly once, in `main()`. Never `MY_TOKEN = os.environ.get(...)` at module top level — it makes the module untestable and the failure mode opaque.
- Wire dependencies in `main()` and pass them down. Subcommands receive their clients as kwargs, not by reaching for globals.
- Use `logging.getLogger(__name__)` (stored as `_LOG`) for diagnostics. Never `print(..., file=sys.stderr)` in library code.

## Functions

- Keyword-only args (`*,`) once a function has more than one non-trivial parameter. Positional args should be self-evident from the call site.
- For required dict fields, do `try: x = d["k"] except KeyError: raise Exception("…")` — don't paper over with `d.get("k") or default` chains. Be explicit about which fields you require.
- Chain exceptions with `raise X from err` when wrapping.
- Use generators (`t.Iterator[X]` return type) for streaming traversals rather than collecting into lists when the caller will iterate once.
- Always start function names with a verb unless the function is a class property, a test fixture, or a builder helper in a test

## Comments & docstrings

- Module-level docstring explains the *why* and the *contract* of the module — what role it plays, what it doesn't do, what invariants callers can rely on.
- Function docstrings are short and only when behaviour is non-obvious. A well-named function with typed args usually needs none.
- Inline comments are rare and call out only the *why*: a subtle invariant, a workaround, a deliberate departure from the obvious approach.
- No banner-style separators (`# ---- env vars ----`). If a module is large enough to need section headers, split it.

## Datetimes

- Use stdlib `datetime.fromisoformat` / `.isoformat()` directly — Python 3.11+ accepts `Z`. Don't write `parse_iso_z` helpers.
- Always tz-aware. Store/transmit in UTC; convert to a display tz only at the formatting boundary.
- Module-level constants for business-time windows / TZ (`BUSINESS_TZ = ZoneInfo("America/Los_Angeles")`), not magic strings inline.

## Style nits

- 100-char line length is the default I'm comfortable with — don't artificially break for an 80-char limit.
- Trailing commas in multi-line literals.
- No unused imports, no unused vars (`_` prefix only for genuinely intentional discards).
- One concept per module file. If two modules import each other, one of them is wrong.
