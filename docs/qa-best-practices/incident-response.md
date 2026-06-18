# Incident Response

**TL;DR:** When something goes wrong (and it will), you need a plan. Not a 47-page document nobody reads—a simple, practiced process that everyone knows. This guide is what you actually need at 2am when production is on fire.

---

## Why This Matters

In 2023, average downtime cost companies $1.7 million per hour. But here's what kills you: the 3 hours spent figuring out who should do what while customers are furious.

This guide prevents that. It's what works in practice, written by people who've been awake at 3am dealing with this.

---

## Severity Levels

### SEV1: Critical (Customer Impact)

- Complete service outage
- Data loss or corruption
- Security breach
- **Response time:** 15 minutes
- **Example:** "Database is down. Nobody can log in."

### SEV2: High (Significant Impact)

- Feature completely broken
- Major functionality impaired
- Performance severely degraded
- **Response time:** 30 minutes
- **Example:** "Checkout is broken. No one can buy anything."

### SEV3: Medium (Limited Impact)

- Feature partially working
- Workaround available
- Performance degraded but usable
- **Response time:** 2 hours
- **Example:** "Search is slow. Still works but users are complaining."

### SEV4: Low (Minimal Impact)

- Minor bugs
- Cosmetic issues
- Documentation errors
- **Response time:** 24 hours
- **Example:** "Typo on the about page."

---

## The Response Process

### 1. Detect & Acknowledge

```
[Alert fires] → [On-call acknowledged] → [Response started]
```

**What happens:**
- Page on-call engineer
- Acknowledge alert (don't let it keep paging)
- Initial assessment

### 2. Assess & Triage

```
[What's broken?] → [Who's affected?] → [How bad?]
```

**Questions to answer:**
- What's the scope?
- Is this a real incident or a false alarm?
- What's the current impact?

### 3. Communicate

```
[Internal: Update channel] → [External: Status page] → [Customers: If needed]
```

**What to say:**
```
📛 INCIDENT: [SEV level] - [Brief title]

Impact: [What's broken]
Status: [Investigating / Identified / Monitoring / Resolved]
Next Update: [When]
```

### 4. Contain

```
[Stop the bleeding first] → [Fix later]
```

**Examples:**
- Roll back deployment
- Disable the broken feature
- Switch to backup systems
- Block malicious traffic

**Never skip this step.** Fix the root cause before you've contained the impact, and you make things worse.

### 5. Fix

```
[Root cause analysis] → [Implement fix] → [Verify]
```

### 6. Recover

```
[Deploy fix] → [Verify resolution] → [Monitor]
```

### 7. Review (Retrospective)

```
[What happened?] → [What went well?] → [What to improve]
```

**Post-mortem template:**
```
## Incident Summary
[What happened]

## Timeline
- [Time] - [Event]
- [Time] - [Event]

## Root Cause
[Why did this happen?]

## Impact
[What was affected]

## What Went Well
[Things that worked]

## What To Improve
[Action items]
```

---

## Roles During an Incident

### Incident Commander (IC)

- Makes all decisions
- Coordinates response
- Communicates status

**Who:** Senior engineer, usually the on-call first responder

### Communications Lead

- Updates status page
- Drafts customer comms
- Handles internal updates

**Who:** If SEV1, dedicated person. Otherwise, IC handles it.

### Fixer

- Investigates the issue
- Implements the fix
- Verifies resolution

**Who:** Subject matter expert for the affected system

---

## Communication Channels

### Internal

- **#incidents** - All hands channel
- **#incident-[ID]** - Dedicated channel for this incident

### External

- Status page (status.example.com)
- Customer support (for SEV1-2)
- Twitter/X (if high visibility)

### What to Communicate

| Time | Update |
|------|--------|
| T+0 | We're aware and investigating |
| T+15 | Root cause identified |
| T+30 | Fix in progress |
| T+60 | Monitoring |
| T+90 | Resolved |

---

## Common Mistakes

### ❌ Waiting to Declare

"We should make sure before we page anyone."

**Problem:** Every minute of delay is more angry customers.

**Fix:** Declare early. Better to have a false alarm than a slow response.

### ❌ The Rabbit Hole

"This should only take 5 minutes to fix. Let me just..."

**Problem:** 3 hours later, still no progress.

**Fix:** 30-minute increments. If not fixed, escalate.

### ❌ Silence

No updates. Nobody knows what's happening.

**Fix:** Even if "no change," say "no change." Update every 30 minutes minimum.

### ❌ Blame Game

"Who deployed this? This is on the frontend team!"

**Fix:** Post-mortems are blameless. Focus on systems, not people.

---

## Runbooks

Create these before you need them:

### Database Connection Failures

```
1. Check RDS/CloudSQL status
2. Verify network connectivity
3. Check connection pool exhaustion
4. Restart application if needed
5. Failover to replica if primary is down
```

### High CPU/Memory

```
1. Identify process: top -c
2. Check for runaway queries
3. Look for memory leaks in recent deploys
4. Scale up temporarily
5. Restart affected pods
```

### Deployment Failures

```
1. Check logs: kubectl logs [pod]
2. Verify config changes in deploy
3. Check resource limits
4. Roll back if needed: git revert && deploy previous
```

---

## Quick Reference

| SEV | Response Time | Update Frequency |
|-----|---------------|------------------|
| SEV1 | 15 min | Every 15 min |
| SEV2 | 30 min | Every 30 min |
| SEV3 | 2 hours | Every hour |
| SEV4 | 24 hours | Daily |

---

*Next: [On-Call Best Practices](./oncall.md)*
