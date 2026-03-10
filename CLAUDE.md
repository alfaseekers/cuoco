# AlfaSeekers Development Workflow

AlfaSeekers uses a three-phase context-driven development workflow: setup, recipe, cook. Code is never written before a reviewed plan exists. All artifacts live in `.cuoco/artifacts/`, a directory gitignored from project repos and synced to `alfaseekers/artifacts`.

---

# Principles

- No code before plan. Never write or modify source code until a plan exists and the user has approved it.
- Artifacts are the source of truth. Every decision, finding, and plan is persisted to a file in `.cuoco/artifacts/`. Chat is ephemeral; artifacts survive context compaction and session boundaries.
- Branch-driven development. Every feature lives on its own branch (`feat/<id>`). No direct commits to main.
- KISS. Start with the simplest implementation that satisfies current requirements. Complexity needs a demonstrated, concrete justification.
- YAGNI. Do not implement anything that isn't required right now. No speculative APIs, no unused parameters, no future-proofing hooks. Every line of code must serve a current, concrete requirement.

---

# Git

## Conventions

Commits follow Conventional Commits (https://www.conventionalcommits.org/en/v1.0.0/). Format: `type: subject` — scope is omitted. Allowed types: feat, fix, docs, style, test, chore. Each commit is atomic — one logical change. Do not append Co-Authored-By lines to commit messages. Do not use `--no-verify` — pre-commit hooks (ruff, ty, commit-msg validation) run on every commit and must pass.

Feature branches: `feat/<feature-id>` where feature-id matches the id field in `.cuoco/artifacts/<project>/feat/index.json`. Branches are created from main and merged back via PR. No commits to main directly.

## Artifacts Sync

`.cuoco/artifacts/` is a git clone of `alfaseekers/artifacts` (github.com/alfaseekers/artifacts). Pull at the start of each phase. Push at the end of each phase. If the user asks to push artifacts at any point mid-session (e.g. "push artifacts", "sync artifacts"), run `git -C .cuoco/artifacts push` immediately.

Project namespace within the artifacts repo is derived from the git remote URL: the repo name extracted from `git remote get-url origin`.

---

# Workflow

Three commands: `/cuoco:setup` (one-time project init), `/cuoco:f-recipe` (research and planning for one feature), `/cuoco:f-cook` (implementation of a planned feature). Setup runs once. Recipe and Cook alternate for each feature.

## `cuoco:setup`

### Purpose

One-time project initialisation. Creates the `.cuoco/` directory, links to the alfaseekers/artifacts repo, and generates foundational project documents.

### Preconditions

A Git repository must exist.

### Steps

1. Bootstrap: add `.cuoco/` to `.gitignore`, clone `alfaseekers/artifacts` into `.cuoco/artifacts/`, create project namespace directory.
2. Seed org-wide artifacts at the artifacts repo root (idempotent — skip if already present): copy `tech-stack.md` → `.cuoco/artifacts/tech-stack.md`; copy `code-style/general.md` and `code-style/python.md` → `.cuoco/artifacts/code-style/`.
3. Interactive Q&A — ask the user about the project:
   - What does the project do? Who is it for?
   - What are the core features / capabilities?
   - What does success look like? Key constraints?
4. Generate `.cuoco/artifacts/<project>/product.md` from the answers.
5. Ask the user whether to use the standard product guidelines or provide their own. If standard: copy the bundled guidelines. If custom: ask the user to provide content or point to a file. If neither: skip.
6. Create an empty feature registry at `.cuoco/artifacts/<project>/feat/index.json`. Features are defined later, one at a time, when running `/cuoco:f-recipe`.
7. Push all artifacts to `alfaseekers/artifacts`.

### Output

`.cuoco/artifacts/tech-stack.md`, `.cuoco/artifacts/code-style/*.md` (org-wide, seeded once). `.cuoco/artifacts/<project>/product.md`, `feat/index.json` (empty). All pushed to `alfaseekers/artifacts`.

---

## `cuoco:f-recipe`

### Purpose

Define and plan a single feature. Produces `research.md` and `plan.md`. No source code is created or modified.

### Preconditions

`/cuoco:setup` must have been run.

### Steps

1. Pull `.cuoco/artifacts/` from `alfaseekers/artifacts`.
2. Ask the user: "What feature do you want to work on? Give it a name and a one-sentence description." Derive a kebab-case `feature-id` from the name. Optionally ask if this depends on any features already in `index.json`.
3. Add a new entry to `feat/index.json` with status `"in-recipe"`. Create the feature branch `feat/<feature-id>` from main. Create the directory `.cuoco/artifacts/<project>/feat/<feature-id>/`.
4. RESEARCH PHASE — read the codebase deeply. Investigate relevant APIs and libraries. Read `.cuoco/artifacts/tech-stack.md` and `.cuoco/artifacts/code-style/` for context. If `.cuoco/references/` exists and contains repos, read from them as additional context. Write findings to `research.md`. The research must be detailed enough that an implementer can write code without consulting external docs.
5. PLANNING PHASE — create `plan.md` using the RED/GREEN step format (see Plan Format section).
6. Present the plan to the user. Revise until approved.
7. Set feature status to `"planned"` in `index.json`.
8. Push artifacts to `alfaseekers/artifacts`.

### Constraints

CRITICAL: During this entire phase, do NOT create, modify, or delete any source code files. Only files under `.cuoco/artifacts/` may be touched. If you find yourself wanting to write code, STOP and write it into the plan instead.

### Output

`research.md`, `plan.md`. Feature status `"planned"` in `index.json`. All pushed to `alfaseekers/artifacts`.

---

## `cuoco:f-cook`

### Purpose

Implement a planned feature by executing its `plan.md` using red/green TDD.

### Preconditions

At least one feature in `feat/index.json` must have status `"planned"` with both `research.md` and `plan.md` present in its directory.

### Steps

1. Pull `.cuoco/artifacts/` from `alfaseekers/artifacts`.
2. Read `feat/index.json`. List features with status `"planned"`. Auto-select if only one; otherwise ask user.
3. Ask the user which execution mode: step-by-step or all at once.
4. Check out the feature branch: `git checkout feat/<feature-id>`.
5. Load context: `research.md`, `plan.md`, `.cuoco/artifacts/tech-stack.md`, `.cuoco/artifacts/code-style/`. If `.cuoco/references/` exists, read from relevant repos as needed.
6. Set feature status to `"in-progress"` in `index.json`.
7. For each step in `plan.md`, in order:
   a. Mark step [RED] in `plan.md`. Commit.
   b. Write the failing tests from the RED section. Run them — they must fail.
   c. Commit the failing tests.
   d. Mark step [GREEN] in `plan.md`. Commit.
   e. Write the minimum implementation from the GREEN section. Run tests — they must pass. Run type checks.
   f. Commit implementation.
   g. Mark step [DONE] in `plan.md`. Commit.
   h. If step-by-step: summarise what was done, which tests pass, what comes next. Offer to push artifacts. Wait for approval.
8. Set feature status to `"done"` in `index.json`.
9. Push artifacts to `alfaseekers/artifacts`.

### Constraints

Follow the plan. If the plan is wrong or incomplete, STOP and tell the user. Do not improvise or go beyond what the plan specifies. The user can update the plan manually or re-run `/cuoco:f-recipe`.

If the user says "push artifacts" or "sync artifacts" at any point, run `git -C .cuoco/artifacts push` immediately.

### Output

Feature implemented on `feat/<feature-id>` branch with atomic conventional commits. `plan.md` fully marked [DONE]. Feature status `"done"` in `index.json`. Pushed to `alfaseekers/artifacts`.

---

# Artifacts

## Structure

```
.cuoco/
├── artifacts/                  ← git clone of alfaseekers/artifacts
│   ├── tech-stack.md          ← org-wide; seeded once during setup
│   ├── code-style/            ← org-wide; seeded once during setup
│   │   ├── general.md
│   │   └── python.md
│   └── <project-name>/        ← derived from git remote URL
│       ├── product.md
│       ├── product-guidelines.md (optional)
│       └── feat/
│           ├── index.json     ← starts empty; entries added per f-recipe run
│           └── <feature-id>/ ← matches branch feat/<feature-id>
│               ├── research.md
│               └── plan.md
└── references/                 ← canvas; clone repos here while working
    └── <repo-name>/
```

## product.md

The project vision document. Describes what the system does, who it is for, core features, success criteria, and key design principles. Generated during `/cuoco:setup` via interactive Q&A. Updated when the product vision changes, not when implementation details change.

## tech-stack.md

AlfaSeekers standard technology stack. Lives at the root of `alfaseekers/artifacts` — shared across all projects, seeded once during the first project setup. Read by agents during recipe and cook for toolchain context.

## code-style/

AlfaSeekers code style guides. Lives at the root of `alfaseekers/artifacts` — shared across all projects, seeded once during the first project setup. `general.md` applies universally; `python.md` applies to all AlfaSeekers Python projects.

## feat/index.json

The feature registry. Initialised as `{"features": []}` during setup. Each `/cuoco:f-recipe` run adds one entry:

```json
{
  "id": "lowercase-kebab-case string, used as branch name suffix in feat/<id>",
  "name": "Human-readable feature name",
  "description": "One-sentence description",
  "status": "in-recipe | planned | in-progress | done",
  "depends_on": ["array", "of", "feature", "ids"]
}
```

## feat/<id>/research.md

Research record for a feature. Documents what was found: API response shapes, library capabilities and limitations, architectural tradeoffs, technology rationale. Dense technical prose. Decisive language — when a tool has been chosen, state it as fact with rationale ("we use X because Y"), not as one option among many. Detail level: an implementer can write code without consulting external documentation. Closes with a ## References table (columns: Reference, URL).

## feat/<id>/plan.md

Implementation roadmap for a feature. Opens with a preamble paragraph summarising the feature and step dependency order. Then one section per step using the RED/GREEN format (see Plan Format section).

---

# References

`.cuoco/references/` is a canvas directory. Clone any repo there while working — the agent will read from it during recipe and cook when relevant. No tracking file is generated.

To add a repo: `git clone <url> .cuoco/references/<name>`

---

# Plan Format

Plan steps use the RED/GREEN TDD format:

```
## Step N — Title [STATUS]

What gets built — modules, classes, functions at implementation-ready detail.
Dependencies — prior step numbers, or "None".

### RED [STATUS]

Tests to write. Specific test file, test names, and what each assertion verifies.
These tests must fail before any implementation is written.
Suggested commits (red phase).

### GREEN [STATUS]

Minimum implementation to make the RED tests pass. Nothing beyond what the tests require.
Suggested commits (green phase).

Output contract — definition of done as observable behaviour (tests pass, commands succeed).
```

STATUS values: [PENDING] → [RED] → [GREEN] → [DONE]. A step reaches [DONE] only when all GREEN-phase tests pass.

---

# Code Style

Style guides live at `.cuoco/artifacts/code-style/`. Read them before writing any code. `general.md` applies universally; `python.md` applies to all AlfaSeekers Python projects.

---

# Testing

Write tests wherever possible. Every plan step has explicit RED and GREEN substeps. RED is not done until the tests exist and fail. GREEN is not done until all RED-phase tests pass. Never write implementation before the failing test exists. Each step is not [DONE] until its tests pass.

---

# Interaction

When user input is required (Q&A, feature selection, plan review, approvals), always use the `AskUserQuestion` tool. Do not ask questions via plain text output.
