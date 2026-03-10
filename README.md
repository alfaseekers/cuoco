# AlfaSeekers Cuoco

Context-driven development workflow for Claude Code at AlfaSeekers. Three phases — **Setup**, **Recipe**, **Cook** — enforcing research → plan → implement with red/green TDD.

```
  ┌─────────┐      ┌──────────┐      ┌──────────┐
  │  Setup  │─────▶│  Recipe  │─────▶│   Cook   │
  │ (once)  │      │ research │      │ red/green│
  └─────────┘      │ + plan   │      │   TDD    │
                   └──────────┘      └──────────┘
```

## Installation

```bash
git clone git@github.com:alfaseekers/cuoco.git /tmp/cuoco
/tmp/cuoco/install.sh /path/to/your-project
rm -rf /tmp/cuoco
```

Use `--force` to overwrite an existing `CLAUDE.md`:

```bash
/tmp/cuoco/install.sh --force /path/to/your-project
```

## Commands

```
/cuoco:setup      # One-time: generate product.md, link to alfaseekers/artifacts
/cuoco:f-recipe   # Define and plan a feature (no code touched)
/cuoco:f-cook     # Implement the approved plan with red/green TDD
```

## Artifact Structure

All artifacts sync to `alfaseekers/artifacts`. Org-wide files live at the repo root; project-specific files are namespaced by project name.

```
.cuoco/
├── artifacts/                  ← clone of alfaseekers/artifacts
│   ├── tech-stack.md          ← org-wide; seeded once
│   ├── code-style/            ← org-wide; seeded once
│   │   ├── general.md
│   │   └── python.md
│   └── <project-name>/
│       ├── product.md
│       └── feat/
│           ├── index.json     ← grows with each f-recipe run
│           └── <feature-id>/
│               ├── research.md
│               └── plan.md
└── references/                 ← canvas; clone repos here while working
    └── <repo-name>/
```

## References

Clone any repo to `.cuoco/references/<name>` and the agent will read from it during recipe and cook:

```bash
git clone <url> .cuoco/references/<name>
```

## Plan Format (RED/GREEN TDD)

```
## Step N — Title [PENDING]

What gets built.
Dependencies — prior step numbers, or "None".

### RED [PENDING]
Tests to write. Must fail before implementation begins.

### GREEN [PENDING]
Minimum implementation to make RED tests pass.

Output contract — tests pass, commands succeed.
```

Status progression: `[PENDING]` → `[RED]` → `[GREEN]` → `[DONE]`
