# Domain documentation

Better-Nexus uses repository-local `.vibe/**` as its canonical compact project
context. Do not create a parallel root `CONTEXT.md` or `CONTEXT-MAP.md`.

## Sources

| Purpose | Source |
| --- | --- |
| Canonical compact context | `.vibe/CONTEXT.md` |
| Current state | `.vibe/STATE.md` |
| Current plan | `.vibe/PLAN.md` |
| Evidence | `.vibe/EVIDENCE.md` |
| Long-form architecture decisions | `docs/adr/` when present or explicitly approved |

## Precedence and use

- Live Git and GitHub truth overrides stale `.vibe/**`.
- Reconciled `.vibe/**` overrides stale chat summaries for repository
  continuation.
- Matt Pocock engineering skills consume these sources but do not replace them.
- Read archived Vibe history only when current context or exact evidence points
  to it.
- Use the project's existing domain vocabulary in issues, specifications,
  tests, and implementation plans.
- Surface conflicts with an accepted architecture decision instead of silently
  overriding it.
