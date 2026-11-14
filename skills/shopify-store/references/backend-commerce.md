# Backend: real commerce, not a mockup

Reference stack: **Next.js static export** (`output: "export"`, `trailingSlash: true`,
`images.unoptimized: true`) on Vercel + **Supabase** (Postgres, Auth, Storage, Realtime,
Edge Functions). Adapt the same contract to other stacks.

## Data model (`assets/schema.sql`)

`products` (slug PK, name, price, compare_at, stock, status, variants jsonb, image,
gallery jsonb, collection, tags, vendor, sort), `collections`, `orders`, `order_items`,
`discounts`, `settings` (key/value jsonb), `admins` (user_id allowlist),
`order_number_seq` starting at 1001 -> `PREFIX-1001`.

RLS:
- `anon` may **select** products where `status='active'` and collections. Nothing else.
- Everything else: `for all to authenticated using (is_admin()) with check (is_admin())`
  where `is_admin()` is a `security definer` function checking the allowlist.
- Orders are only ever **inserted by the edge function** (service role), never by the browser.

## One edge function, action-routed

`POST /functions/v1/storefront-api` with `{ action, ... }`. Bootstrap the schema
idempotently on cold start (create if not exists / add column if not exists / drop+create
policy) so a fresh project self-provisions.

- `validate-discount {code, subtotal}` -> `{ok, type, value, amount}`.
- `create-order {email, phone, name, address, shipping_method, payment_method, code, note,
  lines:[{slug, variant_id, qty}]}`:
  1. Reject empty/oversized carts, validate email/phone, clamp qty 1-10.
  2. **Re-read every product from the DB**; reject inactive/unknown; use DB price - ignore
     any client price/total.
  3. Check stock per variant (fallback product stock); return `out_of_stock` with the item.
  4. Compute subtotal, discount (server-validated code), shipping from settings (free over
     threshold), total.
  5. In one transaction: next order number, insert order + items, decrement variant stock
     and recompute product stock.
  6. Send confirmation email (Resend) if `RESEND_API_KEY` is set; record `email_sent`.
     Failure to email must not fail the order.
  7. Return `{ok, order_number, total, email_sent}`; the client clears the cart and shows
     the thank-you page.
- `admin-*` actions (verify the caller's JWT and allowlist membership first):
  `admin-sign-upload` (signed upload URL to the `product-media` bucket),
  `admin-remove-upload`, `admin-publish` (calls the Vercel deploy hook stored as a secret).
- CORS for the storefront origin; honeypot field on public forms.

## Storefront catalog

- Build time: fetch active products with the anon key to generate static pages
  (`generateStaticParams`), falling back to the bundled catalog if the DB is unreachable.
- Run time: a `CatalogProvider` refetches on load so price, stock and sold-out state are
  live without a rebuild. New products / slugs / collections need a rebuild -> admin
  "Publish" triggers the deploy hook.
- Cart in localStorage as `{slug, variant, qty}` only; resolve against the live catalog,
  drop unknown items, fall back to the first variant if a variant id disappeared.

## Realtime

Add `orders` (and `products`) to the `supabase_realtime` publication. Subscribe in the
admin with `postgres_changes`; RLS keeps the feed admin-only.
**Give every subscription a unique channel name** (`orders-live-${++seq}`): supabase-js
returns the existing channel for a reused name and throws "cannot add postgres_changes
callbacks after subscribe()" when two components subscribe - this crashes the page.
Keep handlers in a ref so the effect can run once.

## Email

Resend: `supabase secrets set RESEND_API_KEY=re_... RESEND_FROM="Brand <orders@domain>"`.
Sender domain must be verified in Resend. Template: order number, items, totals, address,
payment instructions (COD: "Please keep Rs X ready; we will call to confirm").

## Admin subdomain

`vercel.json` host rewrite, active once the domain is attached:
```json
{ "rewrites": [ { "source": "/:path((?!admin|_next).*)", "has": [{ "type": "host", "value": "admin.example.com" }], "destination": "/admin/:path" } ] }
```
The pattern excludes `/admin/*` and `/_next/*` so absolute admin links and JS chunks are not
rewritten twice. Add `admin.example.com` to the same Vercel project, point the DNS CNAME at
Vercel, then verify on the real host: `/`, a deep admin route, and that no `/_next` asset 404s.

## Secrets and env

- Browser: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY` (public by design,
  safe only because of RLS), `NEXT_PUBLIC_SUPABASE_FUNCTION_URL`.
- Server only (function secrets): service role key (auto), `SUPABASE_DB_URL` (auto),
  `RESEND_API_KEY`, `RESEND_FROM`, `VERCEL_DEPLOY_HOOK`.
- `.env*` in `.gitignore`. Grep the repo for `service_role`/`sb_secret` before every push.
- Vercel may refuse a JWT-looking `NEXT_PUBLIC_*` value; add it explicitly as a plain
  (non-sensitive) env var since the anon key is meant to be public.
