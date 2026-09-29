# CALIDAD OPERATIVA 🥇 — GitHub / Vercel / Supabase V2

Proyecto completamente independiente de `app1`, `Código Qr` y `grupo-jdo-services`.

## Backend dedicado
- Supabase project: `CALIDAD OPERATIVA`
- Project ref: `uykzanpyakexfaaxjzrp`
- Región: `us-east-2`
- URL: `https://uykzanpyakexfaaxjzrp.supabase.co`
- Auth: Supabase Auth
- Database: PostgreSQL + RLS

## Seguridad V2
La función de autorización `current_role()` ya no queda expuesta en `public`.
La versión V2:
1. crea `private.current_role()`;
2. limita su ejecución a usuarios autenticados;
3. actualiza las políticas RLS para usar `private.current_role()`;
4. elimina la función antigua `public.current_role()`.

El asesor de seguridad del proyecto dedicado quedó sin lints después de esta modificación.

## Variables
`.env.example` contiene solamente la URL pública y la publishable key del proyecto dedicado. Nunca agregues `service_role` ni claves secretas al frontend.

## Roles
- Administrador
- Coordinador
- Colaborador

## Actividades
1. Venta 1 — Día de Apertura: captura hora por hora.
2. Venta 2 — Seguimiento semanal: captura diaria.

## Integraciones previstas
- GitHub: repositorio nuevo, separado de `app1`.
- Vercel: proyecto nuevo para este repositorio.
- Context7: documentación actual de Next.js y Supabase SSR.
- Create State: World Model `CALIDAD OPERATIVA` creado para conservar arquitectura, decisiones y avances.

## Estado de esta V2
Esta entrega es la base técnica. El dashboard incluido sigue mostrando datos de demostración y el endpoint de login es un scaffold; la implementación completa de Auth, captura Venta 1/Venta 2, tiempo real y exportación PDF/Excel se construirá encima de esta base.

## Desarrollo
```bash
npm install
npm run dev
```

## Despliegue
Configura las variables de `.env.example` en Vercel y conecta este repositorio nuevo.


## V3 — Login real con Supabase Auth
Se eliminó el endpoint de login que devolvía `503 Configura Supabase Auth`.
Ahora busca `Admin1` en `public.profiles`, valida que esté activo y autentica contra Supabase Auth mediante `admin1@calidad-operativa.local`, usando cookies SSR.
El usuario de Auth y su registro en `public.profiles` deben existir antes del acceso.
