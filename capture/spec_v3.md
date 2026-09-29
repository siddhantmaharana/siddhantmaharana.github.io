Capture — v3

A notes app that helps me keep becoming.

Goal

v1–v2.1 made capture work: fast input, tags, sync, edit. It's a good inbox and a bad mirror. Right now:

* I write a thought, and it sinks. Nothing ever brings it back, so the archive is write-only.
* There's no reason to open the app unless something is already on my mind.
* It holds what I noticed, but never what I learned from it, or what I decided to do differently.

v3 turns capture from a place I drop thoughts into a small, kind **growth loop**:

> Observe → Reflect → Learn → Adjust → Forgive → Continue

Capturing stays exactly as fast as it is today. Around it, the app now deals a few reflection prompts, brings old entries back so I can see how I've changed, keeps short lists of lessons and small experiments, and runs a light weekly look-back.

It follows the rules I wrote for myself: improve, don't perfect. Keep the improvement button on and the self-criticism button off. My past self is evidence of growth, not evidence against me. Anything in the app that feels like a scorecard, a streak, or a guilt trip is a bug.

Challenges (from actually using v2.1)

1. **Entries sink.** The log is a reverse-chronological pile. I almost never scroll back more than a few days, so old thoughts do no work.
2. **No reason to open it.** Touchbase had the same problem before Pop Quiz: the app only helps if I already arrive with something to say.
3. **Noticing isn't learning.** A note like "snapped at A. again in the planning meeting" just sits there. There's nowhere to turn it into a lesson, or into something I'll try next time.
4. **No rhythm.** I want to do a regular look-back (what did I notice, where was I wrong, what am I proud of), but a blank textarea doesn't ask me anything.
5. **Old entries can sting.** When I do scroll back and find something I'd now cringe at, the app has no way to say "that was then". It's just a record, and records invite judgment.

What v3 changes over v2.1

* **Today, a new home:** the composer stays on top, unchanged. Below it: a one-line reminder, what I'm trying right now, and a hand of 3 reflection cards.
* **Reflection cards:** gentle prompts from a bank built on my growth questions. Answers are saved as entries.
* **Look-back cards:** an old entry comes back ("you, 7 months ago") with a question about what's changed. I can reply, pull out a lesson, or let it go.
* **Lessons and tries:** a lesson is a one-line takeaway. A try is one small thing I'm doing differently, at most 3 at a time, with a gentle check-in.
* **Let it go:** any entry can be released. It stays in the database (the record is still the record), but it stops resurfacing and leaves the default log.
* **Sunday look-back:** once a week, the journal-loop questions, one at a time, with that week's entries alongside for reference.
* **A Growth page:** lessons, tries I kept, and times I changed my mind. The evidence that I'm evolving, in one place.
* **Three tabs:** Today, Log, Growth.

Unchanged: fast capture with inline `#tags`, tag autocomplete, edit in place, sync, magic-link auth, the Supabase project shared with touchbase, and the single-file no-build approach.

Ideas

1. Today: capture first, then a hand of cards (fixes challenges 2 and 4)

Top to bottom:

1. **Composer.** Exactly as in v2.1. It's still the first thing on screen, and capturing must still take under five seconds from a cold open.
2. **The reminder.** One small italic line, rotating daily from my philosophy notes:
   * "Improve, don't perfect."
   * "Future-me will probably cringe at current-me too. That's okay."
   * "Don't confuse being knowledgeable with being wise."
   * "Don't take yourself too seriously."
   * "Be ambitious about becoming better, humble about how much I know, honest about my mistakes, and forgiving about the person who made them."
3. **Trying.** My active tries (idea 3), max 3, as small chips. A try that's due for a check-in shows a soft dot, not a badge.
4. **Today's hand.** 3 cards: normally 2 reflection cards and 1 look-back card (idea 2). If there's nothing old enough to look back on yet, it's 3 reflection cards.
5. **After the third card:** "that's plenty. go live a little." with **deal again** for more. Nothing pushes me to. No streaks, no counts, no "you haven't reflected in 4 days".

A reflection card:

> **notice**
> **What's one thing that went better than expected this week?**
> [ type an answer… ]
> **save** · **→ lesson** · **skip**

* **save** stores the answer as an entry, with the question attached so it reads well in the log later.
* **→ lesson** saves the answer and opens a one-line field: "so the lesson is…". This is optional; most answers are just answers.
* **skip** swaps in a different prompt. No penalty.
* Inline `#tags` work in answers too, same as the composer.

