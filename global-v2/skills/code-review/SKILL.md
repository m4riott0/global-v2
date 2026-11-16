---
name: code-review
description: Independent read-only review of current changes (or given files) for correctness, regressions, security, performance and test gaps. Runs in an isolated subagent.
argument-hint: "[files or scope - default: uncommitted changes]"
disable-model-invocation: true
context: fork
agent: code-reviewer
---

Review scope: $ARGUMENTS
If no scope was given, review the uncommitted changes (`git status` and `git diff`, read-only).

- Do not edit files.
- Read only the changed code and the surrounding code needed to understand it.
- Findings first, highest severity first. Each: severity, file:line, triggering scenario, impact, suggested fix.
- Prioritize correctness, security, data loss, concurrency, performance, then maintainability.
- No style nitpicks presented as defects.
- End with missing tests and what could not be verified. If nothing significant is found, say so in one line.
