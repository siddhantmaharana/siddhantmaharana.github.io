-- touchbase v4 migration: run once in the Supabase SQL editor
-- (Dashboard -> SQL Editor -> New query), BEFORE deploying the v4 index.html.
-- Only adds columns and tables. v3 keeps working, and it's safe to run twice.

-- people: rhythm, phone, details, birthday, snooze
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_name = 'people' and column_name = 'rhythm'
  ) then
    alter table people
      add column rhythm text not null default 'regular'
        check (rhythm in ('close','regular','occasional'));
    -- derive rhythm from the old cadence, only on the first run
    update people set rhythm = case
      when cadence_days <= 20 then 'close'
      when cadence_days <= 60 then 'regular'
      else 'occasional'
    end;
  end if;
end $$;

alter table people
  add column if not exists phone text,             -- digits with country code, e.g. '14155550123'
  add column if not exists details text,
  add column if not exists birthday text,          -- 'MM-DD' or 'YYYY-MM-DD'
  add column if not exists snoozed_until timestamptz;

-- Pop Quiz answers
create table if not exists cards (
  id uuid primary key default gen_random_uuid(),
  person_id uuid not null references people(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  prompt_id text,
  deck text not null,
  question text not null,
  answer text not null,
  created_at timestamptz not null default now()
);

-- things to ask about next time
create table if not exists ask_abouts (
  id uuid primary key default gen_random_uuid(),
  person_id uuid not null references people(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  prompt_id text,                 -- set when it came from "no idea, ask them" in Pop Quiz
  text text not null,
  done_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists cards_person_id_idx on cards(person_id);
create index if not exists cards_user_id_idx on cards(user_id);
create index if not exists ask_abouts_person_id_idx on ask_abouts(person_id);
create index if not exists ask_abouts_user_id_idx on ask_abouts(user_id);

alter table cards enable row level security;
alter table ask_abouts enable row level security;

drop policy if exists "cards_select_own" on cards;
drop policy if exists "cards_insert_own" on cards;
drop policy if exists "cards_update_own" on cards;
drop policy if exists "cards_delete_own" on cards;
create policy "cards_select_own" on cards
  for select using (auth.uid() = user_id);
create policy "cards_insert_own" on cards
  for insert with check (auth.uid() = user_id);
create policy "cards_update_own" on cards
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "cards_delete_own" on cards
  for delete using (auth.uid() = user_id);

drop policy if exists "ask_abouts_select_own" on ask_abouts;
drop policy if exists "ask_abouts_insert_own" on ask_abouts;
drop policy if exists "ask_abouts_update_own" on ask_abouts;
drop policy if exists "ask_abouts_delete_own" on ask_abouts;
create policy "ask_abouts_select_own" on ask_abouts
  for select using (auth.uid() = user_id);
create policy "ask_abouts_insert_own" on ask_abouts
  for insert with check (auth.uid() = user_id);
create policy "ask_abouts_update_own" on ask_abouts
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "ask_abouts_delete_own" on ask_abouts
  for delete using (auth.uid() = user_id);
