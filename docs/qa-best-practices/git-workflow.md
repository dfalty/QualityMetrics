# Git Workflow

**TL;DR:** Git is a tool, not a religion. Pick a workflow that works for your team size and style. The best workflow is one everyone understands and follows consistently.

---

## Why This Matters

We've all seen git horror stories: 47 merge conflicts, commit messages like "WIP" and "fix", branches that haven't been touched in 6 months.

This guide prevents that. Simple, practical git practices that scale.

---

## Branching Strategy

### Git Flow (Good for Large Teams)

```
main
 ↑
develop
 ↑
 feature/xyz
 ↑
 bugfix/xyz
 ↑
 release/1.0
```

- **main:** Production-ready code
- **develop:** Integration branch
- **feature/*:** New features
- **bugfix/*:** Bug fixes
- **release/*:** Release prep

### Trunk-Based (Simpler, Good for Small Teams)

```
main
 ↑
 feature/xyz (short-lived, < 2 days)
 ↑
 hotfix/xyz
```

- Short-lived branches (< 2 days)
- Commit directly to main after review
- Feature flags for risky changes

---

## Commit Messages

### Conventional Commits

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- **feat:** New feature
- **fix:** Bug fix
- **docs:** Documentation
- **style:** Formatting
- **refactor:** Code change that neither fixes nor adds
- **test:** Adding tests
- **chore:** Maintenance

### Examples

```bash
# ✅ Good
feat(auth): add OAuth 2.0 login

fix(api): handle rate limit response correctly

docs(readme): update setup instructions

# ❌ Bad
fixed it
WIP
asdf
```

### The Message Rule

**Write for humans.** Future you will read this. Make it useful.

---

## Branch Naming

```bash
# ✅ Good
feature/user-login
bugfix/fix-payment-error
hotfix/critical-security-patch
refactor/cleanup-user-service

# ❌ Bad
feature/xyz
my-branch
fix
wip
```

---

## Merging Strategy

### Merge vs Rebase

**Merge (Safe, preserves history):**
```bash
git checkout main
git merge feature/xyz
```

**Rebase (Clean history, but rewrites history):**
```bash
git checkout feature/xyz
git rebase main
git checkout main
git merge feature/xyz
```

**When to use each:**
- **Merge:** When collaborating (don't rewrite shared history)
- **Rebase:** Before merging feature branch (clean history)

### Squashing

When merging a finished feature branch, consider squashing:

```bash
git checkout main
git merge --squash feature/xyz
git commit -m "feat(xyz): complete feature"
```

---

## Common Commands

### Daily Workflow

```bash
# Start new feature
git checkout -b feature/my-feature

# Keep updated
git fetch origin
git pull origin main

# Make commits
git add .
git commit -m "feat: add feature"

# Push
git push -u origin feature/my-feature

# After PR merge
git checkout main
git pull origin main
git branch -d feature/my-feature
```

### Undo Things

```bash
# Unstage files
git reset HEAD

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Undo published commit
git revert abc123
```

---

## What Bad Looks Like

### ❌ Giant Commits

"Added feature and fixed bugs and changed styling"

**Fix:** Smaller, atomic commits.

### ❌ Commit Message Spam

```
fix
fix again
almost done
okay really done
```

**Fix:** One commit per logical change.

### ❌ Forgotten Branches

Branches that haven't been touched in months.

**Fix:** Delete old branches. Use a naming convention that makes them easy to find.

### ❌ Merge Conflicts as a Team Sport

Everyone merges into main at once, then conflicts everywhere.

**Fix:** Pull before you push. Small, frequent merges.

---

## Quick Reference

| Question | Answer |
|----------|--------|
| Branch naming | feature/description |
| Commit messages | Conventional, descriptive |
| Branch lifetime | < 2 days for features |
| Review before merge? | Always |

---

*Next: [Code Review Checklist](./code-review-checklist.md)*
