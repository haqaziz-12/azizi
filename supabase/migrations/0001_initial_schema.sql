-- UQAAB CARPET initial schema. Review and run in the Supabase SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('admin','editor')),
  created_at timestamptz not null default now()
);

create or replace function public.has_site_role(required_roles text[])
returns boolean language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.user_roles
    where user_id = auth.uid() and role = any(required_roles)
  );
$$;

create table if not exists public.site_settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);

create table if not exists public.pages (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  content jsonb not null default '{}'::jsonb,
  seo_title text,
  seo_description text,
  og_image text,
  published boolean not null default false,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);

create table if not exists public.collections (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  description text not null default '',
  cover_image text,
  sort_order integer not null default 0,
  published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  collection_id uuid references public.collections(id) on delete set null,
  collection_type text not null default '',
  size text not null default 'Confirm dimensions',
  quality text not null default 'Confirm with Uqaab team',
  materials text not null default 'Confirm composition',
  washing_type text not null default 'Confirm care instructions',
  pile_type text not null default 'Confirm construction',
  description text not null default '',
  price_label text not null default 'Price on inquiry',
  front_image text,
  back_image text,
  detail_image text,
  status text not null default 'draft' check (status in ('draft','published','archived')),
  sort_order integer not null default 0,
  seo_title text,
  seo_description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id)
);
create index if not exists products_status_sort_idx on public.products(status, sort_order);
create index if not exists products_collection_idx on public.products(collection_id);

create table if not exists public.media_assets (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  bucket text not null default 'site-media',
  storage_path text not null unique,
  public_url text,
  alt_text text not null default '',
  media_type text not null default 'image' check (media_type in ('image','video')),
  width integer,
  height integer,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id)
);

create table if not exists public.enquiries (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text not null,
  country text not null default '',
  subject text not null default 'Product enquiry',
  message text not null,
  status text not null default 'new' check (status in ('new','in_progress','responded','closed')),
  created_at timestamptz not null default now()
);
create index if not exists enquiries_status_created_idx on public.enquiries(status, created_at desc);

alter table public.user_roles enable row level security;
alter table public.site_settings enable row level security;
alter table public.pages enable row level security;
alter table public.collections enable row level security;
alter table public.products enable row level security;
alter table public.media_assets enable row level security;
alter table public.enquiries enable row level security;

-- Public can read published content; authenticated editors/admins can manage content.
create policy "roles: users read own role" on public.user_roles for select to authenticated using (user_id = auth.uid());
create policy "roles: admins manage roles" on public.user_roles for all to authenticated using (public.has_site_role(array['admin'])) with check (public.has_site_role(array['admin']));

create policy "settings: public read" on public.site_settings for select to anon, authenticated using (true);
create policy "settings: editors manage" on public.site_settings for all to authenticated using (public.has_site_role(array['admin','editor'])) with check (public.has_site_role(array['admin','editor']));

create policy "pages: public read published" on public.pages for select to anon, authenticated using (published = true or public.has_site_role(array['admin','editor']));
create policy "pages: editors manage" on public.pages for all to authenticated using (public.has_site_role(array['admin','editor'])) with check (public.has_site_role(array['admin','editor']));

create policy "collections: public read published" on public.collections for select to anon, authenticated using (published = true or public.has_site_role(array['admin','editor']));
create policy "collections: editors manage" on public.collections for all to authenticated using (public.has_site_role(array['admin','editor'])) with check (public.has_site_role(array['admin','editor']));

create policy "products: public read published" on public.products for select to anon, authenticated using (status = 'published' or public.has_site_role(array['admin','editor']));
create policy "products: editors manage" on public.products for all to authenticated using (public.has_site_role(array['admin','editor'])) with check (public.has_site_role(array['admin','editor']));

create policy "media: public read" on public.media_assets for select to anon, authenticated using (true);
create policy "media: editors manage" on public.media_assets for all to authenticated using (public.has_site_role(array['admin','editor'])) with check (public.has_site_role(array['admin','editor']));

-- Public enquiry creation is permitted; only editors/admins can read and update submissions.
create policy "enquiries: public submit" on public.enquiries for insert to anon, authenticated with check (length(trim(name)) between 1 and 120 and length(trim(email)) between 3 and 254 and length(trim(message)) between 10 and 5000);
create policy "enquiries: editors read" on public.enquiries for select to authenticated using (public.has_site_role(array['admin','editor']));
create policy "enquiries: editors update" on public.enquiries for update to authenticated using (public.has_site_role(array['admin','editor'])) with check (public.has_site_role(array['admin','editor']));

-- Public media bucket. Upload/delete are restricted to authenticated site editors.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('site-media','site-media',true,52428800,array['image/jpeg','image/png','image/webp','image/avif','image/svg+xml','video/mp4','video/webm'])
on conflict (id) do update set public = true, file_size_limit = 52428800,
  allowed_mime_types = array['image/jpeg','image/png','image/webp','image/avif','image/svg+xml','video/mp4','video/webm'];

create policy "storage: public view site media" on storage.objects for select to anon, authenticated using (bucket_id = 'site-media');
create policy "storage: editors upload site media" on storage.objects for insert to authenticated with check (bucket_id = 'site-media' and public.has_site_role(array['admin','editor']));
create policy "storage: editors update site media" on storage.objects for update to authenticated using (bucket_id = 'site-media' and public.has_site_role(array['admin','editor'])) with check (bucket_id = 'site-media' and public.has_site_role(array['admin','editor']));
create policy "storage: editors delete site media" on storage.objects for delete to authenticated using (bucket_id = 'site-media' and public.has_site_role(array['admin','editor']));

