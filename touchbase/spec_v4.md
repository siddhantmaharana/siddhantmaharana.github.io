Personal CRM — v4

A simple personal CRM for staying in touch with friends and family.

Goal

v1–v3 made touchbase work: data model, sync, a Timeline to browse. v4 is about making it something I actually want to open. Right now:

* The app tells me how late I am, which makes me avoid it.
* The person view is a floating sheet that's awkward to use on a phone.
* It only holds one line about each person, so it can't help me remember what matters to them.

v4 turns it from a tracker of what I owe into a notebook about my people that's fun to fill in. The home screen stops being a list of who I'm behind on. Instead it's a **Pop Quiz**: a few playful questions about the people in my life. Answering them builds up each person's profile, card by card. When it's time to reach out, one tap opens WhatsApp.

Challenges (from actually using v3)

1. I never use "needs attention", and I never notice the days-overdue counts. Red "34d over" badges make it feel like it's already too late, so I keep putting it off. The warning backfires.
2. Tapping a name opens a floating sheet that's hard to navigate and scroll. What the code does today:
   * The note box is auto-focused on open. On a phone the keyboard pops up, covers half the sheet, and hides the history.
   * The sheet is a fixed overlay with its own inner scroll (90vh). Scrolling inside it fights the page behind it.
   * Tapping the dark backdrop closes the sheet and silently throws away a half-written note.
   * The phone's back gesture doesn't close it. It leaves the app instead.
   * The log form comes first. What I usually want when I open someone is to remember who they are and what we last talked about, and that sits underneath the form.
3. There's nowhere to keep things *about* a person: interests, their partner's or kids' names, how we met, what to ask about next time. The only field is a one-line `about`.
4. There's no reason to open the app unless I've just talked to someone. Filling in profiles by hand is a chore, so it won't happen.
5. Even when the app reminds me of someone, actually reaching out means leaving it, finding them in WhatsApp, and thinking of what to say. Then I forget to come back and log it.

What v4 changes over v3

* **A new home screen, Pop Quiz:** fun prompts about my people, answered as quick Q&A cards that go into their profiles.
* **No more overdue debt.** Remove the red badges and the "needs attention" section. Replace them with a short, forgiving "worth a hello" list.
* **Reaching out happens from the app:** WhatsApp, text or call in one tap, with a suggested opener, and a prompt to log it when I come back.
* **The person view becomes a full page** with a back button, showing their Pop Quiz answers, notes, and an "ask about next time" list.
* **Simpler navigation:** two tabs, Pop Quiz and People. Timeline moves one level down, and the whole app gets a more playful feel.

Unchanged: sync, auth, export/import, and the single-file no-build approach.

Ideas

1. Pop Quiz: prompts about a person, answered as cards (fixes challenges 3 and 4)

The home screen deals a hand of **3 prompt cards**, each about one specific person:

> **What's Priya's go-to coffee order?**
> [ type an answer… ]
> **save** · **no idea, ask her** · **skip**

* **save** stores the Q&A as a card in the Pop Quiz section of that person's profile.
* **no idea, ask her** turns the question into an **ask-about** item on her profile ("ask: what's her go-to coffee order?"). This gives a natural opener for next time and feeds idea 2's WhatsApp message. Not knowing is useful too.
* **skip** swaps in a different prompt, with no penalty.
* **After the third card:** "that's plenty. go text someone." with a link to the people in "worth a hello". You can tap **deal again** for more, but nothing pushes you to. No streaks and no scores.
* Cards flip in with a small animation, and each person keeps their avatar color on the card, so it feels like a deck, not a form.

Choosing who and what to ask:

* **Who:** a weighted random pick that favors people with the fewest answered cards. Thin profiles fill up first, and nobody gets asked about twice in one hand.
* **What:** a random prompt from a static bank shipped inside the app. It's never one that person already has an answer for, unless it's a "lately" prompt that has gone stale (below).
* **Rhythm:** close friends come up a bit more often than occasional contacts.

The prompt bank for v4 is static: about 60 prompts, easy and fun first, in four decks.

