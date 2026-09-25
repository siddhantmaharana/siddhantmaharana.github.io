-- touchbase v2 schema
-- Run this in the Supabase project's SQL editor (Dashboard -> SQL Editor -> New query)

create table if not exists people (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  about text,
  cadence_days integer not null default 30,
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

create index if not exists touch_logs_person_id_idx on touch_logs(person_id);
create index if not exists people_user_id_idx on people(user_id);
create index if not exists touch_logs_user_id_idx on touch_logs(user_id);

alter table people enable row level security;
alter table touch_logs enable row level security;

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
