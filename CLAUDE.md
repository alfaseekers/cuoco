# Cuoco

Cuoco is a three-phase Context Driven Development workflow: setup, recipe, cook. Code is never written before a reviewed plan exists. All artifacts live on an isolated Git orphan branch (`cuoco/artifacts`) mounted at `artifacts/` via a Git worktree.

---

# Principles

- No code before plan. Never write or modify source code until a plan exists and the user has approved it.
- Artifacts are the source of truth. Every decision, finding, and plan is persisted to a file in `artifacts/`. Chat is ephemeral; artifacts survive context compaction and session boundaries.
- Branch-driven development. Every feature lives on its own branch (`feat/<id>`). No direct commits to main.
- KISS. Start with the simplest implementation that satisfies current requirements. Complexity needs a demonstrated, concrete justification.

---

# Git

## Artifact Isolation

All artifacts are tracked on the `cuoco/artifacts` orphan branch, mounted at `artifacts/` via git worktree add. The `artifacts/` directory is listed in `.gitignore` on every code branch so it never appears in code history.

Every code commit on a feature branch has a corresponding artifact commit on `cuoco/artifacts` (1:1 mapping). Cuoco commands handle both commits explicitly — there are no hooks. This makes it possible to trace any code change back to the plan step that motivated it.

## Conventions

