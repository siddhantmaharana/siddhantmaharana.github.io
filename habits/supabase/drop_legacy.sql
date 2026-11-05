-- Drops the retired capture and touchbase tables. Irreversible.
-- Run ONLY after `python3 -I _automations/import_legacy.py` has run in the vault and you've
-- checked the result (Journal notes tagged #imported, and the From capture / From touchbase
-- sections in Personal/INBOX.md). Take a backup first if in doubt:
-- Dashboard -> Database -> Backups, or `select * from <table>` and export.

drop table if exists tries;
drop table if exists tag_vocab;
drop table if exists entries;        -- capture's, not habit_entries

drop table if exists ask_abouts;
drop table if exists cards;
drop table if exists touch_logs;
drop table if exists people;