* **favorites** (easy warm-ups)
  * What's {name}'s go-to coffee order?
  * What's {name}'s comfort movie or show?
  * What would {name} bring to a potluck?
  * What's a topic {name} could talk about for an hour?
* **story** (how you know them)
  * How did you and {name} meet?
  * What's your favorite memory with {name}?
  * What's a running joke you have with {name}?
* **people** (their world)
  * Who are the important people in {name}'s life right now?
  * What are {name}'s partner's or kids' or pets' names?
* **lately** (answers that go stale)
  * What's {name} excited about these days?
  * What's {name} working on or stressed about?
  * What was {name} obsessed with last time you talked?

A "lately" answer is treated as stale after about 90 days, so the same prompt can come back and the profile shows the newest answer. Older answers stay in the history, which ends up as a quiet record of how their life has changed.

AI later, not in v4: the prompt bank is designed so an AI step can be added without changing the UI. A later version could generate follow-up prompts from a person's existing notes and cards ("You noted Priya started pottery in March. Ask how her first piece turned out?"). That needs a server-side call, such as a Supabase Edge Function, so the API key never ships in the page. It also means sending notes to an AI provider, which deserves its own decision. For now it's a roadmap item only.

2. Worth a hello: nudges that lead straight to a message (fixes challenges 1 and 5)

Who shows up:

* **"Worth a hello"** shows at most 3 people, chosen from those furthest past their rhythm. It never lists everyone who is late. It sits at the top of both the Pop Quiz home and the People tab, showing the same 3 people in both places.
* **No day counts and no red anywhere.** Rows say how long it's been in plain words, like "last talked in July" or "a while now".
* **A reason to reach out** shows as a small line under the name: an open ask-about ("you wanted to ask about the Atlanta trip"), a fresh Pop Quiz answer, or an upcoming birthday. That makes the nudge an invitation, not a debt.
* **Three loose rhythms replace exact cadences:** **close** (~2 weeks), **regular** (~monthly), **occasional** (~quarterly). They're only used for picking people and are never shown as a deadline.

Actions on each person:

* **WhatsApp** (the main action when a phone number is saved). Opens a chat with them via `https://wa.me/<number>?text=<opener>`. On a phone this opens the WhatsApp app; on desktop it opens WhatsApp Web. The opener is pre-filled and editable in WhatsApp before sending:
  * with an open ask-about: "hey! how did the Atlanta trip go?"
  * with a birthday coming up: "happy birthday!! 🎉"
  * otherwise, a short rotating casual line ("hey, been a while! how are things?")
  * The suggested message is always included; I can edit or delete it in WhatsApp before sending.
* **text** (`sms:`) and **call** (`tel:`) in the ⋯ menu, for people who aren't on WhatsApp.
* **not now** snoozes that person for exactly 7 days and brings in the next one.
* **log it** opens the composer directly, for when I've already talked to them.

Closing the loop:

* When I come back to the app after tapping WhatsApp, text or call, a small card asks: "talked to Priya? jot it down". It offers **log it** (which opens the composer with any ask-about pre-ticked) or **not yet**.
* This is detected with `visibilitychange`, and it's shown once per outreach, never as a nag.
* The same WhatsApp / text / call buttons appear in the person page header, so reaching out works from anywhere, not just from the nudges.
* People without a phone number show **add number** in place of the WhatsApp button, which opens the edit sheet at the phone field.

3. Person page instead of a floating sheet (fixes challenge 2)

* **A full-screen page** with ← back, the name, and ⋯ (edit / delete). It uses normal page scrolling, with no nested scroll area.
* **The back gesture works.** Opening a person adds a `#p/<id>` history entry, so the phone's back gesture returns to the list. It's still one HTML file with no router, using the same show/hide view switch the tabs already use.
* **Page order puts reading first:**
  1. **Header:** avatar, name, the one-line about, rhythm, when you last talked, and the WhatsApp / text / call buttons
  2. **Ask about next time:** open items, since this is what you want to see before a call
  3. **Pop Quiz:** their answered prompts as cards in a grid, grouped by deck, with the newest "lately" answers first. Tap a card to edit it, or use **"+ quiz me on {name}"** to deal a card for just this person.
  4. **Details:** an optional freeform box for anything that doesn't fit a card
  5. **Notes:** their full history, grouped by Today / This week / month, with no cap
