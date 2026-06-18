# Shift-Left Testing

**TL;DR:** Find bugs when they're cheap to fix, not when they cost you a weekend. Shift-left means testing earlier in the development cycle—thinking about quality from the first line of code, not the last.

---

## Why This Matters

Here's a number that'll make you wince: **The average cost to fix a bug multiplies by 6x between development and production.**

| Stage Found | Relative Cost |
|-------------|---------------|
| Requirements | 1x |
| Development | 6x |
| Testing | 15x |
| Production | 100x |

Shift-left isn't a buzzword. It's an economic decision. Catch it early, fix it cheap.

---

## What Shift-Left Actually Means

It's not "move all testing to developers" (that's not sustainable). It's not "delete your QA team" (that's stupid).

It's this: **Make testing a shared responsibility throughout the cycle, with more emphasis on early stages.**

```
Traditional:
Requirements → Dev → QA → Release

Shift-Left:
Requirements → [Test] → Dev → [Test] → QA → [Test] → Release
                  ↑              ↑            ↑
              Reviews        Unit tests   Integration
              Static         TDD           Contracts
```

---

## Core Practices

### 1. Requirements Review (Before Coding Starts)

**What:** Review user stories and requirements for testability before anyone writes code.

**Why:** Half of bugs come from unclear requirements. Catch that before you write a single line.

**How:**

```
Checklist for requirements review:
- [ ] Are acceptance criteria specific and measurable?
- [ ] Can we verify this without manual testing?
- [ ] What are the edge cases?
- [ ] What happens if we get this wrong? (risk assessment)
- [ ] Are there any ambiguous terms?
```

**What good looks like:**
```
❌ Bad: "User should be able to upload a file"
✅ Good: "User can upload CSV files up to 10MB. 
         Files over 10MB show inline error. 
         Invalid file types show inline error."
```

### 2. Static Analysis & Linting

**What:** Automated checks on code before it runs.

**Tools:**
- ESLint / TSLint for JS/TS
- Pylint / Black for Python
- SonarQube for code quality

**What it catches:**
- Syntax errors
- Security vulnerabilities (SQL injection, hardcoded secrets)
- Code smells (duplicate code, complexity issues)
- Style violations

**How to integrate:**
```yaml
# Pre-commit hook (example)
repos:
  - repo: local
    hooks:
      - id: lint
        name: lint
        entry: npm run lint
        language: system
        stages: [pre-commit]
```

### 3. Developer Testing (Unit + TDD)

**What:** Developers write tests for their code.

**Not controversial anymore:** If your developers aren't writing unit tests, you have a hiring or culture problem, not a testing problem.

**What to test:**
- Business logic
- Edge cases
- Error handling
- Data transformations

**What NOT to test:**
- Boilerplate (getters, setters, constructors)
- Code that wraps framework calls
- Third-party code

### 4. Contract Testing

**What:** Verify that APIs work as promised, between services.

**The problem:** Service A breaks Service B's API, neither notices until production.

**The solution:** Contract tests.

```python
# Example: Consumer-driven contract
# Service B says: "I promise to respond like this"

def test_user_endpoint_contract():
    response = client.get("/users/1")
    
    expect(response.status_code).to_equal(200)
    expect(response.json()).to_have_keys([
        "id", "email", "name", "created_at"
    ])
    expect(response.json()["email"]).to_match(
        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    )
```

**Tools:**
- Pact (consumer-driven contracts)
- WireMock (mock services)
- Postman contract testing

### 5. Integration Testing

**What:** Test how components work together, not in isolation.

**When:** After unit tests pass, before E2E.

**Example:**
```python
def test_order_workflow():
    # Create order
    order = create_order(items=[item1, item2])
    
    # Process payment
    payment = process_payment(order.id, "valid_card")
    
    # Verify order state
    order = get_order(order.id)
    expect(order.status).to_equal("paid")
    
    # Verify inventory
    inventory = get_inventory(item1.id)
    expect(inventory.available).to_equal(98)  # 2 were ordered
```

---

## Quality Gates

These are the checkpoints that must pass before moving forward:

### Before Code Review

- [ ] All unit tests pass
- [ ] Linting passes
- [ ] No new security vulnerabilities introduced
- [ ] Code coverage doesn't decrease (if tracking)

### Before Merging to Main

- [ ] All integration tests pass
- [ ] Contract tests pass
- [ ] Manual smoke tests pass (if applicable)
- [ ] No high-severity bugs open

### Before Release

- [ ] E2E regression tests pass
- [ ] Performance tests pass (if applicable)
- [ ] Security scan passes
- [ ] Rollback plan ready

---

## Shared Ownership Model

| Phase | Primary | Secondary |
|-------|---------|-----------|
| Requirements | Product | QA, Engineering |
| Design | Engineering | QA |
| Development | Engineering | QA (review) |
| Unit Testing | Engineering | - |
| Integration | Engineering | QA |
| E2E Testing | QA | Engineering |
| Production | SRE | Everyone |

**The key insight:** Everyone owns quality. QA is not a gatekeeper—they're a guide and specialist.

---

## What Bad Looks Like

### ❌ Waiting Until "Done" to Test

```
Dev: "I'll finish the feature, then test it."
   → Bugs found at 5pm Friday
   → Fix goes in Monday
   → Nobody remembers what changed
   → Production incident
```

### ❌ Handing Off to QA as a Black Box

```
Dev: "It's ready for QA."
QA: *finds 47 bugs*
   → Finger-pointing
   → Deadlines missed
   → Resentment
```

### ❌ "Shift Left" Means "No QA"

```
Manager: "We're doing shift-left now. We don't need QA."
   → Quality crashes
   → Developers hate testing
   → Manual regression takes forever
   → Eventually, QA gets hired back at 3x cost
```

---

## What Good Looks Like

### ✅ Early and Often

```
Ticket created → QA reviews for testability
                    ↓
Code written → Developer writes unit tests
                    ↓
PR opened → Code review + automated checks
                    ↓
Merged → Contract tests + integration tests
                    ↓
Release → E2E smoke + monitoring
```

### ✅ Collaborative

- QA helps write test cases for complex features
- Developers explain architecture to QA
- QA provides feedback on requirements
- Everyone knows what "done" means

---

## Implementation Checklist

### Week 1-2: Foundation
- [ ] Set up linting in CI
- [ ] Add pre-commit hooks
- [ ] Define code review checklist

### Week 3-4: Developer Tests
- [ ] Set up test framework
- [ ] Define coverage targets (start at 60%)
- [ ] Add to CI pipeline

### Week 5-8: Integration
- [ ] Add integration test layer
- [ ] Set up contract testing (start with key services)
- [ ] Define quality gates

### Ongoing
- [ ] Review and refine requirements
- [ ] Add new quality gates as needed
- [ ] Measure: bug escape rate, time-to-fix, test coverage

---

## Common Objections (And Responses)

### "We don't have time for this"

**Response:** You don't have time NOT to do this. A production bug costs 100x more than preventing it.

### "Developers won't write tests"

**Response:** Then hire developers who will. It's part of the job. Model the behavior yourself.

### "QA will be out of a job"

**Response:** QA shifts to strategy, exploratory testing, and complex scenarios. That's more valuable work anyway.

---

## Quick Reference

| Practice | When | Who |
|----------|------|-----|
| Requirements review | Before coding | Product + QA |
| Static analysis | Every commit | CI |
| Unit tests | Every PR | Developer |
| Contract testing | Integration | Dev + QA |
| Integration testing | Pre-merge | CI |
| E2E testing | Pre-release | QA |

---

*Next: [AI-Enhanced Testing](../ai-testing/README.md)*
