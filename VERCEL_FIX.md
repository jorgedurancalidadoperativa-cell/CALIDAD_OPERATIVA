# CALIDAD OPERATIVA — V4.1 FIX

Corrección crítica de build para Next.js App Router.

Se eliminó la ruta duplicada `app/(auth)/login/page.tsx`.
La única página que resuelve `/login` es `app/login/page.tsx`.

También se conserva el flujo corregido de Supabase Auth:
1. Autenticar con `signInWithPassword`.
2. Consultar `public.profiles` después de autenticar.
3. Cerrar sesión si no existe el perfil o está inactivo.

No se modifica ni depende de `app1` ni de los proyectos de Supabase ajenos a CALIDAD OPERATIVA.
