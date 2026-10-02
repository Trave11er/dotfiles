---
name: gems
description: Extract the 1-5 most valuable system/domain facts (not code) the user shared in conversation and save them in one gems file. By default only saves the gems — does not touch other files.
---

## When to Use

- MANDATORY AUTO-TRIGGER: Any time the user writes `gem` or `gems` (case-insensitive), you MUST immediately run this skill without hesitation.
- Captures system/domain knowledge the user volunteered to correct or educate the agent — how the product, hardware, data or processes work, not how the code is written.

## Default behaviour — save gems only

- Scan the full conversation for facts the **user** stated to clarify how the system or domain works (e.g. device behaviour, data provenance, business rules, terminology). Ignore agent-generated knowledge.
- Ignore facts about the code itself — function/file names, implementation details, coding conventions, review feedback. Those can be read from the repo or belong in memories, not gems.
- Pick the 1-5 most useful, non-obvious facts — things a future agent could not derive from reading the code. Fewer strong gems beat padding to five.
- Distill each into one sentence (max ~120 chars).
- Create `agents_output/` at repo root if missing.
- Write all gems from this invocation to one file, `gems_<YYYY-MM-DD-HH-MM>_<short-desc>.md` (lowercase kebab-case, 2-6 words), with one numbered entry per gem containing:
  - **Gem**: the one-liner fact
  - **Context**: 1-2 sentences on where in the conversation it came up
  - **Area** (if identifiable): which part of the system or domain it relates to
- If context is insufficient to identify a clear gem, or the user only shared code-level facts, use the ask questions tool to ask the user which facts they consider most valuable.
- **STOP here.** Do NOT update any other files (READMEs, AGENTS.md, skills, etc.) unless the user explicitly asks you to apply the gems.

## Updating repo docs (only when explicitly asked)

This step runs ONLY when the user explicitly asks to apply a gem (e.g. "add this gem to the README"). It does NOT run by default after saving a gem.

- Decide where the fact belongs:
  - A section-relevant README.md (e.g. `src/monitoring/README.md`)
  - Or `AGENTS.md` if it is cross-cutting domain knowledge
- Append or insert the fact under the most fitting heading. If no heading fits, add a short new one.
- Make changes that are small and surgical — one or two lines maximum. Never restructure or rewrite a section.
- Only update files inside the current repo — never home-dir paths.
- After processing, notify the user of the changes made.
- Use the ask questions tool if you're unsure which file is most relevant to update.