* **Logging:** a sticky **"+ log a note"** button opens a compact composer with the note, a date (defaulting to today), and ticks for any open ask-abouts you covered. Nothing is auto-focused until you tap the note box.
* **Drafts are never silently lost.** Each person's draft is kept in `localStorage` until it's logged, so closing the composer (✕, tapping outside, the back gesture) just keeps it. Only the explicit **discard** button throws it away, after asking.
* **Edit sheet additions:** phone number and birthday (optional). Birthday feeds the nudges.

4. Reorganized navigation and a more playful feel

**Two tabs:**

| tab | what |
|---|---|
| **Pop Quiz** (home, default) | "worth a hello" strip up top (max 3 people), then today's hand of 3 prompt cards |
| **People** | "worth a hello" strip up top (the same 3 people), then everyone, searchable, sorted by name. Each row shows the avatar, name and about, plus a small count of answered cards so thin profiles are visible. No status badges. |

**Timeline** stays, but moves one level down instead of taking up a tab:

* It's reachable from an **"all notes →"** link at the bottom of People, and from **"see everyone's notes →"** under a person's notes history.
* It gets its own `#timeline` history entry, so back returns to where I came from.
* Otherwise it's unchanged from v3: every note across everyone, newest first.

**The app should feel more playful:**

* **Personality in the copy, not alarms.** Empty states and confirmations get a little dry humor, matching the homepage.
  * no people yet: "it's quiet in here. add someone you like."
  * a finished hand: "that's plenty. go text someone."
* **Motion, used sparingly:** a card-deal and flip animation for the Pop Quiz hand, a small check pop on save, and page slide-in and slide-out for the person page and Timeline. All of it is off under `prefers-reduced-motion`.
* **Color:** avatar colors carry through to each person's cards and page header, so each person has a recognizable look. The accent stays the shared purple, and red is reserved for delete.
* **Styling** uses the shared `../shared/theme.css` tokens, so touchbase stays consistent with the other apps.

Data model

All changes only add columns and tables; nothing existing is renamed or dropped. v3 clients keep working until they refresh.

```sql
alter table people
  add column if not exists rhythm text not null default 'regular'
    check (rhythm in ('close','regular','occasional')),
  add column if not exists phone text,             -- digits with country code, e.g. '14155550123'
  add column if not exists details text,
  add column if not exists birthday text,          -- 'MM-DD' or 'YYYY-MM-DD'
  add column if not exists snoozed_until timestamptz;

-- Pop Quiz answers: one row per answered prompt. A re-answered "lately" prompt adds
-- a new row; the page shows the newest per prompt and keeps the rest as history.
create table if not exists cards (
  id uuid primary key default gen_random_uuid(),
  person_id uuid not null references people(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  prompt_id text,                 -- id from the static bank; null for a custom question
  deck text not null,             -- favorites | story | people | lately | custom
  question text not null,         -- stored as asked, so bank edits don't rewrite history
  answer text not null,
  created_at timestamptz not null default now()
);

create table if not exists ask_abouts (
  id uuid primary key default gen_random_uuid(),
  person_id uuid not null references people(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  prompt_id text,                 -- set when it came from "no idea, ask them", so it isn't re-dealt
  text text not null,
  done_at timestamptz,
  created_at timestamptz not null default now()
);
-- both new tables get the same four own-rows RLS policies as touch_logs,
-- plus an index on person_id
```

* **Phone numbers** are stored as digits only, with the country code, because that's the format `wa.me` needs. The edit sheet accepts any formatting ("+1 (415) 555-0123") and strips it on save. A number typed without a country code gets +1 (US).
* **Migrating rhythm:** `cadence_days` ≤ 20 becomes close, 21–60 regular, > 60 occasional. `cadence_days` stays in the table, unused, so v3 still works during the transition.
* **`next_contact`:** kept, and repurposed. A manually set next date now just means "suggest them on that day".
* **The prompt bank** is a JS array in `index.html` (`{id, deck, text}` with a `{name}` placeholder), not a database table. It's easy to edit, and it's what a future AI step would add to.
* **Export (markdown and JSON)** includes Pop Quiz answers, phone, details, birthday and open ask-abouts. The markdown export writes each person's answers as a Q&A list, which suits the Obsidian and AI workflow the export already serves.

