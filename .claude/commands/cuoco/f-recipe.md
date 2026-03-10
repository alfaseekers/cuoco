---
description: Research and plan a feature — produces research.md and plan.md without touching source code.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion, Agent, WebFetch
---

You are running /cuoco:f-recipe. Read CLAUDE.md for full operational rules.

CRITICAL CONSTRAINT: During this entire phase, do NOT create, modify, or delete any source code files. Only files under .cuoco/artifacts/ may be touched. If you want to write code, write it into the plan as a code snippet instead.

## 0. Sync

```bash
git -C .cuoco/artifacts pull
PROJECT_NAME=$(git remote get-url origin | sed 's|.*/||; s|\.git$||')
ARTIFACTS=".cuoco/artifacts/$PROJECT_NAME"
```

## 1. Define the Feature

Ask the user with AskUserQuestion: "What feature do you want to work on? Give it a name and a one-sentence description."

Derive a kebab-case `feature-id` from the name (e.g. "Data Ingestion Layer" → `data-ingestion-layer`).

If `$ARTIFACTS/feat/index.json` already contains features, ask the user with AskUserQuestion whether this feature depends on any of them. If yes, note the dependency ids.

Add a new entry to `$ARTIFACTS/feat/index.json`:

```json
{
  "id": "<feature-id>",
  "name": "<Feature Name>",
  "description": "<one-sentence description>",
  "status": "in-recipe",
  "depends_on": []
}
```

## 2. Create Feature Branch

```bash
git checkout -b feat/<feature-id> main
```

Create the directory `$ARTIFACTS/feat/<feature-id>/`.

## 3. Research Phase

Read the codebase deeply and thoroughly. Investigate relevant APIs, libraries, tools, and architectural patterns. Consult:
- `.cuoco/artifacts/tech-stack.md` — toolchain and stack constraints
- `.cuoco/artifacts/code-style/` — style rules to respect in the plan
- `$ARTIFACTS/product.md` — project vision and goals
- `.cuoco/references/<repo>/` — if `.cuoco/references/` exists and contains repos, read from them where relevant

Write findings to `$ARTIFACTS/feat/<feature-id>/research.md`.

The research document must follow this form:
- Opens with a paragraph naming the feature and summarising what was investigated
- One ## section per significant investigation area
- Dense technical prose — no bullet lists as primary structure
- Decisive language: "we use X because Y", not listing options neutrally
- Detailed enough that an implementer can write code without consulting external docs
- Closes with a ## References table (columns: Reference, URL)

## 4. Planning Phase

Using research.md plus project artifacts, create `$ARTIFACTS/feat/<feature-id>/plan.md`.

The plan must follow this form:
- Opens with a preamble paragraph: what the feature does and step dependency order
- One section per implementation step:

  ## Step N — Title [PENDING]

  What gets built — modules, classes, functions at implementation-ready detail.
  Dependencies — prior step numbers, or "None".

  ### RED [PENDING]

  Tests to write. Specific test file, test names, and what each assertion verifies.
  These tests must fail before any implementation is written.
  Suggested commits (red phase).

  ### GREEN [PENDING]

  Minimum implementation to make the RED tests pass. Nothing beyond what the tests require.
  Suggested commits (green phase).

  Output contract — definition of done as observable behaviour (tests pass, commands succeed).

## 5. User Review

Present the plan to the user. If they reject or request changes, revise and re-present until approved.

## 6. Finalise

Set the feature status to `"planned"` in `$ARTIFACTS/feat/index.json`.

```bash
git -C .cuoco/artifacts add .
git -C .cuoco/artifacts commit -m "docs: add recipe for <feature-id>"
git -C .cuoco/artifacts push
```

Announce that the recipe is complete and the user can run `/cuoco:f-cook` to start implementation.
