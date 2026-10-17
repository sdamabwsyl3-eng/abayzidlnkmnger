-- أبا يزيد لنك منجر: جداول قاعدة البيانات الحقيقية + سياسات أمان الصفوف (RLS)
-- آمن للتشغيل أكثر من مرة (idempotent) — شغّله كامل من: Supabase Dashboard -> SQL Editor -> New query -> Run

-- 1) جدول الملف الشخصي لمشغّل الشبكة (مرتبط تلقائياً بكل حساب يسجّل)
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null default '',
  region text not null default '',
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "profiles are self-readable" on public.profiles;
create policy "profiles are self-readable"
  on public.profiles for select
  using (auth.uid() = id);

drop policy if exists "users can update their own profile" on public.profiles;
create policy "users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- إنشاء صف profile تلقائياً عند تسجيل أي حساب جديد
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', ''));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 2) جدول باقات الكروت (قابلة للتعديل، كل مشغّل له قائمته الخاصة)
create table if not exists public.packages (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  name text not null,
  subtitle text not null default '',
  duration_days integer not null default 30,
  price numeric(12, 2) not null,
  currency text not null default 'SDG',
  created_at timestamptz not null default now()
);

alter table public.packages enable row level security;

drop policy if exists "owners manage their packages" on public.packages;
create policy "owners manage their packages"
  on public.packages for all
  using (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);

-- 3) جدول الكروت المولّدة فعلياً (كل كرت له كود فريد وحالة)
create table if not exists public.cards (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  package_id uuid not null references public.packages (id) on delete cascade,
  code text not null unique,
  status text not null default 'unused', -- unused | sold | used
  created_at timestamptz not null default now()
);

alter table public.cards enable row level security;

drop policy if exists "owners manage their cards" on public.cards;
create policy "owners manage their cards"
  on public.cards for all
  using (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);

-- 4) جدول عناصر المتجر (باقات Starlink، أجهزة، مستلزمات)
create table if not exists public.store_items (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  category text not null default 'starlink', -- starlink | device
  name text not null,
  subtitle text not null default '',
  price numeric(12, 2) not null,
  currency text not null default 'USD',
  created_at timestamptz not null default now()
);

alter table public.store_items enable row level security;

drop policy if exists "owners manage their store items" on public.store_items;
create policy "owners manage their store items"
  on public.store_items for all
  using (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);

-- 5) جدول طلبات الشراء من المتجر
create table if not exists public.store_orders (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  item_id uuid not null references public.store_items (id) on delete cascade,
  quantity integer not null default 1,
  status text not null default 'قيد المراجعة',
  created_at timestamptz not null default now()
);

alter table public.store_orders enable row level security;

drop policy if exists "owners manage their store orders" on public.store_orders;
create policy "owners manage their store orders"
  on public.store_orders for all
  using (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);
