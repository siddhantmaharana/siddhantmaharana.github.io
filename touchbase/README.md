# touchbase

A minimal personal CRM for staying in touch with people you care about. A single-file PWA, synced across your devices via Supabase — no subscriptions, no third party seeing your data beyond the database you own.

See [CHANGELOG.md](CHANGELOG.md) for what changed between versions.

## what it does

- **Pop Quiz** (home): deals 3 fun prompts a day about your people ("What's Priya's go-to coffee order?"). Answers become cards on their profile; "no idea, ask them" queues the question for your next chat.
- **Worth a hello**: at most 3 people it'd be nice to reach out to, with a reason (an open question, an upcoming birthday). No overdue counts, no red. "Not now" snoozes someone for 7 days.
- **One-tap WhatsApp** with a suggested opener (plus text and call). Come back to the app and it asks whether you talked, so logging is one tap too.
- **Person page**: ask-about-next-time checklist, Pop Quiz answers, free-form details, and every note, with a sticky "+ log a note". The phone's back gesture works.
- Notes can be backdated, edited or deleted. Drafts are kept per person, so closing the composer never loses one.
- **Timeline** of every note across everyone, one level down from People.
- Export everything as markdown to paste into Obsidian and run AI on top; backup and restore via JSON.
- Signs in with a magic link and syncs the same data to every device.

## stack

Single HTML file, zero build step. Data lives in Supabase (Postgres, guarded by row-level security) instead of `localStorage`, reached from the browser via `supabase-js`. Auth is email magic link.

## deploy

Lives in the `touchbase/` folder of [siddhantmaharana.github.io](https://github.com/siddhantmaharana/siddhantmaharana.github.io). Push `main` there and GitHub Pages serves it — no separate repo or Pages setup.

Live at `https://siddhantmaharana.github.io/touchbase/`

## backend setup (one-time)

1. Create a project at [supabase.com](https://supabase.com) (free tier is enough)
2. SQL Editor → run [supabase/schema.sql](supabase/schema.sql) — creates the `people`, `touch_logs`, `cards` and `ask_abouts` tables and RLS policies. Upgrading an existing v2/v3 project? Run [supabase/migrate_v4.sql](supabase/migrate_v4.sql) instead, before deploying v4.
3. Authentication → URL Configuration → add your deployed URL (and `http://localhost:PORT` if testing locally) to Redirect URLs
4. Project Settings → API → copy the **Project URL** and **anon public key** into the `SUPABASE_URL` / `SUPABASE_ANON_KEY` constants near the top of `index.html`'s script

The anon key is safe to commit — RLS is what actually restricts each signed-in user to their own rows.

## install on mobile

**Android (Pixel)**
Chrome → visit the URL → three-dot menu → Add to Home screen

**iPhone**
Safari → visit the URL → Share → Add to Home Screen

## data format

Data lives in Supabase (`people`, `touch_logs`, `cards` and `ask_abouts` tables). You can export a JSON backup anytime from the data sheet (↓ icon), useful for offline backups or scripting. v4 backups add `rhythm`, `phone`, `birthday` and `details` to each contact, plus `cards` and `asks` arrays; older backups without them still import:

```json
{
  "contacts": [
    {
      "id": "1234567890",
      "name": "Rohan Sharma",
      "about": "College friend, Pune",
      "rhythm": "regular",
      "phone": "14155550123",
      "birthday": "03-14",
      "details": "Partner: Jordan",
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
  ],
  "cards": [
    { "contactId": "1234567890", "promptId": "coffee", "deck": "favorites",
      "question": "What's Rohan's go-to coffee order?", "answer": "Masala chai", "ts": 1748908800000 }
  ],
  "asks": [
    { "contactId": "1234567890", "promptId": null, "text": "how did the new job start?", "doneAt": null, "ts": 1748908800000 }
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
supabase/schema.sql   tables + RLS policies for a fresh backend
supabase/migrate_v4.sql  one-time upgrade of a v2/v3 backend to v4
spec_v4.md            design spec for the current version
```

## roadmap ideas

- [ ] AI-generated Pop Quiz prompts from a person's notes and answers (needs a server-side call; see spec_v4.md)
- [ ] Tags or groups (family, work, college)

## license

MIT