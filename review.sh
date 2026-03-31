#!/bin/bash
# review.sh — AI Code Review using Amazon Q CLI

set -e

TARGET_FILE="${1:-index.html}"
REPORT_FILE="review_report.txt"

echo "============================================"
echo "  AI Code Review — Amazon Q"
echo "  File: $TARGET_FILE"
echo "============================================"

if [ ! -f "$TARGET_FILE" ]; then
  echo "[ERROR] File not found: $TARGET_FILE"
  exit 1
fi

CODE=$(cat "$TARGET_FILE")

PROMPT="You are a senior code reviewer. Review the following code for:
1. Security vulnerabilities
2. Best practices
3. Performance issues
4. Accessibility (if HTML)
5. Any bugs or improvements

Code to review:
\`\`\`
$CODE
\`\`\`

Provide a concise review with a PASS or FAIL verdict at the end."

echo ""
echo "[INFO] Sending code to Amazon Q for review..."
echo ""

# Use Amazon Q CLI to perform the review
REVIEW_OUTPUT=$(q chat --no-interactive "$PROMPT" 2>&1)

echo "$REVIEW_OUTPUT"
echo ""

# Save report
{
  echo "=== AI Code Review Report ==="
  echo "File   : $TARGET_FILE"
  echo "Date   : $(date)"
  echo ""
  echo "$REVIEW_OUTPUT"
} > "$REPORT_FILE"

echo "[INFO] Report saved to: $REPORT_FILE"

# Check verdict
if echo "$REVIEW_OUTPUT" | grep -qi "FAIL"; then
  echo ""
  echo "[RESULT] ❌ Code review FAILED. Fix issues before deploying."
  exit 1
else
  echo ""
  echo "[RESULT] ✅ Code review PASSED."
  exit 0
fi
