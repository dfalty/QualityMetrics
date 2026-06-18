# Code Review Best Practices

**TL;DR:** Code review is where bugs go to die—or where relationships go to die. Do it right, and it's a learning moment. Do it wrong, and you're the person everyone dreads reviewing code with.

---

## Why This Matters

Code review is your last line of defense before code hits production. It's also the best way to share knowledge across your team. A good code review catches bugs, improves code quality, and teaches everyone something.

A bad code review? That's how you get a team where nobody wants to submit PRs.

---

## For the Reviewer

### The Golden Rule

**Review the code, not the person. Be kind, be specific, be helpful.**

### What to Look For

#### 1. Correctness
- Does the code do what it's supposed to?
- Are edge cases handled?
- Are there off-by-one errors?

#### 2. Security
- Any SQL injection vulnerabilities?
- Sensitive data being logged?
- Proper authentication/authorization checks?

#### 3. Performance
- N+1 queries?
- Unnecessary loops?
- Missing indexes?

#### 4. Readability
- Is it self-documenting?
- Are variable names clear?
- Is the logic flow obvious?

#### 5. Test Coverage
- Are there tests?
- Do they actually test the right things?
- Are edge cases covered?

### How to Comment

**✅ Good:**
```
Consider using `const` here - the value never changes.

Tip: This loop could be a map() instead - more readable.
```

**❌ Bad:**
```
This is wrong.
Why would you do it this way?
This is stupid.
```

### The "Nit" Rule

- **Nits:** Minor suggestions (formatting, variable names). Keep it brief.
- ** blocking:** Issues that must be fixed (bugs, security).

Don't block on nits. You'll annoy everyone.

---

## For the Author

### Before Submitting

- [ ] Run the tests locally
- [ ] Self-review your own diff
- [ ] Don't submit code you know is broken
- [ ] Keep PRs small (< 400 lines)

### How to Write Good PR Descriptions

```markdown
## What Changed
Added user login endpoint with OAuth 2.0

## Why
Users needed to authenticate to access their data

## How
- Added /api/v1/auth/login endpoint
- Integrated with OAuth provider
- Added session management

## Testing
- [ ] Unit tests added
- [ ] Tested happy path
- [ ] Tested invalid credentials
- [ ] Tested rate limiting
```

### What NOT to Do

- Don't blind-side reviewers with 47 files
- Don't write descriptions like "fixed bugs" (what bugs?!)
- Don't take feedback personally
- Don't argue about preferences—use linters

---

## What Good Looks Like

### Reviewer Feedback

```
✅ "This looks great! One small suggestion: consider using 
   async/await here for readability."

✅ "Nit: this variable name is a bit unclear - could we call 
   it `authenticatedUser` instead?"

✅ "I think we need to handle the case where the API returns 
   a 500 here. What do you think about adding error handling?"
```

### Author Response

```
✅ "Good catch! I'll add that error handling."

✅ "I had the same thought - but decided to let the caller 
   handle it since they might want different behavior. 
   Thoughts?"
```

---

## What Bad Looks Like

### ❌ The Silent Reviewer

Never comments. Doesn't review. Your PR sits for 3 days.

**Fix:** Set SLA. "Reviews within 24 hours."

### ❌ The Nitpicker

Comments on every spacing and variable name but misses the security bug.

**Fix:** Use automated formatters/linters. Save human review for real issues.

### ❌ The Gatekeeper

Blocks everything. "We can't merge until we rewrite this in Rust."

**Fix:** Distinguish must-haves from nice-to-haves.

### ❌ The Anger

"Merged without my approval" or "This is terrible code."

**Fix:** Be professional. You're all on the same team.

---

## Process Guidelines

### PR Size Limits

| Lines Changed | Review Time | Recommendation |
|---------------|-------------|----------------|
| < 100 | 10 min | Quick review, often approve |
| 100-300 | 30 min | Standard review |
| 300-600 | 1 hour | Consider splitting |
| 600+ | Too much | MUST split |

### Review Turnaround

- **Target:** 24 hours
- **Blocker:** If stuck > 48 hours, escalate
- **Auto-assign:** Use review queues, not manual assignment

### Approvals Required

- **Standard:** 1 approval (or 2 for critical systems)
- **Security:** 2 approvals + security review
- **Hotfixes:** Can be 1 approval with notification

---

## Checklist for Reviewers

- [ ] Code compiles/runs
- [ ] Tests pass
- [ ] No security issues introduced
- [ ] No obvious bugs
- [ ] Readable and maintainable
- [ ] Error handling present
- [ ] Logging/metrics added (where appropriate)
- [ ] Documentation updated (if user-facing)

---

## Quick Reference

| Question | Answer |
|----------|--------|
| How long should a review take? | < 24 hours |
| How many lines per review? | < 300 preferred |
| Block on formatting? | No—use linters |
| Block on style preferences? | No—use style guides |
| How many approvals? | 1-2 depending on risk |

---

*Next: [Pull Request Etiquette](./pull-request-etiquette.md)*
