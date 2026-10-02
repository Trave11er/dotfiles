---
name: write_tests
description: Write a few high-coverage, simple unit tests for the given functions and report what else could be tested. Only use when the user explicitly requests it (e.g. /write_tests).
---

For each file given write up to a few short tests. Aim for 1-3 tests written that would provide the most coverage with as little test code as possible.
Avoid comments but add a single docstring under the test name saying what tests does - don't just repeat the test name though.
Use plain `test_*` functions, not test classes. Keep tests simple - prefer inline logic or at most 1-2 helpers per test file. Do not over-engineer with many abstractions. Use mocks where appropriate.
Separately report, what other tests could be added. When referencing a function, class, or symbol, include its file and line number in the form `file:line`.

## "adversarial" option

When the user's request includes the word **adversarial**, spawn a `general-purpose` subagent via the Agent tool. Do NOT write normal tests first — this is a standalone mode. The subagent must follow the same test style rules above (plain `test_*` functions, docstrings, simple, mocks where appropriate) but with a different goal: read the existing source code and any existing tests, then write tests for cases that a reader would **expect to pass** but that actually **fail** — exposing hidden bugs, incorrect assumptions, or missing edge-case handling. The subagent should:

1. Read the source code and any existing tests.
2. Write `test_*` functions in the test file, in a section headed by a `# Adversarial` comment separator.
3. Each test must document in its docstring why a reasonable person would expect it to pass.
4. Run the tests — failures are the point. Report which adversarial tests failed and what that reveals about the code.
