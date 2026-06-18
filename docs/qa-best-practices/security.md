# Security Best Practices

**TL;DR:** Security isn't a feature—it's a mindset. You can't bolt it on at the end. This guide covers the basics that every SaaS company should have in place, written by people who've seen what happens when you don't.

---

## Why This Matters

In 2024 alone:
- Average data breach costs $4.45 million
- 95% of security incidents involve human error
- 43% of breaches target small businesses

You can't afford to skip this. One mistake, and you're in the news for the wrong reasons.

---

## Authentication

### Password Requirements

**Don't:**
- Store plain-text passwords
- Use reversible encryption
- Limit special characters (attackers love that)
- Email password resets

**Do:**
```python
# ✅ Use bcrypt/Argon2
import bcrypt

hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt())
bcrypt.checkpw(password.encode(), hashed)
```

### Multi-Factor Auth (MFA)

- Require MFA for all employee accounts
- Support TOTP (Google Authenticator, Authy)
- Support hardware keys (YubiKey) for sensitive accounts
- Don't require MFA for low-risk API actions (use API keys instead)

### Session Management

```python
# ✅ Good: Secure session handling
session_config = {
    'cookie_secure': True,      # HTTPS only
    'cookie_httponly': True,    # No JS access
    'cookie_samesite': 'Lax',   # CSRF protection
    'session_timeout': 3600,     # 1 hour max
    'absolute_timeout': 86400,  # 24 hour max (re-auth for sensitive actions)
}
```

---

## Authorization

### Role-Based Access Control (RBAC)

```python
ROLES = {
    'admin': ['read', 'write', 'delete', 'manage_users'],
    'developer': ['read', 'write', 'deploy'],
    'viewer': ['read'],
}

def check_permission(user, action, resource):
    if user.role not in ROLES:
        return False
    return action in ROLES[user.role]
```

### The Principle of Least Privilege

- Give minimum access needed to do the job
- Review access quarterly
- Revoke access immediately on offboarding
- Use service accounts with limited scopes

### API Authorization

```python
# ❌ Bad: No authorization check
def get_user(user_id):
    return db.query(f"SELECT * FROM users WHERE id = {user_id}")

# ✅ Good: Check ownership
def get_user(user_id, current_user):
    user = db.query("SELECT * FROM users WHERE id = ?", user_id)
    if user.id != current_user.id and not current_user.is_admin:
        raise Unauthorized()
    return user
```

---

## Data Protection

### Encryption at Rest

- Use AES-256 for database encryption
- Encrypt sensitive fields (PII, passwords, payment info)
- Use KMS (AWS KMS, HashiCorp Vault) for key management

### Encryption in Transit

- TLS 1.3 everywhere (minimum 1.2)
- HSTS headers
- Certificate pinning for mobile apps

### Sensitive Data Handling

```python
# ✅ Good: Mask sensitive data in logs
def log_user_access(user):
    logger.info(f"User {user.id} accessed {resource}", extra={
        # Never log:
        # - password
        # - credit card
        # - social security number
        # - api_key
    })

# ✅ Good: Return only necessary fields
def serialize_user(user):
    return {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        # Don't return: password_hash, ip_address, etc.
    }
```

---

## Common Vulnerabilities

### SQL Injection

**❌ Never do this:**
```python
query = f"SELECT * FROM users WHERE id = {user_id}"
```

**✅ Always do this:**
```python
query = "SELECT * FROM users WHERE id = %s"
cursor.execute(query, (user_id,))
```

### XSS (Cross-Site Scripting)

**❌ Never do this:**
```python
return f"<h1>Welcome {user.name}</h1>"
```

**✅ Always do this:**
```python
from markupsafe import escape
return f"<h1>Welcome {escape(user.name)}</h1>"
```

### CSRF (Cross-Site Request Forgery)

```python
# Use CSRF tokens
csrf_token = generate_token()
# Include in forms
<input type="hidden" name="csrf_token" value="{{ csrf_token }}">
# Validate on submission
validate_csrf_token(request.POST['csrf_token'])
```

### Command Injection

**❌ Never do this:**
```python
os.system(f"git pull {branch}")
```

**✅ Always do this:**
```python
subprocess.run(["git", "pull", branch], shell=False)
```

---

## Dependencies

### Keep Updated

```bash
# Check for vulnerabilities
npm audit
pip-audit
safety check

# Update regularly
npm update
pip update
```

### Dependency Scanning

Use automated tools in CI:
- GitHub Dependabot
- Snyk
- WhiteSource
- Renovate

### Pin Versions

```json
// ✅ Good: Exact versions in package.json
{
  "dependencies": {
    "lodash": "4.17.21"
  }
}

// ❌ Bad: Loose versions
{
  "dependencies": {
    "lodash": "^4.17.0"  
  }
}
```

---

## Logging & Monitoring

### What to Log

- Authentication events (login, logout, failures)
- Authorization failures
- Data access (especially sensitive data)
- Configuration changes
- Errors and exceptions

### What NOT to Log

- Passwords, API keys, tokens
- Credit card numbers
- Personal identifiable information (PII)
- Session tokens

### Log Format

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "WARNING",
  "event": "auth_failure",
  "user_id": 123,
  "ip_address": "192.168.1.1",
  "reason": "invalid_password"
}
```

---

## Incident Response

### The Plan

1. **Detect** - Alert on anomalies
2. **Contain** - Stop the bleeding
3. **Eradicate** - Remove the threat
4. **Recover** - Restore normal operations
5. **Review** - Learn and improve

### Contacts to Have Ready

- Security team on-call
- Legal/compliance
- PR/Communications (for breaches)
- External security contacts (AWS, etc.)

### Communication Template

```
Subject: SECURITY INCIDENT - [Brief Description]

What happened:
[Timeline of events]

Impact:
[What data/systems were affected]

Actions taken:
[What we've done so far]

Next steps:
[What we're doing next]

Updates will be posted to: [internal channel]
```

---

## Quick Reference

| Question | Answer |
|----------|--------|
| Min password length? | 12+ characters |
| MFA required? | Yes for employees |
| TLS version? | 1.3 (min 1.2) |
| Dependency scans? | Weekly in CI |
| Log retention? | 90 days minimum |

---

*Next: [Incident Response](./incident-response.md)*
