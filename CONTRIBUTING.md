# Contributing

This skill is a distillation of a production store build, not a style guide. Contributions
should follow the same standard.

## What belongs here

- **Rules proven in a real build.** If you fixed a bug, found a layout gotcha, or learned
  a Shopify convention the docs miss, add it to the right reference file. Prefer one
  concrete rule over three general ones.
- **Reusable assets.** CSS, SQL, scripts and snippets that can be copied into a new store
  as-is go in `assets/`. Keep them brand-neutral and free of secrets.
- **Pitfalls.** If something broke for you and had a non-obvious fix, it belongs in
  `references/qa-and-pitfalls.md`.

## What doesn't

- Generic web design advice ("make it responsive", "use semantic HTML").
- Brand-specific content from a particular store.
- Vendor lock-in that isn't justified - the skill's default stack is documented, but the
  design rules should stay stack-agnostic.
- Secrets, tokens, API keys or real customer data. Check diffs before committing.

## Guidelines

- Keep `SKILL.md` short - it routes; the detail lives in `references/`.
- Edit `references/` files rather than adding new ones unless a topic is genuinely separate.
- For `assets/schema.sql`, keep it idempotent (`create ... if not exists`, drop+create
  policies) and brand-neutral. Test with a throwaway Postgres before committing:

  ```bash
  docker run -d --rm -e POSTGRES_PASSWORD=x postgres:16-alpine
  ```

  (You'll need the Supabase stubs shown in git history for `auth`, `storage` and
  `supabase_realtime`.)
- Commits: small, logical, conventional style (`feat:`, `fix:`, `docs:`).

## Pull requests

Describe what the change teaches the agent and where you verified it (a build, a page,
a schema run). Screenshots help for design rules.
