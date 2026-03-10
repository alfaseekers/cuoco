# AlfaSeekers Technology Stack

Standard toolchain for all AlfaSeekers Python projects. Copied automatically during `/cuoco:setup`.

## Toolchain

| Category | Tool |
| :--- | :--- |
| Language | Python 3.13+ |
| Package management | [`uv`](https://docs.astral.sh/uv/) |
| Linting & formatting | [`ruff`](https://docs.astral.sh/ruff/) |
| Type checking | [`ty`](https://docs.astral.sh/ty/) |
| Testing | [`pytest`](https://docs.pytest.org/) |
| Git hooks | [`pre-commit`](https://pre-commit.com/) |

## Setup

Run once after cloning:

```bash
bash setup.sh
```

This installs dependencies (`uv sync`) and pre-commit hooks (`pre-commit install --install-hooks`).

## Pre-Commit Hooks

Hooks run automatically on every commit. Do not bypass them with `--no-verify`.

- **ruff-check --fix** + **ruff-format** — lint and format (auto-applied)
- **ty check** — type check; commit is blocked if types fail
- **conventional-pre-commit** — enforces `type: subject` format (no scope); allowed types: `feat`, `fix`, `docs`, `style`, `test`, `chore`
- **no-commit-to-branch** — blocks direct commits to `main`; branch names must match `(feat|fix|docs|style|test|chore)/[a-z0-9-]+`

## Project Layout

Source root is `src/` or `app/`. Use absolute imports relative to the source root:

```python
from data.processor import process_data  # not relative imports
```

One-way dependency flow: entry points import from modules, not the reverse.
