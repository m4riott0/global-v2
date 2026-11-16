---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
---

# React

- Follow the project's React version and established patterns.
- Keep components cohesive, focused and explicit in their props.
- Keep state close to consumers; avoid global state without a real cross-tree need.
- Avoid useEffect for derived state or event-driven logic when render/event logic is sufficient.
- Clean up subscriptions, timers and other effects.
- Preserve accessibility: semantic HTML, labels, keyboard behavior and focus management.
- Avoid premature memoization; use memo/useMemo/useCallback only when justified.
- Reuse existing design-system components and styling conventions.
- Test observable user behavior with the existing test stack.
