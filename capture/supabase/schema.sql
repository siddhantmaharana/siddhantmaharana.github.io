-- capture schema (v2.1: adds the entries update policy for in-place edits)
-- Run this in the SAME Supabase project touchbase uses (Dashboard -> SQL Editor -> New query).
-- Table names (entries, tag_vocab) don't collide with touchbase's (people, touch_logs).

create table if not exists entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  text text not null,
  tags text[] not null default '{}',
  ts timestamptz not null,
  created_at timestamptz not null default now()
);

create table if not exists tag_vocab (
  user_id uuid not null references auth.users(id) on delete cascade,
  tag text not null,
  last_used_at timestamptz not null default now(),
  primary key (user_id, tag)
);

create index if not exists entries_user_id_idx on entries(user_id);
create index if not exists entries_ts_idx on entries(ts);
create index if not exists tag_vocab_user_id_idx on tag_vocab(user_id);

alter table entries enable row level security;
alter table tag_vocab enable row level security;

create policy "entries_select_own" on entries
  for select using (auth.uid() = user_id);
create policy "entries_insert_own" on entries
  for insert with check (auth.uid() = user_id);
create policy "entries_delete_own" on entries
  for delete using (auth.uid() = user_id);
create policy "entries_update_own" on entries
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "tag_vocab_select_own" on tag_vocab
  for select using (auth.uid() = user_id);
create policy "tag_vocab_insert_own" on tag_vocab
  for insert with check (auth.uid() = user_id);
create policy "tag_vocab_update_own" on tag_vocab
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- entries persist indefinitely — there is no app-level purge or export-triggered delete.
-- if you want to prune or archive old rows, do it directly in the Supabase SQL editor.
-- no delete policy on tag_vocab: vocabulary is meant to persist even if entries are pruned
