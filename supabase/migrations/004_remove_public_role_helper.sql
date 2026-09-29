-- Remove the old exposed helper after all policies use private.current_role().
drop function if exists public.current_role();
