"use client";
import {FormEvent,useState} from "react";
import {LogIn} from "lucide-react";

export default function LoginForm(){
 const [loading,setLoading]=useState(false),[error,setError]=useState("");
 async function submit(e:FormEvent<HTMLFormElement>){
  e.preventDefault();
  setLoading(true);
  setError("");
  try{
   const r=await fetch("/api/auth/login",{method:"POST",body:new FormData(e.currentTarget)});
   const body=await r.json().catch(()=>({}));
   if(!r.ok){setError(body.error ?? "No fue posible iniciar sesión.");setLoading(false);return;}
   window.location.href="/dashboard";
  }catch{
   setError("No fue posible conectar con el servidor.");
   setLoading(false);
  }
 }
 return <main style={{minHeight:"100vh",display:"grid",placeItems:"center",padding:20}}><form onSubmit={submit} style={{width:"100%",maxWidth:390,background:"#fff",border:"1px solid #e2e6ea",borderRadius:20,padding:28}}><div style={{fontSize:38}}>🥇</div><h1 style={{margin:"8px 0 4px"}}>CALIDAD OPERATIVA</h1><p className="muted">Acceso al sistema</p><label>Usuario<input name="username" required style={{display:"block",width:"100%",padding:12,margin:"6px 0 14px",border:"1px solid #d7dce1",borderRadius:10}}/></label><label>Contraseña<input name="password" type="password" required style={{display:"block",width:"100%",padding:12,margin:"6px 0 14px",border:"1px solid #d7dce1",borderRadius:10}}/></label><button disabled={loading} style={{width:"100%",padding:13,border:0,borderRadius:10,background:"#17191c",color:"#fff",fontWeight:800}}><LogIn size={17} style={{verticalAlign:"middle",marginRight:6}}/>{loading?"Entrando...":"Entrar"}</button>{error&&<p style={{color:"#b33"}}>{error}</p>}</form></main>
}
