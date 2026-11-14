# Shopify Skill

An agent skill for building custom online stores that are indistinguishable from real
Shopify stores: a Dawn-theme storefront, a Polaris-style admin, and a working commerce
backend (server-priced orders, per-variant inventory, discounts, cash on delivery,
confirmation emails, receipt printing, realtime order feed).

Distilled from building and shipping a production store end to end, including the
mistakes, so the agent skips them.

## What's inside

```
skills/shopify-store/
├── SKILL.md                      workflow, non-negotiables, definition of done
├── references/
│   ├── storefront-dawn.md        layout system, components, every page's anatomy, imagery, copy
│   ├── admin-polaris.md          admin look and every page/feature (orders, products, media, inventory...)
│   ├── backend-commerce.md       schema, RLS, order function contract, realtime, email, subdomain, secrets
│   ├── localization.md           money formats by market, Pakistan/COD preset, market checklist
│   └── qa-and-pitfalls.md        release gate + real bugs and their fixes
└── assets/
    ├── dawn-base.css             Dawn tokens, type, buttons, floating-label fields, cards, price
    ├── polaris-admin.css         Polaris frame, cards, tables, tabs, badges, forms
    └── schema.sql                idempotent Supabase schema + admin-allowlist RLS + realtime + bucket
```

## Install

**Devin CLI / Devin Desktop**

```bash
devin plugins install hanzlahsfc/Shopify-Skill
```

or copy `skills/shopify-store` into `.devin/skills/` (one project) or
`~/.config/devin/skills/` (`%APPDATA%\devin\skills\` on Windows) for every project.

**Claude Code**: copy `skills/shopify-store` into `~/.claude/skills/` or `.claude/skills/`.

**Other agents**: point the agent at `skills/shopify-store/SKILL.md`; it links to the rest.

## Use

```
/shopify-store sunglasses brand for Pakistan, COD, with admin
```

or just ask for "an online store like Shopify" and the agent will pick it up.

## Default stack

Next.js (App Router, static export) on Vercel + Supabase (Postgres, Auth, Storage,
Realtime, Edge Functions) + Resend for email. The design and commerce rules apply to any stack.
