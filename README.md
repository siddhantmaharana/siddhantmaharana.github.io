# siddhantmaharana.github.io

Personal homepage. Single `index.html`, no build step, no dependencies.

## Structure

```
index.html        — the whole site
favicon*.png/ico  — browser icons
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

### Add a writing entry
In the `panel-writing` div, replace the empty state with a `writing-list` and add rows:
```html
<div class="writing-list">
  <a class="writing-row" href="URL" target="_blank" rel="noopener">
    <span class="writing-title">Article Title</span>
    <span class="writing-meta">Jun 2026</span>
    <span class="row-arrow">↗</span>
  </a>
</div>
```
Works for internal posts or external links (Medium, Substack, etc.).

## Deploy

Push to `main` — GitHub Pages serves it automatically.
