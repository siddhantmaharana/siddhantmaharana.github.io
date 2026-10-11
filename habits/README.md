# habits

A habit tracker. The math (habit score, frequency auto-fill, streaks) is a port of
[Loop Habit Tracker](https://github.com/iSoron/uhabits), so a "3x per week" habit done three
times this week counts as done, and a missed day lowers the score gradually instead of wiping
out a streak.

## what it does

- **Home**: every habit with its score, streak and the last 7 days. Tap a day to open the day
  card: ✓ / ✗ (or a number for measurable habits like miles), skip, and a note.
- **Habit page**: score over the last 180 days, a 26-week heatmap, a month calendar you can page
  back through, best streaks and every note. Any day in the heatmap or calendar opens the day card.
- **Yes/no or measurable** habits, with frequencies from every day to once a month. Measurable habits
  have an at-least/at-most target, and the score compares the total over each window with it
  (e.g. at least 15 miles per 7 days).
- Archive, edit and delete habits. Export a JSON backup or CSV from the ⋯ menu, and import a backup.
- Signs in with a magic link and syncs to every device.

## stack

Single HTML file plus `engine.js` (the math), no build step. Data lives in Supabase (Postgres,
guarded by row-level security), reached from the browser via `supabase-js`. Only what you log is
stored; scores, auto-filled days and streaks are recomputed in the browser on load.

`engine.js` is checked against the Python reference implementation (habitkit's `engine.py`, which
is checked against Loop's own test values) with `scripts/check_js_engine.py` in the habitkit repo.

## backend setup (one-time)

Uses the same Supabase project and Redirect URLs as capture and touchbase.

1. SQL Editor → run [supabase/schema.sql](supabase/schema.sql). It creates the `habits` and
   `habit_entries` tables with RLS policies. (`entries` belongs to capture, hence the prefix.)
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