The prompt bank for v3 is static: about 50 prompts in seven decks, taken from my growth questions. The decks are split into light and heavy on purpose.

* **light decks**
  * **notice**: What did you notice today? · What surprised you this week? · What went better than expected? · What are you learning about yourself lately?
  * **proud**: What are you proud of this week? · What would {future_age}-year-old you thank you for this week? · What meaningful risk did you take, even a small one?
  * **curious**: Who sees something differently from you, and what might they know? · What did you change your mind about recently? · What are you curious about right now?
  * **let go**: What should you simply let go of? · What would you tell a friend who did the same thing? · What deserves forgiveness, from you or for you?
* **heavy decks**
  * **wrong**: What might you be wrong about right now? · What did you believe strongly five years ago that looks naive now? · Where are you confusing knowing a lot with being right?
  * **patterns**: What pattern keeps repeating? · Where did you react this week instead of choosing? · What are you avoiding?
  * **ego**: Where did ego show up this week? · Where were you acting for validation? · Was a recent choice about your values, or your impulses?

Dealing rules:

* **At most one heavy card per hand.** This is the "improvement on, self-criticism off" rule turned into code.
* No prompt repeats within 14 days.
* A hand never has two cards from the same deck.
* `{future_age}` is my age plus ten, from a `BIRTH_YEAR` constant in the page, so the 36 → 46 prompt stays true next year without an edit.

2. Look-back cards: the archive comes back as evidence of growth (fixes challenges 1 and 5)

One card per hand shows an old entry:

> **you, 7 months ago** · Feb 12
> "snapped at A. again in the planning meeting. felt justified at the time. #work"
> **What's changed since then?**
> [ reply… ]
> **reply** · **→ lesson** · **let it go** · **skip**

* **reply** saves my answer as a new entry linked to the old one. In the log, the old entry then shows a small "later:" thread underneath it, so the two versions of me sit side by side.
* **→ lesson** writes a one-line lesson linked to the entry.
* **let it go** releases the entry (idea 4). The confirmation is kind: "released. you were doing your best with what you had."
* **skip** puts it back in the pool.

Choosing which entry comes back:

* Only entries at least 30 days old, never released, and not resurfaced in the last 90 days.
* Prefer "anniversaries": entries from about 1, 3, 6 or 12 months ago, give or take a week. Otherwise pick at random, favoring older entries.
* Skip entries shorter than about 20 characters. "#groceries eggs" doesn't need reflecting on.
* An entry can come back more than once over the years. Each reply adds to its thread.

The questions on look-back cards follow the "learning from the past" steps I wrote, and never ask "why did you do that?":

* What's changed since then?
* What would you say to the person who wrote this?
* What do you understand now that you didn't then?
* Is this still true?

The point is the healthy path (past behavior → reflection → lesson → changed behavior → move on), not the other one (past behavior → shame → rumination → self-judgment).

3. Lessons and tries: noticing becomes learning becomes adjusting (fixes challenge 3)

**Lessons** are one-liners: "I get short with people when I'm hungry and behind." They can come from:

* **→ lesson** on a reflection or look-back card
* **→ lesson** on any expanded entry in the log (next to edit and delete)
* **+ lesson** on the Growth page, written from scratch

A lesson keeps a link to the entry it came from, when there is one.

**Tries** are the Adjust step. A try is one small, specific thing I'm doing differently: "pause for one breath before replying in a disagreement."

* Made from a lesson (**try something →**), from the "one thing to do differently" step of the Sunday look-back, or with **+ try** on the Growth page.
* **At most 3 active at once.** Adding a fourth asks which one to finish first. Small upgrades, not a self-improvement program.
* Each try has an optional **area**, from the list of small upgrades I care about: communication, relationships, judgment, emotional regulation, health, time, values, changing my mind.
* **Check-in after 14 days**, shown as a soft dot on its chip on Today. Tapping it asks "how's it going?" with three answers, none of them a failure:
  * **it stuck** (it moves to "kept" on the Growth page)
  * **still trying** (check in again in 14 days)
  * **letting it go** (it moves to "tried" on the Growth page, with an optional note on what I learned)
* There are no daily checkboxes and no tracking of hits and misses. A try is an intention, not a habit tracker.

4. Let it go: forgiveness as a feature (fixes challenge 5)

