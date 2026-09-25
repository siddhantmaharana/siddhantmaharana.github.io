# touchbase

A minimal personal CRM for staying in touch with people you care about. A single-file PWA, synced across your devices via Supabase — no subscriptions, no third party seeing your data beyond the database you own.

See [CHANGELOG.md](CHANGELOG.md) for what changed between versions.

## what it does

- Tracks contacts and how long since you last spoke
- Sorts your list by urgency — most overdue floats to the top
- Two sections: **needs attention** and **all good**
- Log notes after a call or meetup, with a timestamp
- Set a specific next contact date that overrides the default cadence
- **Timeline tab** — every note you've logged, across everyone, newest first and grouped by date, so you can browse without opening each person one at a time
- Person sheet keeps one primary action (log it); edit/delete live behind a small ⋯ menu instead of crowding the main actions
- Any logged note can be edited or deleted after the fact, from either the person sheet or the Timeline
- Export everything as markdown to paste into Obsidian and run AI on top
- Backup and restore via JSON — your data is always yours
- Signs in with a magic link and syncs the same contacts to every device

## stack

Single HTML file, zero build step. Data lives in Supabase (Postgres, guarded by row-level security) instead of `localStorage`, reached from the browser via `supabase-js`. Auth is email magic link.

## deploy

Lives in the `touchbase/` folder of [siddhantmaharana.github.io](https://github.com/siddhantmaharana/siddhantmaharana.github.io). Push `main` there and GitHub Pages serves it — no separate repo or Pages setup.

Live at `https://siddhantmaharana.github.io/touchbase/`

## backend setup (one-time)

1. Create a project at [supabase.com](https://supabase.com) (free tier is enough)
2. SQL Editor → run [supabase/schema.sql](supabase/schema.sql) — creates the `people`/`touch_logs` tables and RLS policies
3. Authentication → URL Configuration → add your deployed URL (and `http://localhost:PORT` if testing locally) to Redirect URLs
4. Project Settings → API → copy the **Project URL** and **anon public key** into the `SUPABASE_URL` / `SUPABASE_ANON_KEY` constants near the top of `index.html`'s script

The anon key is safe to commit — RLS is what actually restricts each signed-in user to their own rows.

## install on mobile

**Android (Pixel)**
Chrome → visit the URL → three-dot menu → Add to Home screen

**iPhone**
Safari → visit the URL → Share → Add to Home Screen

## data format

Data lives in Supabase (`people` and `touch_logs` tables). You can still export a JSON backup anytime from the data sheet (↓ icon) — same shape as before, useful for offline backups or scripting:

```json
{
  "contacts": [
    {
      "id": "1234567890",
      "name": "Rohan Sharma",
      "about": "College friend, Pune",
      "cadence": 30,
      "lastContact": 1748908800000,
      "nextContact": 1751500800000
    }
  ],
  "logs": [
    {
      "id": "1234567891",
      "contactId": "1234567890",
      "note": "Caught up over call. New job next month.",
      "ts": 1748908800000
    }
  ]
}
```

Timestamps are Unix milliseconds — `Date.now()` in JS or `int(time.time() * 1000)` in Python.

## importing existing data

Tap the ↓ icon → data sheet → **import section**

- **merge** — adds contacts and logs not already present. Safe to run multiple times, no duplicates.
- **replace** — wipes everything and restores from file. Asks for confirmation.

## files

```
index.html            the entire app
manifest.json         PWA metadata (name, colors, icons)
icon-192.png          home screen icon
icon-512.png          splash screen icon
supabase/schema.sql   tables + RLS policies for the backend
```

## roadmap ideas

- [ ] Search / filter contacts
- [ ] Tags or groups (family, work, college)
- [ ] Weekly digest email export
- [ ] Reminders via browser notifications

## license

MIT