Suggestion logic for "worth a hello" (replaces urgency / isAttention)

* Rhythm maps to a number of days: close 14, regular 30, occasional 90.
* A person is eligible when all of these hold:
  * they're not snoozed
  * *days since last contact ≥ rhythm days*, or they've never been contacted, or their `next_contact` date has arrived
* Rank eligible people by how far past their rhythm they are, as a ratio. Open ask-abouts give a small boost, and a birthday within 5 days always takes a slot. Show the top 3.
* The ranking is internal only. The UI never shows a number of days late.

Non-goals for v4

* AI-generated prompts (designed for, but deferred; see idea 1)
* Sending messages from inside touchbase, or reading WhatsApp chats. The app only opens WhatsApp with a draft; I still press send.
* Notifications, email, or SMS reminders (they'd bring back the pressure this release removes)
* Streaks, scores, points, or any "relationship health" metric. Pop Quiz should be fun because it's light, not because it's gamified.
* Importing from phone contacts or social media
* A build step, framework, or router library

Build plan

Phase 1: data

* `supabase/migrate_v4.sql` to run once, with `schema.sql` updated to match
* Load and save `cards`, `ask_abouts` and the new `people` fields (including phone) into `DB`
* Export includes the new data

Phase 2: person page

* Replace `#sheet-person` with a `#person-main` view: back button, `#p/<id>` history entries, and handling for the back gesture (`popstate`)
* Sections: header with WhatsApp / text / call, ask-abouts, Pop Quiz grid, details, full notes history
* Sticky composer with no auto-focus, ask-about ticks, a draft saved per person, and a confirm-before-discard prompt
* The edit sheet gains phone, rhythm, birthday and details

Phase 3: Pop Quiz home and worth a hello

* The prompt bank (about 60 prompts across four decks)
* Dealing a hand of 3: weighted person pick, prompt pick, and "lately" staleness
* Card UI with save / no idea, ask them / skip, the end-of-hand screen, and deal again
* The "worth a hello" strip, using the suggestion logic, with WhatsApp (and its pre-filled opener), not now, log it, and text / call in ⋯
* The "talked to them? jot it down" card when returning to the app after reaching out

Phase 4: navigation and polish

* Two tabs (Pop Quiz / People), with Pop Quiz as the default
* Timeline moved to a `#timeline` page, linked from People and from person pages
* People tab: "worth a hello" strip on top, then search, sorted by name, no badges, answered-card count per row
* Remove all red status badges, overdue counts and the old sections
* Motion (respecting reduced-motion), copy pass, and moving touchbase fully onto the shared theme tokens
* Test on a phone:
  * deal a hand, answer, "ask them"
  * WhatsApp opens with the right number and opener, and the jot-it-down card appears on return
  * open a person, use the back gesture, open Timeline and go back
  * log with the keyboard open; a draft survives an accidental close
* Update README and CHANGELOG, and tag v4

Success criteria

* I open touchbase for fun, not because I'm behind. Nothing on screen says I'm late.
* After a week of occasional 3-card hands, most of my close people have 5 or more answered cards.
* From a nudge to a WhatsApp chat with a good opener takes one tap, and I usually log it when I come back.
* In 10 seconds before a call, I can see who they are, what we last talked about, and what to ask.
* The person page scrolls like a normal page, and back takes me back.
* Carried over: it syncs across devices, and the notes stay mine (export works).

Decided

* The feature is called **Pop Quiz**. On a person's page, the section is also called Pop Quiz.
* A hand is **3 cards** to start with. It's easy to change later.
* **Timeline stays**, as a page one level down rather than a tab.
* **Worth a hello opens WhatsApp** with a suggested message always pre-filled. Text and call are secondary options.
* **Worth a hello sits at the top of People** as well as on the Pop Quiz home.
* **Snoozing lasts a fixed 7 days**, with no choice of length.
* **Numbers typed without a country code default to +1 (US).** An international number just needs its `+code` typed.
