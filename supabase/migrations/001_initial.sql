create extension if not exists pgcrypto;
create type public.app_role as enum ('admin','coordinador','colaborador');

create table public.profiles(
 id uuid primary key references auth.users(id) on delete cascade,
 username text unique not null,
 full_name text not null,
 role public.app_role not null default 'colaborador',
 active boolean not null default true,
 created_at timestamptz not null default now()
);
create table public.regions(id uuid primary key default gen_random_uuid(),name text not null,active boolean not null default true,created_at timestamptz not null default now());
create table public.stores(
 id uuid primary key default gen_random_uuid(),
 region_id uuid not null references public.regions(id) on delete restrict,
 code text not null unique,
 name text not null,
 address text,
 opening_date date not null,
 daily_opening_target numeric(12,2) not null default 0,
 weekly_budget numeric(12,2) not null default 0,
 active boolean not null default true,
 created_at timestamptz not null default now()
);
create table public.coordinator_regions(coordinator_id uuid references public.profiles(id) on delete cascade,region_id uuid references public.regions(id) on delete cascade,primary key(coordinator_id,region_id));
create table public.store_assignments(store_id uuid references public.stores(id) on delete cascade,collaborator_id uuid references public.profiles(id) on delete cascade,assignment_order smallint not null check(assignment_order in(1,2)),active boolean not null default true,primary key(store_id,collaborator_id));
create unique index one_primary_assignment_per_store on public.store_assignments(store_id) where assignment_order=1 and active=true;
create table public.opening_hourly_sales(
 id uuid primary key default gen_random_uuid(),
 store_id uuid not null references public.stores(id) on delete cascade,
 collaborator_id uuid not null references public.profiles(id) on delete restrict,
 sale_date date not null,
 sale_hour smallint not null check(sale_hour between 0 and 23),
 amount numeric(12,2) not null check(amount>=0),
 created_at timestamptz not null default now(),
 unique(store_id,sale_date,sale_hour)
);
create table public.weekly_sales(
 id uuid primary key default gen_random_uuid(),
 store_id uuid not null references public.stores(id) on delete cascade,
 collaborator_id uuid not null references public.profiles(id) on delete restrict,
 week_start date not null,
 sale_date date not null,
 amount numeric(12,2) not null check(amount>=0),
 daily_budget numeric(12,2) not null default 0,
 created_at timestamptz not null default now(),
 unique(store_id,sale_date)
);

alter table public.profiles enable row level security;
alter table public.regions enable row level security;
alter table public.stores enable row level security;
alter table public.coordinator_regions enable row level security;
alter table public.store_assignments enable row level security;
alter table public.opening_hourly_sales enable row level security;
alter table public.weekly_sales enable row level security;

create or replace function public.current_role() returns public.app_role language sql stable security definer set search_path=public as $$select role from public.profiles where id=auth.uid();$$;

create policy profiles_self_or_admin on public.profiles for select using(id=auth.uid() or public.current_role()='admin');
create policy admin_manage_profiles on public.profiles for all using(public.current_role()='admin') with check(public.current_role()='admin');
create policy store_visibility on public.stores for select using(
 public.current_role()='admin'
 or exists(select 1 from public.coordinator_regions cr where cr.coordinator_id=auth.uid() and cr.region_id=stores.region_id)
 or exists(select 1 from public.store_assignments sa where sa.store_id=stores.id and sa.collaborator_id=auth.uid() and sa.active=true)
);
create policy store_assignment_visibility on public.store_assignments for select using(
 public.current_role()='admin' or collaborator_id=auth.uid()
 or exists(select 1 from public.stores s join public.coordinator_regions cr on cr.region_id=s.region_id where s.id=store_assignments.store_id and cr.coordinator_id=auth.uid())
);
create policy opening_sales_access on public.opening_hourly_sales for all using(
 public.current_role()='admin' or collaborator_id=auth.uid()
 or exists(select 1 from public.stores s join public.coordinator_regions cr on cr.region_id=s.region_id where s.id=opening_hourly_sales.store_id and cr.coordinator_id=auth.uid())
) with check(public.current_role()='admin' or collaborator_id=auth.uid());
create policy weekly_sales_access on public.weekly_sales for all using(
 public.current_role()='admin' or collaborator_id=auth.uid()
 or exists(select 1 from public.stores s join public.coordinator_regions cr on cr.region_id=s.region_id where s.id=weekly_sales.store_id and cr.coordinator_id=auth.uid())
) with check(public.current_role()='admin' or collaborator_id=auth.uid());

-- Passwords live only in Supabase Auth; never store passwords in profiles.
