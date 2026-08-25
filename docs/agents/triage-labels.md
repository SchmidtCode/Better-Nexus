# Triage labels

Matt Pocock engineering skills use five canonical triage roles. Better-Nexus
maps them to this minimal GitHub label vocabulary:

| Matt role | GitHub label | Meaning |
| --- | --- | --- |
| `needs-triage` | `needs-triage` | Maintainer evaluation is required. |
| `needs-info` | `needs-diagnostics` | More reporter or runtime evidence is required. |
| `ready-for-agent` | `ready-for-agent` | The public contract is sufficiently specified for package planning. |
| `ready-for-human` | `ready-for-human` | Human implementation or interaction is required. |
| `wontfix` | `wontfix` | The work will not be actioned. |

Do not create a separate `needs-info` label. Preserve the repository's existing
labels, including `bug`, `enhancement`, `sync`, `migration`, `performance`,
`prerelease`, `confirmed`, and `needs-diagnostics`.

`ready-for-agent` does not authorize implementation and is not an automatic
campaign-dispatch trigger. Campaign admission still requires the explicit
issue-to-package mapping documented in `docs/agents/issue-tracker.md`.
