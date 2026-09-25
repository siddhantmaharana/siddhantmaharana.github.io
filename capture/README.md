# capture

A minimal notes PWA. Log what's on your mind, tag it, read it back, edit it. Synced across your devices via Supabase — the same project [touchbase](../touchbase/) uses, one account for both apps.

See [spec_v2.1.md](spec_v2.1.md) for the current design, [CHANGELOG.md](CHANGELOG.md) for what changed and when.

## what it does

- Quick capture with inline `#tags` — no mood buttons, tags are the only categorization
- Tag autocomplete pulls from your tag vocabulary
- Log view grouped by date, filterable by tag
- Tap an entry to expand it — `edit` to change the text in place, `delete` to remove it
- Writes straight to Supabase as you capture — no local draft state to lose
- Entries persist. There's no export-and-purge step; the database is the record
- Responsive: a real desktop layout above 720px wide, not a phone screen stretched out
- Signs in with a magic link and syncs the same entries to every device

## stack

Single HTML file, zero build step. Data lives in Supabase (Postgres, guarded by row-level security) instead of `localStorage`, reached from the browser via `supabase-js`. Auth is email magic link — same Supabase project and account as touchbase, different tables.

## deploy

Lives in the `capture/` folder of [siddhantmaharana.github.io](https://github.com/siddhantmaharana/siddhantmaharana.github.io). Push `main` there and GitHub Pages serves it — no separate repo or Pages setup.

Live at `https://siddhantmaharana.github.io/capture/`

## backend setup (one-time)

Uses the same Supabase project as touchbase — no new project needed if you already have that one running.

1. SQL Editor → run [supabase/schema.sql](supabase/schema.sql) — creates the `entries`/`tag_vocab` tables and RLS policies (no collision with touchbase's `people`/`touch_logs`)
2. Authentication → URL Configuration → add this app's deployed URL (and `http://localhost:PORT` if testing locally) to Redirect URLs
3. `SUPABASE_URL` / `SUPABASE_ANON_KEY` near the top of `index.html`'s script already point at the shared project — no edit needed unless you're pointing this at a different project

The anon key is safe to commit — RLS is what actually restricts each signed-in user to their own rows.

Already running v2? Just run the new `entries_update_own` policy statement in `supabase/schema.sql` — it's additive, no data changes.

## install on mobile

**Android**
Chrome → visit the URL → three-dot menu → Add to Home Screen

**iPhone**
Safari → visit the URL → Share → Add to Home Screen

## data lifecycle

There's no export or purge feature in the app. Entries stay in Supabase until you delete them one at a time from the log view. If you ever want to prune or archive old rows in bulk, do it directly in the Supabase SQL editor — a deliberate, occasional action, not a button that can misfire.

## files

```
index.html            the entire app
manifest.json          PWA metadata (name, colors, icons)
icon-192.png           home screen icon
icon-512.png           splash screen icon
supabase/schema.sql    tables + RLS policies for the backend
spec_v2.1.md           current design doc
spec_v2.md             v2 design doc (superseded, kept for history)
CHANGELOG.md           version history
```

## sister project

[touchbase](../touchbase/) — minimal personal CRM, same philosophy, same Supabase project

## license

MIT
