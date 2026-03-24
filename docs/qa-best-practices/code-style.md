# Code Style Guide

**TL;DR:** Style guides aren't about "right" vs "wrong." They're about consistency across a codebase. When everyone follows the same rules, code is easier to read, review, and maintain. This guide covers what actually matters.

---

## Why This Matters

You ever open a file and it's got 4 different indentation styles, mixed naming conventions, and random formatting? That's technical debt before you've even shipped anything.

Good code style prevents that. It's not about personal preference—it's about making the codebaseReadable and consistent.

---

## The Golden Rule

**Use automated tools. Don't rely on humans to catch style issues.**

- Linters fix things automatically
- Formatters run on save
- CI blocks code that doesn't comply

This frees humans to focus on actual code review, not "missing semicolon."

---

## Language Standards

### JavaScript/TypeScript

```javascript
// Use ESLint + Prettier
// .eslintrc.js
module.exports = {
  extends: ['eslint:recommended', 'plugin:@typescript-eslint/recommended'],
  parser: '@typescript-eslint/parser',
};

// .prettierrc
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5"
}
```

### Python

```python
# Use Black + isort + flake8
# pyproject.toml
[tool.black]
line-length = 88
target-version = ['py310']

[tool.isort]
profile = "black"

[tool.flake8]
max-line-length = 88
extend-ignore = "E203"
```

### Go

```go
// Use gofmt + golint
// Run: gofmt -w .
// CI: golint -set_exit_status ./...

func init() {
    // Imports organized:
    // 1. Standard library
    // 2. External packages
    // 3. Internal packages
    
    // Example:
    import (
        "fmt"
        "os"
        
        "github.com/pkg/errors"
        "github.com/spf13/viper"
        
        "myproject/internal/config"
    )
}
```

---

## Naming Conventions

### Variables

| Language | Convention | Example |
|----------|------------|---------|
| JavaScript | camelCase | `userName` |
| Python | snake_case | `user_name` |
| Go | camelCase | `userName` |
| Java | camelCase | `userName` |

### Constants

| Language | Convention | Example |
|----------|------------|---------|
| JavaScript | UPPER_SNAKE | `MAX_RETRIES` |
| Python | UPPER_SNAKE | `MAX_RETRIES` |
| Go | Mixed | `maxRetries` (unexported), `MaxRetries` (exported) |

### Functions/Methods

| Language | Convention | Example |
|----------|------------|---------|
| JavaScript | camelCase | `getUserById` |
| Python | snake_case | `get_user_by_id` |
| Go | camelCase | `GetUserById` |
| Java | camelCase | `getUserById` |

### Classes

| Language | Convention | Example |
|----------|------------|---------|
| JavaScript | PascalCase | `UserService` |
| Python | PascalCase | `UserService` |
| Go | PascalCase | `UserService` |
| Java | PascalCase | `UserService` |

---

## Formatting Rules

### Indentation

- **2 spaces** is standard (not tabs)
- Configure your editor to convert tabs to spaces

### Line Length

- **80 characters** (classic)
- **100 characters** (modern, acceptable)
- **120 characters** (too long, breaks side-by-side diffs)

### Blank Lines

```python
# ✅ Good: Logical spacing
def authenticate_user():
    user = get_user_from_db()
    
    if not user:
        return None
    
    return verify_password(user)


# ❌ Bad: Too many or too few
def authenticate_user():
    user = get_user_from_db()
    if not user:
        return None
    return verify_password(user)
```

### Imports

```python
# ✅ Good: Organized
# Standard library
import os
import json

# Third-party
import requests
from django.db import models

# Internal
from .models import User
from .services import AuthService


# ❌ Bad: All mixed together
import os
import requests
from django.db import models
from .models import User
from .services import AuthService
import json
```

---

## Comments

### When to Comment

**Do:**
- Explain WHY, not WHAT (the code shows what)
- Document complex algorithms
- Note non-obvious workarounds

```python
# ✅ Good: Explains why
# Using exponential backoff because the upstream API
# rate-limits aggressively on immediate retries.
for attempt in range(5):
    try:
        return make_request()
    except RateLimited:
        sleep(2 ** attempt)
```

**Don't:**
- Comment out code (delete it, git has history)
- Explain obvious code
- Use comments as TODO tracking (use tickets)

```python
# ❌ Bad: What this does is obvious
# Increment counter by 1
counter += 1
```

---

## What Bad Looks Like

### ❌ Mixed Styles in One File

```javascript
// Some camelCase
const userName = "John";
// Some snake_case  
const user_email = "john@example.com";
```

**Fix:** One style per file, enforced by linter.

### ❌ Giant Functions

```python
def process_everything():
    # 500 lines of code
    # Does 15 different things
```

**Fix:** Break into smaller functions. Each does one thing.

### ❌ Magic Numbers

```python
# ❌ Bad
if attempts > 5:
    return error

# ✅ Good
MAX_RETRY_ATTEMPTS = 5

if attempts > MAX_RETRY_ATTEMPTS:
    return error
```

---

## Quick Reference

| Question | Answer |
|----------|--------|
| Indentation? | 2 spaces |
| Line length? | 80-100 characters |
| Auto-format? | Yes, always |
| Comments? | Explain why, not what |

---

*Next: [Error Handling](./error-handling.md)*
