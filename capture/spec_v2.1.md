Capture — v2.1

A minimal notes PWA. Log what's on your mind, tag it, read it back, edit it, sync it. No purge, no export — the database is the record now, not a mailbox.

Goal

v2 treated the database as an inbox: write fast, occasionally export, then empty it out. In practice that made the app worse at the thing people actually do with notes — go back and read or fix something you wrote. v2.1's goal is to make capture, review, and editing all first-class, on both a phone and a laptop, without adding a build step or a second screen size nobody tested.

What v2.1 changes over v2

* **Entries persist.** Export-then-delete is gone. There is no in-app purge. If you ever want to prune old rows, do it directly in the Supabase SQL editor — a deliberate, occasional DBA action, not a button in the UI that can misfire.
* **Export is gone.** The Obsidian markdown export and its "clear the db?" confirmation sheet are removed entirely. A better export — e.g. a saved SQL view or a scheduled job — is a v2-era idea to revisit later, not an app feature to maintain now.
* **Entries are editable.** `entries` gets an `update` RLS policy. The log screen can now change a note in place, not just delete and recreate it.
* **No more long-press.** Tap an entry to expand it, and `edit` / `delete` are buttons right there — no 600ms hidden gesture standing in for "modify."
* **Mobile Enter key inserts a newline**, like every other text field on the device. Enter-to-save was a desktop affordance that leaked onto touch keyboards and silently posted half-finished thoughts. Detected via `(pointer: coarse)`; desktop keeps Enter-to-save / Shift+Enter-for-newline, since that's a real speed win with a physical keyboard.
* **Desktop gets a real layout.** The single-column, 480px-max, 15px-font design was phone-only CSS shipped unchanged to a 1440px browser window. A `min-width: 720px` breakpoint widens the column, bumps the font and the composer's height ceiling, and gives the textarea room to actually write in.
* **The stale one-time `localStorage` import prompt is gone.** It was v1→v2 migration code that kept re-triggering ("found 24 entries, import them?") on browsers that still had old local data lying around, well after everyone had already migrated. Deleted along with `loadLocal()`/`loadLocalMeta()`.
* **Header gets a refresh button.** Sign-out was the only way to force a resync, which is a much bigger hammer than "pull latest." `↻` calls the same fetch the app does on load; sign-out still exists for actually switching accounts.

Everything else — single HTML file, zero build step, Supabase backend, magic-link auth, inline `#tag` capture — is unchanged.

Non-goals for v2.1

* A real export/archive story (deferred — see "Later additions")
* Rich text, markdown rendering, or attachments — still plain text with inline `#tags`
* Full-text search
* Offline queue / conflict resolution — still single-user, one device at a time
* A build step, framework, or component library

Core user flow

1. Open the app (already signed in, session persists).
2. Type a thought, tag it inline with `#tags`. Enter saves on desktop; tap Save on mobile.
3. It's in Supabase immediately.
4. Open the log, filter by tag, tap an entry to read the full text.
5. Found a typo, or thought of something to add? Tap `edit`, fix it, `save`. Tap `delete` if it shouldn't exist at all.
6. Entries stay there. There's no cleanup step to remember.

Information model

Same two tables as v2 — `entries` and `tag_vocab` — with one addition:

`entries`

* id, user_id, text, tags (text[]), ts, created_at — unchanged
* **new:** `entries_update_own` RLS policy, so a signed-in user can update their own rows (needed for edit)

`tag_vocab` — unchanged. Still upserted on save, still never deleted by the app.

Why keep `tag_vocab` separate now that `entries` isn't purged: autocomplete still wants "every tag I've ever used," and a manual prune of old entries (done directly in SQL, per the non-goal above) shouldn't blow away tag history either. Same reasoning as v2, now doubly true since entries live longer.

Main screens

Capture (default screen)

* Textarea, inline `#tag` detection, tag autocomplete — unchanged
* Save button — unchanged
* Enter-to-save is desktop-only now; mobile textareas behave like every other mobile textarea

Log view

* Grouped by date, filterable by tag — unchanged
* Tap to expand → shows `edit` and `delete` buttons directly, no long-press
* `edit` swaps the entry body for an inline textarea; `save` writes the update through Supabase and re-derives tags from the edited text; `cancel` reverts
* `delete` opens the same confirm sheet v2 used, just triggered by a visible button instead of a hidden gesture
* No export/cleanup footer — the screen ends after the list

Header

* Entry count — unchanged
* **New:** refresh icon (`↻`) — re-fetches entries + tag vocab, same call the app makes on load
* Sign out — unchanged, now secondary to refresh for the "get my latest data" case

Sync model

* Unchanged from v2: no offline queue, no conflict resolution, single user
* On load: fetch entries + tag_vocab
* On save: write straight through, update in-memory list, re-render
* On edit: same pattern — optimistic update, write-through, rollback on error
* **New:** manual refresh button re-runs the load fetch on demand
* If Supabase is unreachable: toast, keep local state untouched, let the user retry (unchanged)

Data lifecycle (replaces v2's "export/cleanup rule")

* `entries` grows without an app-driven ceiling. That's intended — this is now the archive, not an inbox.
* Nothing in the app deletes a row except the user hitting `delete` on that specific entry.
* If the table needs pruning or archiving someday, that's a Supabase SQL editor job — a `DELETE ... WHERE ts < ...`, an export view, a scheduled function. Not app surface area, because a feature used rarely and destructively is exactly the kind of button that gets tapped by accident.

Migration path from v2

1. Run the updated `capture/supabase/schema.sql` (or just the new `entries_update_own` policy statement) in the same Supabase project — additive, no data changes.
2. Deploy the new `index.html` — same static file, GitHub Pages, no other steps.
3. Nothing to migrate in the data itself: every entry that existed under v2 is still there under v2.1, since v2.1 never triggers a delete on its own.
4. Anyone who still had an old browser tab holding pre-migration `localStorage` data: that data is simply no longer read. If it matters, copy it out of dev tools before updating — the import prompt won't offer to bring it in anymore.

Success criteria

* Can I write a thought in under five seconds, from a cold open, on either a phone or a laptop?
* Can I open a note a week later, fix a typo, and have it save without leaving the log screen?
* Does pressing Enter on my phone ever save early instead of adding a line? (Should be no.)
* Does the desktop window feel like a place to write, not a phone screen stretched wide?
* Is deleting or editing an entry discoverable without being told "long-press it"?

Later additions (deferred, unchanged in spirit from v2's roadmap)

* Search entries
* A real export path — most likely a saved SQL view or scheduled job against Supabase directly, not an in-app button that also deletes
* Weekly digest / summary
* Browser notifications for journaling reminders

Notes

Keep this release scoped to what's listed above: data lifecycle (no purge, no export), edit support, and the three UX bugs (mobile Enter, long-press, desktop layout) plus the refresh button and dead migration-code removal. Not a redesign, not a new screen, not a new dependency.
