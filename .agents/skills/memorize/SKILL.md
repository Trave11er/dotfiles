---
name: memorize
description: Analyzes user "wtf" feedback to identify misunderstanding or mistakes, then write a concise memory note to output as memory_<date-time>_<short-desc>.md so future responses improve.
---

# Memorize

Create a short memory note whenever the user replies with `wtf`.

## When to Use

- Use this skill when the user writes `wtf` in response to the agent.
- This skill is helpful for capturing what the agent likely misunderstood or did wrong.

## Instructions

- Trigger condition: user message contains `wtf` (case-insensitive).
- Analyze recent conversation context and extract:
  - What the user likely wanted.
  - What the agent understood incorrectly.
  - What the agent did wrong (or failed to do).
  - What to do differently next time.
- Create an `agents_output/` if missing.
- Write a markdown file named:
  - `memory_<YYYY-MM-DD-HH-MM>_<short-desc>.md`
  - Use lowercase kebab-case for `<short-desc>` (2-6 words, concise).
- File content format:
  - Task/user intent
  - Observed mismatch
  - Root cause
  - Correction for next attempt
  - Optional: concrete prompt/response pattern to follow next time
- Keep the note concise and actionable.
- If context is insufficient to identify the mismatch, use the ask questions tool to clarify before writing.
