# Accessibility Standards

**TL;DR:** Accessibility isn't a feature you add at the end. It's about building software that works for everyone—regardless of ability. This guide covers what you need to make your product usable by people with disabilities.

---

## Why This Matters

15% of the world's population has some form of disability. That's over 1 billion people. If your app isn't accessible, you're excluding a massive chunk of potential users.

Also, it's the law in many places (ADA, WCAG, etc.).

---

## WCAG Basics

### Levels

| Level | What It Means |
|-------|---------------|
| A | Basic accessibility features |
| AA | Addresses most common barriers (this is the standard target) |
| AAA | Highest level, often impractical |

**Target:** WCAG 2.1 AA

---

## Common Issues

### Missing Alt Text

```html
<!-- ❌ Bad: No alt text -->
<img src="chart.png">

<!-- ✅ Good: Descriptive alt text -->
<img src="chart.png" alt="Sales increased 25% in Q3 2024">

<!-- ✅ Good: Empty for decorative images -->
<img src="decoration.png" alt="">
```

### Poor Color Contrast

**Minimum:**
- Text: 4.5:1 against background
- Large text (18pt+): 3:1

**Tools:** Check with WebAIM Contrast Checker

### Not Keyboard Accessible

```html
<!-- ❌ Bad: Only works with mouse -->
<button onclick="submit()">Submit</button>

<!-- ✅ Good: Works with keyboard -->
<button onclick="submit()">Submit</button>
<!-- Also works with: tab, enter, space -->
```

### Missing Form Labels

```html
<!-- ❌ Bad: No label -->
<input type="email" placeholder="Email">

<!-- ✅ Good: Associated label -->
<label for="email">Email</label>
<input type="email" id="email" placeholder="Email">
```

---

## Testing

### Automated Testing

- **axe:** Web Accessibility Testing
- **WAVE:** Web Accessibility Evaluation Tool
- **Lighthouse:** Built into Chrome DevTools

### Manual Testing

- [ ] Navigate entire app with keyboard only
- [ ] Use screen reader (NVDA, VoiceOver)
- [ ] Zoom to 200%
- [ ] Disable images

---

## Quick Reference

| Issue | Fix |
|-------|-----|
| Images | Add alt text |
| Forms | Label every input |
| Color | 4.5:1 contrast ratio |
| Navigation | Keyboard accessible |
| Focus | Visible focus indicators |

---

*Next: [Logging Standards](./logging.md)*
