# Code Review Checklist

**TL;DR:** Don't just review code—review it systematically. This checklist ensures you catch common issues and don't miss anything important.

---

## Before You Review

- [ ] Understand what the PR is trying to accomplish
- [ ] Check if there are linked issues/tickets
- [ ] Look at the diff in context of the whole file

---

## Correctness

- [ ] Does the code do what it's supposed to?
- [ ] Are edge cases handled?
- [ ] Are there off-by-one errors?
- [ ] Are error conditions handled?
- [ ] Does it handle null/missing values?

---

## Security

- [ ] Any SQL injection vulnerabilities?
- [ ] Any command injection risks?
- [ ] Sensitive data logged?
- [ ] Authentication/authorization checks present?
- [ ] Input validation present?

**Security questions to ask:**
- Can users access only their own data?
- Can this endpoint be accessed without auth?
- Are external inputs sanitized?

---

## Performance

- [ ] N+1 queries?
- [ ] Unnecessary database calls?
- [ ] Missing indexes?
- [ ] Expensive operations in loops?
- [ ] Memory-intensive operations?

---

## Readability

- [ ] Variable names clear?
- [ ] Functions small and focused?
- [ ] Logic easy to follow?
- [ ] Comments explain why, not what?
- [ ] No magic numbers?

---

## Testing

- [ ] Tests added for new functionality?
- [ ] Tests cover edge cases?
- [ ] Tests actually verify the behavior?
- [ ] No tests = need justification

---

## Error Handling

- [ ] Errors handled gracefully?
- [ ] Errors logged (at appropriate level)?
- [ ] User-facing errors are friendly?
- [ ] No bare exceptions?

---

## Dependencies

- [ ] New dependencies necessary?
- [ ] Dependencies up to date?
- [ ] No vulnerable packages?

---

## Documentation

- [ ] User-facing changes documented?
- [ ] API changes documented?
- [ ] Complex logic commented?
- [ ] README updated if needed?

---

## Quick Reference

| Category | Priority |
|----------|----------|
| Security | Critical |
| Correctness | High |
| Error Handling | High |
| Performance | Medium |
| Readability | Medium |
| Testing | Medium |
| Dependencies | Low |

---

*Next: [Testing Strategy](./testing-strategy.md)*
