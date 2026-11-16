---
name: refactor-code
description: Refactor existing code safely while preserving observable behavior and minimizing scope.
argument-hint: "[file, module or code smell]"
---

# Refactor

Target: $ARGUMENTS

1. Name the concrete problem (duplication, coupling, unclear responsibility...) and its impact in one or two lines.
2. Establish current behavior from code and existing tests; add a focused characterization test if behavior is unprotected.
3. Make small, coherent changes. Preserve public contracts and behavior unless told otherwise.
4. No broad rewrites, no speculative abstractions, no unrelated edits.
5. Run safe checks (build, lint, unit tests without DB).
6. Re-read the diff for accidental behavior changes, then report changed files, checks and risks.
