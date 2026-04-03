---
name: sleep
description: Updates existing skills by analyzing memory files from past mistakes.
---

# Sleep

Updates your persistent instructions and definitions based on past mistakes and user feedback stored as memory notes.

## When to Use

- Use this skill when you want to learn from past errors and improve your future performance.
- This skill is helpful when you've received several `wtf` responses or created multiple memory files and want to codify the solutions into permanent files.

## Instructions

- Search for memory files that match `memory_*.md`.
- For each memory file, separately analyze it and identify the most relevant file to update in /skills dir
- Update the identified file by organically incorporating the learning from that specific memory file into the existing content, aiming for minimal yet effective changes. Do not simply copy the "Correction for Next Attempt" section.
- After processing all memory files and completing the updates, ask the user if they accept the changes made.
- If the user accepts the changes, ask for explicit permission to remove (delete) the processed memory files.
- Use the ask questions tool if you're unsure which file is most relevant to update or for confirmations.
