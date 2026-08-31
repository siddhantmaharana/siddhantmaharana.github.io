# Changelog

Format follows [Keep a Changelog](https://keepachangelog.com/), versioned as `major.minor.patch`. This app has one user and one deploy target, so versions here track meaningful behavior changes, not a public API contract.

## [2.1.0] — 2026-08-31

### Changed
- Entries are no longer purged on export — the database is now the permanent record, not an inbox. There is no in-app bulk delete; pruning old rows, if ever needed, is a direct Supabase SQL job.
- Desktop/web layout is responsive above 720px: wider column, larger font, taller composer. Previously the phone-width layout (480px, 15px font) shipped unchanged to every screen size.
- Mobile Enter key now inserts a newline instead of saving. Enter-to-save is desktop-only (`pointer: coarse` detection); Shift+Enter-for-newline stays the desktop shortcut.
- Header's sign-out icon is joined by a refresh (`↻`) icon that re-fetches entries and tags without ending the session.

### Added
- Entries can be edited in place: tap to expand, `edit`, change the text, `save`. Tags re-derive from the edited text on save.
- `entries_update_own` RLS policy in `supabase/schema.sql`, required for edit to work.

### Removed
- Export to Obsidian (markdown + frontmatter) and the export-triggered "clear the db?" confirmation. A better export, built directly against Supabase, is deferred — see `spec_v2.1.md`.
- Long-press-to-delete. Replaced by an explicit `delete` button shown when an entry is expanded.
- The one-time `localStorage` → Supabase import prompt left over from the v1 → v2 migration. It kept re-triggering ("found N entries, import them?") on browsers with stale local data long after everyone had migrated.

Full design rationale: [spec_v2.1.md](spec_v2.1.md).

## [2.0.0] — 2026-08-09

### Changed
- Storage moved from `localStorage` to Supabase (Postgres + RLS), shared with the [touchbase](https://github.com/siddhantmaharana/touchbase) project's account and auth.
- Auth added: email magic link, session-persisted.
- Export to Obsidian markdown now deletes the exported rows from the database on confirm — the db was treated as an inbox, not an archive.

### Removed
- Mood tracking (buttons, colors, filter row, `mood::` export line) — tags became the only categorization.

Full design rationale: [spec_v2.md](spec_v2.md).

## [1.0.0] — 2026-06-29

Initial release: single-file PWA, `localStorage`-backed, inline `#tag` capture with mood buttons, log view, Obsidian markdown export.

[2.1.0]: https://github.com/siddhantmaharana/capture/compare/ce6c93f...HEAD
[2.0.0]: https://github.com/siddhantmaharana/capture/commit/ce6c93f
[1.0.0]: https://github.com/siddhantmaharana/capture/commit/7a2b277
