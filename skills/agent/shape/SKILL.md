---
name: shape
description: Turn an idea into a reviewed spec and tickets under .scratch/<KEY>-<slug>/ via grill, architecture review, to-spec and to-tickets, ready for /build. Only use when the user explicitly requests it (e.g. /shape).
---

# Shape

Interactive: the user is present throughout. The output is a spec and tickets that `/build` can run unattended.

Requires the mattpocock-skills plugin (`/plugin install mattpocock-skills@claude-plugins-official`) for `improve-codebase-architecture`, `to-spec` and `to-tickets`.

## Instructions

1. Ask for the Jira key (e.g. `SIIS-912`) and a short kebab-case slug. The feature dir is `.scratch/<KEY>-<slug>/`, and every skill below uses it as the issue tracker location.
2. Call the Skill tool with `grill` on the idea.
3. When the grilling feels settled, run two subagents in parallel, both scoped to the modules the grilling touched:
   - `improve-codebase-architecture`: steps 1–2 only (explore, write the HTML report). Return the candidates as one line each.
   - `maintainable`: apply all four checks to the proposed design. Return the findings as one line each.
4. Keep grilling on their findings, one decision at a time. Accepted findings become design decisions, typically prefactors.
5. Call the Skill tool with `to-spec`. It writes `.scratch/<KEY>-<slug>/spec.md`.
6. Call the Skill tool with `to-tickets` on that spec. It writes `.scratch/<KEY>-<slug>/issues/NN-<slug>.md`, with prefactors first and `Status: ready-for-agent`.
7. Finish by printing the build commands:
   ```
   /goal /build printed BUILD DONE, BUILD STOPPED or BUILD PAUSED for <KEY>
   /build .scratch/<KEY>-<slug>
   ```
