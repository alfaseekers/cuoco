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

Clone and install into your project:

```bash
git clone git@github.com:alfaseekers/cuoco.git /tmp/cuoco
/tmp/cuoco/install.sh /path/to/your-project
rm -rf /tmp/cuoco
```

Or as a one-liner:

```bash
git clone git@github.com:alfaseekers/cuoco.git /tmp/cuoco && /tmp/cuoco/install.sh . && rm -rf /tmp/cuoco
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

## Artifacts

All artifacts sync to `alfaseekers/artifacts` — the org-wide knowledge base. Each project gets a namespace derived from its git remote URL.

```
.cuoco/                         ← gitignored in project repos
├── artifacts/                  ← clone of alfaseekers/artifacts
│   └── <project-name>/
│       ├── product.md
│       ├── tech-stack.md
│       ├── code-style/
│       └── feat/
│           ├── index.json      ← feature registry (grows with each f-recipe)
│           └── <feature-id>/
│               ├── research.md
│               ├── plan.md
│               └── references.md
└── references/                 ← local repo clones for agent inspection
    └── <repo-name>/            ← added only on explicit request
```

## References

To make a codebase available to the agent during research or implementation:

```bash
git clone <url> .cuoco/references/<name>
```

The agent will detect it automatically on the next `/cuoco:f-recipe` run and list it in `references.md`.

## Plan Format (RED/GREEN TDD)

Every plan step has two mandatory substeps:

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
