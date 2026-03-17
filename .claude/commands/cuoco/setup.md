---
description: One-time project initialisation — generates product.md or receives it from user, and sets up the .cuoco/ directory linked to alfaseekers/artifacts.
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
mkdir -p .cuoco/artifacts/repositories/$PROJECT_NAME/feat
```

After cloning, `.cuoco/artifacts/tech-stack.md` and `.cuoco/artifacts/code-style/` are already present — these are org-wide files maintained directly in `alfaseekers/artifacts`. Do not modify them.

## 1. Product Vision (.cuoco/artifacts/repositories/$PROJECT_NAME/product.md)

Ask the user using AskUserQuestion whether the product.md shall be provided manually, or generated. 
- If the user wants to provide it manually:
  - Use AskUserQuestion to find out the file's location
  - The two options should be "Project Root" or user-defined (type something). 
  - Copy the file to`.cuoco/artifacts/repositories/$PROJECT_NAME/product.md`.
  - Move on to step 2
- Else, Ask the user 3–4 batched questions using AskUserQuestion:
  - What does the project do and who is it for?
  - What are the core features / capabilities?
  - What does success look like? Any key constraints?
  - Generate `.cuoco/artifacts/repositories/$PROJECT_NAME/product.md` from the answers. Show it to the user; revise if needed.

## 2. Product Guidelines (optional)

Ask the user with AskUserQuestion: use the standard product guidelines, provide your own, or skip.

If standard: copy bundled guidelines into `.cuoco/artifacts/repositories/$PROJECT_NAME/product-guidelines.md`.
If custom: ask the user to provide the content or point to a file; ingest and save.
If skip: move on.

## 3. Feature Registry

Create an empty feature registry at `.cuoco/artifacts/repositories/$PROJECT_NAME/feat/index.json`:

```json
{"features": []}
```

Features are defined later, one at a time, when the user runs `/cuoco:f-recipe`.

## 4. Push

```bash
git -C .cuoco/artifacts add .
git -C .cuoco/artifacts commit -m "chore: initial setup for $PROJECT_NAME"
git -C .cuoco/artifacts push
```

Announce that setup is complete and the user can run `/cuoco:f-recipe` to define and plan their first feature.
