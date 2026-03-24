# Monitoring & Observability

**TL;DR:** If you're waiting for users to report bugs, you're behind. Good monitoring means you know something is wrong before your users do. This guide covers what metrics matter, how to set up alerts, and how to sleep better at night.

---

## Why This Matters

We've all been there: "Users are reporting the site is down" at 2am. Good monitoring? You already got the page, started fixing it, and users never noticed.

This guide prevents the 2am surprise. It's what separates professional ops from "hopium."

---

## The Three Pillars

### 1. Metrics (Numbers)

Quantitative measurements over time.
- Response time, error rate, throughput
- CPU, memory, disk usage

### 2. Logs (Events)

Discrete events with timestamps.
- "User logged in"
- "Payment processed"
- "Error: connection refused"

### 3. Traces (Flow)

How requests flow through your system.
- "User clicked checkout → API called → DB queried → response returned"

---

## Key Metrics

### Application Metrics

| Metric | What It Tells You | Alert Threshold |
|--------|-------------------|-----------------|
| Request rate | Traffic volume | > 2x normal |
| Error rate | Quality | > 1% for 5 min |
| Latency p50 | Typical user experience | > 500ms |
| Latency p99 | Worst-case users | > 2s |

### System Metrics

| Metric | What It Tells You | Alert Threshold |
|--------|-------------------|-----------------|
| CPU | How hard server is working | > 80% sustained |
| Memory | RAM pressure | > 85% |
| Disk | Storage left | > 90% |
| Network | Traffic volume | > 80% capacity |

### Business Metrics

- **Signups:** Is acquisition working?
- **Revenue:** Are users paying?
- **Conversion:** Is funnel broken?
- **Active users:** Retention healthy?

---

## Alerting

### The Alert Pyramid

```
SEV1: Service down, data loss
SEV2: Feature broken, major impact  
SEV3: Degraded performance
SEV4: Warning signs
```

### What to Alert On

- **Service health:** Is it up?
- **Error rates:** Is it working correctly?
- **Latency:** Is it fast?
- **Business metrics:** Is anything broken?

### What NOT to Alert On

- Metrics in warning zone but stable
- One-off errors
- Metrics that bounce back naturally

### Alert Fatigue

**❌ Too many alerts:**
- Every warning → page
- Same alert every 5 minutes
- Nobody pays attention

**✅ Good alerting:**
- Actionable alerts only
- Group similar alerts
- Escalate if not acknowledged

---

## Dashboards

### What Every Dashboard Should Have

1. **Service Health** - Up/down status
2. **Error Rate** - Last 24 hours
3. **Latency** - p50, p95, p99
4. **Throughput** - Requests per second
5. **Resources** - CPU, memory, disk

### Dashboard Principles

- **At a glance:** Can you see status in 5 seconds?
- **Drill-down:** Click to get more detail
- **Time range:** Default to last 24 hours
- **Comparisons:** Compare to yesterday/last week

---

## Logging

### Log Levels

| Level | When to Use |
|-------|-------------|
| DEBUG | Detailed debugging info |
| INFO | Normal operations |
| WARNING | Something's wrong but working |
| ERROR | Something failed |
| CRITICAL | System may crash |

### What to Log

```python
# ✅ Good: Structured logging
logger.info("user_created", extra={
    "user_id": 123,
    "email": "user@example.com",
    "source": "web"
})

# ❌ Bad: String interpolation
logger.info(f"Created user {user.email}")  # Hard to parse
```

### Log Fields

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "INFO",
  "event": "user_created",
  "user_id": 123,
  "trace_id": "abc-123",
  "service": "users-api"
}
```

### What NOT to Log

- Passwords, API keys, tokens
- Credit card numbers
- PII (without masking)
- Entire request/response bodies (unless debugging)

---

## Tracing

### Distributed Tracing

When a request hits multiple services, tracing follows it:

```
[Gateway] → [Auth Service] → [User Service] → [Database]
    ↓
Trace ID: abc-123
```

Each service adds its span.

### What to Trace

- All API requests
- Database queries
- External API calls
- Background jobs

### Trace Annotations

- Start/finish times
- Error information
- User/context identifiers

---

## Quick Reference

| Question | Answer |
|----------|--------|
| Error rate alert? | > 1% for 5 minutes |
| Latency alert? | > p99 at 2s for 5 min |
| Logs retention? | 30-90 days |
| Alert response time? | 15 min for SEV1 |

---

*Next: [Code Style Guide](./code-style.md)*
