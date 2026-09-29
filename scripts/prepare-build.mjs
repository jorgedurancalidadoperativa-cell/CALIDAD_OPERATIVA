import { rm, access, readdir } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const appRoot = path.join(projectRoot, "app");
const staleDuplicate = path.join(appRoot, "(auth)", "login");
const pageNames = new Set(["page.tsx", "page.ts", "page.jsx", "page.js"]);

// The historical repository contained a duplicate /login page under a route group.
// Route groups do not change the URL, so Next.js resolves both files to /login.
// Remove the stale copy before every production build so Vercel cannot fail on it.
await rm(staleDuplicate, { recursive: true, force: true });

async function collectPages(dir, relativeDir = "") {
  const entries = await readdir(dir, { withFileTypes: true });
  const pages = [];

  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    const relPath = path.join(relativeDir, entry.name);

    if (entry.isDirectory()) {
      if (entry.name.startsWith("_") || entry.name.startsWith("@")) continue;
      pages.push(...await collectPages(fullPath, relPath));
      continue;
    }

    if (pageNames.has(entry.name)) pages.push(relPath);
  }

  return pages;
}

function normalizeRoute(pagePath) {
  const parts = pagePath.split(path.sep);
  parts.pop();

  const routeParts = parts
    .filter((part) => !part.startsWith("(") && !part.startsWith("@") && !part.startsWith("_"))
    .map((part) => part || "");

  return "/" + routeParts.filter(Boolean).join("/");
}

const pages = await collectPages(appRoot);
const routes = new Map();

for (const page of pages) {
  const route = normalizeRoute(page);
  const existing = routes.get(route);
  if (existing) {
    throw new Error(
      `Build detenido: rutas duplicadas detectadas para ${route}: ${existing} y ${page}`
    );
  }
  routes.set(route, page);
}

const loginPage = path.join(appRoot, "login", "page.tsx");
try {
  await access(loginPage);
} catch {
  throw new Error("Build detenido: falta app/login/page.tsx, la página única de /login.");
}

console.log(
  `[CALIDAD OPERATIVA] Build preflight OK: ${pages.length} páginas, ${routes.size} rutas únicas; /(auth)/login removido si existía.`
);
