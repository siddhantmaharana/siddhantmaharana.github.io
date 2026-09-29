-- capture v3 migration: run once in the Supabase SQL editor
-- (Dashboard -> SQL Editor -> New query), BEFORE deploying the v3 index.html.
-- Only adds columns and a table. v2.1 keeps working, and it's safe to run twice.

-- entries: reflections, look-back replies, lessons and weekly look-backs are all rows here,
-- told apart by `kind`. Existing rows become 'note'.
alter table entries
  add column if not exists kind text not null default 'note',
  add column if not exists prompt_id text,          -- id from the static prompt bank, for reflections
  add column if not exists question text,           -- stored as asked, so bank edits don't rewrite history
  add column if not exists parent_id uuid references entries(id) on delete set null,
                                                    -- replies and lessons point at their source entry
  add column if not exists area text,               -- lessons only, optional
  add column if not exists released_at timestamptz, -- "let it go"; null means active
  add column if not exists resurfaced_at timestamptz; -- last shown on a look-back card

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'entries_kind_check') then
    alter table entries add constraint entries_kind_check
      check (kind in ('note','reflection','reply','lesson','lookback'));
  end if;
end $$;

create index if not exists entries_parent_id_idx on entries(parent_id);

-- tries: one small thing I'm doing differently. At most 3 active (enforced in the app).
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

create index if not exists tries_user_id_idx on tries(user_id);

alter table tries enable row level security;

drop policy if exists "tries_select_own" on tries;
drop policy if exists "tries_insert_own" on tries;
drop policy if exists "tries_update_own" on tries;
drop policy if exists "tries_delete_own" on tries;
create policy "tries_select_own" on tries
  for select using (auth.uid() = user_id);
create policy "tries_insert_own" on tries
  for insert with check (auth.uid() = user_id);
create policy "tries_update_own" on tries
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "tries_delete_own" on tries
  for delete using (auth.uid() = user_id);
