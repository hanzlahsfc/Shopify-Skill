---
name: shopify-store
description: Build a custom e-commerce site that is indistinguishable from a real Shopify store - Dawn-theme storefront, Polaris-style admin, and a working commerce backend (orders, server-side pricing, inventory, discounts, COD, emails, receipts). Use when asked for an online store, "something like Shopify", a store that "doesn't look like AI", or a store admin/backend.
argument-hint: "[brand / product category / country]"
triggers:
  - user
  - model
---

# Shopify-grade store

Goal: a store where **nobody could tell it isn't on Shopify**. That means copying Shopify's
real conventions (Dawn theme for the storefront, Polaris for the admin, Shopify checkout
behaviour) rather than "designing" something. Originality is the enemy here: every custom
flourish is a tell.

Read the references before building the matching part:

| Building | Read |
|---|---|
| Storefront (home, collection, PDP, cart, checkout) | `references/storefront-dawn.md` |
| Admin panel | `references/admin-polaris.md` |
| Orders, inventory, DB, auth, email, deploy | `references/backend-commerce.md` |
| Currency, address, payment for a country | `references/localization.md` |
| Before every hand-off | `references/qa-and-pitfalls.md` |

Assets (copy and adapt, don't rewrite from scratch):

- `assets/dawn-base.css` - Dawn tokens, type scale, buttons, floating-label fields, cards, price, badges
- `assets/polaris-admin.css` - Polaris frame, cards, tables, tabs, badges, forms
- `assets/schema.sql` - products/collections/orders/discounts/settings/admins + RLS + realtime

## Workflow

1. **Pin the brief** (ask only what you can't infer): brand name, product category,
   country/currency, payment methods (COD? cards?), whether an admin/backend is needed,
   hosting. Default stack: Next.js App Router static export + Supabase + Vercel.
2. **Catalog first.** One typed product model (`slug, name, price, compareAt, variants
   [{id, option1, option2, image, stock, sku}], images[], collection, tags, status`). All
   UI reads from it. Keep a static fallback file, but treat the DB as the source of truth
   once a backend exists.
3. **Storefront** exactly per `storefront-dawn.md`. Route group `(store)` for pages with
   header/footer; checkout and thank-you live outside it with their own minimal chrome.
4. **Photography pass.** Normalize every product shot: same canvas (e.g. 1200x1200), pure
   white background, subject trimmed and re-padded to the same fill ratio (~78% width), no
   stickers/watermarks/props. Inconsistent imagery is the #1 reason a grid looks "off".
5. **Backend** per `backend-commerce.md`: server-side order creation that re-prices from
   the DB, stock checks + decrement per variant, discount validation, order numbers,
   confirmation email, admin allowlist RLS.
6. **Admin** per `admin-polaris.md`: Home, Orders (+detail, status workflow, receipt
   print), Products (+editor with media manager and variants), Collections, Inventory,
   Customers, Discounts, Settings. Realtime new-order feed.
7. **Localize** per `localization.md` (currency format, regions, phone, payment, couriers, copy).
8. **QA gate** per `qa-and-pitfalls.md`: build, browser capture at 390/800/1280 px, console
   errors on every route (logged-in admin too), full add-to-cart -> checkout -> order -> admin
   loop, RLS checks with the anon key. Then deploy and re-check production.

## Non-negotiables (the "not AI slop" rules)

- **No** cream/terracotta palettes, serif display headlines, arch-shaped images, floating
  stat chips, marquee tickers, grain overlays, gradient blobs, glassmorphism, emoji, or an
  "eyebrow" kicker above every heading.
- **No em dashes** in visible copy. Use commas, periods, colons or a middot (`·`).
- White background, near-black text (`rgb(18,18,18)` at 75% for body), one accent at most.
  Regular-weight headings with letter-spacing, not bold display type.
- Square buttons (radius 0), 45px tall, 1px shadow-border, hover = 2px. Floating-label inputs.
- Borderless product cards, square (1:1) media, second image on hover, badge bottom-left.
- Money always via one `formatPrice()`; never hand-format a number in JSX.
- Copy is short, plain and specific ("Free shipping over Rs 8,000"), never hype.
- Every interactive element works. No dead buttons, no `href="#"`, no fake reviews counts
  that change between pages, no "Lorem".

## Done means

- Every route builds and renders with zero console errors (storefront + logged-in admin).
- Mobile 390px: header on one row, 2-up product grid, sticky add-to-cart, drawer cart, no
  horizontal scroll.
- A real order placed from the storefront appears in the admin without refresh, with the
  correct server-calculated total, decremented stock, a printable receipt, and (if
  configured) a confirmation email.
- Anonymous key cannot read orders/customers/settings; only allowlisted admins can.
- No secrets in client code or git.
