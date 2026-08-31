# changelog

## v3 — 2026-08-31

- Added a **Timeline** tab — every logged note across all people, newest first, grouped by Today / Yesterday / This week / month, reachable from a new bottom tab bar (People / Timeline)
- Person sheet decluttered: one primary "log it" button; edit and delete moved behind a small ⋯ overflow menu next to close, and the redundant "cancel" button was removed (✕ already dismisses the sheet)
- Recent-notes history inside the person sheet is now grouped by relative date, with a link into the Timeline tab when there's more than 5 entries
- Export/add-person icons in the header now only show on the People tab; sign-out stays available on both

## v2.1
- ability to delete entries

## v2 — 2026-08-03

- Data now synced via Supabase (Postgres + RLS) instead of `localStorage` — same contacts on every device
- Added email magic-link sign-in
- One-time import of any existing local backup into your account on first sign-in
- Fixed: a manually-set "next contact" date could get stuck in the past and permanently override the normal cadence calculation, showing a contact as overdue even after a more recent note was logged

## v1 — 2026-06-29

- Initial release: single-file PWA, add/edit contacts, log notes, cadence-based due tracking, JSON backup/import, markdown export
