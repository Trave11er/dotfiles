---
name: atomic
description: Executes large changes in approved steps. Use when work is split into phases and the user must approve each completed step before moving to the next.
---

# Atomic

- Run big work as gated steps with explicit user approval after each phase.

## When to Use

- Use when a change is large and should be broken into ordered steps.
- Use when risk is high and user wants checkpoints before continuing.
- Use when requirements may evolve after each intermediate result.

## Instructions

- You are given a series of steps to execute
- Execute only Step 1.
- Verify Step 1 outcome (unit tests/lints relevant to that step).
- If the step adds or changes a user-facing entry point (script, CLI flag, slash command, Makefile target), update the README in the same step before reporting.
- Report what changed and ask for explicit approval to continue or revise
- Do not start the next step until user approval is received.
- Repeat execute -> verify -> report -> approval for each step.
- If user requests changes at a checkpoint, revise only current or prior approved scope and re-request approval.
