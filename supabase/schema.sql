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

-- 6) رصيد الكروت (العداد الظاهر في شاشة توليد الكروت) — كل عملية توليد كروت
-- تخصم من الرصيد، وكل طلب شحن موافَق عليه يضيف له.
alter table public.profiles
  add column if not exists card_credit_balance integer not null default 0;

-- 7) قوالب تصميم الكروت (قسم "تخصيص الكرت" عند توليد كروت جديدة)
create table if not exists public.card_templates (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  name text not null,
  thumbnail_url text,
  created_at timestamptz not null default now()
);

alter table public.card_templates enable row level security;

drop policy if exists "owners manage their card templates" on public.card_templates;
create policy "owners manage their card templates"
  on public.card_templates for all
  using (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);

-- 8) أعمدة إضافية على الكروت: القالب المستخدم، طول الكود المختار لكل دفعة،
-- وعنوان MAC الجهاز اللي اتقفل عليه الكرت أول ما يتفعّل (قفل الكرت على جهاز واحد)
alter table public.cards
  add column if not exists template_id uuid references public.card_templates (id) on delete set null,
  add column if not exists code_length integer not null default 12,
  add column if not exists locked_device_mac text;

-- 9) أجهزة MikroTik المرتبطة بكل مشغّل. بيانات دخول الراوتر (IP/يوزر/باسورد)
-- ما بتتخزن هنا أبداً — دي بتفضل محلياً على جهاز المشغّل فقط (شاشة الإعدادات).
-- هذا الجدول بيانات وصفية بس (الموديل، حالة الربط) لعرضها في لوحة التحكم.
create table if not exists public.devices (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  name text not null,
  model text,
  setup_mode text not null default 'fresh_wipe'
    check (setup_mode in ('fresh_wipe', 'adopt_existing')),
  status text not null default 'setting_up'
    check (status in ('linked', 'setting_up', 'offline')),
  created_at timestamptz not null default now()
);

alter table public.devices enable row level security;

drop policy if exists "owners manage their devices" on public.devices;
create policy "owners manage their devices"
  on public.devices for all
  using (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);

-- 10) طلبات شحن رصيد الكروت — تحويل يدوي (بنكك / تحويل بنكي) بموافقة أدمن.
-- المشغّل يرسل طلب برقم مرجع التحويل، وحالته "قيد المراجعة" لحد ما يراجعها
-- الأدمن يدوياً من لوحة Supabase ويغيّر status إلى 'approved' — عندها الـ trigger
-- تحت بيضيف الرصيد تلقائياً لحساب المشغّل.
create table if not exists public.credit_topup_requests (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  requested_credits integer not null check (requested_credits > 0),
  payment_method text not null default 'بنكك', -- بنكك | تحويل بنكي | أخرى
  reference_note text not null default '',
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz not null default now(),
  reviewed_at timestamptz
);

alter table public.credit_topup_requests enable row level security;

-- المشغّل يقدر يشوف طلباته وينشئ طلب جديد بس — مش يعدّل حالتها (الموافقة أدمن فقط،
-- يدوياً من Supabase Dashboard بصلاحيات أعلى من الـ RLS دي).
drop policy if exists "owners view their topup requests" on public.credit_topup_requests;
create policy "owners view their topup requests"
  on public.credit_topup_requests for select
  using (auth.uid() = owner_id);

drop policy if exists "owners create topup requests" on public.credit_topup_requests;
create policy "owners create topup requests"
  on public.credit_topup_requests for insert
  with check (auth.uid() = owner_id and status = 'pending');

-- عند الموافقة على طلب شحن، تُضاف الكروت لرصيد المشغّل تلقائياً.
create or replace function public.handle_credit_topup_approved()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if new.status = 'approved' and old.status is distinct from 'approved' then
    update public.profiles
      set card_credit_balance = card_credit_balance + new.requested_credits
      where id = new.owner_id;
    new.reviewed_at = now();
  end if;
  return new;
end;
$$;

drop trigger if exists on_credit_topup_approved on public.credit_topup_requests;
create trigger on_credit_topup_approved
  before update on public.credit_topup_requests
  for each row execute procedure public.handle_credit_topup_approved();
