-- habits schema (v1)
-- Run this in the shared Supabase project's SQL editor (Dashboard -> SQL Editor -> New query).
-- Safe to re-run. Table names are prefixed because capture already owns `entries`.
--
-- Store only what was logged; scores, auto-filled days and streaks are computed in the browser
-- (engine.js). Entry values use Loop Habit Tracker's encoding:
--   yes/no habits:     -1 unknown, 0 no, 1 yes (auto), 2 yes, 3 skip
--   numerical habits:  the amount x1000 (9.01 miles -> 9010)

create table if not exists habits (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name          text not null,
  question      text not null default '',
  description   text not null default '',
  type          text not null default 'yes_no' check (type in ('yes_no', 'numerical')),
  freq_num      integer not null default 1,
  freq_den      integer not null default 1,
  target_type   text not null default 'at_least' check (target_type in ('at_least', 'at_most')),
  target_value  double precision not null default 0,
  unit          text not null default '',
  color         text not null default '#4f8a8b',
  position      integer not null default 0,
  archived      boolean not null default false,
  reminder_time text,                                   -- 'HH:MM', stored for later
  reminder_days integer not null default 127,           -- weekday bitmask, Mon = bit 0
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  check (freq_num > 0 and freq_den > 0 and freq_num <= freq_den)
);

create table if not exists habit_entries (
  habit_id   uuid not null references habits(id) on delete cascade,
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  date       date not null,
  value      integer not null,
  notes      text not null default '',
  updated_at timestamptz not null default now(),
  primary key (habit_id, date)
);

create index if not exists habits_user_id_idx on habits(user_id);
create index if not exists habit_entries_user_id_idx on habit_entries(user_id);

alter table habits enable row level security;
alter table habit_entries enable row level security;

drop policy if exists "habits_select_own" on habits;
drop policy if exists "habits_insert_own" on habits;
drop policy if exists "habits_update_own" on habits;
drop policy if exists "habits_delete_own" on habits;
create policy "habits_select_own" on habits
  for select using (auth.uid() = user_id);
create policy "habits_insert_own" on habits
  for insert with check (auth.uid() = user_id);
create policy "habits_update_own" on habits
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "habits_delete_own" on habits
  for delete using (auth.uid() = user_id);

-- An entry must belong to you *and* point at one of your habits.
drop policy if exists "habit_entries_select_own" on habit_entries;
drop policy if exists "habit_entries_insert_own" on habit_entries;
drop policy if exists "habit_entries_update_own" on habit_entries;
drop policy if exists "habit_entries_delete_own" on habit_entries;
create policy "habit_entries_select_own" on habit_entries
  for select using (auth.uid() = user_id);
create policy "habit_entries_insert_own" on habit_entries
  for insert with check (auth.uid() = user_id
    and exists (select 1 from habits h where h.id = habit_entries.habit_id and h.user_id = auth.uid()));
create policy "habit_entries_update_own" on habit_entries
  for update using (auth.uid() = user_id)
  with check (auth.uid() = user_id
    and exists (select 1 from habits h where h.id = habit_entries.habit_id and h.user_id = auth.uid()));
create policy "habit_entries_delete_own" on habit_entries
  for delete using (auth.uid() = user_id);

-- keep updated_at current on every edit (same function touchbase uses; identical body)
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists habits_set_updated_at on habits;
create trigger habits_set_updated_at
  before update on habits
  for each row execute function set_updated_at();
drop trigger if exists habit_entries_set_updated_at on habit_entries;
create trigger habit_entries_set_updated_at
  before update on habit_entries
  for each row execute function set_updated_at();
