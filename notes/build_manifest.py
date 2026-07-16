#!/usr/bin/env python3
"""Scan notes/ for .md files and regenerate manifest.json.

Run this after adding or editing a note, before committing:
    python3 notes/build_manifest.py
"""
import json
import re
from pathlib import Path

NOTES_DIR = Path(__file__).parent
FRONTMATTER_RE = re.compile(r"^---\s*\n(.*?\n)---\s*\n?", re.DOTALL)


def parse_frontmatter(text):
    match = FRONTMATTER_RE.match(text)
    if not match:
        return {}, text
    raw, body = match.group(1), text[match.end():]
    meta = {}
    for line in raw.splitlines():
        if not line.strip() or ":" not in line:
            continue
        key, _, value = line.partition(":")
        key, value = key.strip(), value.strip()
        if value.startswith("[") and value.endswith("]"):
            meta[key] = [v.strip().strip('"').strip("'") for v in value[1:-1].split(",") if v.strip()]
        else:
            meta[key] = value.strip('"').strip("'")
    return meta, body


def main():
    entries = []
    skipped_drafts = 0
    for md_path in sorted(NOTES_DIR.rglob("*.md")):
        if md_path.name.lower() == "template.md":
            continue
        text = md_path.read_text(encoding="utf-8")
        meta, body = parse_frontmatter(text)

        if str(meta.get("draft", "false")).strip().lower() == "true":
            skipped_drafts += 1
            continue

        rel_path = md_path.relative_to(NOTES_DIR).as_posix()
        title = meta.get("title") or md_path.stem.replace("-", " ").title()
        summary = meta.get("summary") or " ".join(body.strip().split()[:30])
        topic = meta.get("topic") or (md_path.parent.name if md_path.parent != NOTES_DIR else "uncategorized")
        entries.append({
            "title": title,
            "path": rel_path,
            "topic": topic,
            "tags": meta.get("tags", []),
            "date": meta.get("date", ""),
            "summary": summary,
        })

    entries.sort(key=lambda e: e["date"], reverse=True)
    out = NOTES_DIR / "manifest.json"
    out.write_text(json.dumps(entries, indent=2) + "\n", encoding="utf-8")
    msg = f"Wrote {len(entries)} note(s) to {out}"
    if skipped_drafts:
        msg += f" ({skipped_drafts} draft(s) skipped)"
    print(msg)


if __name__ == "__main__":
    main()
