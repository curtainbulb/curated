create table if not exists progress(user_id uuid not null default auth.uid() references auth.users on delete cascade,film_id text not null,watched boolean not null default false,note text not null default '',updated_at timestamptz not null default now(),primary key(user_id,film_id));
create table if not exists settings(user_id uuid primary key default auth.uid() references auth.users on delete cascade,data jsonb not null default '{}');
alter table progress enable row level security;alter table settings enable row level security;
create policy "own progress" on progress for all using(auth.uid()=user_id) with check(auth.uid()=user_id);
create policy "own settings" on settings for all using(auth.uid()=user_id) with check(auth.uid()=user_id);
