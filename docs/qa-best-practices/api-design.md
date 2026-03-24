# API Design Best Practices

**TL;DR:** Your API is someone's interface to your system. Make it pleasant to use. Don't make developers cry.

---

## Why This Matters

We've all dealt with terrible APIs. The ones that return different error formats on different endpoints. The ones where you need a PhD to figure out how to create a user. The ones that return `200 OK` when something clearly went wrong.

This guide prevents that. Good APIs are intuitive, consistent, and forgiving. Bad APIs cause support tickets, developer frustration, and late-night debugging sessions.

---

## Core Principles

### 1. Use Nouns for Resources, Verbs for Operations

**The rule:** URIs should represent resources (nouns), not actions (verbs).

```http
# ✅ Good
GET    /users
POST   /users
GET    /users/123
DELETE /users/123

# ❌ Bad
POST   /createUser
GET    /getUserById
POST   /deleteUser
```

**The exception:** RPC-style endpoints for operations that don't map naturally to REST resources.

```http
POST   /users/123/activate
POST   /orders/456/cancel
POST   /reports/generate
```

### 2. Use HTTP Methods Correctly

| Method | Use For | Idempotent? |
|--------|---------|-------------|
| GET | Retrieve resources | Yes |
| POST | Create resources | No |
| PUT | Replace entire resource | Yes |
| PATCH | Partial update | No |
| DELETE | Remove resource | Yes |

**What idempotent means:** Calling the same request multiple times produces the same result. `DELETE /users/123` called twice should both return 404 (already deleted).

### 3. Use Plural Nouns for Collections

```http
# ✅ Good
GET /users
GET /orders

# ❌ Bad
GET /user
GET /order
```

### 4. Use Nested Resources for Relationships

```http
# User's orders
GET /users/123/orders

# Order's line items
GET /orders/456/items

# Avoid flat structures when relationships exist
# ❌ Bad: GET /order-items?order_id=456
```

---

## Response Formats

### Consistent Error Responses

**The golden rule:** Same error structure everywhere.

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Invalid input",
    "details": [
      {
        "field": "email",
        "message": "Must be a valid email address"
      }
    ]
  }
}
```

### Error Codes to Use

| Code | When to Use |
|------|-------------|
| 400 | Bad Request - client sent something invalid |
| 401 | Unauthorized - missing or invalid auth |
| 403 | Forbidden - authenticated but not allowed |
| 404 | Not Found - resource doesn't exist |
| 409 | Conflict - state mismatch (like version conflicts) |
| 422 | Unprocessable Entity - valid request, can't process |
| 429 | Too Many Requests - rate limited |
| 500 | Internal Error - server exploded (never expose internal details) |

### Success Responses

```json
// GET /users/123
{
  "data": {
    "id": 123,
    "email": "user@example.com",
    "created_at": "2024-01-15T10:30:00Z"
  },
  "meta": {
    "request_id": "abc-123"
  }
}
```

---

## Pagination

### Cursor-Based (Preferred for Large Datasets)

```http
GET /users?cursor=eyJpZCI6MTIzfQ
```

```json
{
  "data": [...],
  "pagination": {
    "next_cursor": "eyJpZCI6MTU5fQ",
    "has_more": true
  }
}
```

### Offset-Based (Okay for Small Datasets)

```http
GET /users?page=2&per_page=20
```

```json
{
  "data": [...],
  "pagination": {
    "page": 2,
    "per_page": 20,
    "total": 150,
    "total_pages": 8
  }
}
```

---

## Versioning

### URL Versioning (Most Common)

```http
GET /v1/users
GET /v2/users
```

**When to bump:**
- Breaking changes to response format
- Removing fields
- Changing behavior

**Don't bump for:**
- Adding new optional fields
- Adding new endpoints

### Header Versioning

```http
Accept: application/vnd.myapp.v2+json
```

**Pros:** Cleaner URLs  
**Cons:** Less discoverable, harder to test

---

## Filtering & Sorting

### Filtering

```http
GET /users?status=active
GET /users?role=admin&status=active
GET /orders?created_after=2024-01-01
```

### Sorting

```http
GET /users?sort=created_at
GET /users?sort=-created_at  # Descending
GET /users?sort=name,-created_at
```

---

## What Bad Looks Like

### ❌ Inconsistent Response Formats

```json
// Endpoint 1: Returns data directly
{"id": 1, "name": "John"}

// Endpoint 2: Wrapped in "result"
{"result": {"id": 1, "name": "John"}}

// Endpoint 3: Wrapped in "data"  
{"data": {"id": 1, "name": "John"}}
```

**Fix:** Pick one format. Use it everywhere.

### ❌ Error Codes as Strings

```json
{"error": "User not found"}
```

**Fix:** Use proper HTTP status codes + structured error body.

### ❌ Action in URI

```http
POST /createUser
POST /deleteUser
GET /getUserById
```

**Fix:** Use HTTP methods + resources.

### ❌ No Documentation

**Fix:** OpenAPI/Swagger. Update it with every change.

---

## What Good Looks Like

### Example: Full CRUD for Users

```http
# Create user
POST /users
# 201 Created
{"data": {"id": 123, "email": "new@example.com"}}

# Get user
GET /users/123
# 200 OK
{"data": {"id": 123, "email": "new@example.com"}}

# Update user
PUT /users/123
{"data": {"email": "updated@example.com"}}
# 200 OK

# Delete user  
DELETE /users/123
# 204 No Content

# Get deleted user
GET /users/123
# 404 Not Found
{"error": {"code": "NOT_FOUND", "message": "User not found"}}
```

---

## Security Essentials

### Authentication

- Use OAuth 2.0 or API keys
- Don't pass credentials in URL (they're logged)
- Use TLS (HTTPS)

### Rate Limiting

```http
# Response when rate limited
HTTP/1.1 429 Too Many Requests
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1609459200
Retry-After: 3600
```

### Input Validation

- Validate on server (never trust client)
- Sanitize inputs (SQL injection, XSS)
- Set max request sizes

---

## Quick Reference

| Question | Answer |
|----------|--------|
| Plural or singular? | Plural (`/users`) |
| Version in URL or header? | URL (`/v1/users`) |
| Error format? | Consistent everywhere |
| Pagination for large lists? | Cursor-based |
| How to handle relations? | Nested URIs (`/users/123/orders`) |

---

*Next: [API Versioning Strategy](./api-versioning.md)*
