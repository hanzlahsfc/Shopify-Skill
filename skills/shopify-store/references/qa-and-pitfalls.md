# QA gate and known pitfalls

## Gate (run before every hand-off and again on production)

1. `npm run build` clean; every route exported (storefront + every admin route).
2. Browser captures at **390, 800, 1280px** of home, collection, PDP, cart drawer,
   checkout, thank-you, and every admin page **while logged in**. Look for: header wrapping,
   uneven product images, cramped 3-across grids at tablet, horizontal scroll, clipped
   sticky bars, double labels in selects.
3. Capture **console + page errors** on each of those routes. Zero is the bar. A blank
   or near-empty screenshot means a client crash ("Application error: a client-side
   exception has occurred").
4. End-to-end: PDP -> choose variant -> add to cart -> drawer -> checkout -> apply discount
   -> place COD order -> thank-you shows server total -> order appears live in admin ->
   stock decremented for that variant -> receipt prints -> email sent (if configured).
5. Security with the anon key: products readable (active only), orders/settings/
   discounts/admins return `[]` or 401, upload signing denied. With a non-allowlisted
   signed-in user: same denials.
6. Grep visible copy for `—` (em dash), "Lorem", "TODO", `href="#"`, wrong currency
   symbols, and old prices.
7. Deploy, wait for Ready, curl all routes for 200, re-run step 3 on production.

## Pitfalls we actually hit

- **Header on two rows**: grid had more children than columns. Wrap nav + icons in one cell.
- **"Out of sync" product grid**: mixed grey/white backgrounds and different subject
  scales; landscape `object-fit: cover` cropping square images. Fix with image
  normalization and square media boxes.
- **Generic AI look**: cream/terracotta palette, serif display font, arch hero, floating
  chips, marquee, eyebrow labels, grain. Users spot it instantly. Use Dawn defaults.
- **Realtime crash**: two components subscribing to the same channel name -> page crash.
  Unique channel per subscription.
- **RLS too loose**: "authenticated = admin" while sign-ups are open lets anyone read
  orders. Use an admin allowlist function.
- **PostgREST `PGRST205` table not found** right after deploying: the function's bootstrap
  hasn't run yet. Invoke it once, then seed.
- **Server/client boundary** (Next.js): don't pass component functions (e.g. icon
  components) from server to client components; pass rendered elements.
- **`useSearchParams` in static export** needs a `<Suspense>` boundary.
- **Shell heredocs truncate long files** on Windows/Git Bash; write large files with the
  file tool or a script file, then verify line counts.
- **Sequential price replacements** corrupted values (15999 -> 999999). Rewrite prices
  explicitly and re-check every rendered price.
- **CRLF** line endings break exact-match patches; match newline-agnostically.
- **Supabase CLI "Cannot find project ref"**: pass `--project-ref` explicitly.
- **Stale cart** from an older catalog: filter unknown slugs, fall back to first variant.
- **Admin edits not visible** on a static site: live fields refresh client-side, but new
  products/slugs need a rebuild via deploy hook.
- **Committing screenshots / temp CLI folders**: gitignore them before `git add -A`.
