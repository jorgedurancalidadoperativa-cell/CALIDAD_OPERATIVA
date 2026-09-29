import {NextResponse} from "next/server";
export async function POST(){return NextResponse.json({error:"Supabase Auth no configurado en esta base."},{status:503})}
