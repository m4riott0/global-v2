---
name: implement-feature
description: Implement a feature or bug fix in an existing codebase with minimal scope, production-ready code and focused validation.
argument-hint: "[feature or bug description]"
---

# Implement feature / fix

Task: $ARGUMENTS

1. Locate the smallest relevant slice (Grep/Glob first): implementation, tests, conventions.
2. For large or risky changes, state a 3-5 line plan. Ask only if a decision is irreversible, changes a public contract/schema, or adds a dependency; otherwise proceed.
3. Implement the smallest complete solution following existing architecture and patterns. No unrelated refactors.
4. Add or update focused tests for the changed behavior where the project has tests.
5. Run safe, relevant checks (build, lint, unit tests). Never DB-backed tests.
6. If the change is non-trivial or spans several files, delegate an independent review to the `code-reviewer` subagent and fix confirmed findings.
7. Report: changed files, checks run with results, open risks.
