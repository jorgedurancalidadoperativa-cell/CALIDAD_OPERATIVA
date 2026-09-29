import { NextResponse } from "next/server";
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

export async function POST(request: Request) {
  const form = await request.formData();
  const username = String(form.get("username") ?? "").trim();
  const password = String(form.get("password") ?? "");

  if (!username || !password) {
    return NextResponse.json({ error: "Usuario y contraseña son obligatorios." }, { status: 400 });
  }

  const cookieStore = await cookies();
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,
    {
      cookies: {
        getAll() { return cookieStore.getAll(); },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) => cookieStore.set(name, value, options));
        },
      },
    }
  );

  const { data: profile, error: profileError } = await supabase
    .from("profiles")
    .select("id, username, full_name, role, active")
    .eq("username", username)
    .maybeSingle();

  if (profileError || !profile) {
    return NextResponse.json({ error: "Usuario o contraseña incorrectos." }, { status: 401 });
  }
  if (!profile.active) {
    return NextResponse.json({ error: "El usuario está inactivo." }, { status: 403 });
  }

  const email = `${username.toLowerCase()}@calidad-operativa.local`;
  const { error: authError } = await supabase.auth.signInWithPassword({ email, password });

  if (authError) {
    return NextResponse.json({ error: "Usuario o contraseña incorrectos." }, { status: 401 });
  }

  return NextResponse.json({
    ok: true,
    user: { username: profile.username, full_name: profile.full_name, role: profile.role },
  });
}
