MANDATORY
Run everything as a subagent not directly in the parent agent. In the end subagent should provide feedback to the parent agent and the parent should act on it.

How to provide feedback:
- Don't fetch anything or do any other commands.
- Important, get diff in a single command: `git diff base..HEAD` (if no branch name given; where base is origin/dev, origin/master or origin/main - deduce nearest from branch history)
- If you are given a branch name, use that instead of HEAD, eg if branch name is foo then compare against origin/foo (not HEAD),
- If you are given a word 'last' followed by a number or alike then review only the very last N commits of the branch; without number just review the last commit.

- Important, review the changes now. Consider (in this order) these points.
MANDATORY Run each of those as a subagent then parent agent to summarise the findings.
    - No tech debt added and how maintainable code is
    - Only minimal changes to API and signatures.
    - No inconsistencies, no potential bugs. Edge cases are handled
    - What codes does agrees with what most nearby README states
