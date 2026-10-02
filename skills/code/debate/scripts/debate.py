#!/usr/bin/env python3
"""
debate.py - file-based turn-taking for a two-agent debate.

Two independent IDE agent sessions (Cursor, Claude Code, whatever) coordinate
through a shared session directory. Neither agent orchestrates the other:
each one posts its turn and then BLOCKS on this script until the opponent
has posted. Strict alternation, pro first.

Commands:
  init          create a session (run this in the PRO window, first)
  join          attach to an existing session (CON window)
  turn          post my outbox (if it's my turn) then wait for the opponent
  status        show session state
  transcript    rebuild transcript.md from the individual turns
  judge         claim the verdict step (judge_role from state, default con)
  post-verdict  publish outbox-verdict.md as the final verdict

Exit codes for `turn`:
  0  opponent's turn is ready (printed to stdout) - continue debating
  1  usage/protocol error (message on stderr)
  2  timed out waiting - just run the exact same command again
  3  debate is closed (converged or round cap) - move to the judge step

No third-party dependencies. Python 3.8+.
"""

import argparse
import json
import os
import re
import shutil
import sys
import time
from datetime import datetime, timezone

ROOT = ".debate"
ROLES = ("pro", "con")


# --------------------------------------------------------------------------
# session plumbing
# --------------------------------------------------------------------------

def sdir(session):
    return os.path.join(ROOT, session)


def resolve_session(name):
    """Return a session id. 'latest' picks the most recently created one."""
    if name and name != "latest":
        if not os.path.isdir(sdir(name)):
            die(f"no such session: {name}")
        return name
    if not os.path.isdir(ROOT):
        die(f"no {ROOT}/ directory yet - run `init` in the pro window first")
    candidates = [
        d for d in os.listdir(ROOT)
        if os.path.isfile(os.path.join(ROOT, d, "state.json"))
    ]
    if not candidates:
        die("no debate sessions found - run `init` in the pro window first")
    # newest by state.json mtime, so custom --name sessions still resolve
    candidates.sort(key=lambda d: os.path.getmtime(os.path.join(ROOT, d, "state.json")))
    return candidates[-1]


def load_state(session):
    with open(os.path.join(sdir(session), "state.json")) as f:
        return json.load(f)


def save_state(session, state):
    path = os.path.join(sdir(session), "state.json")
    tmp = path + ".tmp"
    with open(tmp, "w") as f:
        json.dump(state, f, indent=2)
    os.replace(tmp, path)  # atomic; avoids a half-written state if we're killed


def turns_dir(session):
    return os.path.join(sdir(session), "turns")


def list_turns(session):
    d = turns_dir(session)
    if not os.path.isdir(d):
        return []
    return sorted(f for f in os.listdir(d) if f.endswith(".md"))


def whose_turn(session):
    """Strict alternation, pro opens."""
    return ROLES[len(list_turns(session)) % 2]


def outbox(session, role):
    return os.path.join(sdir(session), f"outbox-{role}.md")


def opponent(role):
    return "con" if role == "pro" else "pro"


def die(msg, code=1):
    print(f"debate.py: {msg}", file=sys.stderr)
    sys.exit(code)


def now():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


# --------------------------------------------------------------------------
# status block parsing / convergence
# --------------------------------------------------------------------------

def parse_status(text):
    """Pull the ---DEBATE_STATUS--- block out of a turn. Missing keys are fine."""
    out = {}
    block = re.search(
        r"---DEBATE_STATUS---(.*?)(?:---END---|\Z)", text, re.S | re.I
    )
    body = block.group(1) if block else ""
    for line in body.splitlines():
        if ":" in line:
            k, v = line.split(":", 1)
            out[k.strip().upper()] = v.strip()
    return out


def truthy(v):
    return str(v).strip().lower() in ("true", "yes", "1")


def as_int(v, default=None):
    m = re.search(r"-?\d+", str(v))
    return int(m.group()) if m else default


def check_convergence(session, state):
    """Close the debate if the round cap is hit or the sides have converged."""
    turns = list_turns(session)
    completed_rounds = len(turns) // 2

    if completed_rounds >= state["max_rounds"]:
        return f"round cap reached ({state['max_rounds']} rounds)"

    if len(turns) < 2:
        return None

    last_path = os.path.join(turns_dir(session), turns[-1])
    with open(last_path) as f:
        last = parse_status(f.read())
    with open(os.path.join(turns_dir(session), turns[-2])) as f:
        prev = parse_status(f.read())

    if truthy(last.get("CONVERGED")) and truthy(prev.get("CONVERGED")):
        return "both sides converged"

    if (as_int(last.get("NEW_ARGUMENTS"), 1) == 0
            and as_int(prev.get("NEW_ARGUMENTS"), 1) == 0):
        return "both sides exhausted (no new arguments)"

    return None


def close(session, state, reason):
    state["status"] = "closed"
    state["closed_reason"] = reason
    state["closed_at"] = now()
    save_state(session, state)
    rebuild_transcript(session)


# --------------------------------------------------------------------------
# commands
# --------------------------------------------------------------------------

