---
description: One-time project initialisation — generates product.md, seeds org-wide artifacts, and sets up the .cuoco/ directory linked to alfaseekers/artifacts.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

You are running /cuoco:setup. Read CLAUDE.md for full operational rules.

Follow these steps exactly:

## 0. Bootstrap

```bash
# Add .cuoco/ to .gitignore (idempotent)
grep -qxF '.cuoco/' .gitignore 2>/dev/null || echo '.cuoco/' >> .gitignore

# Derive project name from git remote
PROJECT_NAME=$(git remote get-url origin | sed 's|.*/||; s|\.git$||')

# Clone or update alfaseekers/artifacts
if [ -d .cuoco/artifacts/.git ]; then
  git -C .cuoco/artifacts pull
else
  mkdir -p .cuoco
  git clone git@github.com:alfaseekers/artifacts.git .cuoco/artifacts
fi

# Create project namespace
mkdir -p .cuoco/artifacts/$PROJECT_NAME/feat
```

## 1. Seed Org-Wide Artifacts (idempotent)

Copy the org-wide files to the artifacts repo root only if they are not already present:

```bash
# tech-stack.md
[ -f .cuoco/artifacts/tech-stack.md ] || cp tech-stack.md .cuoco/artifacts/tech-stack.md

# code-style/
mkdir -p .cuoco/artifacts/code-style
[ -f .cuoco/artifacts/code-style/general.md ] || cp code-style/general.md .cuoco/artifacts/code-style/general.md
[ -f .cuoco/artifacts/code-style/python.md  ] || cp code-style/python.md  .cuoco/artifacts/code-style/python.md
```

These files are shared across all AlfaSeekers projects. Skip if already seeded by a previous project setup.

## 2. Product Vision (.cuoco/artifacts/$PROJECT_NAME/product.md)

Ask the user 3–4 batched questions using AskUserQuestion:
- What does the project do and who is it for?
- What are the core features / capabilities?
- What does success look like? Any key constraints?

Generate `.cuoco/artifacts/$PROJECT_NAME/product.md` from the answers. Show it to the user; revise if needed.

## 3. Product Guidelines (optional)

Ask the user with AskUserQuestion: use the standard product guidelines, provide your own, or skip.

If standard: copy bundled guidelines into `.cuoco/artifacts/$PROJECT_NAME/product-guidelines.md`.
If custom: ask the user to provide the content or point to a file; ingest and save.
If skip: move on.

## 4. Feature Registry

Create an empty feature registry at `.cuoco/artifacts/$PROJECT_NAME/feat/index.json`:

```json
{"features": []}
```

Features are defined later, one at a time, when the user runs `/cuoco:f-recipe`.

## 5. Push

```bash
git -C .cuoco/artifacts add .
git -C .cuoco/artifacts commit -m "chore: initial setup for $PROJECT_NAME"
git -C .cuoco/artifacts push
```

Announce that setup is complete and the user can run `/cuoco:f-recipe` to define and plan their first feature.
