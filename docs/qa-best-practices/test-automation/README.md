# Test Automation Standards

**TL;DR:** Automation is not the goal. Faster feedback is. If your automation takes more time to maintain than it saves, you're doing it wrong. This guide covers how we write automation that actually scales.

---

## Why This Matters

Every team that gets serious about automation hits a wall. At first, it's great. Tests run fast, bugs are caught early, everyone loves it.

Then comes the wall.

- Tests start failing for the wrong reasons
- Nobody wants to update the test suite because it's "too fragile"
- CI runs take 47 minutes
- The team spends more time fixing tests than writing features

This guide prevents that. These are the standards that keep automation valuable.

---

## Framework Selection

### What We Use (And Why)

| Layer | Tool | Why |
|-------|------|-----|
| **E2E UI** | Playwright | Better than Selenium. Works offline. Better selectors. |
| **API** | Playwright (REST) or PyTest | Same tool, fewer frameworks |
| **Unit** | Whatever your dev team uses | Don't reinvent |

### Framework Rules

1. **One framework per layer.** Not Playwright AND Selenium AND Cypress. Pick one.

2. **Stick with what works.** If your team knows Cypress, don't switch to Playwright because a blog post said so.

3. **If it requires a dedicated automation team to maintain, it's too complex.**

---

## Test Architecture

### The Pyramid (Still Works)

```
        /\
       /  \     ← Few, expensive E2E tests (5-10%)
      /____\
     /      \    ← More API/integration tests (20-30%)
    /________\
   /          \  ← Many, fast unit tests (60-70%)
  /____________\
```

**The point:** Most of your coverage should be at the bottom. E2E tests are slow and fragile. They should be the thin tip of the pyramid, not the whole thing.

### Directory Structure

```
tests/
├── unit/                    # Unit tests (dev team ownership)
├── api/                    # API tests
│   ├── test_users.py
│   ├── test_payments.py
│   └── conftest.py         # Shared fixtures
├── e2e/                    # E2E tests (QA ownership)
│   ├── login/
│   ├── payments/
│   └── conftest.py
└── fixtures/               # Shared test data
    ├── users.json
    └── test_data.py
```

---

## Writing Tests That Don't Suck

### The Golden Rule

**If a manual tester can't understand what your test is doing, your test is too complex.**

### Good Test Structure

```python
# test_login__valid_credentials.py

def test_login__valid_credentials(page):
    """User can log in with valid email and password."""
    
    # Arrange - explicit setup
    user = create_test_user(email="qa@test.com")
    
    # Act - simple action
    page.goto("/login")
    page.fill("[name=email]", "qa@test.com")
    page.fill("[name=password]", "TestPass123!")
    page.click("button[type=submit]")
    
    # Assert - clear verification
    expect(page).to_have_url("/dashboard")
    expect(page.locator(".user-name")).to_contain_text("QA Test")
```

### What Bad Looks Like

```python
# DON'T DO THIS
def test_login():
    """Test login functionality."""
    # What functionality?? No idea from this test
    login("qa@test.com", "password")
    assert "logged in"  # What does that even mean?
```

### Selectors (The Right Way)

**Use semantic, stable selectors in this priority:**

1. **Test IDs** (best): `data-testid="login-submit-btn"`
2. **Semantic HTML:** `button[type="submit"]`
3. **Text content:** `page.get_by_text("Sign In")`
4. **CSS/Locator last resort:** `.login-form .submit`

**Never use:**
- Auto-generated IDs like `ember1234`
- Fragile XPaths like `/html/body/div[2]/div[1]/form/button`
- Position-dependent selectors like `:nth-child(3)`

---

## Handling Flaky Tests

### What Makes Tests Flaky

- **Race conditions:** Test runs before the page loads
- **Shared state:** Tests depend on each other's data
- **Network instability:** API calls timeout randomly
- **Environment issues:** Works on dev machine, fails in CI

### Our Anti-Flake Rules

#### 1. Always Wait (But Not Forever)

