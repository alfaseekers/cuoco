---
description: One-time project initialisation — generates product.md, tech-stack.md, feature roadmap, and sets up the .artifacts/ directory.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

You are running /cuoco:setup. Read CLAUDE.md for full operational rules.

Follow these steps exactly:

## 1. Create .artifacts/ Directory

Create the `.artifacts/` directory and its subdirectories if they don't already exist:

```
mkdir -p .artifacts/feat .artifacts/code-style
```

## 2. Product Vision (.artifacts/product.md)

Ask the user 3–4 batched questions using AskUserQuestion:
- What does the project do and who is it for?
- What are the core features / capabilities?
- What does success look like? Any key constraints?

Generate `.artifacts/product.md` from the answers. Show it to the user; revise if needed.

## 3. Tech Stack (.artifacts/tech-stack.md)

Ask the user with AskUserQuestion whether to infer the tech stack from the existing codebase or specify it manually.

If inferring: scan the codebase for package.json, requirements.txt, go.mod, Cargo.toml, pyproject.toml, file extensions, etc. Build a draft tech-stack.md and present it for review.

If manual, ask the user using AskUserQuestion:
- Language(s) and framework(s)
- Package manager
- Testing framework
- Database (if any)
- Key libraries

Generate `.artifacts/tech-stack.md`. Include git conventions (conventional commits, branch-driven dev).

## 4. Product Guidelines (optional)

Ask the user with AskUserQuestion: use the standard product guidelines, provide your own, or skip.

If standard: copy bundled guidelines into `.artifacts/product-guidelines.md`.
If custom: ask the user to provide the content or point to a file; ingest and save as `.artifacts/product-guidelines.md`.
If skip: move on.

## 5. Code Style Guides

Copy the bundled code style guides from `code-style/` into `.artifacts/code-style/`. At minimum copy `general.md`. If the project uses a specific language (from tech-stack.md), also copy the relevant language guide (e.g., `typescript.md`, `python.md`). Only copy guides for languages the project actually uses.

## 6. Feature Roadmap (.artifacts/feat/index.json)

Extract a preliminary feature list from product.md. For each feature, determine:
- A kebab-case id (used as branch name: feat/<id>)
- A human-readable name
- A one-sentence description
- Dependencies (which features must complete first)

Write `.artifacts/feat/index.json` with all features at status "pending".

Present the feature list to the user. Adjust based on feedback.

## 7. Commit

Commit all generated artifacts:

```
git add .artifacts && git commit -m "chore(cuoco): initial project setup"
```

Announce that setup is complete and the user can run `/cuoco:f-recipe` to start their first feature.
