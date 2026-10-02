---
name: stub
description: Design deep modules for a problem as stubs only — classes with data members, typed signatures and 1-line "why" docstrings, no implementation. Step 1 of stubs → tests → implementation. Only use when the user explicitly requests it (e.g. /grill /stub <problem>).
---

# Stub

Shape a design so it is expressed purely as interfaces. No logic is written: tests (step 2) and implementation (step 3) come later.

## When to Use

- Combined as `/grill /stub <problem>`: grill drives the conversation and settles the design decisions; this skill defines what gets designed and what is written once the grilling ends.
- On its own, `/stub` only primes the design rules below; it does not write files.

## Design rules

- **Deep modules.** Apply the `maintainable` skill: simple interfaces hiding a lot, no information leakage, no hidden dependencies, high cohesion. Explore the relevant code first and use what it shows.
- **KISS — human working memory holds ~4 things.** Keep the number of modules, classes per module, and public methods per class small; if a reader must juggle more than ~4 things at once, simplify. YAGNI: prune anything not needed.
- **Clear responsibilities.** Every `.py` file and every class has one clear responsibility, stated in its docstring.

## What gets written (only at the end of a grill session)

- **Stubs only:**
  - Classes with their data members (typed).
  - Every method/function with its full typed signature.
  - A 1-line docstring on every module, class, method and function, saying why it exists, what it does, and how it relates to other entities (who uses it, or what it uses or hides), e.g. "Find the boxes for predicted items so push can untick them".
  - The name echoes its docstring (`fetch_boxes` → "Fetch every checkbox…, so …").
  - No implementation: the body is only the docstring.
- **Refactors:** write new files (and later new tests); leave existing files untouched as reference unless the user says otherwise.
- Follow the project's instructions (AGENTS.md/CLAUDE.md), run its lint and tests, and report anything stubs force you to waive or suppress.
