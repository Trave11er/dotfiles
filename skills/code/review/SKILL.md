---
name: review
description: Review a branch/diff via subagents for tech debt, API changes, bugs and doc agreement, then act on the feedback. Only use when the user explicitly requests it (e.g. /review).
---

MANDATORY
Run everything as a subagent not directly in the parent agent. In the end subagent should provide feedback to the parent agent and the parent should act on it.

How to provide feedback:
- Don't fetch anything or do any other commands.
- Important, get diff in a single command: `git diff base..HEAD` (if no branch name given; where base is origin/dev, origin/master or origin/main - deduce nearest from branch history)
- If you are given a branch name, use that instead of HEAD, eg if branch name is foo then compare against origin/foo (not HEAD),
- If you are given a word 'last' followed by a number or alike then review only the very last N commits of the branch; without number just review the last commit.

- Important, review the changes now. Consider (in this order) these points.
MANDATORY Run each of those as a subagent then parent agent to summarise the findings.
    - Deep modules: Use the `maintainable` skill and do the deep vs shallow module check 1.
    - Loose coupling: Use the `maintainable` skill and do the checks 2-4 on information leakage, hidden dependencies and code cohesion
    - Correct: requires you to be adversarial about
        - Potential bugs
        - Any edge cases that should be covered by tests but aren't. 
        - If code being difficult to test.
    - Readable: requires
        - Code does not have unnecessary nesting and branching
        - No classes or functions that combine too many concerns
        - Names are clear to the reader; generic names are avoided 
        - Naming is consistent
        - Code itself is generally readable and not hard to follow
        - Consider if the same can be achieved with fewer concepts
        - No comments/docstrings explaining obvious code in vicinity.
        - What code does agrees with what most nearby README states.
        - Comments/docstring/README answer 'why's behind design choices.