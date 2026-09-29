-- Move the SECURITY DEFINER role helper out of the exposed public schema.
create schema if not exists private;

create or replace function private.current_role()
returns public.app_role
language sql stable security definer set search_path=public
as $$ select role from public.profiles where id=auth.uid(); $$;

revoke all on function private.current_role() from public, anon, authenticated;
grant execute on function private.current_role() to authenticated;

drop policy if exists profiles_self_or_admin on public.profiles;
drop policy if exists admin_manage_profiles on public.profiles;
drop policy if exists store_visibility on public.stores;
drop policy if exists store_assignment_visibility on public.store_assignments;
drop policy if exists opening_sales_access on public.opening_hourly_sales;
drop policy if exists weekly_sales_access on public.weekly_sales;
drop policy if exists regions_visibility on public.regions;
drop policy if exists admin_manage_regions on public.regions;
drop policy if exists coordinator_region_visibility on public.coordinator_regions;

create policy profiles_self_or_admin on public.profiles for select to authenticated
using(id=auth.uid() or private.current_role()='admin');

create policy admin_manage_profiles on public.profiles for all to authenticated
using(private.current_role()='admin') with check(private.current_role()='admin');

create policy store_visibility on public.stores for select to authenticated
using(
 private.current_role()='admin'
 or exists(select 1 from public.coordinator_regions cr where cr.coordinator_id=auth.uid() and cr.region_id=stores.region_id)
 or exists(select 1 from public.store_assignments sa where sa.store_id=stores.id and sa.collaborator_id=auth.uid() and sa.active=true)
);

create policy store_assignment_visibility on public.store_assignments for select to authenticated
using(
 private.current_role()='admin' or collaborator_id=auth.uid()
 or exists(select 1 from public.stores s join public.coordinator_regions cr on cr.region_id=s.region_id where s.id=store_assignments.store_id and cr.coordinator_id=auth.uid())
);

create policy opening_sales_access on public.opening_hourly_sales for all to authenticated
using(
 private.current_role()='admin' or collaborator_id=auth.uid()
 or exists(select 1 from public.stores s join public.coordinator_regions cr on cr.region_id=s.region_id where s.id=opening_hourly_sales.store_id and cr.coordinator_id=auth.uid())
)
with check(private.current_role()='admin' or collaborator_id=auth.uid());

create policy weekly_sales_access on public.weekly_sales for all to authenticated
using(
 private.current_role()='admin' or collaborator_id=auth.uid()
 or exists(select 1 from public.stores s join public.coordinator_regions cr on cr.region_id=s.region_id where s.id=weekly_sales.store_id and cr.coordinator_id=auth.uid())
)
with check(private.current_role()='admin' or collaborator_id=auth.uid());

create policy regions_visibility on public.regions for select to authenticated
using (
 private.current_role()='admin'
 or exists(select 1 from public.coordinator_regions cr where cr.region_id=regions.id and cr.coordinator_id=auth.uid())
 or exists(select 1 from public.stores s join public.store_assignments sa on sa.store_id=s.id where s.region_id=regions.id and sa.collaborator_id=auth.uid() and sa.active=true)
);

create policy admin_manage_regions on public.regions for all to authenticated
using(private.current_role()='admin') with check(private.current_role()='admin');

create policy coordinator_region_visibility on public.coordinator_regions for select to authenticated
using(coordinator_id=auth.uid() or private.current_role()='admin');
