# Database Standards

**TL;DR:** Databases aren't magic. They're just storage, with all the same problems as file storage—plus more. This guide covers what you need to know to not lose data,的性能, and your sanity.

---

## Why This Matters

We've seen companies lose hours of data because "we didn't think about backups." We've seen performance crumble because "it worked fine with 100 users." We've seen 4am pages because "who knew a simple query could lock the whole table?"

This guide prevents that. Basic database hygiene that would have saved us all those nights.

---

## Schema Design

### Naming Conventions

```sql
-- Tables: plural, snake_case
CREATE TABLE users;
CREATE TABLE order_items;

-- Columns: snake_case
user_id
created_at
is_active

-- Primary keys
id (auto-incrementing integer) OR
uuid (universally unique identifier)

-- Foreign keys
user_id REFERENCES users(id)
```

### Required Fields

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    -- Always have these:
    -- created_at: when record was created
    -- updated_at: when record was last modified
);
```

### Soft Deletes (Usually)

```sql
-- ❌ Bad: Hard delete
DELETE FROM users WHERE id = 123;

-- ✅ Good: Soft delete
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMP;
UPDATE users SET deleted_at = NOW() WHERE id = 123;

-- Query with filter
SELECT * FROM users WHERE deleted_at IS NULL;
```

---

## Query Performance

### Indexes

**When to index:**
- Foreign keys (always)
- Columns in WHERE clauses
- Columns in JOIN conditions
- Columns in ORDER BY

**When NOT to index:**
- Low-cardinality columns (sex, boolean)
- Frequently updated columns
- Tables < 1000 rows (overhead > benefit)

```sql
-- Basic index
CREATE INDEX idx_users_email ON users(email);

-- Composite index
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Partial index
CREATE INDEX idx_orders_active ON orders(created_at) 
WHERE status = 'active';
```

### N+1 Queries

**❌ Bad:**
```python
for user in users:
    print(user.name, user.orders)  # Each order triggers a query!
```

**✅ Good:**
```python
# Eager load
users = db.query("SELECT * FROM users").join('orders')

# Or with SQLAlchemy
users = session.query(User).options(joinedload(User.orders))
```

### Query Review Checklist

- [ ] Index used? (EXPLAIN ANALYZE)
- [ ] SELECT only needed columns?
- [ ] No SELECT * (unless debugging)
- [ ] Pagination used?
- [ ] No LIKE '%startswith%' (can't use index)

---

## Migrations

### Best Practices

1. **Always backup before migration**
2. **Test on staging first**
3. **Small, reversible migrations**
4. **Never modify migration after running in prod**

### Migration Template

```python
# 001_add_users_table.py

def upgrade():
    # Create table
    db.execute("""
        CREATE TABLE users (
            id SERIAL PRIMARY KEY,
            email VARCHAR(255) NOT NULL
        );
    """)
    
    # Add index
    db.execute("""
        CREATE INDEX idx_users_email ON users(email);
    """)

def downgrade():
    db.execute("DROP TABLE users;")
```

### Zero-Downtime Migrations

```python
# ❌ Bad: Can't add NOT NULL without table lock
ALTER TABLE users ADD COLUMN name VARCHAR(255) NOT NULL;

# ✅ Good: Add nullable first
ALTER TABLE users ADD COLUMN name VARCHAR(255);
UPDATE users SET name = 'unknown' WHERE name IS NULL;
ALTER TABLE users ALTER COLUMN name SET NOT NULL;
```

---

## Backups

### The 3-2-1 Rule

- **3** copies of data
- **2** different storage types
- **1** offsite

### Implementation

```yaml
# Example: PostgreSQL backup strategy
backup:
  # Daily full backup
  - pg_dump -Fc mydb > /backup/daily/mydb_$(date +%Y%m%d).dump
  
  # WAL archiving for point-in-time recovery
  - wal_archive: /backup/wal/
  
  # Weekly offsite sync
  - aws s3 sync /backup s3://company-backups/
```

### Testing Backups

You better hope you never need it, but:
- Test restores monthly
- Document restore procedure
- Verify checksums

---

## Connection Management

### Connection Pooling

```python
# ❌ Bad: New connection per request
def get_user(id):
    conn = psycopg2.connect(DATABASE_URL)
    # ...
    conn.close()

# ✅ Good: Connection pool
pool = psycopg2.pool.SimpleConnectionPool(
    minconn=5,
    maxconn=20,
    dsn=DATABASE_URL
)

def get_user(id):
    conn = pool.getconn()
    # ...
    pool.putconn(conn)
```

### ORM Settings

```python
# SQLAlchemy example
engine = create_engine(
    DATABASE_URL,
    pool_size=10,
    max_overflow=20,
    pool_pre_ping=True,  # Verify connection works
    pool_recycle=3600,   # Recycle after 1 hour
)
```

---

## What Bad Looks Like

### ❌ No Foreign Keys

```sql
-- Users can have non-existent roles!
CREATE TABLE users (
    role_id INTEGER  -- No REFERENCES
);
```

**Fix:** Always use foreign keys. Enforce integrity.

### ❌ SELECT *

```sql
SELECT * FROM orders;  -- Grabs all columns, all rows
```

**Fix:** SELECT only needed columns.

### ❌ No Pagination

```sql
SELECT * FROM users;  -- Returns 10 million rows
```

**Fix:** LIMIT and OFFSET or cursor-based pagination.

---

## Quick Reference

| Question | Answer |
|----------|--------|
| SELECT * allowed? | Never in code |
| Backups tested? | Monthly |
| Max connection pool? | Based on DB max connections / 2 |
| Migration approach? | Additive preferred |

---

*Next: [Monitoring & Observability](./monitoring.md)*
