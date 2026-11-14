-- Commerce schema for a Shopify-style store on Supabase.
-- Idempotent: safe to run repeatedly (SQL editor, migration, or an edge-function bootstrap).
-- Orders are written only by a server function using the service role.

create table if not exists public.products (
  slug text primary key,
  name text not null,
  tagline text not null default '',
  description text not null default '',
  price numeric not null default 0,
  compare_at numeric,
  sku text,
  stock integer not null default 0,
  status text not null default 'active' check (status in ('active','draft','archived')),
  variants jsonb not null default '[]'::jsonb,   -- [{id, option1, option2, sku, stock, image, color}]
  image text not null default '',
  gallery jsonb not null default '[]'::jsonb,
  collection text,
  product_type text,
  vendor text not null default '',
  badge text,
  tags jsonb not null default '[]'::jsonb,
  features jsonb not null default '[]'::jsonb,
  rating numeric not null default 0,
  review_count integer not null default 0,
  sort integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.collections (
  slug text primary key,
  name text not null,
  description text not null default '',
  image text not null default '',
  sort integer not null default 0,
  created_at timestamptz not null default now()
);

create sequence if not exists public.order_number_seq start 1001;

create table if not exists public.orders (
  id bigint generated always as identity primary key,
  order_number text not null unique,            -- e.g. 'ST-' || nextval('order_number_seq')
  email text not null,
  phone text,
  customer_name text,
  address jsonb not null default '{}'::jsonb,   -- {line1, line2, city, region, postal, country}
  payment_method text not null default 'cod',
  payment_status text not null default 'unpaid' check (payment_status in ('unpaid','paid','refunded')),
  status text not null default 'pending'
    check (status in ('pending','confirmed','dispatched','delivered','completed','returned','cancelled')),
  shipping_method text not null default 'standard',
  shipping_label text,
  subtotal numeric not null default 0,
  discount numeric not null default 0,
  discount_code text,
  shipping numeric not null default 0,
  total numeric not null default 0,
  note text,
  email_sent boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id bigint generated always as identity primary key,
  order_id bigint not null references public.orders(id) on delete cascade,
  slug text not null,
  name text not null,
  variant_id text,
  variant_name text,
  qty integer not null check (qty > 0),
  unit_price numeric not null,
  line_total numeric not null
);

create table if not exists public.discounts (
  code text primary key,
  type text not null check (type in ('percent','fixed')),
  value numeric not null,
  active boolean not null default true,
  min_subtotal numeric not null default 0,
  uses integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.settings (
  key text primary key,          -- 'store' -> {name, address, phone, email, currency, receipt_footer}
  value jsonb not null default '{}'::jsonb  -- 'shipping' -> {standard, express, free_over}
);

create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text,
  created_at timestamptz not null default now()
);

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where user_id = auth.uid())
$$;

-- RLS: admins get everything; the public gets the active catalog only.
do $$
declare t text;
begin
  foreach t in array array['products','collections','orders','order_items','discounts','settings','admins'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists admin_all on public.%I', t);
    execute format('create policy admin_all on public.%I for all to authenticated using (public.is_admin()) with check (public.is_admin())', t);
  end loop;
end $$;

drop policy if exists public_read on public.products;
create policy public_read on public.products for select to anon, authenticated using (status = 'active');
drop policy if exists public_read on public.collections;
create policy public_read on public.collections for select to anon, authenticated using (true);

-- Realtime feed for the admin (RLS still applies to subscribers).
do $$ begin
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and tablename = 'orders') then
    alter publication supabase_realtime add table public.orders;
  end if;
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and tablename = 'products') then
    alter publication supabase_realtime add table public.products;
  end if;
end $$;

-- Public bucket for product media; writes go through admin-signed upload URLs.
insert into storage.buckets (id, name, public)
values ('product-media', 'product-media', true)
on conflict (id) do nothing;

-- Make the first admin (after creating the user in Auth):
-- insert into public.admins (user_id, email) select id, email from auth.users where email = 'owner@example.com';
