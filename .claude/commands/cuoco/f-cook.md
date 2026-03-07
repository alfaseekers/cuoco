---
description: Implement a planned feature by executing its plan.md step by step.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion, Agent
---

You are running /cuoco:f-cook. Read CLAUDE.md for full operational rules.

CRITICAL CONSTRAINT: Follow the plan. If the plan is wrong or incomplete, STOP and tell the user. Do not improvise or go beyond what the plan specifies.

## 1. Select a Feature

Read `artifacts/feat/index.json`. Identify features with status "planned".

If only one exists, auto-select it. Otherwise present the options with AskUserQuestion.

## 2. Choose Execution Mode

Ask the user with AskUserQuestion:
- **Step-by-step**: pause between steps for verification
- **All at once**: run to completion, only stop on errors

## 3. Start Cooking

Check out the feature branch:
```
git checkout feat/<feature-id>
```

Load context:
- Read `artifacts/feat/<feature-id>/research.md`
- Read `artifacts/feat/<feature-id>/plan.md`
- Read `artifacts/tech-stack.md`

Set the feature status to "in-progress" in `artifacts/feat/index.json`.

## 4. Execute Each Step

For each step in plan.md, in order:

### a. Mark In Progress
Update the step status from [PENDING] to [IN PROGRESS] in plan.md.
Commit to artifacts:
```
cd artifacts && git add -A && git commit -m "docs(cuoco): start step N of <feature-id>" && cd ..
```

### b. Implement
Write the code changes described in the step. Follow artifacts/tech-stack.md conventions.

Do not add unnecessary comments or docstrings. Do not use `any` or `unknown` types.

### c. Test
Run tests and type checks continuously during implementation. Each step's Tests section defines what must pass.

### d. Commit Code
Create atomic conventional commits on the feature branch for the code changes.

### e. Mark Done
Update the step status from [IN PROGRESS] to [DONE] in plan.md.
Commit to artifacts:
```
cd artifacts && git add -A && git commit -m "docs(cuoco): complete step N of <feature-id>" && cd ..
```

### f. Checkpoint (step-by-step mode only)
If step-by-step mode: present a summary of what was implemented, what tests pass, and what comes next. Wait for user approval before continuing.

## 5. Finalise

When all steps are [DONE]:

1. Set feature status to "done" in `artifacts/feat/index.json`
2. Commit to artifacts:
```
cd artifacts && git add -A && git commit -m "docs(cuoco): complete <feature-id>" && cd ..
```
3. Announce completion. Suggest the user create a PR for the feature branch.