```python
# ❌ Bad - hope it loads in time
page.click("button")

# ❌ Bad - arbitrary sleep
time.sleep(3)

# ✅ Good - explicit wait for element
page.wait_for_selector("button[type=submit]", state="visible")
page.click("button")

# ✅ Good - wait for navigation
page.click("button")
page.wait_for_url("**/dashboard")
```

#### 2. Isolate Tests

```python
# ❌ Bad - shared data
def test_user_sees_data():
    user = get_or_create_user()  # Might exist from other test
    ...

# ✅ Good - create fresh data per test
@pytest.fixture
def unique_user():
    return create_user(email=f"test-{uuid4()}@test.com")

def test_user_sees_their_data(unique_user):
    login_as(unique_user)
    ...
```

#### 3. Clean Up After Yourself

```python
@pytest.fixture
def test_user():
    user = create_user()
    yield user
    # Cleanup runs after test
    delete_user(user.id)
```

---

## Maintenance Patterns

### The 30-Day Rule

If a test consistently fails for 30 days without being fixed, delete it. It's not testing anything. It's just noise.

### When to Update Tests

- UI changed? Update selectors only.
- Behavior changed? Update assertions.
- Feature removed? Delete the test.
- Test is confusing? Rewrite it.

### When NOT to Update Tests

- "It fails sometimes but passes on retry" → Fix the root cause
- "It passes locally but fails in CI" → Fix the environment mismatch
- "Nobody knows what this tests" → Delete and rewrite

---

## CI/CD Integration

### Running Tests

```bash
# Local development
pytest tests/ -v

# CI Pipeline
# 1. Run unit tests first (fast)
pytest tests/unit/ --cov

# 2. Run API tests (medium)
pytest tests/api/ -v

# 3. Run E2E tests last (slow)
playwright test tests/e2e/ --reporter=html
```

### Pipeline Best Practices

1. **Fail fast:** Run fastest tests first
2. **Parallelize:** Split tests across workers
3. **Report:** Use HTML reporters for debugging
4. **Retry once:** For known flaky tests, single retry is OK. More is not.
5. **Track time:** If tests take >30 min, something is wrong

---

## Code Review for Tests

### Review Checklist

- [ ] Test name describes what it tests
- [ ] No shared state between tests
- [ ] Selectors are stable (not fragile)
- [ ] Assertions are specific
- [ ] Cleanup is handled
- [ ] Test can run independently
- [ ] No sleeps or arbitrary waits

### Who Owns What

| Test Type | Owner | Reason |
|-----------|-------|--------|
| Unit | Developers | Know the code best |
| API | Developers + QA | Both care about contracts |
| E2E | QA | User-focused, end-to-end |

---

## Common Mistakes

### 1. Automating Everything

**The trap:** "If it's testable, we should automate it."

**The reality:** Some things cost more to automate than to test manually. Some things can't be automated (captcha, complex verification).

**The fix:** Use the ROI rule. If it takes longer to automate than to manual test repeatedly, skip it.

### 2. Treating E2E Like Unit Tests

**The trap:** 500 E2E tests because "we want full coverage."

**The result:** CI takes 2 hours. Tests fail randomly. Nobody runs them locally.

**The fix:** Keep E2E tests to 10-20 core user journeys. Let lower-level tests provide coverage.

### 3. Ignoring Test Maintenance

**The trap:** "We'll fix the tests later."

**The result:** Technical debt accumulates. Eventually, the suite is unusable.

**The fix:** Budget 20% of automation time for maintenance. If tests need more, refactor.

---

## Quick Reference

| Question | Answer |
|----------|--------|
| How many E2E tests? | 10-20 critical paths |
| How long should CI take? | < 30 minutes |
| How to handle flaky tests? | Fix root cause, don't just retry |
| Who writes unit tests? | Developers (that's their job) |
| Can I use Page Object Model? | Yes, but don't over-engineer it |

---

*Next: [Shift-Left Testing](../shift-left/README.md)*
