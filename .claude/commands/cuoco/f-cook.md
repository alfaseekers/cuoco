---
description: Implement a planned feature by executing its plan.md step by step using red/green TDD.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion, Agent
---

You are running /cuoco:f-cook. Read CLAUDE.md for full operational rules.

CRITICAL CONSTRAINTS:
- Follow the plan. If the plan is wrong or incomplete, STOP and tell the user. Do not improvise or go beyond what the plan specifies.
- Never write implementation before the failing test exists.
- If the user says "push artifacts", "sync artifacts", or equivalent at any point, immediately run: `git -C .cuoco/artifacts push`

## 0. Sync

```bash
git -C .cuoco/artifacts pull
PROJECT_NAME=$(git remote get-url origin | sed 's|.*/||; s|\.git$||')
ARTIFACTS=".cuoco/artifacts/$PROJECT_NAME"
```

## 1. Select a Feature

Read `$ARTIFACTS/feat/index.json`. Identify features with status `"planned"`.

If only one exists, auto-select it. Otherwise present the options with AskUserQuestion.

## 2. Choose Execution Mode

Ask the user with AskUserQuestion:
- Step-by-step: pause between steps for verification
- All at once: run to completion, only stop on errors

## 3. Start Cooking

```bash
git checkout feat/<feature-id>
```

Load context:
- Read `$ARTIFACTS/feat/<feature-id>/research.md`
- Read `$ARTIFACTS/feat/<feature-id>/plan.md`
- Read `.cuoco/artifacts/tech-stack.md`
- Read `.cuoco/artifacts/code-style/`
- If `.cuoco/references/` exists, read from relevant repos as needed

Set the feature status to `"in-progress"` in `$ARTIFACTS/feat/index.json`.

## 4. Execute Each Step

For each step in plan.md, in order:

### a. Mark RED

Update the step status from [PENDING] to [RED] in plan.md (both the step header and the RED subsection header).

```bash
git add $ARTIFACTS && git commit -m "docs: start step N of <feature-id> (RED)"
```

### b. Write failing tests (RED phase)

Write exactly the tests described in the step's RED section. Run them — they must fail before proceeding.

```bash
git add <test-files> && git commit -m "test: add failing tests for <step-title>"
```

### c. Mark GREEN

Update the step status from [RED] to [GREEN] in plan.md (step header and RED subsection → [DONE], GREEN subsection → [GREEN]).

```bash
git add $ARTIFACTS && git commit -m "docs: step N of <feature-id> RED done"
```

### d. Write minimum implementation (GREEN phase)

Write the minimum code described in the GREEN section to make the RED tests pass. Nothing beyond what the tests require. Run tests — they must pass. Run type checks.

```bash
git add <source-files> && git commit -m "<type>: <description>"
```

### e. Mark DONE

Update the step status to [DONE] in plan.md (step header and all subsection headers).

```bash
git add $ARTIFACTS && git commit -m "docs: complete step N of <feature-id>"
```

### f. Checkpoint (step-by-step mode only)

Summarise: what was built, which tests pass, what comes next. Ask if user wants to push artifacts now. Wait for approval before continuing to the next step.

## 5. Finalise

When all steps are [DONE]:

1. Set feature status to `"done"` in `$ARTIFACTS/feat/index.json`.

2. ```bash
   git -C .cuoco/artifacts add .
   git -C .cuoco/artifacts commit -m "docs: complete <feature-id>"
   git -C .cuoco/artifacts push
   ```

3. Announce completion. Suggest the user create a PR for the feature branch.
