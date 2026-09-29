# capture

A notes PWA that helps me keep becoming. Log what's on your mind, tag it, and let the app bring it back: a few reflection prompts a day, old entries resurfacing so you can see how you've changed, a short list of lessons and small things you're trying, and a light weekly look-back. Synced across your devices via Supabase — the same project [touchbase](../touchbase/) uses, one account for both apps.

See [spec_v3.md](spec_v3.md) for the current design, [CHANGELOG.md](CHANGELOG.md) for what changed and when.

## what it does

- **Today:** quick capture with inline `#tags` (unchanged, still first on screen), a one-line reminder, your active tries, and a hand of 3 cards
- **Reflection cards** from a static prompt bank — at most one "heavy" question per hand
- **Look-back cards:** an entry from a month or more ago comes back; reply, pull out a lesson, or let it go
- **Lessons** (one-liners) and **tries** (max 3 small experiments, with a 14-day check-in)
- **Let it go:** released entries stay in the database but stop resurfacing and leave the log
- **Weekly look-back:** eight journal questions, one per screen, saved as one `#lookback` entry
- **Growth** tab: trying now, lessons, kept, tried, changed my mind, past look-backs
- **Log:** grouped by date, replies and lessons threaded under their source, filter by kind or tag, edit in place
- No streaks, scores or reminders, on purpose

## stack

Single HTML file, zero build step. Data lives in Supabase (Postgres, guarded by row-level security) instead of `localStorage`, reached from the browser via `supabase-js`. Auth is email magic link — same Supabase project and account as touchbase, different tables.

## deploy

Lives in the `capture/` folder of [siddhantmaharana.github.io](https://github.com/siddhantmaharana/siddhantmaharana.github.io). Push `main` there and GitHub Pages serves it — no separate repo or Pages setup.

Live at `https://siddhantmaharana.github.io/capture/`

## backend setup (one-time)

Uses the same Supabase project as touchbase — no new project needed if you already have that one running.

1. SQL Editor → run [supabase/schema.sql](supabase/schema.sql) — creates the `entries`/`tag_vocab`/`tries` tables and RLS policies (no collision with touchbase's tables)
2. Authentication → URL Configuration → add this app's deployed URL (and `http://localhost:PORT` if testing locally) to Redirect URLs
3. `SUPABASE_URL` / `SUPABASE_ANON_KEY` near the top of `index.html`'s script already point at the shared project — no edit needed unless you're pointing this at a different project

The anon key is safe to commit — RLS is what actually restricts each signed-in user to their own rows.

Already running v2.1? Run [supabase/migrate_v3.sql](supabase/migrate_v3.sql) once **before** deploying v3 — it only adds columns and the `tries` table, and is safe to run twice.

## run locally

From the repo root (so `../shared/theme.css` resolves):

```
python3 -m http.server 8765
```

- `http://localhost:8765/capture/?demo` — demo mode: seeded sample data in `localStorage`, never touches Supabase. **reset** in the header reseeds it.
- `http://localhost:8765/capture/` — the real app; needs `http://localhost:8765` in Supabase's Redirect URLs for the magic link.

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
supabase/migrate_v3.sql  one-time v2.1 → v3 migration
spec_v3.md             current design doc
spec_v2.1.md           v2.1 design doc (superseded, kept for history)
spec_v2.md             v2 design doc (superseded, kept for history)
CHANGELOG.md           version history
```

## sister project

[touchbase](../touchbase/) — minimal personal CRM, same philosophy, same Supabase project

## license

MIT
