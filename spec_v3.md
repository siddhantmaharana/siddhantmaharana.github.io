Personal CRM — v3

A simple personal CRM for staying in touch with friends and family.

Goal

v1 and v2 nailed the data model and sync. v3 is a readability and interaction pass: the single people-list screen is fine for triage, but there's no good way to browse everything you've logged over time, and the person sheet has grown a button for every action (✕ close, edit, cancel, log it, plus delete once editing) — too many low-frequency actions competing with the one you actually use every time (log it).

What v3 adds over v2

* A second screen — **Timeline** — a reverse-chronological feed of every note logged across all people, groupable/scannable by date, with a way to jump back to the person it belongs to
* Bottom tab bar to switch between **People** (the existing dashboard) and **Timeline**
* Person sheet decluttered to one primary action (log it) plus a small ⋯ overflow menu for edit/delete; the redundant "cancel" button is removed since ✕ already closes the sheet
* Log history inside the person sheet grouped by relative date (Today / Yesterday / This week / Older) instead of a flat list, for faster scanning

Everything else — the data model, sync model, auth, export/import — stays the same. This is an interaction-design pass, not a rewrite.

Non-goals for v3

* Social media integrations
* Email or SMS notifications
* AI summaries
* Shared accounts or team workflows
* Complex task management
* A build step, framework, or component library
* Search across notes (Timeline is browse-only in v3; search is a later addition once browsing itself is validated)
* Editing or deleting a single log entry from Timeline (still only add-a-log from the person sheet; log entries stay append-only for now)

Why a Timeline tab instead of a separate page/URL

The app is intentionally one static file with no router, no build step, and a single PWA `start_url`. A second `.html` file would mean duplicating the auth gate, the Supabase client, the header, and `DB` state, and keeping two copies in sync by hand — exactly the complexity v2's "no framework" non-goal was written to avoid. A client-side view switch inside the same `app-root` (toggle which `<main>` is visible, no new network calls beyond what's already fetched into `DB`) gets the "browse everything" feature with zero new architecture.

Screens

People (unchanged dashboard, now one of two tabs)

* Needs attention / all good sections, same as v2
* Tapping a row opens the person sheet

Timeline (new)

* Every `touch_logs` row across all people, newest first, grouped under date headers: **Today**, **Yesterday**, **This week**, then by month
* Each row: avatar + name (tap → opens that person's sheet, scrolled/focused on history), the note text, relative timestamp
* Empty state: "no notes logged yet" (mirrors the People empty state tone)
* No filter/search UI in v3 — pure scroll; the list is naturally short for a personal-scale contact book (roadmap item if it ever gets long)

Bottom tab bar

* Two tabs: People / Timeline, icons + label, same dark/mono aesthetic as the rest of the UI
* Persistent across both screens, hidden while a sheet is open (sheets already cover the viewport)
* Replaces nothing in the header — export and add-person icons stay where they are, scoped to the People tab since they're both People-specific actions

Person sheet (reworked)

* Header: name + meta on the left, ⋯ overflow and ✕ close on the right
* ⋯ opens a small menu: **edit**, **delete** (delete asks for confirmation same as today)
* Body unchanged: when/date, note textarea, next-contact override
* One action button: **log it** (primary, full-width or right-aligned — no more "cancel" button; ✕ is the only way to dismiss without logging)
* History section grouped by relative date bucket instead of a flat "recent notes" list; still capped (last 5) with the rest visible via the new Timeline tab — this is what makes cutting the cap from the person sheet safe

Add/edit contact sheet

* Unchanged in v3, just now opened via the ⋯ menu instead of a full "edit" button in the person sheet

Data model

No changes. Timeline reads the same `DB.logs` + `DB.contacts` already fetched into memory; nothing new to query or store.

Interaction rules carried forward (unchanged)

* Cadence defaults to 30 days
* A log always updates last-contact
* `next_contact` only overrides cadence while `next_contact > last_contact` (the v1 bug fix, still load-bearing)
* Prefer simplicity over automation

Build plan

Phase 1: navigation shell

* Add bottom tab bar to `app-root`, two tabs, client-side show/hide of two `<main>` containers (`#people-main` existing, new `#timeline-main`)
* Hide tab bar while any `.overlay` sheet is open

Phase 2: Timeline screen

* Build `renderTimeline()`: flatten `DB.logs`, join to contact name/avatar, sort desc by `ts`, bucket by relative date, render grouped HTML
* Tapping a row opens the existing person sheet for that contact

Phase 3: person sheet declutter

* Replace edit button + cancel button with a ⋯ trigger and a small dropdown/menu (edit, delete)
* Wire delete confirmation through the same `deleteContact()` path, now reachable from the person sheet directly instead of only from inside the edit sheet
* Group `renderHistory()` output by relative date bucket

Phase 4: polish + ship

* Re-test full flow: add person → log note → see it in Timeline → edit via ⋯ → delete via ⋯
* Update README, CHANGELOG, bump manifest version if applicable
* Commit and tag as v3

Success criteria

* Carried over from v2: who have I not spoken to, what did we last talk about, who's next, does it sync across devices
* (new) Can I scroll back through everything I've logged, across everyone, without opening each person one at a time?
* (new) Does the person sheet show exactly one obvious thing to do (log it), with the occasional actions (edit/delete) out of the way but still reachable in one tap?

Notes

Keep this release scoped to navigation and information architecture. No new data, no new backend calls, no new non-goals violated — same philosophy as v2's "storage upgrade, not a rewrite," just applied to the UI this time.
