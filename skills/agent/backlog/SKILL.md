---
name: backlog
description: Create, modify, list, and remove task .md files in .backlog/. One file per task, git-tracked. Only use when the user explicitly requests it (e.g. /backlog).
---

# Backlog

Manage a lightweight task backlog as individual `.md` files in `.backlog/` at the project root.

## File format

Filename: `YYYY-MM-DD-slug.md` (date of creation, kebab-case slug), or `YYYY-MM-DD-tag-slug.md` when a tag is provided.

```markdown
---
status: todo
created: YYYY-MM-DD
where:
  - path/to/file.ts:42
---

# Short task title

Description and notes.
```

### Fields

- **status** — one of: `todo`, `later`, `wip`, `closed`
- **created** — date the task was created
- **tag** — optional tag string (e.g. `refactor`, `bug`). Present when the user's input includes `tag <name>`.
- **where** — list of code references (`file:line`). Omit if not applicable.

## Operations

Infer the intended operation from the user's message and conversational context.

### Create

1. Pick today's date and a short kebab-case slug for the filename. If the user's input includes `tag <name>`, prefix the slug with the tag: `YYYY-MM-DD-tag-slug.md`.
2. Write the `.md` file to `.backlog/` with status `todo`, created date, `tag` if provided, and `where` refs if the user mentioned code locations.
3. Do not auto-commit.

### Start (move to `wip`)

1. Find the matching task file in `.backlog/`.
2. Brief the item (see Briefing below).
3. Set status to `wip`.
4. `git add` and `git commit` the file with message: `backlog: start <filename>`
5. This commit captures the full task description in git history before any code changes begin.
6. Proceed with the work.

### Update

1. Find the matching task file in `.backlog/`.
2. Edit the frontmatter or body as requested (change status, update where refs, add notes).
3. Do not auto-commit — the change will be picked up in the user's normal workflow.

### Close

1. Find the matching task file in `.backlog/`.
2. Run `git rm <file>` and `git commit` with message: `backlog: close <filename>`
3. The file's full content is preserved in the start commit's git history.

### List

1. Scan `.backlog/` for `.md` files.
2. Parse frontmatter from each file.
3. If the user's input includes `tag <name>`, show only items with that tag. If no tag is specified, show only untagged items, and append a line listing all distinct tags found (e.g. `Tags in backlog: bug, refactor`) so the user knows they exist.
4. Verify `where` refs: check that each referenced file and line still exists. Flag stale refs as `(stale)` rather than silently showing them.
5. Display tasks grouped by status: `wip` first, then `todo`, then `later`.
6. Do not show `closed` tasks unless the user explicitly asks.
7. For each task show: filename, title (first `#` heading), status, tag (if any), and `where` refs (with staleness indicator if applicable).

## Briefing

Before acting on an item (fixing or closing), read the file, verify its `where` refs, and print three one-liners:

- **Summary** — what the item is, in your own words. Not the title restated.
- **Effort** — files and call sites the fix touches, whether tests cover the path, mechanical vs. design decision.
- **Blast radius** — what else the change can reach: callers, shared code paths, generated files.

If `where` has gone stale since the item was filed, say so in the briefing before proceeding.

## Rules

- Before creating `.backlog/`, search the entire repo (`find` from repo root) for any `.backlog/` directory. If one exists anywhere other than the repo root, stop and report it to the user — `.backlog/` must only live at the repo root. If one exists at the repo root, use it. If none is found, create `.backlog/` at the repo root.
- When multiple tasks are created on the same date, disambiguate via the slug — no extra numbering needed.
- Keep commit messages terse: `backlog: create <filename>` or `backlog: close <filename>`.
- Do not create an index file.
