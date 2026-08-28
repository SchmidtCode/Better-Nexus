# CONTEXT

## Architecture

- Package A is reconstructed in
  `better-nexus-publication-worktrees/bn-t19-sync-trust-24-27-31` directly on
  exact PR #67 head `4f2138b72edc778fabc55049b251a3872f5d4cbe`.
- `core/Identity.lua` owns raw identity validation and inert display projection.
- Community, DPS, Panel, Nameplate, LogViewer, chat, and Wishlist presentation
  consume display projections while persistence and wire owners retain raw data.
- `core/SyncSession.lua` owns remote status-request passivity.
- `core/Updates.lua` owns bundled release authority and bounded peer observations.
- Runtime targets WoW 3.3.5a and Lua 5.1.

## Key Decisions (2026-08-28)

- Publish only issues #24, #27, and #31 in Package A.
- Preserve rejected long execution ancestry as local evidence. Publish one new
  clean commit instead of cherry-picking the 98-commit mixed range.
- Focused EditBoxes never restore raw rich-text syntax on focus.
- Explicit export owners retain exact raw bytes separately and show reversible
  inert projections in EditBoxes.
- Exclude #22 catalog authority and #40 typed digest from this package.
- Freeze one final commit before Full. Do not add a post-Full Git receipt.

## Gotchas

- The unused local branch `bugfix/test19-sync-trust-24-27-31` points to rejected
  evidence. Preserve it. Push the frozen publication HEAD directly to the unused
  remote branch of that name through an explicit non-force refspec.
- The existing accepted execution branch remains at `3f1e7f2...`; it is evidence,
  not clean publication ancestry.
- Protected Package B files must remain byte-identical to PR #67.
- LuaLS, Luacheck, and StyLua may remain advisory-unavailable and are not passes.
- Offline checks do not prove native WoW or SavedVariables behavior.

## Hot Files

- Identity and presentation: `core/Identity.lua`, `ui/CommunityRenderer.lua`,
  `ui/Leaderboard.lua`, `ui/LogViewer.lua`, `ui/Nameplate.lua`, `ui/Panel.lua`,
  `ui/WishlistEditor.lua`, and `ui/WishlistRenderer.lua`.
- Passivity and release authority: `core/SyncSession.lua`, `core/MainLifecycle.lua`,
  `core/Main.lua`, and `core/Updates.lua`.
- Focused regressions: `tests/run_remote_display_projection.lua`,
  `tests/run_default_inert_status_requests.lua`,
  `tests/run_peer_version_observations.lua`, and parity runners.

## Agent Notes

- Spec and Standards reviews pass on the stable pre-receipt reconstruction diff.
- Final focused, Fast, and Full gates run after the receipt commit is frozen.
- Publication authorization is valid. No active orchestrator lease exists.
- Stop after draft PR exact-head CI and review reconciliation. Do not start
  Package B / issue #22.
