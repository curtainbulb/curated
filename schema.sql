create table if not exists progress(user_id uuid not null default auth.uid() references auth.users on delete cascade,film_id text not null,watched boolean not null default false,note text not null default '',updated_at timestamptz not null default now(),primary key(user_id,film_id));
create table if not exists settings(user_id uuid primary key default auth.uid() references auth.users on delete cascade,data jsonb not null default '{}');
alter table progress enable row level security;alter table settings enable row level security;
create policy "own progress" on progress for all using(auth.uid()=user_id) with check(auth.uid()=user_id);
create policy "own settings" on settings for all using(auth.uid()=user_id) with check(auth.uid()=user_id);

-- Shared poster cache: one copy per film, fetched once from TMDB/OMDb/iTunes/Wikipedia and
-- reused by every signed-in user thereafter, instead of every browser re-hitting those
-- IP-rate-limited providers for the same film. Public-read (posters are not sensitive and
-- are already public images from the providers) so <img> tags can load them directly without
-- a signed URL round trip; write is restricted to authenticated users so anonymous clients
-- cannot use this bucket to host arbitrary files.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('posters', 'posters', true, 2097152, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;
create policy "posters are publicly readable" on storage.objects for select
 using (bucket_id = 'posters');
create policy "authenticated users can cache posters" on storage.objects for insert
 to authenticated with check (bucket_id = 'posters');
