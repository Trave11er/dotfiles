---
name: build
description: Implement the tickets of a /shape feature dir one by one, unattended, in a git worktree, with an implementer subagent per ticket and agent review rounds between tickets. Only use when the user explicitly requests it (e.g. /build .scratch/<KEY>-<slug> [extra review skills...]).
---

# Build

You are a thin orchestrator: delegate all implementing and reviewing to subagents and never load review skills or read diffs yourself, so your context stays small for a long run. All state lives in files under the feature dir, which makes a re-run after a crash or `/clear` safe.

Requires the mattpocock-skills plugin (`/plugin install mattpocock-skills@claude-plugins-official`) for `code-review` and `improve-codebase-architecture`.

Arguments: the feature dir, then optionally the names of extra skills to run as reviewers, e.g. `/build .scratch/SIIS-912-foo check_style check_tests`.

Optional goal: `/goal /build printed BUILD DONE, BUILD STOPPED or BUILD PAUSED for <KEY>`.

## Layout

```
<feature dir>/            # .scratch/<KEY>-<slug>/, KEY is the commit prefix
  spec.md
  issues/NN-<slug>.md     # Status: and Blocked by: lines near the top
  reviews/NN-rR-<reviewer>.md, NN-triage.md
  followups.md
```

Status: `ready-for-agent` → `in-progress` → `done (<first sha>..<last sha>)` | `blocked`.

## Worktree

Resolve the feature dir to an absolute path first; it stays where it is. Then:
- if the cwd is already under `.claude/worktrees/`, build there;
- else if `.claude/worktrees/<KEY>-<slug>` exists, from an earlier run, call `EnterWorktree` with that `path`;
- else call `EnterWorktree` with `name: <KEY>-<slug>`.

Give subagents absolute paths to the ticket, spec and feature dir.

## Preconditions

Stop and tell the user if any of these hold:
- the branch is `dev` or `master`;
- `git status --porcelain --untracked-files=no` is non-empty;
- any ticket is `in-progress`, because a previous run crashed and needs manual cleanup.

## Per ticket

Pick the lowest-numbered ticket that isn't `done` and whose blockers are all `done`. If none is left, finish with `BUILD DONE`.

1. Record `base=$(git rev-parse HEAD)` and set `Status: in-progress`.
2. **Implementer**: spawn a fresh general-purpose subagent. Give it only the ticket and spec paths. Tell it to:
   - implement only this ticket;
   - run the project's tests and linters until green;
   - commit as `<KEY>: <ticket title>`;
   - reply in at most 10 lines.
   Keep its agent ID.
3. **Review round R** (1 or 2): spawn a fresh general-purpose subagent as the review coordinator, with `base`, the ticket path, the spec path, `R` and the feature dir. Tell it to run each of these and write the full findings of each to `reviews/NN-rR-<reviewer>.md`:
   - `review_ last N`, where N is the number of commits in `base..HEAD`;
   - only the Spec axis of `code-review <base>`, with the ticket and spec as the spec source;
   - `improve-codebase-architecture`, steps 1–2 only, scoped to the files in the diff, with no HTML report and no grilling. Report its Strong candidates that stay within the ticket; append the rest to `followups.md`;
   - each extra skill from the arguments, applied to the diff as a reviewer: report only, no fixes.

   It replies with at most 10 lines per reviewer, formatted `severity | file:line | claim`.
4. **Triage**: write `reviews/NN-triage.md`. Mark each finding `pass on` or `dismissed (nitpick | false positive | out of scope)`, with a one-line reason. Open a full findings file only when unsure. Dismiss again any finding that matches an earlier dismissal for this ticket. The ticket is clean when nothing is passed on.
5. If clean: tick the ticket's acceptance boxes, set `Status: done (<first sha>..<last sha>)` and continue with the next ticket.
6. If not clean after round 2:
   - append the passed-on findings under `## Comments` and set `Status: blocked`;
   - run `git reset --soft $base`, which leaves the work staged but uncommitted;
   - finish with `BUILD STOPPED: NN blocked`.
7. Otherwise **fix**: `SendMessage` the implementer, pointing it at `reviews/NN-triage.md`. It applies the `pass on` findings, reruns the tests and linters, and commits as `<KEY>: Address review of <ticket title>`. Go back to step 3 with round 2.

After 10 tickets are done in this run, finish with `BUILD PAUSED: <KEY>`; the user runs `/clear` and then `/build` again.

## Finish

Print exactly one marker line, `BUILD DONE: <KEY>`, `BUILD STOPPED: NN blocked` or `BUILD PAUSED: <KEY>`. Follow it with a brief: the worktree path and branch, the commits per ticket, the paths to the triage files, and `followups.md` if it exists. Never push.
