# siddhantmaharana.github.io

Personal homepage plus my personal apps. Every app is a single `index.html`: no
framework, no npm, no build step. Reading notes and writing live in a separate
digital garden (reading-vault, a Cloudflare Worker behind Cloudflare Access), which the
homepage links to.

## Apps

Each app lives in its own folder and is served at `/<app>/`. See each app's README for details.

| folder | what | data |
|---|---|---|
| [`habits/`](habits/) | habit tracker (Loop Habit Tracker's math) and the journal composer | Supabase |
| [`zentype/`](zentype/) | typing practice on your own text | `localStorage` only |

habits uses a Supabase project with magic-link sign-in. Journal entries written there are pulled into
the Obsidian vault by `_automations/pull_journal.py` (see [habits/spec_v2.md](habits/spec_v2.md)).

capture and touchbase were retired in habits v2; they're in git history (`git checkout 0561449 -- capture/ touchbase/`).

Every page links `shared/theme.css` before its own `<style>`. Change a color there and
it changes everywhere. Use the shared token names (`--surface-2`, `--border-2`, `--muted-2`, …)
instead of hardcoding hex values. An app can override `--accent` to keep its own identity
(zentype does). zentype's desktop app (`main.py`) inlines the sheet, since pywebview loads
the page from a string.

These folders were merged in with `git subtree`, so each app's full history is kept. The
old standalone repos are retired.

## Structure

```
index.html         — the whole homepage
favicon*.png/ico   — browser icons
habits/            — habit tracker (see habits/README.md)
zentype/           — zentype app (see zentype/README.md)
shared/
  theme.css          — colors, fonts, and base reset used by every page
```

## How to update

### Add a project
In the `project-list` div, copy a `project-row` and update the name, description, and link.
Apps in this repo link to their folder (`href="app/"`, same tab); external sites get
`target="_blank" rel="noopener"`. Add the `private` tag for anything that needs my sign-in:
```html
<a class="project-row" href="app/">
  <span class="project-name">name</span>
  <span class="project-desc">one line description</span>
  <span class="project-tag">private</span>
  <span class="row-arrow">↗</span>
</a>
```

## Deploy

Push to `main` — GitHub Pages serves it automatically.
