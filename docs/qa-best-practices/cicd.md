# CI/CD Best Practices

**TL;DR:** Your CI/CD pipeline should be so boring nobody talks about it. If it's constantly breaking, taking forever, or causing drama, something is wrong. This guide makes it boring on purpose.

---

## Why This Matters

Your pipeline is the heartbeat of development. When it works, nobody notices. When it breaks, nothing gets done. A good CI/CD setup means faster releases, fewer bugs, and less arguing about "but it works on my machine."

---

## The Pipeline Stages

### Stage 1: Build

- Compile code
- Install dependencies
- Generate artifacts

### Stage 2: Test

- Unit tests
- Integration tests
- E2E tests (if applicable)

### Stage 3: Security

- Dependency scanning
- Static analysis
- Secret detection

### Stage 4: Deploy

- Deploy to staging
- Run smoke tests
- Deploy to production

---

## Essential CI/CD Best Practices

### 1. Keep Builds Fast

**Target:** < 10 minutes total

**How:**
- Run unit tests in parallel
- Cache dependencies
- Skip unchanged jobs
- Fail fast (run fastest checks first)

### 2. Fail Fast

```yaml
# ✅ Good - run fast checks first
lint:
  script: npm run lint
  stage: build

test:unit:
  script: npm run test:unit
  stage: test

test:e2e:
  script: npm run test:e2e
  stage: test

# ❌ Bad - slow check runs last
# E2E tests fail, but you waited 30 minutes to find out
```

### 3. Use Caching

```yaml
cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - node_modules/
    - .npm/
```

### 4. Parallelize Tests

```yaml
test:unit:
  script: npm run test:unit -- --parallel
  
# Or split across multiple jobs
test:unit:api:
  script: npm run test:unit:api
  parallel: 5

test:unit:ui:
  script: npm run test:unit:ui
  parallel: 5
```

---

## Environment Management

### What to Avoid

- ❌ Hard-coded credentials in configs
- ❌ Manual environment setup
- ❌ Different configs per machine

### What to Do

```yaml
# ✅ Good - use environment variables
deploy:
  script: npm run deploy
  environment:
    name: production
    url: https://api.example.com
  env:
    API_URL: https://api.example.com
    LOG_LEVEL: info
```

### Secrets Management

- Use CI/CD secrets (GitHub Secrets, GitLab CI Variables)
- Never commit secrets to repo
- Rotate credentials regularly

---

## Testing in CI

### The Testing Pyramid

```
E2E Tests (5-10%)
  ↑
Integration Tests (20-30%)  
  ↑
Unit Tests (60-70%)
```

### Required Checks

```yaml
# Linting
lint:
  script: npm run lint

# Type checking
types:
  script: npm run types

# Unit tests with coverage
test:unit:
  script: npm run test:coverage
  coverage: /Coverage: \d+.\d+%/

# Security audit
security:
  script: npm audit --audit-level=high
```

---

## Deployment Strategies

### Blue-Green Deployment

```
[Traffic] → [Blue Environment] → [Green Environment]
```

- Deploy to inactive environment
- Test it
- Switch traffic
- Rollback if needed

### Canary Deployment

```
[10%] → New Version
[90%] → Old Version
```

- Deploy to small percentage
- Monitor metrics
- Gradually increase
- Rollback if issues

### Rolling Deployment

```
v1.0 → v1.1 → v1.2 → v1.3
```

- Update instances one by one
- No downtime
- Easy rollback

---

## What Bad Looks Like

### ❌ 47-Minute Build Times

**Problem:** Tests run serially, no caching, everything rebuilds.

**Fix:** Parallelize, cache, skip unchanged jobs.

### ❌ Flaky Tests Pass Sometimes

**Problem:** Tests depend on timing, race conditions, shared state.

**Fix:** Fix root cause. Don't just retry.

### ❌ Manual Deployments

**Problem:** "Bob deployed the fix last night."

**Fix:** Automate everything. Humans should only trigger, not perform.

### ❌ No Rollback Plan

**Problem:** Deployment fails, nobody knows how to undo it.

**Fix:** Automate rollback. Test it regularly.

---

## What Good Looks Like

### ✅ Example Pipeline

```yaml
stages:
  - build
  - test
  - security
  - deploy

build:
  stage: build
  script: npm ci
  artifacts:
    paths:
      - node_modules/

lint:
  stage: test
  script: npm run lint

test:unit:
  stage: test
  script: npm run test:unit
  coverage: '/Coverage: \d+.\d+%'

test:e2e:
  stage: test
  script: npm run test:e2e

security:
  stage: security
  script: npm audit --audit-level=high

deploy:staging:
  stage: deploy
  script: npm run deploy:staging
  environment:
    name: staging
  only:
    - main

deploy:production:
  stage: deploy
  script: npm run deploy:production
  environment:
    name: production
  when: manual
  only:
    - main
```

---

## Monitoring & Alerts

### What to Monitor

- Build success/failure rate
- Build duration trends
- Test flakiness
- Deployment frequency
- Mean time to recovery (MTTR)

### Alert on Failures

```yaml
# Example: Slack notification
notify_failure:
  script: |
    curl -X POST -H 'Content-type: application/json' \
    --data '{"text": "Build failed on main!"}' \
    $SLACK_WEBHOOK
  only:
    - failure
```

---

## Quick Reference

| Question | Answer |
|----------|--------|
| Build time target? | < 10 minutes |
| How many environments? | Dev, Staging, Prod |
| Deploy strategy? | Blue-green or canary |
| Manual steps? | Zero (except trigger) |

---

*Next: [Incident Response](./incident-response.md)*
