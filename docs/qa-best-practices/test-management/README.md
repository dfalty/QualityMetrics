# Test Case Standards

**TL;DR:** Write test cases like you're explaining to a smart coworker what your code should do. If you can't explain it simply, your test case is too complicated. If your test case is 47 steps long, something is wrong with your requirements.

---

## Why This Matters

We've all been there. You pick up a ticket, look at the test case, and have no idea what it's actually testing. Or worse—you write a test case that passes perfectly but somehow misses the bug that crashes production at 2am.

This guide prevents that. These are the standards our team uses. They're not perfect, but they've saved us from shipping garbage more times than we can count.

---

## Test Case Structure

Every test case needs these fields. Nothing more, nothing less.

### The Basics

```markdown
Test Case ID: TC-[AREA]-[NUMBER]
Title: [What you're testing - keep it under 10 words]
Priority: P0 / P1 / P2 / P3
Type: Functional / Regression / Smoke / Exploratory
```

### Test Case Body

```
Preconditions:
- What needs to be true before you start
- Logged in user, specific data in DB, etc.

Test Data:
- Specific values you're using
- Not "valid email" but "test@company.com"

Steps:
1. Do X
2. Do Y  
3. Verify Z

Expected Result:
- What should happen
- Be specific: "User sees error message" is bad. 
  "User sees 'Invalid email format' in red text below 
  the email field" is good.
```

### Post-conditions

```
Cleanup:
- What to do after (delete test data, reset state)
```

---

## What Good Looks Like

### ✅ Good Test Case

```
Test Case ID: TC-LOGIN-001
Title: Successful login with valid credentials

Priority: P0
Type: Functional

Preconditions:
- User account exists with email: qa-test@company.com
- Password: TestPass123!

Test Data:
- Email: qa-test@company.com
- Password: TestPass123!

Steps:
1. Navigate to /login
2. Enter qa-test@company.com in email field
3. Enter TestPass123! in password field
4. Click "Sign In" button

Expected Result:
- User is redirected to dashboard within 3 seconds
- URL changes to /dashboard
- No error messages displayed
- Session cookie is set

Cleanup:
- Delete test user from system (or mark as inactive)
```

### ❌ Bad Test Case

```
Test Case ID: TC-LOGIN-999
Title: Login functionality

Priority: (left blank)

Steps:
1. Go to login page
2. Enter credentials
3. Click login
4. Verify successful login
```

This is useless. What credentials? What does "successful login" even mean? How is anyone supposed to execute this consistently?

---

## Naming Conventions

### Test Case IDs

Format: `TC-[AREA]-[NUMBER]`

```
TC-LOGIN-001      → Login feature
TC-PAYMENT-001   → Payment feature  
TC-DASHBOARD-001 → Dashboard feature
TC-API-USER-001  → User API endpoints
```

### File Names (for test automation)

```
# Bad
test_login.py
TestPayment.java
MyCoolTest.js

# Good  
test_login__valid_credentials.py
test_login__invalid_password.py  
test_payment__card_declined.py
```

Pattern: `test_[area]__[specific_scenario].py`

---

## Test Case Priority Guidelines

| Priority | When to Use | Example |
|----------|-------------|----------|
| **P0** | Core functionality, data loss risk, security | "User can access their own data only" |
| **P1** | Important features, workarounds exist | "Password reset email arrives" |
| **P2** | Moderate impact, edge cases | "Email validation rejects invalid formats" |
| **P3** | Nice to have, minor UI issues | "Button tooltip text is correct" |

**Real talk:** If everything is P0, nothing is P0. Be honest about priorities. Your P0 tests should run in every build. Your P3 tests might run weekly.

---

## Coverage Guidelines

### Minimum Coverage by Type

| Feature Type | Minimum Coverage |
|--------------|-------------------|
| New feature | 80% positive paths, key negative paths |
| Bug fix | Regression test for the bug + related areas |
| API endpoint | Happy path + validation errors |
| UI form | All required field validations + happy path |

### When You Need More Tests

- **Security-sensitive areas:** Auth, payments, data access → P0 coverage required
- **Third-party integrations:** Mock and real tests → both required
- **Data migrations:** Rollback tests → always required
- **Performance-critical paths:** Load tests → required before release

---

## Test Case Review Checklist

Before marking a test case as "Ready," verify:

- [ ] Title clearly describes what's being tested
- [ ] Preconditions are achievable and documented
- [ ] Test data is specific (not "valid data")
- [ ] Steps are numbered and sequential
- [ ] Expected result is verifiable and objective
- [ ] Cleanup is documented
- [ ] Priority is set and justified
- [ ] Related test cases are linked (if any)

---

## Common Mistakes We Made (So You Don't Have To)

### 1. Writing Tests Before Understanding Requirements

**The trap:** "I'll just write the test case while I'm in the code."

**The result:** Tests that verify implementation details, not user behavior. Tests that have to be rewritten when the UI changes slightly.

**Fix:** Write test cases from requirements / user stories first. The test case should read like a user would describe the feature.

### 2. Over-Testing Happy Path

**The trap:** 47 test cases for "user can successfully complete purchase" and 1 for "error handling."

**The result:** You ship with confidence, then the payment processor goes down and nobody knows what happens.

**Fix:** Aim for 60/40 positive to negative coverage. The world is full of edge cases.

### 3. Test Cases That Assume Too Much Context

**The trap:** "User logs in" as a precondition when you mean "User with specific permissions logs in."

**The result:** Flaky tests that pass sometimes depending on who ran them last.

**Fix:** Be explicit. If it matters, write it down.

---

## Tools We Use

- **Test management:** Jira, TestRail, or (honestly) a well-organized spreadsheet if you're small
- **Automation:** See [../test-automation/README.md](../test-automation/README.md)
- **Execution:** CI/CD pipeline with reporting

---

## Quick Reference

| Question | Answer |
|----------|--------|
| How detailed should steps be? | Enough that someone who's never seen the feature can execute it |
| How many steps is too many? | If you're over 15 steps, consider breaking into multiple test cases |
| What if I don't know the expected result? | That's a requirements problem, not a testing problem. Fix requirements first. |
| Can I skip test cases for MVP? | You can skip coverage, but document what you're not testing and why |

---

*End of test case standards. Next up: [Test Automation Standards](../test-automation/README.md)*