def cmd_init(a):
    session = a.name or datetime.now().strftime("%Y%m%d-%H%M%S")
    d = sdir(session)
    if os.path.isdir(d):
        die(f"session {session} already exists")
    os.makedirs(turns_dir(session))

    # Capture whatever is under review into target.md.
    target_md = os.path.join(d, "target.md")
    if a.target_file:
        shutil.copyfile(a.target_file, target_md)
        desc = f"file: {a.target_file}"
    elif a.target_cmd:
        rc = os.system(f"{{ {a.target_cmd} ; }} > {target_md!r} 2>&1")
        if rc != 0 or os.path.getsize(target_md) == 0:
            die(f"target command produced nothing: {a.target_cmd}")
        desc = f"command: {a.target_cmd}"
    elif a.target_text:
        with open(target_md, "w") as f:
            f.write(a.target_text + "\n")
        desc = a.target_text
    else:
        die("give one of --target-file, --target-cmd, or --target-text")

    save_state(session, {
        "session": session,
        "created_at": now(),
        "target": desc,
        "max_rounds": a.rounds,
        "status": "open",
        "closed_reason": None,
        "verdict_by": None,
        "judge_role": "pro" if a.judge else "con",
    })

    print(f"session:    {session}")
    print(f"dir:        {d}")
    print(f"target:     {desc}  ->  {target_md}")
    print(f"max rounds: {a.rounds}")
    print()
    print("You are PRO and you open the debate.")
    print(f"Write your opening turn to: {outbox(session, 'pro')}")
    print("Then run:  python3 <skill>/scripts/debate.py turn --role pro")
    print()
    print("In the OTHER window, start con with:")
    print(f"  python3 <skill>/scripts/debate.py join --role con --session {session}")


def cmd_join(a):
    session = resolve_session(a.session)
    state = load_state(session)
    print(f"session: {session}   status: {state['status']}   "
          f"max rounds: {state['max_rounds']}")
    print(f"target:  {state['target']}  ->  {os.path.join(sdir(session), 'target.md')}")
    print(f"turns so far: {len(list_turns(session))}   next up: {whose_turn(session)}")
    print(f"your outbox: {outbox(session, a.role)}")
    if state["status"] == "closed":
        print(f"\nDebate is closed ({state['closed_reason']}). Go to the judge step.")
        sys.exit(3)
    print("\nNext: run `turn --role %s`. If it isn't your turn yet it will wait." % a.role)


def do_post(session, state, role):
    """Move my outbox into the turn log."""
    src = outbox(session, role)
    with open(src) as f:
        text = f.read()
    if not text.strip():
        die(f"{src} is empty - write your turn into it first")

    n = len(list_turns(session)) + 1
    dst = os.path.join(turns_dir(session), f"{n:03d}-{role}.md")
    header = f"<!-- round {(n + 1) // 2}, {role}, {now()} -->\n\n"
    with open(dst, "w") as f:
        f.write(header + text.rstrip() + "\n")
    os.remove(src)
    print(f"[posted] turn {n:03d} as {role}", file=sys.stderr)

    if not parse_status(text):
        print("[warn] no ---DEBATE_STATUS--- block found in your turn; "
              "convergence detection will not work", file=sys.stderr)

    reason = check_convergence(session, state)
    if reason:
        close(session, state, reason)
    return reason


def cmd_turn(a):
    session = resolve_session(a.session)
    state = load_state(session)
    role = a.role

    if state["status"] == "closed":
        print(f"Debate closed: {state['closed_reason']}")
        print(f"Transcript: {os.path.join(sdir(session), 'transcript.md')}")
        print("Next: run `judge --role %s`." % role)
        sys.exit(3)

    # Post my turn, but only if it is actually my turn.
    if whose_turn(session) == role:
        if os.path.isfile(outbox(session, role)):
            reason = do_post(session, state, role)
            if reason:
                print(f"Debate closed: {reason}")
                print(f"Transcript: {os.path.join(sdir(session), 'transcript.md')}")
                print("Next: run `judge --role %s`." % role)
                sys.exit(3)
        else:
            die(f"it's your turn but {outbox(session, role)} doesn't exist - "
                "write your turn there, then run this again")
    elif os.path.isfile(outbox(session, role)):
        print(f"[note] not your turn yet; {outbox(session, role)} is held until it is",
              file=sys.stderr)

    # Wait for the opponent.
    before = len(list_turns(session))
    deadline = time.time() + a.timeout
    print(f"[waiting] for {opponent(role)} (timeout {a.timeout}s)", file=sys.stderr)
    while time.time() < deadline:
        time.sleep(a.poll)
        state = load_state(session)
        if state["status"] == "closed":
            rebuild_transcript(session)
            print(f"Debate closed: {state['closed_reason']}")
            print(f"Transcript: {os.path.join(sdir(session), 'transcript.md')}")
            print("Next: run `judge --role %s`." % role)
            sys.exit(3)
        turns = list_turns(session)
        if len(turns) > before:
            latest = turns[-1]
            with open(os.path.join(turns_dir(session), latest)) as f:
                body = f.read()
            rebuild_transcript(session)
            print(f"===== {opponent(role).upper()} replied ({latest}) =====")
            print(body)
            print("===== end of their turn =====")
            print(f"\nRounds completed: {len(turns) // 2} of {state['max_rounds']}.")
            print(f"Your move: write {outbox(session, role)} and run this command again.")
            sys.exit(0)

    print(f"No reply from {opponent(role)} within {a.timeout}s. "
          "Run the exact same command again to keep waiting.")
    sys.exit(2)


