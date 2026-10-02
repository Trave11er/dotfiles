---
name: abstract
description: Write a 1-2 sentence abstract from provided text. Only use when the user explicitly requests it (e.g. /abstract).
---

# Abstract

Write a concise 1-2 sentence abstract of the provided text.

## Goal

The abstract must answer three questions in a single tight passage:

1. **What** — what is being done / was done / should be done
2. **Why** — why it matters
3. **Context** — the setting, system, or domain this applies to

## Rules

- Maximum two sentences. Prefer one if it covers all three questions.
- No bullet points, no headings — plain prose only.
- Use the same tense as the source text (past if reporting results, present if describing ongoing work, imperative if proposing action).
- Strip jargon that the source text itself doesn't define; keep domain terms that it does.
- Do not add information absent from the source text.

## Input

The text to abstract. Accepted as:
- inline text in the user's message
- a file path the user points to (read it first)
- clipboard / pasted content

## Output

Print only the abstract — nothing else.
