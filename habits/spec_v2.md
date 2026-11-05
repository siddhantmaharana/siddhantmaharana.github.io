Habits — v2: one daily app

Write on the phone, think in the vault.

Goal

Three apps (capture, touchbase, habits) gave me about seven places to write and no default, so I barely wrote in any of them, and ended up typing journal notes into habit day-notes because habits is the app I actually open. Meanwhile my Obsidian vault already has the rule I need: "This is about ___ → that note's Log; can't say in five seconds → this month's Journal Diary." And the diary is where I really write (long, often dictated, several thoughts a day).

v2 makes habits the one daily app: **a composer on top, today's habits below.** Every entry goes to this month's Journal Diary. Capture and touchbase retire. Reflection, review and filing happen in the vault, with AI, over everything I've written. The app's only job is to get text into the vault with no friction.

Rules

* Writing takes zero decisions: open, type or dictate, save.
* The vault is the source of truth. The app holds entries only until they're pulled.
* No prompts, cards, lessons, tries, quizzes, scores for writing, or nudges.

Home, top to bottom

1. **Composer.** One autosizing textarea, focused on open, dictation-friendly. A small date chip under it, today by default; tap to backdate ("re-visiting Saturday"). **Save** (Cmd/Ctrl+Enter on desktop).
   * Title rule, matching the vault's quick_log box: if the text has more than one line and the first line is ≤ 80 chars, the first line is the title and the rest is the body. Otherwise the title is blank (`#### @2026-08-02-Sun: ` is a normal entry in my diary) and everything is the body.
   * Inline `#tags` are kept verbatim. No tag UI.
   * The draft autosaves to localStorage on every keystroke and survives closing the app or a failed save.
2. **Today's habits.** The existing home grid, unchanged.
3. **Recent entries.** The last ~10 entries, newest first, one line each (date · title or first words). Tap to edit or delete while the entry is *not yet in the vault*. Pulled entries show a quiet "in vault" mark and are read-only; edit them in Obsidian.

The habit page, day card, import/export and auth stay as they are. Habit day-notes stay for short habit context ("felt good", "knee sore"); they aren't journal entries and aren't pulled.

The name stays "Habits" and the URL stays `/habits/`, so the installed icon and data keep working. Only the manifest `description` changes.

Data

New table, same Supabase project and RLS pattern as `habits`:

```sql
create table journal_entries (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  entry_date  date not null,                 -- the day it's about (backdatable)
  title       text not null default '',
  body        text not null default '',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  pulled_at   timestamptz                    -- set by the vault script; null = still in the app
);
```

RLS: select/insert/delete own rows; update own rows only while `pulled_at is null` (so the app can't edit what the vault already owns). The script sets `pulled_at` with its own key.

Getting entries into the vault: `_automations/pull_journal.py`

Lives in the vault next to `build_vault_index.py`, runs with `python3 -I`, standard library only.

1. Read `SUPABASE_URL` and `SUPABASE_SERVICE_KEY` from `~/.config/pull_journal/env` — **outside the vault**, so Obsidian Sync never copies the key.
2. Fetch rows with `pulled_at is null`, ordered by `entry_date, created_at`.
3. For each row, open the month note `Journal/<YYYY-MM>.md` (vault at `~/Documents/Vault`, found as `Path(__file__).parent.parent` like the other scripts). If it doesn't exist, create it from `_templates/month.md`: fill `created`/`updated`/`year`/`mm` (`mm` unpadded, e.g. `11`) and drop the `tp.file.move` line, so it has the usual `## Diary`, `---`, `## Tasks` (dataviewjs), `---`, `## Review` layout.
4. Insert the entry into the `## Diary` section (which ends at the next `## ` heading), keeping it newest first:

   ```
   #### @2026-11-05-Thu: title
   body

   ```
   * Place it above the first existing `#### @YYYY-MM-DD` heading whose date is earlier than the entry's; same date goes above (it's newer). If none is earlier, place it at the end of the new-style block: before the first `---` or old-style `### YYYY-MM-DD` line in the section, or at the section's end.
   * Old-style `###` entries and everything after `## Diary` (`## Tasks`, `## Review`) are never touched.
   * Weekday comes from the date (`Thu`), not from the device.
5. Bump `updated:` in the frontmatter to today.
6. Write the file, then set `pulled_at` for that row. If the heading and body already appear in the file (a crash between write and mark), skip the write and just mark it, so reruns never duplicate.
7. Print a one-line summary per month: `2026-11: +3 entries`. `--dry-run` prints what would be inserted and writes nothing.

Run by hand to start; a launchd schedule can come once it's trusted.

Retiring capture and touchbase

One-time `_automations/import_legacy.py`, run once, then deleted:

* **capture** `entries` (including replies, lessons, look-backs), not released → diary entries in their own month, title from the first line, tagged `#imported`.
* **touchbase** `touch_logs` → diary entries titled `[[Person name]]`, tagged `#imported` (an unresolved link is fine; it resolves when the people note exists).
* **touchbase** Pop Quiz answers, ask-abouts and details → one section per person appended to `INBOX`, to move into that person's Key info by hand.
* **habits** day-notes that read like journaling (longer than ~140 chars) → diary entries titled with the habit name, tagged `#imported`. Short ones stay as habit notes.

Then:

* The old vault pipeline (capture export → `## Capture` in `Personal/INBOX.md` → `import_capture.py`, plus `map_capture_to_people.py`) is superseded by `pull_journal.py`. Both scripts move to `_automations/_archive/`.
* `capture/` and `touchbase/` are deleted from the repo; git history is the archive (`git checkout <commit> -- capture/` brings either back). Each folder keeps only a tiny `index.html` that redirects to `/habits/`, so icons already installed on the phone don't 404. Remove those too once the icons are gone.
* The homepage lists habits only; the capture and touchbase rows go.
* Supabase tables (`entries`, `tag_vocab`, `tries`, `people`, `touch_logs`, `cards`, `ask_abouts`) stay until `import_legacy.py` has run and the result has been checked in the vault, then get dropped in the SQL editor, deliberately.

Later, not v2

* **Filing with AI**, in the vault: ask Claude to read a month and suggest which entries belong in a hub, project or people Log. Accepted ones get copied under that note's `## Log` (newest first, same heading format), with a link back to the diary. Hub and project templates already have the `## Log` heading this needs.
* Offline queue for saves without network (the draft already survives).
* Scheduled runs of the pull script.
