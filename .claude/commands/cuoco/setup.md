---
description: One-time project initialisation — generates product.md, tech-stack.md, and sets up the .cuoco/ directory linked to alfaseekers/artifacts.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

You are running /cuoco:setup. Read CLAUDE.md for full operational rules.

Follow these steps exactly:

## 0. Bootstrap

Run the following before anything else:

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
mkdir -p .cuoco/artifacts/$PROJECT_NAME/feat .cuoco/artifacts/$PROJECT_NAME/code-style
```

All subsequent artifact writes use the path `.cuoco/artifacts/$PROJECT_NAME/`.

## 1. Product Vision (.cuoco/artifacts/$PROJECT_NAME/product.md)

Ask the user 3–4 batched questions using AskUserQuestion:
- What does the project do and who is it for?
- What are the core features / capabilities?
- What does success look like? Any key constraints?

Generate `.cuoco/artifacts/$PROJECT_NAME/product.md` from the answers. Show it to the user; revise if needed.

## 2. Tech Stack

Copy the bundled `tech-stack.md` from the cuoco repo root into `.cuoco/artifacts/$PROJECT_NAME/tech-stack.md`. Do not ask the user — the AlfaSeekers stack is fixed.

## 3. Product Guidelines (optional)

Ask the user with AskUserQuestion: use the standard product guidelines, provide your own, or skip.

If standard: copy bundled guidelines into `.cuoco/artifacts/$PROJECT_NAME/product-guidelines.md`.
If custom: ask the user to provide the content or point to a file; ingest and save.
If skip: move on.

## 4. Code Style Guides

Copy `general.md` and `python.md` from the bundled `code-style/` directory into `.cuoco/artifacts/$PROJECT_NAME/code-style/`. Do not ask the user — these are always copied.

## 5. Feature Registry

Create an empty feature registry at `.cuoco/artifacts/$PROJECT_NAME/feat/index.json`:

```json
{"features": []}
```

Features are defined later, one at a time, when the user runs `/cuoco:f-recipe`.

## 6. Push

```bash
git -C .cuoco/artifacts add $PROJECT_NAME
git -C .cuoco/artifacts commit -m "chore(cuoco): initial setup for $PROJECT_NAME"
git -C .cuoco/artifacts push
```

Announce that setup is complete and the user can run `/cuoco:f-recipe` to define and plan their first feature.
