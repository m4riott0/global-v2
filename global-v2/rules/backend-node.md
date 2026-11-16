---
paths:
  - "**/*.ts"
  - "**/*.js"
  - "**/package.json"
---

# Node.js backend

- Detect runtime, framework, module system and existing conventions first.
- Prefer TypeScript for new code only when the project already uses it; do not migrate without approval.
- Keep transport handlers thin and place business rules in the project's existing application/domain layer.
- Validate untrusted input at system boundaries using existing libraries and patterns.
- Handle async errors intentionally; avoid floating promises.
- Reuse existing dependency injection, logging and error-handling conventions.
- Watch for N+1 and unbounded access patterns; never execute database queries.
- Do not add dependencies or change runtime versions without approval.
- Add focused tests for behavior changes; never run DB-backed integration tests.