* Any entry can be **released**, from a look-back card or from its expanded view in the log.
* Released entries **stay in the database.** v2.1 decided the database is the record, and that still holds. Releasing is not deleting.
* A released entry never resurfaces, and it's hidden from the log by default. A **"show released"** toggle at the bottom of the log brings them back, dimmed.
* It can be undone: an expanded released entry shows **un-release**.
* **delete** still exists for things that shouldn't be in the record at all. Release is for things that happened and are done.

5. Sunday look-back: the journal loop, one question at a time (fixes challenge 4)

* From Saturday through Monday, if I haven't done one this week, a card on Today says: "12 notes this week. look back?" It isn't a notification, and it disappears after Monday with no guilt.
* It opens a full page. At the top, the week's entries sit in a collapsed list I can open for reference.
* It walks through the journal-loop questions, one per screen, each skippable:
  1. What did I notice?
  2. What did I learn?
  3. Where was I wrong?
  4. What am I proud of?
  5. Where did ego show up?
  6. What deserves forgiveness?
  7. What's one thing I want to do differently? (**make it a try →**)
  8. What should I simply let go of?
* On finish, all the answers are saved as **one entry**, formatted as Q&A, tagged `#lookback`, and dated that week. Skipped questions are left out. The page closes with the one-line reminder, in full.
* It also works any day, from **look back on this week →** at the bottom of Today.

6. Growth page: the evidence, in one place

This is the payoff tab, and it should feel like a record of someone trying, not a report card.

* **Trying now:** active tries, each with its area and how long I've been at it ("since Sep 3").
* **Lessons:** newest first, each linking to its source entry. Filterable by area.
* **Kept:** tries that stuck, with the month they started.
* **Tried:** tries I let go of, with their notes. These count as learning, not failure, and the copy says so.
* **Changed my mind:** every look-back reply to an entry older than 6 months, shown as "then → now" pairs. This is the section most likely to make me cringe and laugh, which is the point.
* **Look-backs:** past Sunday look-backs, one line each, tap to open.

No charts, totals, or "growth score".

7. Navigation and feel

**Three tabs:**

| tab | what |
|---|---|
| **Today** (home, default) | composer, reminder, trying chips, today's hand, Sunday look-back card when it's that time |
| **Log** | the v2.1 log, plus reply threads under old entries, **→ lesson** and **let go** on expanded entries, a "show released" toggle, and filters for reflections and look-backs next to the tag filters |
| **Growth** | idea 6 |

The Sunday look-back and the "which try should I finish?" chooser are full pages with their own history entries (`#lookback`, `#tries`), so the phone's back gesture works. This is the same show/hide approach touchbase v4 uses for the person page.

**Feel:**

* **Personality in the copy.** Dry, warm, and never preachy. The app quotes my own principles back to me and doesn't add new ones.
  * empty log: "nothing yet. that's allowed."
  * finished hand: "that's plenty. go live a little."
  * first look-back card ever: "this is you, a month ago. be nice to them."
* **Motion:** the same card deal and flip as touchbase's Pop Quiz, and a soft fade when an entry is released. All of it is off under `prefers-reduced-motion`.
* **Color:** shared `../shared/theme.css` tokens and the shared purple accent. Heavy-deck cards get no scarier color than light ones. Red is only for delete.
* **Desktop:** at 720px and up, Today becomes two columns: the composer and trying on the left, the hand on the right.

Data model

Everything is additive. v2.1 clients keep working until they refresh.

```sql
alter table entries
  add column if not exists kind text not null default 'note'
    check (kind in ('note','reflection','reply','lesson','lookback')),
  add column if not exists prompt_id text,          -- id from the static bank, for reflections
  add column if not exists question text,           -- stored as asked, so bank edits don't rewrite history
  add column if not exists parent_id uuid references entries(id) on delete set null,
                                                    -- replies and lessons point at their source entry
  add column if not exists area text,               -- lessons only, optional
  add column if not exists released_at timestamptz, -- "let it go"; null means active
  add column if not exists resurfaced_at timestamptz; -- last shown on a look-back card

create table if not exists tries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  text text not null,
  area text,
  lesson_id uuid references entries(id) on delete set null,
  status text not null default 'active' check (status in ('active','kept','dropped')),
  checkin_at timestamptz not null default now() + interval '14 days',
  note text,                                        -- what I learned, when it ends
  created_at timestamptz not null default now(),
  ended_at timestamptz
);
-- tries gets the same four own-rows RLS policies as entries, plus an index on user_id
create index if not exists entries_parent_id_idx on entries(parent_id);
```

