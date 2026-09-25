# siddhantmaharana.github.io

Personal homepage plus my personal apps. Every app is a single `index.html`: no
framework, no npm, no build step. A `notes/` folder adds a lightweight place to
publish notes from Obsidian.

## Apps

Each app lives in its own folder and is served at `/<app>/`. See each app's README for details.

| folder | what | data |
|---|---|---|
| [`capture/`](capture/) | quick notes with `#tags` | Supabase (shared project) |
| [`touchbase/`](touchbase/) | personal CRM | Supabase (shared project) |
| [`zentype/`](zentype/) | typing practice on your own text | `localStorage` only |

capture and touchbase use the same Supabase project and magic-link account. Both are on
the same origin, so a sign-in in one browser tab carries over to the other.
Installed home-screen PWAs (iOS in particular) each get their own storage and still sign in separately.

These folders were merged in with `git subtree`, so each app's full history is kept. The
old standalone repos (`capture`, `touchbase`, `zentype`) are retired.

## Structure

```
index.html         — the whole homepage
favicon*.png/ico   — browser icons
capture/           — capture app (see capture/README.md)
touchbase/         — touchbase app (see touchbase/README.md)
zentype/           — zentype app (see zentype/README.md)
notes/
  build_manifest.py  — regenerates manifest.json from the .md files (run before pushing)
  manifest.json       — generated list of published notes (topic, tags, date) — don't hand-edit
  template.md          — copy this to start a new note
  index.html           — browses all notes, grouped by topic
  note.html             — renders a single note (fetches ?path=...)
  <topic>/<slug>.md      — the actual notes, one file per note
```

## How to update

### Add a project
In the `panel-projects` div, copy a `project-row` and update the name, description, and GitHub link:
```html
<a class="project-row" href="https://github.com/siddhantmaharana/REPO" target="_blank" rel="noopener">
  <span class="project-name">name</span>
  <span class="project-desc">one line description</span>
  <span class="row-arrow">↗</span>
</a>
```

### Add a writing entry (external link)
For links to things published elsewhere (Medium, Substack, etc.), add a row directly
in the `panel-writing` div of `index.html`:
```html
<a class="writing-row" href="URL" target="_blank" rel="noopener">
  <span class="writing-title">Article Title</span>
  <span class="writing-meta">Jun 2026</span>
  <span class="row-arrow">↗</span>
</a>
```
The homepage's "Writing" tab otherwise auto-populates from `notes/manifest.json` — see below.

## Publishing a note (from Obsidian)

1. Copy the note's markdown into `notes/<topic>/<slug>.md`. The folder is just for your
   own organization — the site groups notes by the `topic` field, not the folder.
2. Add frontmatter at the top (copy `notes/template.md`):
   ```yaml
   ---
   title: Note Title
   topic: ai
   tags: [tag-one, tag-two]
   date: 2026-07-16
   draft: false
   ---
   ```
3. Link to other notes anywhere in the body with `[[Other Note Title]]` or
   `[[Other Note Title|custom text]]` — same syntax Obsidian uses, so most existing
   links just work. A link to a note that doesn't exist (yet) renders with a dashed
   underline instead of breaking, so you can spot it later.
4. Keep `topic` values consistent (e.g. always `ai`, not sometimes `AI` or
   `artificial-intelligence`) — that's what clusters related notes together.
5. Set `draft: true` to keep a note out of `notes/index.html` and the homepage's
   Writing tab while you're still working on it. Flip it to `false` (or remove the
   line) to publish. Note: this only hides it from listings — the raw file is still
   in the repo, so don't use `draft` for anything actually private.
6. Regenerate the manifest and push:
   ```bash
   python3 notes/build_manifest.py
   git add notes/ && git commit -m "Add note: <title>" && git push
   ```

## Deploy

Push to `main` — GitHub Pages serves it automatically.
