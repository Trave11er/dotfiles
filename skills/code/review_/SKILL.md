---
name: review_
description: Review a branch/diff via subagents for tech debt, API changes, bugs and doc agreement, then provide on the feedback. Only use when the user explicitly requests it (e.g. /review).
---

MANDATORY
Run everything as a subagent not directly in the parent agent. In the end subagent should provide feedback to the parent agent and the parent shoulld provide feedback; no edits - a review is read-only.

How to provide feedback:
- Don't fetch anything or do any other commands.
- Important, get diff in a single command: `git diff base..HEAD` (if no branch name given; where base is origin/dev, origin/master or origin/main - deduce nearest from branch history)
- If you are given a branch name, use that instead of HEAD, eg if branch name is foo then compare against origin/foo (not HEAD),
- If you are given a word 'last' followed by a number or alike then review only the very last N commits of the branch; without number just review the last commit.

- Important, first step - review the changes now. 
MANDATORY Run each of 6 points below as a subagent. Instruct them:
    - When referencing a function, class, or symbol in feedback, include its file and line number in the form `file:line`.
    - Write findings to file
The 6 subagents to run:
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

IMPORTANT. After the subagents above have finished assume role of judge their findings. Give back ranked list with of findings where ranking = severity (1-3)* your confidence in the claim (1-3). The output list format should be:
- number, subagent, 1-5 words overview
- original claim, including file:line
- your judgement, < 20 words 
