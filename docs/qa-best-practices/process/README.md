# QA Process & Workflows

**TL;DR:** Your testing process should be invisible when it's working well. Bugs flow through predictable stages, everyone knows what "done" means, and release decisions aren't guesswork. This doc makes that happen.

---

## Bug Lifecycle

Every bug goes through stages. Here's how we do it.

### The Stages

```
NEW → TRIAGED → IN PROGRESS → CODE REVIEW → READY FOR QA → VERIFIED → CLOSED
         ↑                                                                        ↓
         └──────────────────────── REOPENED (if needed) ─────────────────────────┘
```

### Stage Definitions

| Stage | What Happens | Who Owns It |
|-------|--------------|-------------|
| **New** | Bug reported, auto-labeled | System |
| **Tried** | QA reviews, assigns severity + priority | QA |
| **In Progress** | Developer fixing the bug | Developer |
| **Code Review** | PR open, peer review | Team |
| **Ready for QA** | Fix merged, ready for verification | QA |
| **Verified** | QA confirms fix works | QA |
| **Closed** | Fix released or ticket resolved | QA |

### Severity vs Priority (The Difference)

| Term | Meaning | Examples |
|------|---------|----------|
| **Severity** | How bad is the bug? | S0 = data loss, S1 = major feature broken |
| **Priority** | How soon should it be fixed? | P0 = now, P1 = this sprint, P2 = backlog |

**Quick rule:** Severity comes from product impact. Priority comes from business context. They're different.

---

## Bug Triage Process

### Weekly Triage Meeting (30 min max)

**Who:** QA lead + engineering lead + product

**Agenda:**
1. New bugs since last meeting (10 min)
2. Bugs stuck > 7 days (10 min)
3. Upcoming releases + risk review (5 min)
4. Process improvements (5 min)

### Triage Checklist

For each new bug, answer:

- [ ] Can we reproduce it?
- [ ] What's the severity? (S0/S1/S2/S3)
- [ ] What's the priority? (P0/P1/P2/P3)
- [ ] Which product area?
- [ ] Is it a regression? (missed by existing tests)
- [ ] Should we fix before release?

---

## Release Criteria

### What Must Pass

| Release Type | Criteria |
|--------------|----------|
| **Hotfix** | S0 bugs fixed, smoke tests pass |
| **Standard** | All P0/P1 bugs fixed, regression pass, code review complete |
| **Major** | Full test suite pass, performance benchmarks, security scan, release notes |

### The Release Go/No-Go Checklist

Before any release, verify:

- [ ] All P0/P1 bugs in release are verified fixed
- [ ] No new S0/S1 bugs since last release
- [ ] Regression test suite passes (ideally automated)
- [ ] Code review approved by 2+ devs
- [ ] Database migrations backward-compatible (if applicable)
- [ ] Rollback plan documented and tested
- [ ] Customer-facing changes documented
- [ ] Monitoring/alerting verified for new features
- [ ] Product sign-off (if new features)

---

## Test Execution Workflow

### Daily: Development Machine

```
1. Developer writes code
2. Runs unit tests locally
3. Runs relevant integration tests
4. Pushes to branch
5. CI runs full suite → pass/fail
6. Code review
7. Merge to main
```

### Each PR: Automated Checks

```yaml
# Pre-merge checklist (automated)
- [ ] Unit tests pass
- [ ] Linting passes
- [ ] Type checking passes
- [ ] Security scan passes
- [ ] Code coverage maintained (or increased)
- [ ] Integration tests pass
```

### Pre-Release: QA Verification

```
1. QA receives "ready for QA" notification
2. QA reviews code changes (understands what changed)
3. QA executes test cases for the feature
4. QA runs regression suite
5. QA verifies bug fixes
6. QA signs off OR reports issues
```

---

## Definition of "Done"

### For a Bug Fix

- [ ] Code written
- [ ] Unit tests added/updated
- [ ] Code review approved
- [ ] QA verified fix works
- [ ] Regression tests pass
- [ ] Documentation updated (if needed)

### For a Feature

- [ ] Acceptance criteria met
- [ ] Unit tests (developer)
- [ ] Integration tests (developer)
- [ ] E2E tests (QA)
- [ ] Documentation (if new user-facing stuff)
- [ ] Release notes updated
- [ ]QA sign-off

---

## Test Reporting

### What We Track

| Metric | Why It Matters |
|--------|----------------|
| **Test coverage** | How much code is tested |
| **Pass rate** | Overall health of test suite |
| **Flaky test %** | How reliable are our tests? |
| **Bug escape rate** | How many bugs get to production? |
| **Time to fix** | How fast do we respond? |
| **Regression failure rate** | What keeps breaking? |

### Dashboards We Use

- **Daily:** Pass/fail count, failure breakdown
- **Weekly:** Coverage trend, top failing tests
- **Sprint:** Bug velocity, escape rate
- **Release:** Overall health, risk assessment

---

## Onboarding New QA Team Members

### First Week

- [ ] Access to all environments
- [ ] Read: Test case standards
- [ ] Read: Automation standards  
- [ ] Read: This process doc
- [ ] Shadow: One full bug lifecycle
- [ ] Execute: One bug fix verification

### First Month

- [ ] Execute: 5 bug verifications
- [ ] Write: 3 new test cases
- [ ] Review: One PR from each team
- [ ] Run: Regression suite once
- [ ] Learn: Product areas (have devs walk through)

---

## Common Anti-Patterns

### ❌ "It's Ready for QA"

This phrase without context means nothing. What specifically is ready? What's been tested? What's the risk?

**Fix:** Include in the ticket:
- Link to PR
- What was tested locally
- Risk assessment
- Special instructions

### ❌ "It Works on My Machine"

The most dangerous sentence in software.

**Fix:** Reproduce locally first. If it's a real issue, CI should catch it.

### ❌ "We'll Test It in Production"

No. Just no.

**Fix:** If you don't have time to test it properly, you don't have time to ship it.

### ❌ "QA is a Gate"

QA shouldn't be a bottleneck that slows everything down. They're advisors, not roadblocks.

**Fix:** Shift quality left. Build it in, don't check it at the end.

---

## Quick Reference

| Question | Answer |
|----------|--------|
| When is a bug "ready for QA"? | When PR is merged, code review done |
| How long should a bug take to fix? | P0: same day, P1: 3 days, P2: 2 weeks |
| What if we disagree on severity? | Discuss in triage, escalate to product lead |
| When can we skip tests? | Never for P0/P1. Document risk for P2+ |

---

*End of QA Best Practices Documentation*

Check out the full suite:
- [Test Case Standards](../test-management/README.md)
- [Test Automation](../test-automation/README.md)
- [Shift-Left Testing](../shift-left/README.md)
- [AI-Enhanced Testing](./README.md)
