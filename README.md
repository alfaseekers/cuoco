# Cuoco 🍝 — Context Driven Development for Claude Code

Cuoco ("cook" in Italian) is a structured workflow for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) for organizing and structuring agent-based software development. It organises the software development lifecycle into three phases — **Setup**, **Recipe**, and **Cook** — and tracks all decisions in persistent artifacts in a `.artifacts/` directory.

## Why Cuoco?

AI coding tools produce the best results when they have deep context and a clear plan. Without structure, common failure modes (e.g., wrong assumptions baked in early that cascade through the codebase) often occur.

Cuoco prevents this by enforcing a **research → plan → implement** pipeline where every decision is documented and reviewed before any code is written.

```
  ┌─────────┐      ┌──────────┐      ┌──────────┐
  │  Setup  │─────▶│  Recipe  │─────▶│   Cook   │
  │ (once)  │      │ research │      │implement │
  └─────────┘      │ + plan   │      │ the plan │
                   └──────────┘      └──────────┘
```

## Installation

**Prerequisites:** [Git](https://git-scm.com/) and [Claude Code](https://docs.anthropic.com/en/docs/claude-code)

### Install script

Clone cuoco and run the install script pointing at your project:

```bash
git clone https://github.com/anzamuel/cuoco.git /tmp/cuoco
/tmp/cuoco/install.sh /path/to/your-project
rm -rf /tmp/cuoco
```

Or as a one-liner:

```bash
git clone https://github.com/anzamuel/cuoco.git /tmp/cuoco && /tmp/cuoco/install.sh . && rm -rf /tmp/cuoco
```

Use `--force` to overwrite an existing `CLAUDE.md`:

```bash
/tmp/cuoco/install.sh --force /path/to/your-project
```

### Manual installation

Copy these files into your project:

```
CLAUDE.md                             → project root
.claude/commands/cuoco/setup.md       → .claude/commands/cuoco/
.claude/commands/cuoco/f-recipe.md    → .claude/commands/cuoco/
.claude/commands/cuoco/f-cook.md      → .claude/commands/cuoco/
code-style/*.md                       → code-style/
```

## Quick Start

Once installed, in Claude Code:

```
/cuoco:setup          # One-time: generate product.md, tech-stack.md, feature roadmap
/cuoco:f-recipe       # Research & plan a feature (no code touched)
/cuoco:f-cook         # Implement the approved plan
```

## Commands

### `/cuoco:setup` — Project Initialisation

Run once per project. Cuoco will:

1. Create the `.artifacts/` directory
2. Walk you through an interactive Q&A to understand your project
3. Generate:
   - **`.artifacts/product.md`** — project vision and requirements
   - **`.artifacts/tech-stack.md`** — technology choices and conventions
   - **`.artifacts/feat/index.json`** — feature roadmap with dependency graph
   - **`.artifacts/code-style/`** — fixed code style guides
5. Optionally ingest existing product/brand guidelines

### `/cuoco:f-recipe` — Feature Recipe (Research + Planning)

Prepares everything needed to implement a feature **without touching any source code**:

1. Shows available features (pending status, all dependencies satisfied)
2. You pick one — Cuoco creates the feature branch `feat/<id>`
3. **Research phase**: deep-reads the codebase, investigates APIs and libraries (according to the state at the current date), writes `research.md`
4. **Planning phase**: creates a step-by-step `plan.md` with output contracts and suggested commits
5. You review and approve the plan (or request changes)

> **Key constraint**: During recipe, only files in `.artifacts/` are created or modified. No source code is touched. This ensures you review the approach before implementation begins.

### `/cuoco:f-cook` — Cook (Implementation)

Executes an approved plan:

1. Shows features with status "planned" — you pick one
2. Choose execution mode:
   - **Step-by-step**: pause between steps for your verification
   - **All at once**: run to completion, only stop on errors
3. For each plan step:
   - Implements the described changes
   - Runs tests and type checks continuously
   - Creates atomic conventional commits
   - Updates plan.md progress (`[PENDING]` → `[IN PROGRESS]` → `[DONE]`)

> **Key constraint**: Follow the plan. If the plan is wrong, stop — don't improvise.

## Artifact Structure

```
.artifacts/                           ← hidden directory, tracked normally
├── product.md                        # Project vision, users, features
├── tech-stack.md                     # Language, framework, packages
├── product-guidelines.md             # Brand guidelines (optional)
├── code-style/
│   ├── general.md                    # General coding principles
│   └── <language>.md                 # Language-specific style guide
└── feat/
    ├── index.json                    # Feature registry + dependency graph
    └── <feature-id>/
        ├── research.md               # Deep research findings
        └── plan.md                   # Step-by-step implementation plan
```

### Feature Lifecycle in `index.json`

Each feature progresses through these statuses:

```
pending ──▶ in-recipe ──▶ planned ──▶ in-progress ──▶ done
            (f-recipe)    (approved)   (f-cook)       (complete)
```

A feature can enter `/cuoco:f-recipe` when it is `pending` and all its `depends_on` features are `done`. A feature can enter `/cuoco:f-cook` when it is `planned`.

### Example `index.json`

```json
{
  "features": [
    {
      "id": "data-ingestion",
      "name": "Data Ingestion Layer",
      "description": "Ingest tweets from X via WebSocket and REST endpoints",
      "status": "done",
      "depends_on": []
    },
    {
      "id": "preprocessing",
      "name": "Tweet Preprocessing",
      "description": "Deduplicate, filter, and normalise incoming tweets",
      "status": "pending",
      "depends_on": ["data-ingestion"]
    },
    {
      "id": "market-matching",
      "name": "Market Matching",
      "description": "Match tweets to relevant prediction markets via cross-encoder",
      "status": "pending",
      "depends_on": ["preprocessing"]
    }
  ]
}
```

## Git Architecture

Artifacts live in `.artifacts/`, a hidden directory tracked normally on every branch. No orphan branches, no worktrees — just a dot-prefixed directory that stays out of your way.

Feature branches (`feat/<id>`) contain both code and artifact changes. This keeps things simple: one branch, one history, one `git log`.

## Development Conventions

| Convention | Rule |
|---|---|
| Commits | [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) — `type(scope): subject` |
| Branching | `feat/<feature-id>` from main, merge via PR |
| Main branch | No direct commits — all work goes through feature branches |
| Testing | Write tests wherever possible; each plan step specifies required tests |
| Types | No `any` or `unknown` — maintain strict typing |
| Comments | Only where logic isn't self-evident — don't add boilerplate docstrings |
| Simplicity | KISS — start simple, add complexity only when justified |

## Implementation

Cuoco is implemented as [Claude Code custom slash commands](https://docs.anthropic.com/en/docs/claude-code/custom-commands) in `.claude/commands/cuoco/`:

```
.claude/commands/cuoco/
├── setup.md        →  /cuoco:setup
├── f-recipe.md     →  /cuoco:f-recipe
└── f-cook.md       →  /cuoco:f-cook
```

The commands reference `CLAUDE.md` at the repo root for their operational rules and use the standard Claude Code toolset (file read/write, bash, glob, grep) — no external dependencies beyond Git.

## How Cuoco Uses Agentic AI

Cuoco treats Claude Code as an autonomous agent that can read files, run shell commands, and write code — but deliberately constrains _when_ it may do what. During **Setup**, the agent conducts an interactive interview, synthesises your answers, and generates the foundational artifacts (product vision, tech-stack decisions, feature roadmap). During **Recipe**, the agent is free to explore — it deep-reads source files, greps for patterns, investigates external APIs and libraries — but is strictly forbidden from modifying any source code; its only outputs are research and planning documents. This separation means the agent can do extensive autonomous exploration without the risk of premature or unchecked code changes. Only in the **Cook** phase does the agent gain write-access to the codebase, and even then it is bound to the approved plan: each step has defined inputs, outputs, and tests, so the agent executes deterministically rather than improvising. The result is an agentic loop where the AI has broad autonomy to _think_ but tightly scoped permission to _act_.

## Limitations

**No built-in revert command.** Cuoco does not yet ship a dedicated undo or rollback command. If a cook step produces an undesirable result, you need to revert manually using standard Git operations (e.g., `git revert` or `git reset`). Because the entire workflow is built on Git — with atomic conventional commits per plan step and a 1:1 mapping between code and artifact commits — adding an automated revert command is straightforward and is planned for a future release.

**No graphical user interface.** All interaction with Cuoco happens through the terminal via Claude Code slash commands. There is no web dashboard, visual dependency graph, or point-and-click feature picker. While this keeps the tool lightweight and dependency-free, it means you need to be comfortable working in a terminal environment. The structured artifacts (JSON roadmap, Markdown plans) are designed to be human-readable in any text editor, which partially offsets the lack of a GUI.

---

*Cuoco — read deeply, plan carefully, cook confidently.*