Commits follow Conventional Commits (https://www.conventionalcommits.org/en/v1.0.0/). Format: type(scope): subject. Types: feat, fix, test, refactor, docs, chore. Each commit is atomic — one logical change.

Feature branches: `feat/<feature-id>` where feature-id matches the id field in `artifacts/feat/index.json`. Branches are created from main and merged back via PR. No commits to main directly.

---

# Workflow

Three commands: `/cuoco:setup` (one-time project init), `/cuoco:f-recipe` (research and planning for one feature), `/cuoco:f-cook` (implementation of a planned feature). Setup runs once. Recipe and Cook alternate for each feature.

## `cuoco:setup`

### Purpose

One-time project initialisation. Creates the artifact infrastructure and generates foundational project documents.

### Preconditions

A Git repository must exist (or be initialised as part of setup).

### Steps

1. Create the `cuoco/artifacts` orphan branch: git checkout --orphan `cuoco/artifacts`, create an initial commit, then git checkout back to the original branch.
2. Set up the worktree: git worktree add artifacts `cuoco/artifacts`.
3. Add `artifacts/` to `.gitignore` on the current branch and commit.
4. Interactive Q&A — ask the user batched questions about the project:
   - What does the project do? Who is it for?
   - What are the core features / capabilities?
   - What does success look like? Key constraints?
5. Generate `artifacts/product.md` from the answers.
6. Ask the user about the tech stack: language(s), framework(s), package manager, testing framework, database, key libraries. Generate `artifacts/tech-stack.md`.
7. Ask the user if product or brand guidelines exist. If yes: ask them to provide the content or point to a file; ingest and save as `artifacts/product-guidelines.md`. If no: skip.
8. Copy the fixed code style guides into `artifacts/code-style/`.
9. Extract a preliminary feature list from `product.md`. For each feature determine dependencies (which features must complete first). Write `artifacts/feat/index.json`.
10. Present the feature list and dependency graph to the user for review. Adjust based on feedback.
11. Commit all generated artifacts to `cuoco/artifacts` with message: chore(cuoco): initial project setup.

### Output

`artifacts/product.md`, `artifacts/tech-stack.md`, `artifacts/feat/index.json`, `artifacts/code-style/*.md`, and optionally `artifacts/product-guidelines.md`. All committed on `cuoco/artifacts`.

---

## `cuoco:f-recipe`

### Purpose

Research and plan a single feature. Produces `research.md` and `plan.md`. No source code is created or modified — only files in `artifacts/`.

### Preconditions

`/cuoco:setup` must have been run. At least one feature in `artifacts/feat/index.json` must have status "pending" with all its dependencies satisfied (status "done").

### Steps

1. Read `artifacts/feat/index.json`. List features whose status is "pending" and whose depends_on entries all have status "done". Present this list and ask the user to choose one.
2. Set the chosen feature's status to "in-recipe" in `index.json`.
3. Create the feature branch: git checkout -b `feat/<feature-id>` main.
4. Create the directory `artifacts/feat/<feature-id>/`.
5. RESEARCH PHASE — read the codebase deeply and thoroughly. Investigate relevant APIs, libraries, tools, and architectural patterns. Study how the feature fits into the existing system. Write all findings to `artifacts/feat/<feature-id>/research.md`. The research must be detailed enough that an implementer can write code without consulting external docs.
6. PLANNING PHASE — using `research.md` plus the project artifacts (`product.md`, `tech-stack.md`), create `artifacts/feat/<feature-id>/plan.md`. The plan breaks the feature into sequential steps, each with: what gets built, dependencies on prior steps, tests, an output contract, and suggested commits.
7. Present the plan to the user for review. If the user rejects or requests changes, revise the plan and re-present. Repeat until approved.
8. Set the feature status to "planned" in `index.json`.
9. Commit all artifacts to `cuoco/artifacts` with message: docs(cuoco): add recipe for <feature-id>.

### Constraints

CRITICAL: During this entire phase, do NOT create, modify, or delete any source code files. Only files under `artifacts/` may be touched. This is the planning phase — produce a complete, reviewed specification before any code is written. If you find yourself wanting to write code, STOP and write it into the plan instead.

### Output

`artifacts/feat/<feature-id>/research.md` and `plan.md`. Feature status "planned" in `index.json`. Feature branch `feat/<feature-id>` created (identical to main — no code changes). All committed on `cuoco/artifacts`.

---

## `cuoco:f-cook`

### Purpose

Implement a planned feature by executing its `plan.md`.

### Preconditions

At least one feature in `artifacts/feat/index.json` must have status "planned" with both `research.md` and `plan.md` present in its directory.

### Steps

1. Read `artifacts/feat/index.json`. List features with status "planned". If only one, auto-select it; otherwise ask the user to choose.
2. Ask the user which execution mode:
   - Step-by-step: pause between steps for user verification.
   - All at once: run to completion, only stop on errors.
3. Check out the feature branch: git checkout `feat/<feature-id>`.
4. Load `artifacts/feat/<feature-id>/research.md` and `plan.md` as working context.
5. Set the feature status to "in-progress" in `index.json`.
6. For each step in `plan.md`, in order:
   a. Mark the step [IN PROGRESS] in `plan.md`. Commit to `cuoco/artifacts`.
   b. Implement the code changes described in the step.
   c. Run tests and type checks continuously during implementation.
   d. Create atomic conventional commits on the feature branch.
   e. Mark the step [DONE] in `plan.md`. Commit to `cuoco/artifacts`.
   f. If step-by-step mode: present a summary of what was done. Wait for the user to approve before continuing to the next step.
7. When all steps are [DONE], set the feature status to "done" in `index.json`. Commit to `cuoco/artifacts`.

### Constraints

Follow the plan. If the plan is wrong or incomplete, STOP and tell the user. Do not improvise or go beyond what the plan specifies. The user can update the plan manually or re-run `/cuoco:f-recipe`.

Do not add unnecessary comments, docstrings, or type annotations. Do not use any or unknown types. Run type checks and tests continuously.

Every code commit on the feature branch must have a corresponding artifact commit on `cuoco/artifacts` updating the plan status.

### Output

Feature implemented on `feat/<feature-id>` branch with atomic conventional commits. `plan.md` fully marked [DONE]. Feature status "done" in `index.json`.

---

# Artifacts

## Structure

```
artifacts/                          # git worktree → cuoco/artifacts branch
├── product.md                      # project vision, users, features, success criteria
├── tech-stack.md                   # languages, frameworks, packages, dev conventions
├── product-guidelines.md           # brand/product guidelines (optional)
├── code-style/
│   ├── general.md                  # universal coding principles
│   └── <language>.md               # language-specific style guide
└── feat/
    ├── index.json                  # feature registry with dependencies and status
    └── <feature-id>/
        ├── research.md             # deep research findings
        └── plan.md                 # step-by-step implementation plan
```

## product.md

The project vision document. Describes what the system does, who it is for, core features, success criteria, and key design principles. Generated during `/cuoco:setup` via interactive Q&A. Updated when the product vision changes, not when implementation details change.

## tech-stack.md

Technology choices and development conventions: language(s), framework(s), package manager, testing framework, database, key libraries. Generated during `/cuoco:setup`. Updated when the stack changes.

## feat/index.json

The feature registry. A JSON object with a "features" array. Each feature object:

```json
{
  "id": "lowercase-kebab-case string, used as branch name suffix in feat/<id>",
  "name": "Human-readable feature name",
  "description": "One-sentence description",
  "status": "pending | in-recipe | planned | in-progress | done",
  "depends_on": ["array", "of", "feature", "ids"]
}
```

A feature can enter `/cuoco:f-recipe` when status is "pending" and all depends_on features have status "done". A feature can enter `/cuoco:f-cook` when status is "planned".

## feat/<id>/research.md

Research record for a feature. Documents what was found: API response shapes, library capabilities and limitations, architectural tradeoffs, technology rationale. Dense technical prose. Decisive language — when a tool has been chosen, state it as fact with rationale ("we use X because Y"), not as one option among many. Detail level: an implementer can write code without consulting external documentation. Closes with a ## References table (columns: Reference, URL).

## feat/<id>/plan.md

Implementation roadmap for a feature. Opens with a preamble paragraph summarising the feature and step dependency order. Then one section per step:

```
## Step N — Title [STATUS]

**What gets built** — modules, classes, functions at implementation-ready detail.
**Dependencies** — prior step numbers, or "None".
**Tests** — what tests exist at the end of this step and what they assert.
**Output contract** — definition of done as observable behaviour (commands that succeed, tests that pass, state that exists).
**Suggested commits** — bullet list of conventional commit messages.
```

STATUS is one of [PENDING], [IN PROGRESS], [DONE].

---

# Code Style

Fixed code style guides are copied into `artifacts/code-style/` during `/cuoco:setup`. They are not generated — they are bundled with the workflow. The `general.md` guide applies universally; language-specific guides apply when the project uses that language.

Core principles: readability over cleverness, consistency with existing patterns, simplicity over abstraction, document why not what, minimise coupling and dependencies.

---

# Testing

Write tests wherever possible. Each plan step in `plan.md` specifies what tests must exist and what they assert. Tests are part of the output contract — a step is not [DONE] until its tests pass.

---

# Interaction

When user input is required (Q&A, feature selection, plan review, approvals), always use the `AskUserQuestion` tool. Do not ask questions via plain text output.
