# changelog

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
