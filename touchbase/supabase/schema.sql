-- touchbase schema (v4)
-- Run this in the Supabase project's SQL editor (Dashboard -> SQL Editor -> New query)
-- for a fresh project. An existing v2/v3 project should run migrate_v4.sql instead.

create table if not exists people (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  about text,
  cadence_days integer not null default 30,   -- v3; v4 uses rhythm but keeps this in sync
  rhythm text not null default 'regular' check (rhythm in ('close','regular','occasional')),
  phone text,                                 -- digits with country code, e.g. '14155550123'
  details text,
  birthday text,                              -- 'MM-DD' or 'YYYY-MM-DD'
  snoozed_until timestamptz,
  last_contact timestamptz,
  next_contact timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists touch_logs (
  id uuid primary key default gen_random_uuid(),
  person_id uuid not null references people(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  note text not null,
  ts timestamptz not null,
  created_at timestamptz not null default now()
);

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

create table if not exists ask_abouts (
  id uuid primary key default gen_random_uuid(),
  person_id uuid not null references people(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  prompt_id text,
  text text not null,
  done_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists touch_logs_person_id_idx on touch_logs(person_id);
create index if not exists cards_person_id_idx on cards(person_id);
create index if not exists cards_user_id_idx on cards(user_id);
create index if not exists ask_abouts_person_id_idx on ask_abouts(person_id);
create index if not exists ask_abouts_user_id_idx on ask_abouts(user_id);
create index if not exists people_user_id_idx on people(user_id);
create index if not exists touch_logs_user_id_idx on touch_logs(user_id);

alter table people enable row level security;
alter table touch_logs enable row level security;
alter table cards enable row level security;
alter table ask_abouts enable row level security;

create policy "people_select_own" on people
  for select using (auth.uid() = user_id);
create policy "people_insert_own" on people
  for insert with check (auth.uid() = user_id);
create policy "people_update_own" on people
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "people_delete_own" on people
  for delete using (auth.uid() = user_id);

create policy "touch_logs_select_own" on touch_logs
  for select using (auth.uid() = user_id);
create policy "touch_logs_insert_own" on touch_logs
  for insert with check (auth.uid() = user_id);
create policy "touch_logs_update_own" on touch_logs
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "touch_logs_delete_own" on touch_logs
  for delete using (auth.uid() = user_id);

create policy "cards_select_own" on cards
  for select using (auth.uid() = user_id);
create policy "cards_insert_own" on cards
  for insert with check (auth.uid() = user_id);
create policy "cards_update_own" on cards
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "cards_delete_own" on cards
  for delete using (auth.uid() = user_id);

create policy "ask_abouts_select_own" on ask_abouts
  for select using (auth.uid() = user_id);
create policy "ask_abouts_insert_own" on ask_abouts
  for insert with check (auth.uid() = user_id);
create policy "ask_abouts_update_own" on ask_abouts
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "ask_abouts_delete_own" on ask_abouts
  for delete using (auth.uid() = user_id);

-- keep updated_at current on every edit
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger people_set_updated_at
  before update on people
  for each row execute function set_updated_at();
