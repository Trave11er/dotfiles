---
name: review_
description: Review a branch/diff via subagents for tech debt, API changes, bugs and doc agreement, then report the feedback. Only use when the user explicitly requests it (e.g. /review_).
---

MANDATORY
Run everything as a subagent not directly in the parent agent. In the end subagent should provide feedback to the parent agent and the parent shoulld provide feedback; no edits - a review is read-only.

How to provide feedback:
- Don't fetch anything and do read-only commands.
- Important, get diff in a single command: `git diff base..HEAD` (if no branch name given; where base is origin/dev, origin/master or origin/main - deduce nearest from branch history)
- If you are given a branch name, use that instead of HEAD, eg if branch name is foo then compare against origin/foo (not HEAD),
- If you are given a word 'last' followed by a number or alike then review only the very last N commits of the branch; without number just review the last commit.

- Important, first step - review the changes now. 
MANDATORY Run each of 7 points below as a subagent. Instruct them:
    - When referencing a function, class, or symbol in feedback, include its file and line number in the form `file:line`.
    - Write findings to file
The 7 subagents to run:
    1. deep_modules: Use the `maintainable` skill and do the deep vs shallow module check 1.
    2. loose_coupling: Use the `maintainable` skill and do the checks 2-4 on information leakage, hidden dependencies and code cohesion
    3. correct: requires you to be adversarial about
        - Potential bugs
        - Any edge cases that should be covered by tests but aren't. 
        - If code being difficult to test.
    4. readabilty: requires
        - Code does not have unnecessary nesting and branching
        - No classes or functions that combine too many concerns
        - Names are clear to the reader; generic names are avoided 
        - Naming is consistent
        - No inderection through many functions; classes are preferred
        - Code itself is generally readable and not hard to follow
        - Consider if the same can be achieved with fewer concepts
        - No comments/docstrings explaining obvious code in vicinity.
        - What code does agrees with what most nearby README states.
        - Comments/docstring/README answer 'why's behind design choices.
    5. minimal: requires
        - Find if any of the existing functionality can be reused/adapted instead of new ones being added
        - The goal is to reduce lines of code being added through refactoring so code easier to read and maintain
        - If there are >3x more lines added than removed that is a red flag that existing functionality wasn't reused
    6. conformist: if AGENTS.md exists check that its guidlines are being followed
    7. consistent: may also run `git log -p` over the same commit range and `find` for the file below
        - Each commit message agrees with what that commit changes; flag claims not in the diff and notable changes not mentioned
        - Deduce the ticket name (eg FOO-XXX) from the branch name or commit messages. If a `pr_<ticket-name>*` file exists in the repo (it holds the PR description and the ticket description), flag discrepancies between the PR description, the ticket description and the diff: requirements not implemented, changes not described, misalignment between claimed and done

MANDATORY. As soon as each reviewer subagent above finishes, spawn a separate fresh 'checker' subagent for it (one checker per reviewer, 7 in total; don't wait for the other reviewers). Instruct each checker:
    - Read the findings file of its reviewer and verify each claim against the diff and the code; don't trust the reviewer.
    - Drop findings that are wrong, unverifiable, duplicates or nitpicks outside the reviewer's remit.
    - For each surviving finding give severity (1-3) and confidence in the claim (1-3), plus a judgement < 20 words.
    - Report only the filtered findings back to the parent agent; the reviewer's raw findings never go to the parent directly.

IMPORTANT. After all checkers have reported, aggregate their findings: merge duplicates across checkers and compute score = severity * confidence, drop every item with score < 6, and give back the rest sorted by score (highest first). If nothing has score >= 6, say so. The output list format should be:
- number, subagent, 1-5 words overview, score
- original claim, including file:line
- checker's judgement, < 20 words
