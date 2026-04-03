---
name: atomic
description: Executes large changes in approved steps. Use when work is split into phases and the user must approve each completed step before moving to the next.
---

# Atomic

Run big work as gated steps with explicit user approval after each phase.

## When to Use

- Use when a change is large and should be broken into ordered steps.
- Use when risk is high and user wants checkpoints before continuing.
- Use when requirements may evolve after each intermediate result.

## Instructions

1. You are given a series of steps to execute
2. Execute only Step 1.
3. Verify Step 1 outcome (unit tests/lints relevant to that step).
4. Report what changed and ask for explicit approval to continue or revise
5. Do not start the next step until user approval is received.
6. Repeat execute -> verify -> report -> approval for each step.
7. If user requests changes at a checkpoint, revise only current or prior approved scope and re-request approval.
