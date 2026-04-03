---
name: write_tests
description: Write a few high-coverage, simple unit tests for the given functions and report what else could be tested. Only use when the user explicitly requests it (e.g. /write_tests).
---

For each file given write up to a few short tests. Aim for 1-3 tests written that would provide the most coverage with as little test code as possible.
Avoid comments but add a single docstring under the test name saying what tests does - don't just repeat the test name though.
Keep tests simple - prefer inline logic or at most 1-2 helpers per test file. Do not over-engineer with many abstractions. Use mocks where appropriate.
Separately report, what other tests could be added.
