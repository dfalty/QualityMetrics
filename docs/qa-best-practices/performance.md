# Performance Optimization

**TL;DR:** Premature optimization is the root of all evil. But ignoring performance until "later" is how you get 47-second page loads. This guide covers when to care about performance and how to do it right.

---

## Why This Matters

We've all been there: "We'll optimize later." Then later is when users are leaving because the site takes 10 seconds to load. Or when your database can't handle the load.

This guide prevents that. It's about knowing when to care, and when "good enough" is actually good enough.

---

## The Performance Budget

Define what "fast enough" means:

- **First Contentful Paint:** < 1.5s
- **Time to Interactive:** < 3s
- **API Response:** < 200ms (p95)
- **Database Queries:** < 100ms (p95)

---

## Common Performance Issues

### N+1 Queries

```python
# ❌ Bad: N+1 queries
users = get_all_users()
for user in users:
    orders = get_orders_for_user(user.id)  # Query per user!
    
# ✅ Good: Single query with join
users = db.query("""
    SELECT u.*, o.*
    FROM users u
    LEFT JOIN orders o ON u.id = o.user_id
""")
```

### Missing Indexes

```sql
-- ❌ Bad: Full table scan
SELECT * FROM users WHERE email = 'test@example.com';

-- ✅ Good: Indexed lookup
CREATE INDEX idx_users_email ON users(email);
```

### Not Caching

```python
# ❌ Bad: Fetch from DB every time
def get_user(email):
    return db.query("SELECT * FROM users WHERE email = ?", email)

# ✅ Good: Cache expensive lookups
def get_user(email):
    cache_key = f"user:{email}"
    user = cache.get(cache_key)
    if not user:
        user = db.query("SELECT * FROM users WHERE email = ?", email)
        cache.set(cache_key, user, ttl=300)
    return user
```

---

## Profiling

### Finding the Slow Part

```python
# Python: cProfile
import cProfile
cProfile.run('expensive_function()')

# Node: Built-in profiler
node --prof app.js
```

### Database Query Analysis

```sql
-- PostgreSQL: EXPLAIN ANALYZE
EXPLAIN ANALYZE 
SELECT * FROM orders 
WHERE user_id = 123 
AND status = 'active';
```

---

## Frontend Optimization

### Minimize Requests

```html
<!-- ❌ Bad: Multiple small requests -->
<script src="a.js"></script>
<script src="b.js"></script>
<script src="c.js"></script>

<!-- ✅ Good: Bundled -->
<script src="bundle.js"></script>
```

### Optimize Images

```html
<!-- Responsive images -->
<img src="small.jpg" srcset="small.jpg 500w, large.jpg 1000w">

<!-- Modern formats -->
<picture>
  <source srcset="image.avif" type="image/avif">
  <source srcset="image.webp" type="image/webp">
  <img src="image.jpg" alt="Description">
</picture>
```

### Lazy Loading

```javascript
// Only load when needed
const heavyModule = () => import('./heavy.js');
```

---

## Caching Strategies

### Cache-Aside

```
1. Check cache
2. If miss: fetch from DB
3. Store in cache
4. Return
```

### Time-Based Expiry

```python
# Cache for 5 minutes
cache.set(key, value, ttl=300)
```

### Invalidation

The hardest problem. When data changes, update cache:

```python
def update_user(user):
    db.update(user)
    cache.delete(f"user:{user.id}")
    cache.delete("users:list")  # If list changes
```

---

## Quick Reference

| Question | Answer |
|----------|--------|
| When to optimize? | When it matters to users |
| How to measure? | Profiling tools |
| Target API latency? | < 200ms p95 |
| Target DB query? | < 100ms p95 |

---

*Next: [Accessibility Standards](./accessibility.md)*
