Personal CRM — v2

A simple personal CRM for staying in touch with friends and family.

Goal

Help me track conversations, remember important context, and know when it is time to reach out again — now synced across devices instead of stuck in one browser's localStorage.

What v2 adds over v1

* Data lives in a real database instead of localStorage, so it's available on every device
* Sign in so the data is actually yours and not readable by anyone with the URL

Everything else — the MVP feature set, the interface, the philosophy — stays the same. This is a storage upgrade, not a rewrite.

MVP (carried over from v1, unchanged)

* Add a person
* Log a conversation or touchpoint
* Set a cadence for the next touch base
* Show who is due soon or overdue
* Keep the interface simple and fast

Non-goals for v2

* Social media integrations
* Email or SMS notifications
* AI summaries
* Shared accounts or team workflows
* Complex task management
* A build step, framework, or component library

Core user flow

1. Sign in with email (magic link).
2. Add a person.
3. Set a cadence.
4. Log a conversation after talking.
5. The app calculates the next touch date.
6. The dashboard surfaces who needs attention.
7. Open the same link on another device, signed in, and see the same data.

Stack

Frontend

* Same single `index.html`, zero build step
* Add the `supabase-js` client via CDN script tag — the only new dependency
* No Next.js, no React, no bundler

Backend

* None. Supabase's auto-generated REST API (PostgREST) is the backend.
* No FastAPI, no separate server to host, monitor, or deploy.

Database

* Supabase Postgres

Auth

* Supabase Auth, email magic link — required in v1 of this rewrite, not deferred
* Row Level Security (RLS) scopes every row to `auth.uid()`, so this doubles as the only access control needed

Why no FastAPI

The original draft of this spec put a FastAPI service between the frontend and Supabase. Its only job would have been to expose `GET/POST /people` and `POST /people/{id}/touch-logs` — which is exactly what PostgREST already generates from the tables, and `next_touch = last_touch + cadence` is simple enough to compute client-side (as the current app already does) or in a Postgres view. Adding FastAPI would mean a second service to deploy and keep running for a single-user app, with no logic it uniquely provides. Cut until something genuinely needs to run server-side (e.g. a future notification digest).

Information model

people

* id (uuid, pk)
* user_id (uuid, fk → auth.users, RLS key)
* name
* about (freeform text — relationship, notes, whatever)
* cadence_days (integer)
* last_contact (timestamptz, nullable)
* next_contact (timestamptz, nullable — manual override, see rule below)
* created_at
* updated_at

touch_logs

* id (uuid, pk)
* person_id (uuid, fk → people)
* user_id (uuid, fk → auth.users, RLS key)
* note (text)
* ts (timestamptz)
* created_at

Kept deliberately close to the current `contacts`/`logs` shape in `index.html` so migration is a straight field mapping, not a redesign.

Reminder / due logic

Derived from `last_contact` + `cadence_days`, same as today — no separate reminders table.

Carry forward the override rule fixed in v1: `next_contact` should only take priority over the cadence calculation while `next_contact > last_contact`. Once a new touch log is created after the planned date, the override is fulfilled and must be cleared — otherwise a stale planned date permanently overrides real activity (this was a live bug in v1, don't reintroduce it in the rewrite).

Main screens (unchanged from v1)

Dashboard

* Needs attention (overdue / due today)
* All good (on track)

Person sheet

* Last contact, cadence
* Log a note, optional next-contact override
* Recent notes history
* Edit / delete

Data sheet

* Export (JSON backup, markdown)
* Import (merge or replace)

New: sign-in screen

* Single email input → magic link
* Nothing else gated behind auth is needed; RLS handles the rest

Sync model

* No offline queue, no conflict resolution for v1 — this is a single-user app used from one device at a time
* On load: fetch people + touch_logs for the signed-in user from Supabase
* On every mutation (add/edit/delete person, log a note): write straight through to Supabase, update local `DB` in memory, re-render
* If Supabase is unreachable, show a toast and don't lose the in-progress edit — keep it in the form until retried

Data rules (unchanged)

* Cadence should default to a simple interval (30 days)
* A log should always update the last touch date
* Due items should be computed consistently
* The system should prefer simplicity over automation

Migration path from v1

1. Create Supabase project, `people` and `touch_logs` tables, RLS policies scoped to `auth.uid()`
2. Add magic-link sign-in gate in front of the existing UI
3. Replace `load()` / `persist()` in `index.html` with Supabase reads/writes
4. One-time import: read existing `localStorage` JSON and push it into Supabase on first sign-in, so nobody loses their existing contacts
5. Keep JSON export/import working against the same shape, so backups still work

Build plan

Phase 1: backend setup

* Create Supabase project
* Define `people` / `touch_logs` tables + RLS policies
* Enable email magic-link auth

Phase 2: wire up the frontend

* Add `supabase-js` via CDN
* Add sign-in screen
* Swap `load()`/`persist()` for Supabase queries
* One-time localStorage → Supabase import on first login

Phase 3: polish

* Loading/error states for network calls
* Confirm export/import still round-trip correctly
* Re-verify the next-contact override rule against real data

Phase 4: deploy

* Same as today: static file, GitHub Pages (or wherever it's hosted now)
* No separate backend deploy — there isn't one

Later additions (unchanged)

* Notification delivery
* Daily digest
* Contact import
* Notes search
* Tags and grouping
* Relationship analytics

If any of these need real server-side logic (e.g. a scheduled digest email), that is the point to introduce a small serverless function — not before.

Success criteria (unchanged)

* Who have I not spoken to in a while?
* What did we last talk about?
* Who should I reach out to next?
* What is the next reminder date?
* (new) Does the same answer show up on my phone and my laptop?

Notes

Keep the release intentionally small. The only thing v2 is allowed to change is where the data lives — not the interface, not the feature set, not the stack complexity.
