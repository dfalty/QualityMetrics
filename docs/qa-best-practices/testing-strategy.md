# Testing Strategy

**TL;DR:** Test where it matters most. The testing pyramid isn't a suggestion—it's the result of learning where time is best spent. This guide covers how to think about testing at a strategic level.

---

## The Testing Pyramid

```
        /\
       /  \     ← E2E Tests (5-10%)
      /____\
     /      \  ← Integration Tests (20-30%)
    /________\
   /          \ ← Unit Tests (60-70%)
  /____________\
```

### Why the Pyramid?

- **Unit tests:** Fast, cheap, reliable. Form the foundation.
- **Integration tests:** Verify that parts work together.
- **E2E tests:** Slow, expensive, flaky. The tip.

---

## What to Test

### Unit Tests

**The rule:** Test business logic, not implementation details.

```python
# ✅ Good: Tests behavior
def test_calculate_discount():
    assert calculate_discount(100, 10) == 10
    assert calculate_discount(100, 0) == 0

# ❌ Bad: Tests implementation
def test_calculate_discount():
    calculator = DiscountCalculator()
    calculator.set_rate(10)
    result = calculator.calculate(100)
    assert result == 10
```

### Integration Tests

```python
def test_create_user():
    # Creates user in database
    user = create_user(email="test@example.com")
    
    # Verifies database state
    db_user = get_user(user.id)
    assert db_user.email == "test@example.com"
    
    # Cleans up
    delete_user(user.id)
```

### E2E Tests

```python
def test_checkout_flow(page):
    page.goto("/store")
    page.click("add-to-cart")
    page.click("checkout")
    page.fill("email", "test@example.com")
    page.fill("card", "4242424242424242")
    page.click("pay")
    
    expect(page).to_have_url("*order-confirmed*")
```

---

## When to Write Tests

### Before Writing Code (TDD)

1. Write failing test
2. Write minimal code to pass
3. Refactor

**Good for:** Bug fixes, new business logic

### After Writing Code

1. Write code
2. Write tests

**Good for:** Exploratory work, experiments

---

## How Much Testing?

| Scenario | Coverage Target |
|----------|-----------------|
| New feature | 80%+ business logic |
| Bug fix | Regression tests + related |
| Hotfix | 100% of fixed behavior |
| Legacy code | Focus on critical paths |

---

## Test Execution

### In CI

```yaml
test:unit:
  script: npm run test:unit
  coverage: /Coverage: \d+.\d+%/

test:integration:
  script: npm run test:integration

test:e2e:
  script: npm run test:e2e
  when: manual
```

### Frequency

- **Unit tests:** Every commit
- **Integration tests:** Every PR
- **E2E tests:** Nightly or before release

---

## What Bad Looks Like

### ❌ Over-Reliance on E2E

"We have 500 E2E tests!"

**Reality:** Tests take 3 hours to run. Flaky. Don't catch most bugs.

### ❌ No Testing in Legacy Code

"The old code doesn't have tests."

**Fix:** Add tests when you touch that code. Don't rewrite everything.

### ❌ Testing Everything

"We need 100% coverage!"

**Reality:** Testing boilerplate is waste.

---

## Quick Reference

| Question | Answer |
|----------|--------|
| Priority? | Unit → Integration → E2E |
| E2E tests limit? | 10-20 critical paths |
| When to skip tests? | Almost never |
| Coverage target? | 70-80% business logic |

---

*Next: [Performance Optimization](./performance.md)*
