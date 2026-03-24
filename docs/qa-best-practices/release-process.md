# Release Process

**TL;DR:** Releasing should be boring. You push a button (or merge a PR), things get deployed, and nothing explodes. This guide covers how to make releases predictable and safe.

---

## Release Types

### Hotfix (Emergency)

- Critical bug fix
- Security patch
- No new features

**Timeline:** Hours, same day

### Standard Release

- Normal feature work
- Bug fixes
- Improvements

**Timeline:** Weekly or bi-weekly

### Major Release

- Big features
- Breaking changes
- Significant migrations

**Timeline:** Monthly or quarterly

---

## The Release Checklist

### Before Release

- [ ] All tests passing
- [ ] Code review approved
- [ ] Changelog updated
- [ ] Database migrations ready
- [ ] Rollback plan documented
- [ ] Monitoring/alerts in place

### During Release

- [ ] Deploy to staging first
- [ ] Run smoke tests
- [ ] Verify staging works
- [ ] Deploy to production
- [ ] Monitor error rates
- [ ] Verify production works

### After Release

- [ ] Monitor for 30 minutes
- [ ] Update status page if needed
- [ ] Notify stakeholders
- [ ] Close release ticket

---

## Deployment Strategies

### Blue-Green

```
[Traffic] → [Blue] → [Green] (new version)
```

- Deploy to inactive environment
- Test it
- Switch traffic
- Rollback by switching back

### Canary

```
[10%] → [New Version]
[90%] → [Old Version]
```

- Deploy to small %
- Monitor metrics
- Gradually increase
- Rollback if issues

### Rolling

Deploy one instance at a time.

---

## Quick Reference

| Type | When | Cadence |
|------|------|---------|
| Hotfix | Critical bugs | As needed |
| Standard | Normal work | Weekly |
| Major | Big changes | Monthly |

---

*End of Best Practices Documentation*
