---
description: One-time project initialisation — generates product.md, tech-stack.md, feature roadmap, and sets up the artifact branch.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

You are running /cuoco:setup. Read CLAUDE.md for full operational rules.

Follow these steps exactly:

## 1. Git Artifact Infrastructure

Check if the `cuoco/artifacts` orphan branch already exists. If not, create it:

```
git checkout --orphan cuoco/artifacts
git rm -rf . 2>/dev/null || true
git commit --allow-empty -m "chore(cuoco): init artifact branch"
git checkout -
```

Then set up the worktree:

```
git worktree add artifacts cuoco/artifacts
```

Add `artifacts/` to `.gitignore` on the current branch if not already there. Commit.

## 2. Product Vision (artifacts/product.md)

Ask the user 3–4 batched questions using AskUserQuestion:
- What does the project do and who is it for?
- What are the core features / capabilities?
- What does success look like? Any key constraints?

Generate `artifacts/product.md` from the answers. Show it to the user; revise if needed.

## 3. Tech Stack (artifacts/tech-stack.md)

Ask the user about their tech stack using AskUserQuestion:
- Language(s) and framework(s)
- Package manager
- Testing framework
- Database (if any)
- Key libraries

Generate `artifacts/tech-stack.md`. Include git conventions (conventional commits, branch-driven dev).

## 4. Product Guidelines (optional)

Ask the user if product/brand guidelines exist. If yes, ingest them into `artifacts/product-guidelines.md`. If no, skip.

## 5. Code Style Guides

Copy the bundled code style guides from `code-style/` into `artifacts/code-style/`. At minimum copy `general.md`. If the project uses a specific language (from tech-stack.md), also copy the relevant language guide (e.g., `typescript.md`, `python.md`). Only copy guides for languages the project actually uses.

## 6. Feature Roadmap (artifacts/feat/index.json)

Extract a preliminary feature list from product.md. For each feature, determine:
- A kebab-case id (used as branch name: feat/<id>)
- A human-readable name
- A one-sentence description
- Dependencies (which features must complete first)

Write `artifacts/feat/index.json` with all features at status "pending".

Present the feature list to the user. Adjust based on feedback.

## 7. Commit

Commit all generated artifacts to the `cuoco/artifacts` branch:

```
cd artifacts && git add -A && git commit -m "chore(cuoco): initial project setup" && cd ..
```

Announce that setup is complete and the user can run `/cuoco:f-recipe` to start their first feature.
