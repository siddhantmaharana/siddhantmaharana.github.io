# touchbase

A minimal personal CRM for staying in touch with people you care about. Built as a standalone PWA — no backend, no accounts, no subscriptions. Just a file you host and own.

## what it does

- Tracks contacts and how long since you last spoke
- Sorts your list by urgency — most overdue floats to the top
- Two sections: **needs attention** and **all good**
- Log notes after a call or meetup, with a timestamp
- Set a specific next contact date that overrides the default cadence
- Export everything as markdown to paste into Obsidian and run AI on top
- Backup and restore via JSON — your data is always yours

## stack

Single HTML file. Zero dependencies. Zero network requests. Data lives in `localStorage`.

## deploy

```bash
git clone https://github.com/yourusername/touchbase
cd touchbase
# enable GitHub Pages: Settings → Pages → main branch → / (root)
```

Live at `https://yourusername.github.io/touchbase`

## install on mobile

**Android (Pixel)**
Chrome → visit the URL → three-dot menu → Add to Home screen

**iPhone**
Safari → visit the URL → Share → Add to Home Screen

## data format

All data is stored locally as JSON. You can export a backup anytime from the data sheet (↓ icon). The format is straightforward if you want to pre-populate from a spreadsheet or script:

```json
{
  "contacts": [
    {
      "id": "1234567890",
      "name": "Rohan Sharma",
      "about": "College friend, Pune",
      "cadence": 30,
      "lastContact": 1748908800000,
      "nextContact": 1751500800000
    }
  ],
  "logs": [
    {
      "id": "1234567891",
      "contactId": "1234567890",
      "note": "Caught up over call. New job next month.",
      "ts": 1748908800000
    }
  ]
}
```

Timestamps are Unix milliseconds — `Date.now()` in JS or `int(time.time() * 1000)` in Python.

## importing existing data

Tap the ↓ icon → data sheet → **import section**

- **merge** — adds contacts and logs not already present. Safe to run multiple times, no duplicates.
- **replace** — wipes everything and restores from file. Asks for confirmation.

## files

```
index.html      the entire app
manifest.json   PWA metadata (name, colors, icons)
icon-192.png    home screen icon
icon-512.png    splash screen icon
```

## roadmap ideas

- [ ] Search / filter contacts
- [ ] Tags or groups (family, work, college)
- [ ] Weekly digest email export
- [ ] Reminders via browser notifications

## license

MIT