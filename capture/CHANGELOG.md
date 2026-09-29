# Changelog

Format follows [Keep a Changelog](https://keepachangelog.com/), versioned as `major.minor.patch`. This app has one user and one deploy target, so versions here track meaningful behavior changes, not a public API contract.

## [3.0.0] — 2026-09-29

### Added
- **Today**, the new home: the composer (unchanged, still first), a rotating one-line reminder, what you're trying, and a daily hand of 3 cards.
- **Reflection cards** from a ~45-prompt bank in seven decks (notice, proud, curious, let go; wrong, patterns, ego). At most one heavy card per hand, no deck twice, no prompt repeated within 14 days.
- **Look-back cards**: an entry from 30+ days ago comes back (anniversaries first) with a question about what's changed. Reply, turn it into a lesson, or let it go.
- **Lessons**: one-line takeaways, linked to the entry they came from, with an optional area.
- **Tries**: at most 3 small things you're doing differently, with a gentle 14-day check-in (it stuck / still trying / letting it go). A 4th asks which one is finished.
- **Let it go**: released entries stay in the database but stop resurfacing and leave the log unless "show released" is on. Undoable.
- **Weekly look-back**: the eight journal-loop questions, one per screen, with the week's notes alongside; saved as one `#lookback` entry. Offered on Today from Saturday to Monday.
- **Growth** tab: trying now, lessons, kept, tried, changed my mind (then → now), past look-backs.
- Log shows replies and lessons threaded under their source entry, plus reflection/lesson/look-back filters.
- `?demo` mode on localhost: seeded sample data in `localStorage`, no Supabase.
- `supabase/migrate_v3.sql`: new `entries` columns (`kind`, `prompt_id`, `question`, `parent_id`, `area`, `released_at`, `resurfaced_at`) and the `tries` table.

### Changed
- Tabs are now today / log / growth. The page scrolls normally instead of inside fixed panes; the look-back and try chooser are pages with their own history entries, so the back gesture works.
- Desktop Today is two columns above 960px.
- Delete asks in a sheet that points at "let go" for things that happened and are done.

Full design rationale: [spec_v3.md](spec_v3.md).

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

[3.0.0]: https://github.com/siddhantmaharana/siddhantmaharana.github.io/tree/main/capture
[2.1.0]: https://github.com/siddhantmaharana/capture/compare/ce6c93f...HEAD
[2.0.0]: https://github.com/siddhantmaharana/capture/commit/ce6c93f
[1.0.0]: https://github.com/siddhantmaharana/capture/commit/7a2b277
