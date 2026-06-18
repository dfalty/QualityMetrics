# Documentation Standards

**TL;DR:** Documentation is a liability if it's wrong or outdated. Keep it minimal, keep it accurate, and update it when things change. This guide covers what to document, how to document it, and when to throw old docs away.

---

## Why This Matters

Documentation is like code: stale documentation is worse than no documentation. We've all seen the "comprehensive" wiki that's 3 years old and leads people completely wrong.

This guide prevents that. The goal is docs that help, not mislead.

---

## What to Document

### Must-Have

| Document | Audience | Updated When |
|----------|----------|---------------|
| README.md | Everyone | New features, setup changes |
| API Docs | Developers | API changes |
| Architecture | Engineers | Major decisions |
| Runbooks | On-call | Incidents, alerts |
| Onboarding | New hires | Team/process changes |

### Nice-to-Have

- Team charter
- Company values
- Meeting notes
- "How to contribute"

### Never Document

- Temporary workarounds (fix the root cause)
- Details that change frequently (write code instead)
- Obvious code (code should be self-documenting)

---

## README.md Template

```markdown
# Project Name

One-paragraph description of what this does.

## Quick Start

```bash
# Get started in 30 seconds
npm install
npm run dev
```

## Development

- [ ] Prerequisites
- [ ] Setup steps
- [ ] Running tests

## Deployment

Link to deployment docs.

## API Reference

Link to API docs.

## Contributing

How to contribute.

## License
```

---

## API Documentation

### OpenAPI/Swagger

```yaml
openapi: 3.0.0
info:
  title: User API
  version: 1.0.0
paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
      responses:
        '200':
          description: List of users
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
```

### Auto-Generate

Don't write API docs by hand. Generate from code:

- **Python:** Swagger automatically from FastAPI/Flask
- **Node:** Swagger Express Middleware
- **Go:** swaggo/swag

---

## Code Comments vs Docs

### Comments: Why, Not What

```python
# ✅ Good: Explains why
# Retry with exponential backoff because the API
# rate-limits on immediate retries.
for i in range(3):
    try:
        return request(url)
    except RateLimited:
        sleep(2 ** i)

# ❌ Bad: Explains what
# Loop through 3 attempts
for i in range(3):
    request(url)
```

### Docs: High-Level Overview

```python
class PaymentProcessor:
    """
    Handles payment processing for orders.
    
    Supports:
    - Credit cards
    - Debit cards
    - Bank transfers
    
    Raises:
    - PaymentDeclinedError: Card was declined
    - InvalidAmountError: Amount is invalid
    """
```

---

## Runbooks

### Template

```markdown
# Alert: High Error Rate

## Description
Alert fires when error rate exceeds 1% for 5 minutes.

## Impact
Users experiencing failed requests.

## Investigation
1. Check error logs: `logs -filter "error"`
2. Identify error type
3. Check recent deploys

## Resolution
1. If new deploy: roll back
2. If known issue: follow fix procedure
3. If unknown: escalate to on-call engineer

## Escalation
- Slack: #engineering
- On-call: PagerDuty
```

---

## What Bad Looks Like

### ❌ Outdated Documentation

Docs that contradict the code.

**Fix:** Tie docs to code reviews. Block PRs that don't update docs.

### ❌ Over-Documentation

Every function has a docstring. Every file has a README.

**Fix:** Document interfaces, not implementations. Document the "why," not the "what."

### ❌ Copy-Paste Documentation

Docs that are just copied from other sources and don't match your setup.

**Fix:** Write your own docs. Copy examples, but adapt to your context.

---

## Quick Reference

| Question | Answer |
|----------|--------|
| Who reads this? | Write for the audience |
| When to update? | When code changes |
| How to keep fresh? | Version control, review process |
| How much? | Minimum useful |

---

*Next: [Git Workflow](./git-workflow.md)*