def rebuild_transcript(session):
    path = os.path.join(sdir(session), "transcript.md")
    parts = [f"# Debate transcript - {session}\n"]
    for name in list_turns(session):
        n, role = name.replace(".md", "").split("-", 1)
        with open(os.path.join(turns_dir(session), name)) as f:
            parts.append(f"\n## Turn {n} - {role.upper()}\n\n{f.read().strip()}\n")
    with open(path, "w") as f:
        f.write("\n".join(parts))
    return path


def cmd_transcript(a):
    session = resolve_session(a.session)
    print(rebuild_transcript(session))


def cmd_status(a):
    session = resolve_session(a.session)
    state = load_state(session)
    turns = list_turns(session)
    print(json.dumps({
        "session": session,
        "status": state["status"],
        "closed_reason": state["closed_reason"],
        "target": state["target"],
        "turns": len(turns),
        "rounds_completed": len(turns) // 2,
        "max_rounds": state["max_rounds"],
        "next_up": None if state["status"] == "closed" else whose_turn(session),
        "judge_role": state.get("judge_role", "con"),
        "verdict_by": state.get("verdict_by"),
    }, indent=2))


def cmd_judge(a):
    session = resolve_session(a.session)
    state = load_state(session)
    if state["status"] != "closed" and not a.force:
        die(f"debate still open (next up: {whose_turn(session)}). "
            "Use --force to judge early.")

    judge_role = state.get("judge_role", "con")
    if a.role != judge_role:
        die(f"only {judge_role} owns the verdict step for this session")

    state["verdict_by"] = judge_role
    save_state(session, state)

    transcript = rebuild_transcript(session)
    print(f"{judge_role.upper()} owns the verdict step for session {session}.")
    print(f"Closed because: {state['closed_reason']}")
    print()
    print("Spawn a fresh subagent to judge (see SKILL.md step 4).")
    print(f"Transcript: {transcript}")
    print(f"Target:     {os.path.join(sdir(session), 'target.md')}")
    print(f"Verdict to: {os.path.join(sdir(session), 'outbox-verdict.md')}")
    print(f"Then run: debate.py post-verdict --role con --session {session}")


def cmd_post_verdict(a):
    session = resolve_session(a.session)
    state = load_state(session)
    judge_role = state.get("judge_role", "con")
    if a.role != judge_role:
        die(f"only {judge_role} can post the verdict for this session")
    src = os.path.join(sdir(session), "outbox-verdict.md")
    if not os.path.isfile(src):
        die(f"{src} not found - write the verdict there first")
    dst = os.path.join(sdir(session), "verdict.md")
    shutil.move(src, dst)
    state["verdict_at"] = now()
    save_state(session, state)
    print(f"Verdict published: {dst}")


# --------------------------------------------------------------------------

def main():
    p = argparse.ArgumentParser(prog="debate.py", description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)

    def common(sp, role_required=True):
        sp.add_argument("--session", default="latest")
        if role_required:
            sp.add_argument("--role", required=True, choices=ROLES)

    i = sub.add_parser("init", help="create a session (pro window)")
    i.add_argument("--target-file")
    i.add_argument("--target-cmd", help='e.g. "git diff HEAD~1"')
    i.add_argument("--target-text", help="the proposition or topic to debate")
    i.add_argument("--rounds", type=int, default=3)
    i.add_argument("--name", help="session id (default: timestamp)")
    i.add_argument("--judge", action="store_true",
                   help="pro (initiator) owns the verdict step instead of con")
    i.set_defaults(func=cmd_init)

    j = sub.add_parser("join", help="attach to a session")
    common(j)
    j.set_defaults(func=cmd_join)

    t = sub.add_parser("turn", help="post my turn, then wait for the opponent")
    common(t)
    t.add_argument("--timeout", type=int, default=180)
    t.add_argument("--poll", type=int, default=3)
    t.set_defaults(func=cmd_turn)

    s = sub.add_parser("status", help="show session state")
    common(s, role_required=False)
    s.set_defaults(func=cmd_status)

    tr = sub.add_parser("transcript", help="rebuild transcript.md")
    common(tr, role_required=False)
    tr.set_defaults(func=cmd_transcript)

    jd = sub.add_parser("judge", help="claim the verdict step (con only)")
    common(jd)
    jd.add_argument("--force", action="store_true")
    jd.set_defaults(func=cmd_judge)

    pv = sub.add_parser("post-verdict", help="publish the verdict")
    common(pv)
    pv.set_defaults(func=cmd_post_verdict)

    a = p.parse_args()
    a.func(a)


if __name__ == "__main__":
    main()
