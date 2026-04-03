Don't fetch anything or do any other commands.
Important, get diff in a single command like that:
`git diff origin/master..HEAD` (if no branch name given)
Use branch name instead of HEAD if given.
Eg if branch name is foo then compare against origin/foo (not HEAD),

Import review the changes now
Consider (in this order)
1. No tech debt added and how maintainable code is
2. Only minimal changes to API and signatures. 
3. No inconsistencies, no potential bugs. Edge cases are handled
