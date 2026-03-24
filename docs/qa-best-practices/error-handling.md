# Error Handling

**TL;DR:** Errors happen. What matters is how you handle them. Good error handling means your app doesn't crash, users get helpful feedback, and you can actually debug when things go wrong. This guide covers what works in practice.

---

## Why This Matters

We've all seen it: "An error occurred. Please try again." That's lazy error handling. Or worse: the app crashes with a stack trace that exposes your database schema.

This guide prevents that. Good error handling is invisible when things work, and helpful when they don't.

---

## The Error Handling Pyramid

```
User-Facing Errors (friendly messages)
        ↑
API Errors (structured responses)  
        ↑
Logging (for debugging)
        ↑
Recovery (try to fix it)
```

---

## Rule 1: Fail Gracefully

### User-Facing Errors

```python
# ❌ Bad: Exposes internals
try:
    process_payment()
except Exception as e:
    # Never do this in production!
    return f"Error: {str(e)}"

# ✅ Good: Friendly message
try:
    process_payment()
except PaymentDeclinedError:
    return {"error": "Your card was declined. Please try another card."}
except InsufficientFundsError:
    return {"error": "Insufficient funds. Please try another payment method."}
except Exception:
    logger.exception("Unexpected payment error")
    return {"error": "Something went wrong. Please try again."}
```

### What to Include

- What happened (in plain English)
- What the user can do (try again? contact support?)
- A reference ID (for debugging)

```json
{
  "error": {
    "code": "PAYMENT_FAILED",
    "message": "Your card was declined. Please try another card.",
    "user_action": "Try a different payment method or contact your bank.",
    "reference_id": "evt_abc123"
  }
}
```

---

## Rule 2: Log for Debugging

### Structured Logging

```python
# ✅ Good: Structured logging
logger.error("payment_failed", extra={
    "user_id": user.id,
    "amount": amount,
    "error_code": "declined",
    "trace_id": trace_id
})

# ❌ Bad: String interpolation
logger.error(f"Payment failed for user {user.id}")
```

### Log Levels

| Level | Use For |
|-------|---------|
| ERROR | Failures that need attention |
| WARNING | Recoverable issues |
| INFO | Normal operations |
| DEBUG | Detailed debugging |

---

## Rule 3: Handle at the Right Level

### Don't Catch Everything

```python
# ❌ Bad: Catches everything, hides bugs
try:
    result = risky_operation()
except Exception:
    result = None

# ✅ Good: Specific exceptions
try:
    result = risky_operation()
except ValueError:
    # Handle invalid input specifically
    return {"error": "Invalid input"}
except TimeoutError:
    # Handle timeout specifically  
    return {"error": "Request timed out. Please try again."}
# Let unexpected exceptions propagate
```

### The Exception Hierarchy

```
BaseException
 ├── KeyboardInterrupt (don't catch)
 └── Exception
      ├── ValueError
      ├── TypeError
      └── CustomError
```

Only catch what you can handle.

---

## Rule 4: Consistent Error Responses

### API Error Format

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [
      {
        "field": "email",
        "message": "Must be a valid email"
      },
      {
        "field": "password", 
        "message": "Must be at least 8 characters"
      }
    ],
    "reference_id": "req_abc123"
  }
}
```

### Use HTTP Status Codes Correctly

| Status | Use When |
|--------|----------|
| 400 | Bad Request - client sent invalid data |
| 401 | Unauthorized - not logged in |
| 403 | Forbidden - logged in but not allowed |
| 404 | Not Found - resource doesn't exist |
| 422 | Unprocessable Entity - valid but can't process |
| 429 | Too Many Requests - rate limited |
| 500 | Internal Error - server broke |

---

## Rule 5: Graceful Degradation

### Circuit Breaker

```python
class CircuitBreaker:
    def __init__(self, failure_threshold=5):
        self.failures = 0
        self.threshold = failure_threshold
        self.state = "closed"  # closed, open, half-open
    
    def call(self, func):
        if self.state == "open":
            raise CircuitOpenError()
        
        try:
            result = func()
            self.failures = 0
            self.state = "closed"
            return result
        except Exception:
            self.failures += 1
            if self.failures >= self.threshold:
                self.state = "open"
            raise
```

### Fallback Responses

```python
def get_user_data(user_id):
    # Try cache first
    try:
        return cache.get(f"user:{user_id}")
    except CacheError:
        pass
    
    # Try database
    try:
        return db.query("SELECT * FROM users WHERE id = ?", user_id)
    except DBError:
        # Fallback to stale cache
        return cache.get_stale(f"user:{user_id}")
```

---

## What Bad Looks Like

### ❌ Silent Failures

```python
try:
    send_email()
except:
    pass  # Swallowed!
```

**Fix:** Always log. At minimum, log at ERROR level.

### ❌ Catching BaseException

```python
try:
    process()
except BaseException:  # Catches everything including KeyboardInterrupt!
    pass
```

**Fix:** Never catch BaseException. Catch Exception or specific types.

### ❌ Raw Exceptions to Users

```python
return {"error": str(e)}  # Shows internal details!
```

**Fix:** Always return sanitized, user-safe messages.

---

## Quick Reference

| Question | Answer |
|----------|--------|
| Catch what? | Specific exceptions |
| Log level? | ERROR for failures |
| Show users? | Friendly messages only |
| Consistent? | Same format everywhere |

---

*Next: [Documentation Standards](./documentation.md)*
