-- habits v2.1: optional group per habit, shown as collapsible sections on Home.
-- Run once in the Supabase SQL editor (project sjycdaxraklxlnrmgqrb). Safe to re-run.
-- '' means no group. Named group_name because GROUP is a reserved word.
alter table habits add column if not exists group_name text not null default '';
notify pgrst, 'reload schema';
