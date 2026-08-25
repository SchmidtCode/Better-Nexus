# Issue tracker: GitHub

Durable public Better-Nexus work is tracked in GitHub Issues for
`Viscerals/Better-Nexus`. Pull requests are publication and review units, not a
request or triage surface.

## Ownership

- GitHub Issues contain durable public bug, compatibility, feature, and
  architecture contracts.
- The Better-Nexus orchestration manifest and durable campaign database control
  execution order, base selection, validation, review, and authorization gates.
- Repository-local `.vibe/**` controls compact repository continuation state.
- GitHub labels describe triage state; they do not authorize implementation or
  campaign dispatch outside an approved orchestration package.

## Issue lifecycle

- Search titles, bodies, keywords, and semantics before creating an issue.
- Reuse an equivalent current issue instead of creating a duplicate.
- Keep transient repair attempts, expected-red scratch work, controller
  receipts, and unpublished execution detail local.
- Close an issue only after its own acceptance criteria pass on accepted and
  appropriately published ancestry.

## Campaign admission

`ready-for-agent` is advisory and never starts work automatically. An issue may
enter the campaign only through an explicit mapping containing its issue
number, package ID, dependency selector, risk level, publication class, and
release-gate status.

```text
GitHub issue
-> durable public contract

orchestrator package
-> execution order, base selector, validation, review, and gates

.vibe/**
-> compact repository continuation state

pull request
-> reviewed publication unit
```
