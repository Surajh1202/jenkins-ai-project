#!/bin/bash
# review.sh — Static Code Review (no external CLI needed)

set -e

TARGET_FILE="${1:-index.html}"
REPORT_FILE="review_report.txt"
ISSUES=0

echo "============================================"
echo "  AI Code Review — Static Analysis"
echo "  File: $TARGET_FILE"
echo "============================================"

if [ ! -f "$TARGET_FILE" ]; then
  echo "[ERROR] File not found: $TARGET_FILE"
  exit 1
fi

echo ""
echo "[INFO] Running static analysis on $TARGET_FILE..."
echo ""

{
  echo "=== AI Code Review Report ==="
  echo "File   : $TARGET_FILE"
  echo "Date   : $(date)"
  echo ""

  # Security checks
  echo "--- Security ---"
  if grep -qi "eval(" "$TARGET_FILE"; then
    echo "[WARN] eval() usage detected — potential security risk"
    ISSUES=$((ISSUES + 1))
  fi
  if grep -qi "innerHTML" "$TARGET_FILE"; then
    echo "[WARN] innerHTML usage detected — potential XSS risk"
    ISSUES=$((ISSUES + 1))
  fi
  if grep -qi "document.write" "$TARGET_FILE"; then
    echo "[WARN] document.write() detected — avoid in modern code"
    ISSUES=$((ISSUES + 1))
  fi

  # Best practices checks
  echo ""
  echo "--- Best Practices ---"
  if ! grep -qi "<!DOCTYPE" "$TARGET_FILE"; then
    echo "[WARN] Missing DOCTYPE declaration"
    ISSUES=$((ISSUES + 1))
  fi
  if ! grep -qi "<meta charset" "$TARGET_FILE"; then
    echo "[WARN] Missing charset meta tag"
    ISSUES=$((ISSUES + 1))
  fi
  if ! grep -qi "<title>" "$TARGET_FILE"; then
    echo "[WARN] Missing <title> tag"
    ISSUES=$((ISSUES + 1))
  fi

  # Accessibility checks
  echo ""
  echo "--- Accessibility ---"
  if grep -qi "<img" "$TARGET_FILE" && ! grep -qi "alt=" "$TARGET_FILE"; then
    echo "[WARN] Image tag missing alt attribute"
    ISSUES=$((ISSUES + 1))
  fi

  echo ""
  echo "--- Summary ---"
  echo "Total issues found: $ISSUES"

  if [ "$ISSUES" -gt 0 ]; then
    echo "Verdict: FAIL"
  else
    echo "Verdict: PASS"
  fi

} | tee "$REPORT_FILE"

echo ""
echo "[INFO] Report saved to: $REPORT_FILE"

if [ "$ISSUES" -gt 0 ]; then
  echo ""
  echo "[RESULT] ❌ Code review FAILED. Fix issues before deploying."
  exit 1
else
  echo ""
  echo "[RESULT] ✅ Code review PASSED."
  exit 0
fi
