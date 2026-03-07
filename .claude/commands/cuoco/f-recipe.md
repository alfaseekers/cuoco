---
description: Research and plan a feature — produces research.md and plan.md without touching source code.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion, Agent, WebFetch
---

You are running /cuoco:f-recipe. Read CLAUDE.md for full operational rules.

CRITICAL CONSTRAINT: During this entire phase, do NOT create, modify, or delete any source code files. Only files under .artifacts/ may be touched. If you want to write code, write it into the plan as a code snippet instead.

## 1. Select a Feature

Read `.artifacts/feat/index.json`. Identify features where:
- status is "pending"
- ALL features listed in depends_on have status "done"

Present the available features to the user with AskUserQuestion. Let them choose one.

## 2. Create Feature Branch

```
git checkout -b feat/<feature-id> main
```

Update the chosen feature's status to "in-recipe" in `.artifacts/feat/index.json`.

Create the directory `.artifacts/feat/<feature-id>/`.

## 3. Research Phase

Read the codebase deeply and thoroughly. Investigate relevant APIs, libraries, tools, and architectural patterns. Study how the feature fits into the existing system. Consult .artifacts/product.md and .artifacts/tech-stack.md for context.

Write findings to `.artifacts/feat/<feature-id>/research.md`.

The research document must follow this form:
- Opens with a paragraph naming the feature and summarising what was investigated
- One ## section per significant investigation area
- Dense technical prose — no bullet lists as primary structure
- Decisive language: "we use X because Y", not listing options neutrally
- Detailed enough that an implementer can write code without consulting external docs
- Closes with a ## References table (columns: Reference, URL)

## 4. Planning Phase

Using research.md plus project artifacts, create `.artifacts/feat/<feature-id>/plan.md`.

The plan must follow this form:
- Opens with a preamble paragraph: what the feature does and step dependency order
- One section per implementation step:

  ## Step N — Title [PENDING]

  What gets built — modules, classes, functions at implementation-ready detail.
  Dependencies — prior step numbers, or "None".
  Tests — what tests exist at the end of this step and what they assert.
  Output contract — definition of done as observable behaviour.
  Suggested commits — bullet list of conventional commit messages.

## 5. User Review

Present the plan to the user. If they reject or request changes, revise and re-present until approved.

## 6. Finalise

Set the feature status to "planned" in `.artifacts/feat/index.json`.

Commit all artifacts:
```
git add .artifacts && git commit -m "docs(cuoco): add recipe for <feature-id>"
```

Announce that the recipe is complete and the user can run `/cuoco:f-cook` to start implementation.
