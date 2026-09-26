# changelog

## v4 — 2026-09-26

Run [supabase/migrate_v4.sql](supabase/migrate_v4.sql) once before deploying this version.

- **Pop Quiz** is the new home screen: 3 fun prompts a day about your people, from a built-in bank of 55 across four decks (favorites, story, people, lately). Saving an answer adds a card to their profile; "no idea, ask them" queues the question for next time; skip swaps the prompt. "Lately" answers go stale after 90 days and get asked again.
- **Worth a hello** replaces "needs attention": at most 3 people, each with a reason (an open question, a birthday within 5 days, or just how long it's been), shown at the top of Pop Quiz and People. Red badges and overdue day counts are gone. "Not now" snoozes someone for 7 days.
- **WhatsApp in one tap** with a suggested opener (their open question, a birthday wish, or a casual hello), plus text and call. Coming back to the app afterwards asks "talked to them? jot it down".
- **Person page** replaces the floating person sheet: full-screen, normal scrolling, and the phone's back gesture returns to the list. Sections: ask about next time, Pop Quiz answers (tap to edit), details, and the full note history. A sticky "+ log a note" opens the composer, which no longer grabs focus and pops the keyboard.
- The composer lets you tick off questions you covered and queue one for next time. Drafts are saved per person, so closing it never loses a note.
- People gain a rhythm (close / regular / occasional) in place of an exact cadence, plus phone and birthday. Existing cadences were mapped to a rhythm by the migration.
- Navigation is two tabs, Pop Quiz and People. Timeline moved one level down (from People, or from a person's notes).
- The People tab is sorted by name, searchable, and shows how many Pop Quiz cards each person has.
- Export and backup include Pop Quiz answers, open questions, phone, birthday and details.
- Fixed: note text was inserted into the page as raw HTML. It's now escaped.
- Fixed: date fields defaulted to tomorrow's date in the evening (they used UTC instead of local time).

## v3.2 — 2026-08-31

- Added the ability to edit or delete an individual logged note — a small ⋯ next to any note (in the person sheet's recent notes, or in Timeline) opens it for editing, with delete alongside
- A contact's "last contact" is now recomputed from what's left whenever a note is edited or deleted, so it can't go stale (the same class of bug the v1 `next_contact` fix addressed)

## v3.1 — 2026-08-31

- Fixed: the bottom tab bar could clip the last item in a long People/Timeline list, making it impossible to scroll to. Root cause was `body { height: 100% }` absorbing its own bottom padding instead of extending the page — changed to `min-height` so the padding actually reserves scroll room, and that room is now measured from the tab bar's real height instead of a guessed pixel value
- On tablet/desktop widths (≥700px), navigation moves from the fixed bottom tab bar into a segmented People/Timeline control in the header — a bottom-pinned bar is a mobile convention and was wasting vertical space and looking out of place on a wide screen
- Page content width now grows to 680px on wider screens instead of staying capped at the 480px mobile column

## v3 — 2026-08-31

- Added a **Timeline** tab — every logged note across all people, newest first, grouped by Today / Yesterday / This week / month, reachable from a new bottom tab bar (People / Timeline)
- Person sheet decluttered: one primary "log it" button; edit and delete moved behind a small ⋯ overflow menu next to close, and the redundant "cancel" button was removed (✕ already dismisses the sheet)
- Recent-notes history inside the person sheet is now grouped by relative date, with a link into the Timeline tab when there's more than 5 entries
- Export/add-person icons in the header now only show on the People tab; sign-out stays available on both
- The log-note sheet now leads with a much bigger note box (the date fields moved into one compact row below it), and on tablet/desktop widths it opens as a centered dialog instead of staying pinned to a phone-width bottom sheet

## v2.1
- ability to delete entries

## v2 — 2026-08-03

- Data now synced via Supabase (Postgres + RLS) instead of `localStorage` — same contacts on every device
- Added email magic-link sign-in
- One-time import of any existing local backup into your account on first sign-in
- Fixed: a manually-set "next contact" date could get stuck in the past and permanently override the normal cadence calculation, showing a contact as overdue even after a more recent note was logged

## v1 — 2026-06-29

- Initial release: single-file PWA, add/edit contacts, log notes, cadence-based due tracking, JSON backup/import, markdown export
