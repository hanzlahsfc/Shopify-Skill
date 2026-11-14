# Storefront: replicate Shopify Dawn

Dawn is Shopify's default theme; millions of real stores use it, so matching it is what
makes a site read as "a Shopify store". Copy its structure, measurements and behaviour.

## Layout system

- Page width: `max-width: 1200px` + side padding **15px mobile / 50px >=750px**.
- Breakpoints: **750px** (tablet) and **990px** (desktop). Don't invent others except a
  480px tweak for tiny phones.
- Section vertical rhythm: 36px mobile / 48px desktop. Alternate sections may use `#f3f3f3`.
- Font: Assistant (Dawn default) or the system sans stack. Body 15px/16px, line-height 1.8,
  letter-spacing .06em, colour `rgba(18,18,18,.75)`. Headings weight 400, letter-spacing
  .06em; h1 30/40px, h2 20/24px, h3 17/18px. Hero `h0` 40/52px.
- Captions: 13px, uppercase variants use letter-spacing .13em.

## Components (see `assets/dawn-base.css`)

- **Button**: radius 0, min-height 45px, padding 0 30px, letter-spacing .1em, solid
  `rgb(18,18,18)` with `box-shadow: 0 0 0 1px`; hover grows shadow to 2px. Secondary =
  white with dark border. Full width on PDP/cart/checkout.
- **Field**: 45px, `box-shadow: 0 0 0 1px rgba(18,18,18,.55)`, floating label that shrinks
  to 10px at `top:4px` on focus / `:not(:placeholder-shown)` (use `placeholder=" "`).
- **Badge**: pill (the one rounded element), 12px, dark or sale-blue `#334fb4`.
- **Price**: `Rs 14,999` / `$259.00`; sale shows compare-at struck through + "Sale" badge.
- **Icons**: 20px stroke icons in 44px hit areas (search, account, cart with count bubble).

## Page anatomy

**Announcement bar**: one short line, 13px, optional rotating messages. Must fit one line
on 390px (drop secondary messages under 560px).

**Header**: logo left (or centred on mobile), inline menu (desktop), icons right; hamburger
drawer on mobile. Sticky. Must stay one row at every width - put nav+icons in one grid cell.
Predictive search modal: products with thumbnail + price as you type, "Search for 'x'" row.

**Home** (Dawn sections, in this order is fine):
1. Image banner (full-bleed photo, heading, 1-2 buttons). No arches, no floating chips.
2. Featured collection (4-up desktop / 2-up mobile grid + "View all").
3. Image with text.
4. Collection list (3 tiles).
5. Multicolumn (shipping / returns / warranty / payment, short text, small icons).
6. Testimonials or rich text.
7. Newsletter (email field with arrow button).

**Collection page**: title, product count, facets - desktop dropdowns (Availability, Price
range, Product type) + Sort by; mobile "Filter and sort" drawer; active-filter pills with
"Remove all". Grid 4/3/2 columns. Empty state text + "Clear filters".

**Product card**: square media (`aspect-ratio:1`), primary image + second image fades in on
hover, scale 1.03; badge bottom-left ("Sale", "Sold out", "New"); title 14/15px with link
overlay covering the whole card; rating stars + count; price; optional swatches; optional
"Quick add" button. Variant line truncates to one line with ellipsis on mobile.

**Product page (PDP)**:
- Left: media gallery (main + thumbnails; variant selection swaps the main image).
  Mobile: swipeable slider with dots.
- Right (sticky on desktop): vendor caption, title, rating, price, "Tax included. Shipping
  calculated at checkout.", variant option pills (Option 1 / Option 2; unavailable combos
  struck through; single-value options collapse to a caption), quantity stepper,
  **Add to cart** (secondary) + **Buy it now** (primary), pickup/delivery note, collapsible
  tabs (Description, Materials, Shipping & returns, Care), Share.
- Below: "You may also like" (4-up / 2-up), recently viewed optional.
- Mobile sticky add-to-cart bar after scrolling past the buy buttons.
- SKU and stock are per variant ("Only 3 left" under 5).

**Cart drawer**: slides from right, header "Your cart" + close, line items (thumb, title,
variant, unit price, qty stepper, remove icon), estimated total, "Taxes, discounts and
shipping calculated at checkout.", Check out button, optional free-shipping progress bar.
Empty state with "Continue shopping". Also a `/cart` page if you can.

**Checkout** (standalone, no store header/footer - like Shopify checkout):
- Two columns: form left, order summary right (grey `#f5f5f5` panel, sticky); on mobile the
  summary collapses into a "Show order summary" toggle at the top.
- Logo aligned with the form column, breadcrumb (Cart > Information > Shipping > Payment)
  or one-page sections: Contact, Delivery (country, first/last name, address, apartment,
  city, region select, postal code, phone), Shipping method (radio cards with prices),
  Payment (radio cards; COD/cards/wallets), Billing address same as shipping, Pay now /
  Complete order.
- Discount code field in the summary, validated server-side.
- Thank-you page: "Thank you, {name}!", order number, map/address, items, totals, "Continue
  shopping".

**Content pages**: About, Contact (Dawn contact form), FAQ (accordion), Policies (Shipping &
returns, Privacy, Terms) rendered as rich text in `page-width--narrow`. Footer: link columns
(Shop / Company / Support), newsletter, payment icons, country/currency, copyright.

## Imagery rules

- Product shots: identical canvas, white background, same subject scale and centring.
  Normalize with `sharp`: flatten near-background pixels to white, trim, resize to fit
  ~78% width / ~62% height, extend to 1200x1200 white. Re-check outliers by measuring the
  subject bounding box.
- Lifestyle images only in banners / image-with-text / gallery slots, never mixed into the grid.
- Variant images named predictably (`<slug>-<variant>.jpg`) so variants can swap images.
- Always `alt` text = product + variant.

## Copy

Short, concrete, policy-style. "Free shipping over Rs 8,000 · Cash on delivery · 30-day
returns". Product descriptions 2-3 sentences + bullet features. No superlatives stacks, no
"elevate your style", no em dashes, no emoji.
