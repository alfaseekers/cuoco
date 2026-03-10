# Python Code Style

This guide reflects the constraints enforced by the AlfaSeekers toolchain (ruff + ty). All rules below are automatically checked on every commit — violations block the commit.

## Annotations

Every function and method must have full type annotations: all parameters and the return type. Use `-> None` explicitly when a function returns nothing. Type-only imports (used only in annotations) must be placed inside an `if TYPE_CHECKING:` block.

```python
from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from mymodule import MyType


def process(data: list[int]) -> dict[str, int]:
    ...
```

## Quotes

Use single quotes for all strings. Use double quotes only for docstrings.

```python
name = 'alfaseekers'        # correct
label = "alfaseekers"       # wrong

def compute() -> int:
    """Return the computed value."""  # correct: double quotes for docstrings
    ...
```

## Exceptions

Always catch specific exception types — never bare `except:` or `except Exception:`. Exception messages must be assigned to a variable before being passed to the exception constructor.

```python
# correct
msg = f'unexpected value: {value}'
raise ValueError(msg)

# wrong
raise ValueError(f'unexpected value: {value}')
```

## Boolean Parameters

Do not use positional boolean parameters. Use keyword-only arguments instead.

```python
# correct
def fetch(*, include_deleted: bool = False) -> list[Record]: ...

# wrong
def fetch(include_deleted: bool = False) -> list[Record]: ...
```

## Imports

Group imports in this order: standard library, third-party, local. Alphabetical within each group. `ruff` enforces this automatically. Avoid wildcard imports (`from x import *`).

## Datetimes

All `datetime` objects must be timezone-aware. Always pass `tz=UTC` or equivalent.

```python
from datetime import UTC, datetime

now = datetime.now(tz=UTC)  # correct
now = datetime.now()        # wrong
```

## Naming

Follow PEP 8 naming enforced by ruff `N` rules: `snake_case` for functions, methods, variables, and modules; `PascalCase` for classes; `ALL_CAPS` for module-level constants.

## Complexity

Keep functions small and focused. Avoid deep nesting. If cyclomatic complexity grows, extract helpers.

## Mutable Defaults

Never use mutable objects as default argument values.

```python
def append(items: list[int] | None = None) -> list[int]:  # correct
    if items is None:
        items = []
    ...

def append(items: list[int] = []) -> list[int]: ...  # wrong
```

## Security

Do not use `assert` outside of test files. Do not use `exec` or `eval`. Do not hardcode secrets or credentials.
