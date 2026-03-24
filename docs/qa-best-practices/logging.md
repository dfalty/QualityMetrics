# Logging Standards

**TL;DR:** Logs are for debugging. Too few and you're blind. Too many and you can't find anything. This guide covers what to log, how to format it, and where to send it.

---

## Why This Matters

When something breaks at 3am, logs are your only window into what happened. But if your logs are useless ("processing"), or overwhelming (logging every HTTP request), you're still blind.

This guide ensures logs actually help you debug.

---

## What to Log

### Always Log

- **Authentication events:** Login, logout, failures
- **Authorization failures:** Access denied
- **Errors and exceptions:** With stack traces
- **Important business events:** Signups, purchases, key actions
- **Configuration changes:** Deploys, config updates

### Never Log

- **Passwords, tokens, keys:** Security risk
- **Credit card numbers:** PCI violation
- **PII:** GDPR/compliance issues
- **Entire request/response bodies:** Unless debugging specific issue

---

## Log Format

### Structured Logging (Preferred)

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "INFO",
  "message": "user_created",
  "context": {
    "user_id": 123,
    "email": "user@example.com",
    "source": "web"
  },
  "trace_id": "abc-123"
}
```

### Fields to Include

| Field | Description |
|-------|-------------|
| timestamp | ISO 8601 format |
| level | DEBUG, INFO, WARNING, ERROR |
| message | What happened |
| context | Relevant data |
| trace_id | Request correlation |

---

## Log Levels

| Level | Use For |
|-------|---------|
| DEBUG | Detailed debugging info |
| INFO | Normal operations |
| WARNING | Something's wrong but working |
| ERROR | Something failed |
| CRITICAL | System may crash |

---

## Quick Reference

| Question | Answer |
|----------|--------|
| Include sensitive data? | Never |
| Format? | Structured JSON |
| Levels? | DEBUG, INFO, WARNING, ERROR |

---

*Next: [Release Process](./release-process.md)*
