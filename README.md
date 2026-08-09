# capture

A minimal thought-capture PWA. Log what's on your mind, tag it, export to Obsidian, keep the database empty. A single-file PWA, synced across your devices via Supabase — the same project [touchbase](https://github.com/siddhantmaharana/touchbase) uses, one account for both apps.

See [spec_v2.md](spec_v2.md) for the full v2 design (why tags replaced mood, why export deletes from the db, why this stays a separate app from touchbase).

## what it does

- Quick capture with inline `#tags` — no mood buttons, tags are the only categorization
- Tag autocomplete pulls from your tag vocabulary, which persists even after you clear the db out
- Log view grouped by date, filterable by tag
- Tap to expand entries, long-press to delete
- Writes straight to Supabase as you capture — no local draft state to lose
- Export to Obsidian — markdown with frontmatter, then a one-tap prompt to clear the exported rows out of the database, since Obsidian is the permanent record, not the db
- Signs in with a magic link and syncs the same entries to every device

## stack

Single HTML file, zero build step. Data lives in Supabase (Postgres, guarded by row-level security) instead of `localStorage`, reached from the browser via `supabase-js`. Auth is email magic link — same Supabase project and account as touchbase, different tables.

## deploy

```bash
git clone https://github.com/siddhantmaharana/capture
cd capture
# enable GitHub Pages: Settings → Pages → main branch → / (root)
```

Live at `https://siddhantmaharana.github.io/capture`

## backend setup (one-time)

Uses the same Supabase project as touchbase — no new project needed if you already have that one running.

1. SQL Editor → run [supabase/schema.sql](supabase/schema.sql) — creates the `entries`/`tag_vocab` tables and RLS policies (no collision with touchbase's `people`/`touch_logs`)
2. Authentication → URL Configuration → add this app's deployed URL (and `http://localhost:PORT` if testing locally) to Redirect URLs
3. `SUPABASE_URL` / `SUPABASE_ANON_KEY` near the top of `index.html`'s script already point at the shared project — no edit needed unless you're pointing this at a different project

The anon key is safe to commit — RLS is what actually restricts each signed-in user to their own rows.

## install on mobile

**Android**
Chrome → visit the URL → three-dot menu → Add to Home Screen

**iPhone**
Safari → visit the URL → Share → Add to Home Screen

## export format

Exports clean markdown with YAML frontmatter for Obsidian, then offers to delete the exported rows from Supabase:

```markdown
---
export_ts: 2026-08-09T09:41:00
export_date: 2026-08-09
entry_count: 24
---

## 2026-08-09

### 09:38
tags:: #idea #product

index entries by energy not topic...
```

The db only ever holds what hasn't been exported yet — export is the only thing that clears it out (long-press delete on a single entry is separate).

## files

```
index.html            the entire app
manifest.json         PWA metadata (name, colors, icons)
icon-192.png          home screen icon
icon-512.png          splash screen icon
supabase/schema.sql   tables + RLS policies for the backend
spec_v2.md            full v2 design doc
```


## sister project

[touchbase](https://github.com/siddhantmaharana/touchbase) — minimal personal CRM, same philosophy, same Supabase project

## license

MIT
