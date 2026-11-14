# Admin: replicate Shopify admin (Polaris)

Serve it at `/admin` now; map `admin.<domain>` to it later (see backend-commerce.md).
Client-rendered pages behind an auth gate; all data via Supabase with RLS.

## Visual system (see `assets/polaris-admin.css`)

- Canvas `#f1f1f1`; cards white, radius 12px, Polaris shadow (no heavy borders).
- System font, **13px** base, line-height 1.45, text `#303030`, secondary `#616161`.
- Top bar: 56px, `#1a1a1a`, logo + store name left, global search centre (rounded,
  translucent), store status + avatar right.
- Sidebar 240px: Home, Orders (count pill of pending), Products > Collections, Inventory,
  Customers, Discounts, then "Sales channels" > Online Store, and Settings/Log out at the bottom.
  Active item = white pill with bold text.
- Primary button dark `#303030`, radius 8px; secondary white with border; critical red
  `#c70a24`; links `#005bd3`.
- Badges (status): pending/unfulfilled = yellow, paid/fulfilled = green-grey, cancelled =
  grey, critical = red. Lowercase data, capitalized display.
- Page = header row (back arrow, title, status badge, actions right) + 2-column layout
  (main 2/3 + sidebar 1/3) collapsing to one column under 990px.
- Tables: flush inside a card, tabs on top ("All", per status with counts), a filter bar
  with search, whole row clickable, 13px cells, subtle row hover.
- Empty states: heading + one sentence + primary action.
- Toasts bottom-centre, dark, auto-dismiss.

## Pages and required features

**Home**: KPI cards (sales today/total, orders today, pending, COD to collect), recent
orders, low-stock list (<=5), realtime updates.

**Orders**: tabs by status, search (order #, name, email, phone, `?q=` from the top
search), columns: Order, Date, Customer, City, Total, Payment status, Fulfillment, Payment
method. New orders stream in via Realtime with a toast.

**Order detail**: line items with image/variant/qty/price, totals (subtotal, discount with
code, shipping, total), customer card (email, phone, link to other orders), address,
note, timeline. Actions: status workflow select with a hint per status, mark paid / COD
collected, print receipt (80mm thermal) and invoice (A4), cancel.
COD workflow: `pending -> confirmed -> dispatched -> delivered -> completed`, plus
`returned` and `cancelled`. Completing a COD order marks it paid.

**Receipt / invoice** (`/admin/receipt?id=&type=thermal|a4`): auth-gated but without the
admin chrome, `@media print` CSS, `@page { size: 80mm auto; margin: 0 }` for thermal,
store header from Settings, items, totals, payment line ("COLLECT ON DELIVERY: Rs x"),
footer text from Settings, auto `window.print()`.

**Products list**: tabs All/Active/Draft/Archived, search, checkbox bulk actions (set
active, set draft, archive, delete), thumbnail, title, status badge, inventory
("24 in stock for 3 variants", red when 0), type, vendor. "Add product" button.

**Product editor** (`/admin/product?slug=` or `?new=1`):
- Main column: Title, Subtitle, Description; **Media** card; Pricing (price, compare-at);
  Inventory (SKU, stock when no variants); **Variants** table (image, option 1, option 2,
  colours, SKU, available, remove; "+ Add variant").
- Sidebar: Status (Active/Draft/Archived with explanation), Product organization
  (collection, type, vendor, badge, tags), Reviews, Danger zone (archive / delete).
- Sticky "Unsaved changes" bar with Discard / Save when dirty. Duplicate + View actions.
- Saving writes the DB row, then triggers a storefront publish if the site is statically built.

**Media manager**: multi-file upload (click + drag-and-drop), progress, drag to reorder,
first image = main (badge "Main"), set as main, delete (also removes the storage object),
add from URL. Uploads go to a public storage bucket through **signed upload URLs issued by
an admin-only endpoint** - never expose the service key.

**Collections**: list with image + product count; editor with title, description, image
upload, product picker (search + checkboxes), sort.

**Inventory**: one row per variant (thumb, product, variant, SKU, available input),
search, "Low stock" filter, inline edit that saves on blur/Enter and keeps the product's
total stock = sum of variants.

**Customers**: aggregated from orders (name, email, phone, city, orders, total spent, last
order), search, link to their orders.

**Discounts**: code, type (percent/fixed), value, active toggle, usage; create/edit/delete.

**Settings**: store name, address, phone, email, currency, shipping rates, free-shipping
threshold, receipt footer. Read by checkout, function and receipts.

## Auth

- `/admin/login`: email + password via Supabase Auth.
- The shell checks session **and** membership in `zl_admins` (call `zl_is_admin()`); non-
  members see "No access" and are signed out. Disable public sign-ups or rely on the
  allowlist - never "any authenticated user is admin".
