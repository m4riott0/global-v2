---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/__tests__/**"
  - "**/tests/**"
  - "**/test/**"
  - "**/*Tests/**"
  - "**/*Tests.cs"
  - "**/*Test.cs"
---
# Testing principles

- Inspect the existing test framework, naming and commands before adding tests.
- Prefer focused tests for observable behavior, edge cases and regressions.
- Use unit tests for isolated logic. Run integration tests only in a safe environment explicitly approved by the developer.
- Never discover credentials, connect to Oracle/SQL Server, execute SQL, run migrations or invoke database-backed test suites.
- Never claim a check passed unless it was run and its result observed.
- If a check cannot safely run, explain why and give the command for the developer to run.
- Avoid brittle tests coupled to private implementation details.
