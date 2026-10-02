# General-Purpose Debate Skill — Spec

Modify the existing code-review debate skill in-place to support any topic.
Clean break: no backward compatibility with defender/critic roles.

## Roles

**Pro** opens the debate arguing for the proposition. **Con** argues against it.
No custom role override — the topic text scopes the debate.

## Turn Structure

Each turn contains numbered claims with evidence. Each side must explicitly
address every opponent claim with one of:

- **REFUTED** — with reasoning
- **CONCEDED** — plainly, no hedging
- **WITHDRAWN** (own prior claim) — when opponent's rebuttal holds

No fabrication. No padding. If nothing new remains, converge.

### Status Block

Pro:
```
---DEBATE_STATUS---
ROLE: PRO
CLAIMS_STANDING: <int>
CONCEDED_THIS_TURN: <int>
NEW_POINTS: <int>
CONVERGED: <true/false>
SUMMARY: <=80 words
---END---
```

Con:
```
---DEBATE_STATUS---
ROLE: CON
CLAIMS_STANDING: <int>
WITHDRAWN_THIS_TURN: <int>
NEW_POINTS: <int>
CONVERGED: <true/false>
SUMMARY: <=80 words
---END---
```

## Convergence

The debate closes when:
1. Round cap hit (default 3), or
2. Both sides set `CONVERGED: true`, or
3. Both sides report `NEW_POINTS: 0` in the same round (auto-close safety valve)

## Judge

Con spawns a **fresh subagent** (`subagent_type: 'claude'`, same model as parent)
when the debate closes. The subagent receives only:
- Path to `transcript.md`
- Path to `target.md`
- Path to `roles/judge.md`

No inherited context from either side. The judge reads the files, writes
`outbox-verdict.md`, then Con runs `debate.py post-verdict`.

## Verdict Format

Claims ledger grouped by outcome, strongest verdicts first:

```markdown
# Verdict

## Sustained
- [Pro/Con] Claim N — <one line> — Evidence: <why it held>

## Refuted
- [Pro/Con] Claim N — <one line> — Refuted by: <what countered it>

## Weakened
- [Pro/Con] Claim N — <one line> — Weakness: <what undermined it>

## Bottom line
<2–4 sentences. Which position prevailed and why. Be decisive.>
```

Empty sections get `- (none)`.

## Init Command

No changes to `--target-file`, `--target-cmd`, `--target-text` flags.
Pro opens. Con joins with `debate.py join --role con --session <id>`.

## File Changes

| File | Action |
|------|--------|
| `SKILL.md` | Rewrite: general-purpose instructions, pro/con framing |
| `roles/defender.md` | Delete |
| `roles/critic.md` | Delete |
| `roles/pro.md` | New: Pro contract and status block |
| `roles/con.md` | New: Con contract, status block, judge-spawning instructions |
| `roles/judge.md` | Rewrite: claims ledger verdict, no code-review fields |
| `scripts/debate.py` | Update: `ROLES = ("pro", "con")`, convergence checks for new status fields, auto-close on dual `NEW_POINTS: 0` |
