-- journal_entries (habits v2): the composer on the home screen.
-- Run once in the shared Supabase project's SQL editor. Safe to re-run.
-- Entries live here only until _automations/pull_journal.py in the vault copies them into
-- Journal/YYYY-MM.md and sets pulled_at. After that the vault owns them, so the app can no
-- longer edit them (the update policy below), only delete its own copy.

create table if not exists journal_entries (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  entry_date  date not null,                 -- the day it's about (backdatable)
  title       text not null default '',
  body        text not null default '',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  pulled_at   timestamptz                    -- set by the vault script; null = still in the app
);

create index if not exists journal_entries_user_id_idx on journal_entries(user_id);
create index if not exists journal_entries_unpulled_idx on journal_entries(entry_date, created_at) where pulled_at is null;

alter table journal_entries enable row level security;

drop policy if exists "journal_entries_select_own" on journal_entries;
drop policy if exists "journal_entries_insert_own" on journal_entries;
drop policy if exists "journal_entries_update_own" on journal_entries;
drop policy if exists "journal_entries_delete_own" on journal_entries;
create policy "journal_entries_select_own" on journal_entries
  for select using (auth.uid() = user_id);
create policy "journal_entries_insert_own" on journal_entries
  for insert with check (auth.uid() = user_id and pulled_at is null);
create policy "journal_entries_update_own" on journal_entries
  for update using (auth.uid() = user_id and pulled_at is null)
  with check (auth.uid() = user_id and pulled_at is null);
create policy "journal_entries_delete_own" on journal_entries
  for delete using (auth.uid() = user_id);

-- set_updated_at() is defined in schema.sql (and by touchbase); redefined here so this file runs alone.
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists journal_entries_set_updated_at on journal_entries;
create trigger journal_entries_set_updated_at
  before update on journal_entries
  for each row execute function set_updated_at();