-- Seed editable brand settings. Update these from the admin interface once it is completed.
insert into public.site_settings(key,value) values
('brand', '{"name":"UQAAB CARPET","legal_name":"Uqaab Nawin Afghanistan Ltd.","founded":2015,"logo_url":"https://acmeg.org.af/wp-content/uploads/2024/12/newlogo-1-400x212.png"}'::jsonb),
('contact', '{"address":"House #3, Opposite to Ansar Hospital, Shahrak Pamir, Kotal Khair Khana, Kabul Afghanistan","email":"uqaab.carpet@yahoo.com","whatsapp":"https://wa.me/93771444555","facebook":"https://www.facebook.com/share/1ZU2fMvYiZ/","maps":"https://maps.app.goo.gl/yErNn6pui4mbvPeE7"}'::jsonb)
on conflict (key) do nothing;

-- Seed the 15 proposed catalogue concepts as drafts. They remain private until an admin verifies and publishes them.
insert into public.products
(slug,name,collection_type,size,quality,materials,washing_type,pile_type,description,price_label,status,sort_order)
values
('heritage-medallion','Heritage Medallion','Traditional','Confirm dimensions','Confirm with Uqaab team','Confirm composition','Confirm care instructions','Confirm construction','A classic medallion concept inspired by Afghan ornamental traditions. Confirm actual specifications before publishing.','Price on inquiry','draft',1),
('khal-mohammadi','Khal Mohammadi','Traditional','Confirm dimensions','Confirm with Uqaab team','Confirm composition','Confirm care instructions','Confirm construction','A deep-toned traditional design concept with geometric motifs. Confirm actual specifications before publishing.','Price on inquiry','draft',2),
('baluchi-tribal','Baluchi Tribal','Tribal','Confirm dimensions','Confirm with Uqaab team','Confirm composition','Confirm care instructions','Confirm construction','A tribal-inspired design concept with compact repeating geometry. Confirm actual specifications before publishing.','Price on inquiry','draft',3),
('afghan-geometric','Afghan Geometric','Traditional','Confirm dimensions','Confirm with Uqaab team','Confirm composition','Confirm care instructions','Confirm construction','A structured geometric concept for timeless interiors. Confirm actual specifications before publishing.','Price on inquiry','draft',4),
('afghan-kilim','Afghan Kilim','Flatweave','Confirm dimensions','Confirm with Uqaab team','Confirm composition','Confirm care instructions','Confirm construction','A flatweave-inspired concept with a clean, tactile character. Confirm actual specifications before publishing.','Price on inquiry','draft',5),
('ivory-heritage','Ivory Heritage','Neutral','Confirm dimensions','Confirm with Uqaab team','Confirm composition','Confirm care instructions','Confirm construction','A restrained neutral concept for calm, contemporary spaces. Confirm actual specifications before publishing.','Price on inquiry','draft',6),
('sapphire-tradition','Sapphire Tradition','Traditional','Confirm dimensions','Confirm with Uqaab team','Confirm composition','Confirm care instructions','Confirm construction','A blue-toned traditional concept with a balanced ornamental field. Confirm actual specifications before publishing.','Price on inquiry','draft',7),
('emerald-afghan','Emerald Afghan','Traditional','Confirm dimensions','Confirm with Uqaab team','Confirm composition','Confirm care instructions','Confirm construction','A rich green palette concept for distinctive interiors. Confirm actual specifications before publishing.','Price on inquiry','draft',8),
('heritage-runner','Heritage Runner','Runner','Confirm dimensions','Confirm with Uqaab team','Confirm composition','Confirm care instructions','Confirm construction','An elongated format concept for corridors and transitional spaces. Confirm actual specifications before publishing.','Price on inquiry','draft',9),
('round-medallion','Round Medallion','Special format','Confirm dimensions','Confirm with Uqaab team','Confirm composition','Confirm care instructions','Confirm construction','A circular medallion concept for a focused interior statement. Confirm actual specifications before publishing.','Price on inquiry','draft',10),
('grand-palace','Grand Palace','Large format','Confirm dimensions','Confirm with Uqaab team','Confirm composition','Confirm care instructions','Confirm construction','A large-format concept for generous rooms and hospitality settings. Confirm actual specifications before publishing.','Price on inquiry','draft',11),
('vintage-revival','Vintage Revival','Vintage inspired','Confirm dimensions','Confirm with Uqaab team','Confirm composition','Confirm care instructions','Confirm construction','A softly aged visual concept with a muted palette. Confirm actual specifications before publishing.','Price on inquiry','draft',12),
('modern-afghan','Modern Afghan','Contemporary','Confirm dimensions','Confirm with Uqaab team','Confirm composition','Confirm care instructions','Confirm construction','A contemporary concept combining restrained geometry and texture. Confirm actual specifications before publishing.','Price on inquiry','draft',13),
('silk-accent','Silk Accent','Premium concept','Confirm dimensions','Confirm with Uqaab team','Confirm composition','Confirm care instructions','Confirm construction','A fine-detail concept; material composition must be confirmed before publishing.','Price on inquiry','draft',14),
('bespoke-signature','Bespoke Signature','Custom','Confirm dimensions','Confirm with Uqaab team','Confirm composition','Confirm care instructions','Confirm construction','A custom-order concept developed around buyer requirements. Confirm feasibility before publishing.','Price on inquiry','draft',15)
on conflict (slug) do nothing;
