# changelog

## v2 — 2026-08-03

- Data now synced via Supabase (Postgres + RLS) instead of `localStorage` — same contacts on every device
- Added email magic-link sign-in
- One-time import of any existing local backup into your account on first sign-in
- Fixed: a manually-set "next contact" date could get stuck in the past and permanently override the normal cadence calculation, showing a contact as overdue even after a more recent note was logged

## v1 — 2026-06-29

- Initial release: single-file PWA, add/edit contacts, log notes, cadence-based due tracking, JSON backup/import, markdown export
