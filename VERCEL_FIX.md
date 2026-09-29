# CALIDAD OPERATIVA — V4.2 STABLE BUILD FIX

## Error corregido
Vercel estaba recibiendo el repositorio con estas dos rutas:

- `app/login/page.tsx` → `/login`
- `app/(auth)/login/page.tsx` → `/login`

Next.js App Router trata `(auth)` como route group y no lo incluye en la URL, por lo que las dos páginas chocan en `/login`.

## Protección adicional V4.2
Además de entregar el proyecto sin la ruta duplicada, `npm run build` ejecuta automáticamente `scripts/prepare-build.mjs` mediante `prebuild`.

Ese prebuild:

1. Elimina cualquier copia residual de `app/(auth)/login` antes de compilar.
2. Comprueba que exista `app/login/page.tsx`.
3. Escanea las páginas del App Router y detiene el build si encuentra otra colisión de rutas.

Esto evita que una subida de archivos sobre un repositorio existente deje una copia antigua que vuelva a romper Vercel.

## Supabase
Se conserva el flujo de autenticación corregido:

1. `signInWithPassword` primero.
2. Consulta de `public.profiles` después de autenticar.
3. Cierre de sesión si el perfil no existe o está inactivo.

El proyecto usa exclusivamente el Supabase independiente de `CALIDAD OPERATIVA`.
