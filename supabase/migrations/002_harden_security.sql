-- Security hardening for CALIDAD OPERATIVA.
-- Restrict helper execution and scope policies to signed-in users.
create policy regions_visibility on public.regions for select to authenticated
using (
  public.current_role()='admin'
  or exists(select 1 from public.coordinator_regions cr where cr.region_id=regions.id and cr.coordinator_id=auth.uid())
  or exists(select 1 from public.stores s join public.store_assignments sa on sa.store_id=s.id where s.region_id=regions.id and sa.collaborator_id=auth.uid() and sa.active=true)
);

create policy admin_manage_regions on public.regions for all to authenticated
using(public.current_role()='admin') with check(public.current_role()='admin');

create policy coordinator_region_visibility on public.coordinator_regions for select to authenticated
using(coordinator_id=auth.uid() or public.current_role()='admin');

revoke execute on function public.current_role() from public, anon;
grant execute on function public.current_role() to authenticated;
