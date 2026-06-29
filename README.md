# capture

A minimal thought-capture PWA. Log what's on your mind, tag it, track your mood, export to Obsidian. No backend, no accounts, no subscriptions — just a file you own.

## what it does

- Quick capture with inline `#tags`
- Mood logging across 4 states — fired up, stressed, calm, drained — based on the [circumplex model of affect](https://en.wikipedia.org/wiki/Emotion_classification#Circumplex_model)
- Tag autocomplete pulls from your existing vocabulary as you type
- Log view grouped by date, filterable by mood or tag
- Tap to expand entries, long-press to delete
- Export to Obsidian — markdown with frontmatter, dedup-safe via `last_id`

## stack

Single HTML file. Zero dependencies. Zero network requests. Data lives in `localStorage`.

## deploy

```bash
git clone https://github.com/siddhantmaharana/capture
cd capture
# enable GitHub Pages: Settings → Pages → main branch → / (root)
```

Live at `https://siddhantmaharana.github.io/capture`

## install on mobile

**Android**
Chrome → visit the URL → three-dot menu → Add to Home Screen

**iPhone**
Safari → visit the URL → Share → Add to Home Screen

## export format

Exports clean markdown with YAML frontmatter for Obsidian:

```markdown
---
export_ts: 2026-06-29T09:41:00
export_date: 2026-06-29
entry_count: 24
last_id: 1751190060000
---

## 2026-06-29

### 09:38
mood:: calm
tags:: #idea #product

index entries by energy not topic...
```

Use `last_id` to avoid re-importing entries you've already processed. The footer includes a ready-to-use Dataview query for Obsidian.

## mood model

Four states derived from the valence × arousal axes of Russell's circumplex model:

| state | energy | valence |
|-------|--------|---------|
| fired up | high | positive |
| stressed | high | negative |
| calm | low | positive |
| drained | low | negative |

Mood appears as a colored left-border on every log entry and as an inline `mood::` field in exports — queryable with Dataview.

## files

```
index.html    the entire app
README.md     this file
```

## roadmap

- [ ] PWA manifest + icons
- [ ] Search entries
- [ ] JSON backup / restore
- [ ] Weekly mood summary export
- [ ] Browser notifications for journaling reminders

## sister project

[touchbase](https://github.com/siddhantmaharana/touchbase) — minimal personal CRM, same philosophy

## license

MIT