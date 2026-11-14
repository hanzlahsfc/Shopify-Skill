# Shopify Skill

An agent skill for building production-grade online stores that are indistinguishable
from Shopify: a Dawn-standard storefront, a Polaris-style admin, and a secure commerce
backend with server-side pricing, per-variant inventory, discounts, cash on delivery,
confirmation emails and receipt printing.

Distilled from building and shipping a real store end to end - including the mistakes -
so your agent ships the same quality without repeating them.

## What you get

- **`shopify-store`** - the skill. Invoke it for any "build me a store" request:

  ```
  /shopify-store sunglasses brand for Pakistan, COD, with admin backend
  ```

  or just describe the store; the description makes the skill auto-trigger for agents
  that support it.

## How it works

`SKILL.md` is a short playbook that routes to deeper reference files, so the agent only
loads what it is building at that step:

```
SKILL.md                    workflow, anti-slop rules, definition of done
references/
  storefront-dawn.md        layout system, components, every page's anatomy, imagery, copy
  admin-polaris.md          the admin look and every page's features
  backend-commerce.md       schema, RLS, order function contract, realtime, email,
                            admin subdomain, secrets model
  localization.md           money formats by market + a proven Pakistan/COD preset
  qa-and-pitfalls.md        release gate + real bugs and their fixes
assets/
  dawn-base.css             Dawn tokens, buttons, floating-label fields, cards, price
  polaris-admin.css         complete Polaris-style admin stylesheet
  schema.sql                Supabase schema + admin-allowlist RLS + realtime + media bucket
```

The assets are working code, not sketches: `schema.sql` is verified idempotent
(Postgres 16) and both stylesheets come from a store deployed in production.

## Installation

### Devin CLI / Devin Desktop

```bash
devin plugins install hanzlahsfc/Shopify-Skill
```

Or copy `skills/shopify-store` into `.devin/skills/` for one project, or
`~/.config/devin/skills/` (`%APPDATA%\devin\skills\` on Windows) for all projects.

### Claude Code

Register the repo as a plugin marketplace:

```
/plugin marketplace add hanzlahsfc/Shopify-Skill
/plugin install shopify-skill@shopify-skill
```

Or copy `skills/shopify-store` into `~/.claude/skills/` or `.claude/skills/`.

### Other agents

Copy `skills/shopify-store/` anywhere your agent reads skills or instructions
(Codex `AGENTS.md`, Cursor rules, Windsurf rules...). `SKILL.md` links to the rest.

## What's inside the skill

- **Storefront like Dawn** - image banner, featured collection, collection facets +
  filter drawer, variant-swapping PDP with sticky add-to-cart, cart drawer, and a
  standalone Shopify-style checkout that lives outside the store chrome.
- **Admin like Polaris** - dark top bar, sidebar with live order counts, orders with a
  COD status workflow and 80mm thermal / A4 receipts, product editor with drag-and-drop
  media manager and variants, collections, inventory, customers, discounts, settings.
- **A backend that is real** - orders priced server-side from the database (client
  totals are never trusted), per-variant stock decrement, server-validated discount
  codes, admin-allowlist RLS, realtime new-order feed, Resend order emails.
- **The "not AI slop" rules** - no cream-and-terracotta palettes, serif display fonts,
  arch heroes, marquee tickers, floating stat chips, eyebrow labels, em dashes, or dead
  buttons. White canvas, square buttons, floating labels, uniform product photography.
- **Pitfalls, pre-solved** - realtime channel-name crashes, the "any authenticated user"
  RLS hole, `PGRST205` bootstrap ordering, price-string corruption, stale carts after
  catalog changes, and more.

## Default stack

Next.js (App Router, static export) on Vercel + Supabase (Postgres, Auth, Storage,
Realtime, Edge Functions) + Resend for order email. The design and commerce conventions
transfer to any stack; the assets are framework-agnostic CSS and SQL.

## Repository structure

```
.
├── .claude-plugin/           plugin + marketplace manifests
├── skills/
│   └── shopify-store/        the skill itself
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Rules distilled from real builds are welcome;
generic advice is not - everything here should either come from a shipped store or be
verified against one.

## License

MIT - see [LICENSE](LICENSE).
