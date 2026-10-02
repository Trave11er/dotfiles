---
name: debate
description: Run one side of a two-agent debate, where PRO argues for a proposition and CON argues against it, exchanging turns through a shared file until they converge or hit a round cap, then a fresh judge subagent produces a claims-ledger verdict. Use this whenever the user asks to debate, argue both sides of, stress-test, red-team, or "find holes in" an idea, design, decision, or piece of code — and also when they ask you to be pro or con, or mention a debate session. Each agent session runs ONE side; the user launches two sessions.
---

# Debate

You are **one side**. The other side is a separate chat window. You exchange
turns through `.debate/`, using `scripts/debate.py`. The script blocks until
the other side has spoken, so the loop runs autonomously once both windows start.

## Step 0 — detect your role automatically

Check whether the user's argument to `/debate` matches an existing session:

```bash
ls -d .debate/*/ 2>/dev/null
```

- **If the argument contains a session id that exists in `.debate/`** → you are
  **CON**, joining that session. The user copied this from the PRO window.
- **Otherwise** → you are **PRO**, starting a new debate. The argument is the
  proposition.

If the word "judge" appears in the argument (case-insensitive), strip it from
the proposition and remember to pass `--judge` to `init`. This means you (PRO)
will own the verdict step instead of CON.

Set `SKILL=` to this skill's directory in every command below.

## Step 1 — start or join the session

**PRO** — init the session. Use `--target-file <path>` for a document, or
`--target-cmd "git diff HEAD~1"` to capture command output. `--rounds 3` is a
good default; 2 for simple topics.

```bash
python3 $SKILL/scripts/debate.py init --rounds 3 --target-text "<proposition>"
# If "judge" was in the user's prompt, add --judge:
# python3 $SKILL/scripts/debate.py init --rounds 3 --judge --target-text "<proposition>"
```

**STOP — before doing anything else** (no reading, no investigating, no writing
your opening), print the exact command the user must paste into their second
window:

> Run `/debate <session-id>` in another window to start the CON side.

The user needs this immediately so CON can start in parallel. Only after
printing it do you move to Step 2.

**CON** — join with the session id the user passed:

```bash
python3 $SKILL/scripts/debate.py join --role con --session <session-id>
```

## Step 2 — understand the topic

Read `roles/pro.md` or `roles/con.md` (whichever is yours) and follow it for
every turn.

Then investigate. Read `.debate/<session>/target.md` for the proposition. If it
references code, files, or external material, use your tools to read and verify.
A turn built on assumptions alone is worthless.

## Step 3 — the debate loop

Repeat until the script tells you to stop:

1. Write your turn to the outbox path the script printed
   (`.debate/<session>/outbox-<your-role>.md`). Include the
   `---DEBATE_STATUS---` block your role file specifies — convergence detection
   depends on it.
2. Run:
   ```bash
   python3 $SKILL/scripts/debate.py turn --role <your-role> --timeout 180
   ```
   This posts your turn and then blocks until the opponent replies.
3. Act on the exit code:
   - **0** — their turn is printed above. Address it and go back to step 1.
   - **2** — timed out. Run the *exact same command* again. Do this up to 5
     times, then stop and tell the user the other side looks stuck.
   - **3** — debate closed. Go to step 4.
   - **1** — protocol error; read the message and fix it.

Con's very first `turn` call has no outbox and simply waits for pro's opening —
that is expected.

Keep going through the loop without checking in with the user between rounds.
That is the point of the mechanism. Report progress only if something breaks.

## Step 4 — the verdict

When the script reports the debate is closed, check who owns the verdict:

```bash
python3 $SKILL/scripts/debate.py status
```

The `judge_role` field tells you who owns the verdict (`"con"` by default,
`"pro"` if `--judge` was passed at init).

**If you own the verdict** (your role matches `judge_role`): Spawn a fresh
subagent to judge:

```
Agent({
  subagent_type: "claude",
  description: "Judge the debate",
  prompt: "You are an impartial judge for a structured debate. Read these files and follow the judge role exactly:\n\n1. Role instructions: <SKILL>/roles/judge.md\n2. Full transcript: .debate/<session>/transcript.md\n3. The proposition: .debate/<session>/target.md\n\nWrite your verdict to: .debate/<session>/outbox-verdict.md\n\nJudge on evidence, not rhetoric. Be decisive."
})
```

Replace `<SKILL>` and `<session>` with the actual paths. Once the subagent
finishes, run:

```bash
python3 $SKILL/scripts/debate.py post-verdict --role <your-role>
```

Show the user the verdict's bottom line and where the full transcript lives.

**If you do NOT own the verdict:** Tell the user you're done and that the other
side will produce the verdict. If the user wants you to see the verdict after
it's posted, read `.debate/<session>/verdict.md`.

