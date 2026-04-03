---
name: memorize
description: Analyzes user "wtf" feedback to identify misunderstanding or mistakes then learn from them by updating persistent instructions. Delegates the update step to a subagent via the Agent tool — never execute it inline.
---

## When to Use

- MANDATORY AUTO-TRIGGER: Any time the user writes `wtf` (case-insensitive, including typos like "wtfg"), you MUST immediately run this skill without hesitation — never wait to be asked twice.
- Use this skill when the user writes `wtf` (case-insensitive) in response to the agent.
- This skill is helpful for capturing what the agent likely misunderstood or did wrong.

## Instructions for creating a memory file
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

## Instructions for updating persistent instructions
- You MUST use the Agent tool to spawn a `general-purpose` subagent for this step. Do not do it inline.
- Search for latest memory file that matches `memory_*.md`.
- Analyze it and identify the most relevant file to save the learning to
- If generic learning, this file can be in skills or commands subdirs. Only update files inside the current repo — never home-dir paths.
- Update the identified file by organically incorporating the learning from that specific memory file into the existing content. Do not include details specific to the repository.
- Make changes that are small and surgical — one or two lines maximum. Never restructure or rewrite a section.
- Do not simply copy the "Correction for Next Attempt" section.
- After processing all memory files and completing the updates, notify the user of the changes made.
- Use the ask questions tool if you're unsure which file is most relevant to update
