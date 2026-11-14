# Changelog

Format follows [Keep a Changelog](https://keepachangelog.com/), versioned as `major.minor.patch`. This app has one user and one deploy target, so versions here track meaningful behavior changes, not a public API contract.

## [2.1.0] — 2026-11-14

Habits now looks and works like Loop Habit Tracker on Android.

### Added
- **Groups**: an optional Group on each habit, set from the edit form (it suggests the vault's areas: health-wellness, career, admin, social, hobbies). Home shows ungrouped habits first, then one collapsible section per group with "done/total today". Collapsed sections are remembered per device. Needs `supabase/groups.sql` (adds `habits.group_name`); until it has run, the app behaves as before.
- **Filter menu** on Home: sort by manual order, name or score; hide habits already done today; show archived habits. Remembered per device.
- **Habit page**: an overview row (score, streak, best streak, total); a score chart with 20–100% gridlines, by week, month or quarter; history bars by week, month, quarter or year; one scrollable calendar of every week, opening on today, with an **EDIT** mode where taps toggle days; best streaks as bars; every note.
- **Number popup** for measurable habits: notes, the value and SAVE, with the number keypad.
- The ✎ icon shows a dot when there's an unsaved journal draft.

### Changed
- **Look**: black background, no cards or boxes. Each habit has a score ring; days show as glyphs (✓, ✗, skip, or the number).
- **Home**: 5 days, newest on the left, with more columns on wider screens (up to 14). The title and day labels stay pinned while scrolling.
- **Logging**: tap a yes/no day to toggle ✓ / ✗; long-press (or right-click) for skip and a note. Previously every tap opened a dialog.
- **Journal** moved from the top of Home to its own page behind ✎, with the composer and recent entries.
- **One color for every habit**; groups do the organizing. The color picker and the Color sort are gone. The `color` column is kept in the database and in backups, just unused.
- Edit and Archive/Delete moved into the habit page's ✎ and ⋮ icons. The edit form has SAVE in the top bar.

### Removed
- The 26-week heatmap and the month-by-month calendar (replaced by the scrollable calendar).
- The score/streak/frequency line and score bar under each habit on Home (the ring replaces them).

## [2.0.0] — 2026-11-05

Habits became the one daily app; capture and touchbase were retired into it.

### Added
- **Journal composer**: type or dictate, save. A short first line followed by more text becomes the title. Backdate with the date chip. Drafts save as you type.
- Entries wait in the new `journal_entries` table (`supabase/journal.sql`) until the vault's `_automations/pull_journal.py` adds them to `Journal/YYYY-MM.md` under `## Diary`. Pulled entries show "in vault" and become read-only here (enforced by row-level security).
- A recent-entries list: tap one to edit or delete it until it's pulled.

### Removed
- The capture and touchbase apps. Their data was imported into the vault and their tables dropped. Both apps are in git history at `0561449`.

Full design rationale: [spec_v2.md](spec_v2.md).

## [1.0.0] — 2026-10-11

### Added
- Habit tracker with Loop Habit Tracker's math (`engine.js`): habit score, frequency auto-fill and streaks.
- Yes/no and measurable habits, with frequencies from every day to once a month and at-least/at-most targets.
- Home with each habit's last 7 days, a habit page with a score line, heatmap, month calendar, best streaks and notes.
- Archive, edit and delete habits; JSON backup and CSV export, and backup import.
- Supabase sync with magic-link sign-in.
