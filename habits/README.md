# habits

A habit tracker. The math (habit score, frequency auto-fill, streaks) is a port of
[Loop Habit Tracker](https://github.com/iSoron/uhabits), so a "3x per week" habit done three
times this week counts as done, and a missed day lowers the score gradually instead of wiping
out a streak.

## what it does

Looks and works like Loop Habit Tracker on Android: black, no boxes, color only where it means something.

- **Home**: each habit with a score ring and the last 5 days, newest on the left (more columns on wider
  screens). The header and day labels stay put while you scroll. **Tap** a yes/no day to toggle ✓ / ✗;
  **long-press** (or right-click) for skip and a note. A measurable day (e.g. miles) opens a small
  number-and-notes popup. The filter icon sorts by manual order, name, color or score, hides habits
  already done today, and shows archived ones; the choice is remembered on that device.
- **Journal** (✎ on Home; a dot means there's an unsaved draft): type or dictate, save. A short first
  line followed by more text becomes the title. Backdate with the date chip. Entries wait in
  `journal_entries` until the vault's `_automations/pull_journal.py` copies them into
  `Journal/YYYY-MM.md`; after that they show "in vault" and are edited in Obsidian. See [spec_v2.md](spec_v2.md).
- **Habit page**: overview (score, streak, best streak, total), score chart with a y axis, history bars
  by week/month/quarter/year, a scrollable calendar of every week (tap a day for its card; **EDIT** makes
  taps toggle), best streaks and every note. Edit, archive and delete from the ✎ and ⋮ icons.
- **Yes/no or measurable** habits, with frequencies from every day to once a month. Measurable habits
  have an at-least/at-most target, and the score compares the total over each window with it
  (e.g. at least 15 miles per 7 days).
- Ten colors from Loop's dark palette; habits saved with the old palette show in the nearest match.
- Export a JSON backup or CSV from the ⋮ menu on Home, and import a backup.
- Signs in with a magic link and syncs to every device.

## stack

Single HTML file plus `engine.js` (the math), no build step. Data lives in Supabase (Postgres,
guarded by row-level security), reached from the browser via `supabase-js`. Only what you log is
stored; scores, auto-filled days and streaks are recomputed in the browser on load.

`engine.js` is checked against the Python reference implementation (habitkit's `engine.py`, which
is checked against Loop's own test values) with `scripts/check_js_engine.py` in the habitkit repo.

## backend setup (one-time)

Uses the Supabase project at `sjycdaxraklxlnrmgqrb.supabase.co`.

1. SQL Editor → run [supabase/schema.sql](supabase/schema.sql). It creates the `habits` and
   `habit_entries` tables with RLS policies. (Prefixed because the retired capture app owned `entries`.)
   Then run [supabase/journal.sql](supabase/journal.sql) for the journal composer's table.
2. `SUPABASE_URL` / `SUPABASE_KEY` near the top of `index.html`'s script hold the project URL and
   publishable key. The key is safe to commit: RLS restricts each signed-in user to their own rows.

## data format

`habit_entries.value` uses Loop's encoding: for yes/no habits `0` no, `2` yes, `3` skip (`1` is an
auto-filled yes and is never stored); for measurable habits the amount ×1000 (9.01 miles → `9010`).

Backups (⋯ → Export backup) are JSON and round-trip through Import:

```json
{
  "format": "habitkit-backup", "version": 1, "exported_at": "2026-10-11",
  "habits": [
    { "uuid": "…", "name": "Run", "type": "numerical", "freq_num": 2, "freq_den": 7,
      "target_type": "at_least", "target_value": 15, "unit": "miles", "color": "#3f8f6b",
      "position": 1, "archived": false,
      "entries": [ { "date": "2026-10-11", "value": 9010, "notes": "felt good" } ] }
  ]
}
```

Importing a backup updates habits with the same `uuid` rather than duplicating them.

## license

GPL-3.0-or-later, because `engine.js` is a port of Loop's GPLv3 code.
