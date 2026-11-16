---
name: analyze-architecture
description: Read-only analysis of architecture, module boundaries, dependencies and technical risks. Runs in an isolated subagent so the main context stays small.
argument-hint: "[area or question - default: whole repository]"
disable-model-invocation: true
context: fork
agent: architect
---

Analyze: $ARGUMENTS (default: the whole repository)

- Read-only. Identify stack, entry points, manifests and the architecture that actually exists, from evidence.
- Trace one representative flow only if it materially helps.
- Do not assume Clean Architecture or recommend a rewrite by default.
- Return, concisely: current structure, prioritized findings with file paths and concrete impact, smallest sustainable recommendations, unknowns.
