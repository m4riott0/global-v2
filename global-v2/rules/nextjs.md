---
paths:
  - "**/next.config.*"
  - "**/next-env.d.ts"
  - "**/app/**"
  - "**/pages/**"
---

# Next.js

- Detect Next.js version and App Router/Pages Router usage before proposing APIs.
- Follow the project's routing, data-fetching, caching and rendering conventions.
- In App Router, prefer Server Components; add "use client" only for browser APIs, client state or event handlers.
- Keep secrets and server-only modules out of client bundles.
- Validate route params, search params, form input and external data at boundaries.
- Be explicit about cache and revalidation behavior; do not assume defaults.
- Preserve existing loading, error and not-found conventions.
- Do not add state, fetching or styling libraries without approval.