* **Why lessons, replies and look-backs are rows in `entries`:** they're all things I wrote, and they belong in the log, in tag search, and in any future export. One table keeps "the database is the record" simple. `kind` tells them apart.
* **Why tries get their own table:** they have state (active, kept, dropped) and a check-in date, and they aren't writing.
* **Recently dealt prompts** (for the 14-day no-repeat rule) come from `entries.prompt_id` plus a small `localStorage` list of skipped ones. Skips don't need to sync.
* **The prompt bank** is a JS array in `index.html` (`{id, deck, weight, text}`), the same way touchbase does it.
* **The week of a look-back** comes from the entry's `ts`. Finding "done this week?" is a query for `kind = 'lookback'` since Saturday.

AI later, not in v3

This is designed the same way as touchbase's Pop Quiz: the card UI doesn't care where a prompt comes from. A later version could notice patterns across entries ("you've written about being tired before 1:1s five times since August. anything there?") or suggest a lesson from a long entry. That needs a server-side call (a Supabase Edge Function) so no API key ships in the page. It also means sending my private journal to an AI provider, which deserves its own careful decision. For now it's a roadmap item only.

Non-goals for v3

* Streaks, scores, points, mood ratings, or any "growth metric". The Growth page shows words, not numbers.
* Daily habit tracking or checkboxes on tries
* Notifications or reminders. The Sunday look-back waits on Today; it doesn't come looking for me.
* AI-generated prompts or summaries (designed for, but deferred)
* Full-text search (still on the later list)
* Export (still deferred, as in v2.1)
* Linking to touchbase people. It's a nice idea ("better relationships" could point at real people), but it's for later.
* A build step, framework, or router library

Build plan

Phase 1: data

* `supabase/migrate_v3.sql` to run once, with `schema.sql` updated to match
* Load `tries` and the new `entries` columns into memory, and teach save, edit and delete about them
* Log: hide released entries by default, and show replies as threads under their parent

Phase 2: Today and cards

* Tabs become Today / Log / Growth, with Today as the default and the composer on top, unchanged
* The prompt bank (about 50 prompts across seven decks) and the reminder lines
* Dealing a hand: the one-heavy-card rule, no repeats, and look-back selection (age, anniversaries, 90-day cooldown, minimum length)
* Card UI for reflection and look-back cards: save / reply, → lesson, let it go, skip, the end-of-hand screen, deal again

Phase 3: lessons, tries, release

* **→ lesson** and **let go / un-release** on expanded log entries
* Trying chips on Today, the 14-day check-in, the three endings, and the max-3 chooser page
* Growth page: trying now, lessons, kept, tried, changed my mind, look-backs

Phase 4: Sunday look-back and polish

* The Saturday-to-Monday card, the one-question-per-screen page with the week's entries alongside, and saving as one `#lookback` entry
* History entries and back-gesture handling for the full pages
* Motion (respecting reduced-motion), the desktop two-column Today, and a copy pass
* Test on a phone:
  * capture from a cold open in under five seconds
  * deal a hand, answer one, skip one, reply to a look-back, turn a reply into a lesson and the lesson into a try
  * release an entry, confirm it's gone from the log, show released, un-release it
  * do a Sunday look-back and use the back gesture partway through
* Update README, CHANGELOG, and the manifest description, and tag v3

Success criteria

* Capturing is still under five seconds from a cold open. v3 adds nothing between me and the textarea.
* I open capture sometimes with nothing on my mind, because a hand of cards is a nice two-minute thing to do.
* Within a month, I've replied to at least a few old entries, and reading "then → now" makes me laugh more than wince.
* I always have 1–3 tries going, and at least one has moved to "kept".
* I do the Sunday look-back most weeks, and skipping one feels like nothing.
* Nothing in the app makes me feel behind, graded, or judged.

Decided

* **The name stays capture.** Capturing is still the first thing on screen; the loop grows around it.
* **The look-back day is Sunday**, as a constant (the card shows Saturday through Monday). Not configurable.
* **A hand is 3 cards**, matching touchbase. Easy to change later.
* **Release only changes what the app shows.** A future export includes released entries; the record is still the record.
* **Local testing uses a demo mode:** `?demo` on localhost runs on seeded sample data in `localStorage` and never talks to Supabase.
