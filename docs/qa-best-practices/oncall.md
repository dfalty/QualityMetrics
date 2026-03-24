# On-Call Best Practices

**TL;DR:** On-call shouldn't destroy your life. If it does, something is wrong with your process, not you. This guide covers how to do on-call sustainably—because you need engineers who can think clearly at 3am, not zombies who are burn out.

---

## Why This Matters

On-call is a necessity. But badly run on-call is how you lose good engineers. We've seen it happen: the constantly paging nightmares, the "I just won't fix it until morning" culture, the burnout.

This guide prevents that. Good on-call means clear expectations, good tools, and a team that's actually functional at 2am.

---

## The On-Call Rotation

### Schedule Structure

- **Primary on-call:** First responder. Gets paged first.
- **Secondary on-call:** Backup. Pages if primary can't respond.
- **Rotation length:** 1 week is standard. Shorter = more disruption. Longer = too much fatigue.

### Handoff

```
Monday 9am: [Outgoing] → [Incoming]

During handoff:
- Review active alerts
- Discuss any ongoing issues
- Share context on recent changes
- Confirm contact info
```

---

## What to Page On

### Page on Production Impact

| Alert | Page? |
|-------|-------|
| Service down | Yes |
| Error rate > 5% | Yes |
| Latency > 500ms | Yes (if sustained) |
| Disk at 90% | Yes |
| Disk at 85% | No (schedule cleanup) |
| 404 errors < 1% | No |

### The "Run the World" Rule

If you can't verify the system works without you, it should be pagable.

- "If the database goes down, I need to know"
- "If error rate spikes, I need to know"
- "If the site is down, I need to know"

Not pagable:
- "This log shows a warning" (unless critical)
- "This metric is slightly elevated" (unless trending badly)

---

## Responding to Pages

### The 30-Minute Rule

1. **0-5 min:** Acknowledge the page
2. **5-15 min:** Initial assessment (what's broken?)
3. **15-30 min:** Decide: Can I fix this quickly? Should I escalate?

### Initial Assessment Questions

- What's actually broken?
- Who is affected (all users? specific region? internal only?)
- When did it start?
- What changed recently?

### To Fix or Escalate?

**Fix yourself if:**
- You know the system
- Fix is straightforward (< 30 min)
- No risk of making it worse

**Escalate if:**
- You're not familiar with the system
- Fix is complex
- Could cause more damage
- You've been stuck > 30 minutes

---

## Escalation Path

```
[Primary on-call] 
     ↓ (no response in 15 min)
[Secondary on-call]
     ↓ (no response in 15 min)
[Engineering Manager]
     ↓ (no response)
[CTO/VP Engineering]
```

### Contact Methods

- **Primary:** PagerDuty/Pingdom → Phone
- **Secondary:** SMS
- **Emergency:** Phone call

---

## Tools You Need

### Monitoring Stack

- **Metrics:** Datadog, Prometheus, CloudWatch
- **Logging:** Splunk, ELK, Loki
- **Tracing:** Jaeger, Zipkin
- **Alerting:** PagerDuty, Opsgenie

### Access

- VPN or zero-trust network access
- Cloud console access
- Database access (read-only for safety)
- Deployment access (for rollback/fix)

### Runbooks

Every alert should have a runbook. If it doesn't, either:
- Create one after hours, or
- Suppress the alert until there's a runbook

---

## What Bad Looks Like

### ❌ The Paging Nightmare

Alert fires every 5 minutes for the same thing. Nobody fixes it because it's "not critical."

**Fix:** Tune the alert. Fix the root cause. Or silence it properly.

### ❌ The "Works on My Machine" Engineer

Can't access production from on-call laptop. Doesn't have credentials. Has never seen the deployment.

**Fix:** Verify access before on-call starts. Test everything.

### ❌ The Silent Sufferer

Got paged 12 times last night. Says nothing. Quits in 3 months.

**Fix:** Track on-call experience. Rotate frequently. Investigate alert fatigue.

### ❌ The Blame Game

"You should have fixed this before going on-call."

**Fix:** Blameless post-mortems. On-call isn't responsible for technical debt.

---

## What Good Looks Like

### ✅ Clear Alert Taxonomy

- **Critical (page):** Service down, data loss risk
- **Warning (no page):** Elevated errors, monitor
- **Info (no page):** Informational only

### ✅ Reasonable Workload

- < 2 pages per night is ideal
- < 5 pages per week is healthy
- More = fix alerts or hire more coverage

### ✅ Proper Compensations

- On-call stipend (money)
- Next-day off after rough night
- Flexible schedule following on-call

---

## Self-Care During On-Call

### Before Your Shift

- Check upcoming deployments (know what's changing)
- Verify your access works
- Review active runbooks

### During Your Shift

- Don't drink too much (need to be responsive)
- Keep your phone charged
- Have a quiet place to work if needed

### After Your Shift

- Take your follow-up day
- Hand off clearly to next person
- Sleep. Seriously.

---

## Post-On-Call Review

After each shift, ask:

- [ ] Were alerts actionable?
- [ ] Were runbooks accurate?
- [ ] Did I have the access I needed?
- [ ] Did I need to escalate more than expected?

Bring issues to team lead. On-call should improve, not degrade, over time.

---

## Quick Reference

| Question | Answer |
|----------|--------|
| How long is shift? | 1 week typical |
| Response time? | 15 minutes |
| Max pages/night? | < 5 |
| After rough night? | Next day off |

---

*Next: [Database Standards](./database.md)*
