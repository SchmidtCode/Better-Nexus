# CONTEXT

## Architecture

- WP4 is isolated in `.test19-wp4-worktree` on `bugfix/test19-wp4-exact-wishlist-evidence`, based exactly on frozen WP3 head `e674f033cc51494a382191b987c9a99cb6827f4a`.
- Wishlist draft flow is `core/WishlistModel.lua` -> `core/WishlistController.lua` -> `ui/WishlistEditor.lua` / `ui/WishlistRenderer.lua`; EBH1 transfer passes through `core/Codec.lua`.
- Typed record evidence is owned by `core/CandidateEvidence.lua`; live active/locked reads and Wishlist association are behind `core/GameAdapter.lua` and `core/LoadoutEvidence.lua`.
- Progress and automation decisions flow through `logic/Model.lua` -> `logic/Policy.lua` -> `logic/Ratchet.lua` -> GameAdapter; `ui/WishlistOverlay.lua` must consume the same exact progress authority.
- Runtime targets WoW 3.3.5a and Lua 5.1. `tools/Invoke-QualityGate.ps1` owns Fast/Full/Package/Security validation.

## Key Decisions (2026-08-21)

- Execute WP4 in order: #43 exact ordinary draft identity -> #44 counted locked evidence -> #20 read-time role derivation -> #35 exact progress.
- Trustworthy exact `spellId` owns ordinary draft rows. Family is display/search grouping only; compatibility rows need deterministic collision-safe fallback identity.
- Locked validation uses total copies `sum(stacks) <= 6`, preserving exact tier, count, provenance, and unknown fields; ordinary and locked limits remain separate.
- #20 derives `exact active total - authoritative exact locked counts = exact ordinary counts` without rewriting active, Snapshot, Designed, or historical evidence. Partial, stale, ambiguous, or underflow inputs fail closed.
- #35 must share one exact-tier progress boundary across model, policy/ratchet, editor, HUD, and overlay; family possession never satisfies a sibling tier.
- Freeze product/test/workflow bytes, complete independent Spec/Standards/adversarial review, then run one final Full. Any governed-byte repair after Full requires another Full.

## Gotchas

- Root and `.lag-hotfix-worktree` contain unrelated user changes. Earlier WP2/WP3 worktrees are frozen and must not be edited, rebased, cleaned, stashed, or deleted.
- Vibe flags and routing are dispatcher-owned. The Stage 48 maintenance scan/review/hygiene is complete and deliberately left product checkpoint 48.1 `NOT_STARTED`.
- Current draft code repeatedly uses `family` as the map/action handle; change the handle explicitly before switching ordinary identity so sibling actions cannot alias.
- CandidateEvidence currently limits locked row count and rejects duplicate spell identities; WP4 must validate counted copies and preserve legitimate exact counted evidence instead.
- GameAdapter locked reads already produce `bySpell` counts. Do not infer count one from row presence or derive roles from title, short hash/name, family, slot proximity, or approximate similarity.
- LuaLS, Luacheck, and StyLua may remain advisory-unavailable and must not be reported as passes. Offline checks do not prove native WoW behavior.

## Hot Files

- #43: `core/WishlistModel.lua`, `core/WishlistController.lua`, `ui/WishlistEditor.lua`, `ui/WishlistRenderer.lua`, `core/Codec.lua`, and Wishlist model/editor/controller/import tests.
- #44: `core/CandidateEvidence.lua`, `core/WishlistModel.lua`, `core/GameAdapter.lua`, `core/LoadoutEvidence.lua`, and CandidateEvidence/locked-loadout tests.
- #20: `core/GameAdapter.lua`, `core/LoadoutEvidence.lua`, association fixtures, and exact active/locked evidence tests.
- #35: `logic/Model.lua`, `logic/Policy.lua`, `logic/Ratchet.lua`, `core/MainViewModel.lua`, `ui/WishlistOverlay.lua`, and Wishlist progress/parity tests.
- Workflow: `AGENTS.md`, `.vibe/STATE.md`, `.vibe/PLAN.md`, this file, and append-only `.vibe/EVIDENCE.md`.

## Agent Notes

- Current state: publication reconstruction checkpoint 49.1 is `NOT_STARTED` on `publication/reconstruct-bn-t19-wp5-pr58-repair-7fc2b347e035` at lifecycle head `3849fdc`; parent is exact accepted WP4 head `e70de8a`.
- Reconstruct accepted source `7fc2b347e035000b8fd65e70ad25e756cc945865` semantically; audit the complete accepted and old-draft ranges with patch IDs and range-diff instead of cherry-picking execution ancestry.
- Reproduce the historical-auto-DPS Copy-authority red on the exact publication parent, then restore only accepted product/tests/contracts and strictly necessary workflow bytes. Preserve Test 18 and external CS-340/SS-540 fail-closed authority.
- Keep historical snapshots immutable; current Copy requires independently verified provenance. Sync/cursor summaries must agree, Average is not ranking authority, and compatible pairing must remain real and bounded.
- Reserve repository Full for controller-owned independent review. No push, GitHub mutation, package/install/native work, SavedVariables access, history rewrite, WP8, PR #59/#60, or unrelated Stage 53 bytes.

## Stage Retrospective Notes

- Stage 48 repeatedly exposed authority drift across parallel Wishlist consumers; Stage 49 must define one current-authority verdict first, then route Copy, summary, UI, and persistence through it.
- Stage 48 review cycles found malformed and aliased evidence after happy-path fixes; Stage 49 expected-red matrices must cover conflicting provenance, verified-empty locks, unknown fields, reload, and Sync before implementation.
- Stage 48 parity repairs showed synchronous and resumed projections need shared fixtures; Stage 49 paired-summary tests must run the same crossed-maxima corpus through both paths.
- Stage 48 kept Full useful by reserving it for independently accepted bytes; this publication reconstruction must leave Full to the controller after exact-head review.
- Build the complete compatibility-positive inventory before freezing an authority migration; late Full-only fixture discovery is avoidable.
- Define one typed authority verdict and cross-surface alias matrix before updating ingress, summary, projection, and export callers.
- Expected-red preservation matrices must include collisions, malformed values, future-owned data, and restart/reload ordering.
- Public quarantine rules require sync/async/detail/fallback/count/sort/page parity.
- Reserve Full until all independent review axes accept the exact frozen bytes.
