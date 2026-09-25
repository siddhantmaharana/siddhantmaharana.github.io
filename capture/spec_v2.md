Capture — v2

A minimal thought-capture PWA. Log what's on your mind, tag it, sync it, export to Obsidian, keep the database empty.

Goal

Make capturing a thought take less than five seconds, from anywhere, on any device — and never let the database become a second place you have to think about. It's a mailbox, not an archive. Obsidian is the archive.

What v2 changes over v1

* Mood buttons are gone. Tags are now the only way you categorize an entry — inline `#tags`, same as today, just no longer competing with a mood grid for space or attention.
* Data moves from `localStorage` to Supabase, **the same Supabase project touchbase already uses** — one account, one set of keys, one backend to maintain across both apps.
* Export now cleans up after itself: exporting to Obsidian markdown deletes the exported rows from the database. The db only ever holds what hasn't been exported yet.

Everything else — single HTML file, zero build step, no framework — stays the same. This is a simplification and a storage upgrade, not a rewrite of the philosophy.

Non-goals for v2

* A unified app with touchbase (two thin apps, one shared backend — see "why not merge the apps" below)
* Mood tracking, in any form
* Social integrations, email/SMS notifications, AI summaries
* Shared accounts or team workflows
* Offline queue / conflict resolution
* A build step, framework, or component library

Why not merge the apps

capture and touchbase are used completely differently: capture is opened many times a day for a five-second write, touchbase is opened a few times a week to browse a list. Merging them into one PWA means both now need a nav/router just to reach their core action — directly working against "easy to enter." A shared Supabase project gets the maintenance win (one account, one key pair, one auth flow) without coupling two apps with different usage patterns and different release cadences. Revisit this only if a third app shows up and the pattern repeats.

Core user flow

1. Open the app (already signed in from last time, magic-link session persists).
2. Type a thought, tag it inline with `#tags` as you go.
3. Hit save — it's already in Supabase.
4. Occasionally: open the log, filter by tag, review.
5. Periodically (weekly? monthly?): export to Obsidian. The exported entries vanish from the app. Tags you've used stay available for autocomplete even though the entries that used them are gone.

Stack

Frontend

* Same single `index.html`, zero build step
* `supabase-js` via CDN — the only dependency
* No React, no bundler

Backend

* None, beyond Supabase. PostgREST is the API.
* Same Supabase project as touchbase — new tables, not a new project.

Auth

* Email magic link, via the same Supabase Auth users table touchbase already uses. Signing in once with an email works for both apps.
* RLS scopes every row to `auth.uid()` — same pattern as touchbase, same policies shape.

Information model

`entries` — the inbox. Emptied by export.

* id (uuid, pk)
* user_id (uuid, fk → auth.users, RLS key)
* text (text)
* tags (text[])
* ts (timestamptz — capture time, what the UI groups/sorts by)
* created_at (timestamptz)

`tag_vocab` — survives export. Without this table, autocomplete would reset to empty every time you clean the db out, which defeats the point of tag autocomplete.

* user_id (uuid, fk → auth.users, RLS key)
* tag (text)
* last_used_at (timestamptz)
* primary key (user_id, tag)

Upserted on every save (insert tag if new, bump `last_used_at` if not). Never deleted by the export/cleanup step — only entries are.

Why not fold tags into a JSON blob or reuse entries for the vocabulary: the whole reason `tag_vocab` exists is to outlive `entries`. Keeping it a separate, tiny, insert-mostly table is the simplest way to guarantee that.

Main screens (mostly unchanged from v1)

Capture (default screen)

* Textarea, inline `#tag` detection, tag autocomplete pulled from `tag_vocab`
* Save button — writes straight to Supabase, no local draft state beyond the input itself
* No mood grid. This is the whole point of the overhaul: one input, one action.

Log view

* Grouped by date, same as today
* Filter chips: **tags only** — no mood filter row
* Tap to expand, long-press to delete (unchanged)

Data / export sheet

* Export button → generates the same markdown-with-frontmatter format as v1, minus `mood::` lines
* On successful copy/download: confirmation ("Exported 14 entries — delete them from the database?") → on confirm, deletes exactly those rows by id (not a blanket delete-all, so anything typed during the async clipboard step survives)
* Shows entry count and last-export timestamp, same as today

New: sign-in screen

* Single email input → magic link, identical to touchbase's

Sync model

* No offline queue, no conflict resolution — single-user, one device at a time, same call touchbase made
* On load: fetch this user's `entries` + `tag_vocab` from Supabase
* On save: write straight through to Supabase, update in-memory list, re-render
* If Supabase is unreachable: toast, keep the text in the input untouched so nothing typed is lost, let the user retry

Export/cleanup rule

* Export is the only thing that deletes from `entries`. Nothing else does (long-press delete on a single entry is separate and unchanged).
* Delete happens immediately after a successful export, not on a delay or retention window — Obsidian becomes the source of truth for anything exported, the db is not a backup of it.
* `tag_vocab` is never touched by export/cleanup.

Migration path from v1

1. In the existing touchbase Supabase project: run `capture/supabase/schema.sql` — creates `entries`, `tag_vocab`, RLS policies scoped to `auth.uid()`. No collision with touchbase's `people`/`touch_logs` tables.
2. Add the magic-link sign-in gate (reuse touchbase's sign-in code almost verbatim — same project, same auth).
3. Strip mood entirely: remove the mood grid, mood CSS variables, mood filter chips, `mood` field, `selectMood()`, `moodColor()`/`moodLabel()`, and the `mood::` line in export.
4. Replace `load()`/`saveToDisk()` with Supabase reads/writes; `saveEntry()` writes through immediately and also upserts `tag_vocab`.
5. One-time import: on first sign-in, read any existing `localStorage` entries and tag vocab and push them into Supabase, so existing captures aren't lost. Existing `mood` values on old entries are dropped, not migrated — mood is gone in v2.
6. Rework export to delete-on-confirm as described above.
7. Deploy: unchanged, static file on GitHub Pages.

Build plan

Phase 1 — backend

* Add `entries` + `tag_vocab` tables and RLS policies to the touchbase Supabase project

Phase 2 — strip mood, simplify entry UI

* Remove every mood-related UI element, CSS variable, and data field
* Confirm the capture screen is just: textarea + tag autocomplete + save

Phase 3 — wire Supabase

* Add `supabase-js`, sign-in screen, session persistence
* Swap `load()`/`saveToDisk()` for Supabase queries; write-through save + tag_vocab upsert
* One-time `localStorage` → Supabase import on first login

Phase 4 — export & cleanup

* Markdown export (mood-free), confirm-then-delete flow, `tag_vocab` left untouched

Phase 5 — polish

* Loading/error states for network calls
* Verify export → delete → re-export produces no duplicates and no data loss
* Verify tag autocomplete still works immediately after a full export/cleanup

Phase 6 — deploy

* Same as today: static file, GitHub Pages

Later additions (unchanged from v1 roadmap, still deferred)

* Search entries
* Weekly digest / summary export
* Browser notifications for journaling reminders

Success criteria

* Can I log a thought in under five seconds, from a cold open?
* Do my tags autocomplete correctly even right after I've exported and cleaned the db out?
* Does the exported markdown read clean, with no mood cruft, in Obsidian?
* Does the same entry list show up whether I open the app on my phone or my laptop?
* Does the `entries` table ever hold more than a few days/weeks of unexported scratch — or does it just quietly grow forever?

Notes

Keep the release intentionally small. The only things v2 is allowed to change are: where the data lives, how tags replace mood, and what export does when it finishes. Not the single-file architecture, not the zero-build philosophy, not the two-separate-apps decision.
