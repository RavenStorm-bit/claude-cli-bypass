#!/bin/bash

# Script to apply Claude CLI bypass modifications

echo "Claude CLI Bypass Modification Script"
echo "===================================="

# Find claude installation
CLAUDE_PATH=$(which claude)
if [ -z "$CLAUDE_PATH" ]; then
    echo "Error: Claude CLI not found in PATH"
    exit 1
fi

echo "Found Claude at: $CLAUDE_PATH"

# Follow symlink to find actual cli.js
CLI_JS_PATH=$(readlink -f "$CLAUDE_PATH")
echo "CLI.js path: $CLI_JS_PATH"

# Create backup
if [ ! -f "${CLI_JS_PATH}.backup" ]; then
    echo "Creating backup..."
    cp "$CLI_JS_PATH" "${CLI_JS_PATH}.backup"
    echo "Backup created at: ${CLI_JS_PATH}.backup"
else
    echo "Backup already exists"
fi

# Apply modifications
echo "Applying modifications..."

# Modification 1: Bypass theme/onboarding check
echo "1. Applying theme/onboarding bypass..."
sed -i '/async function x38(Z, G) {/,/if (!D.theme || !D.hasCompletedOnboarding)/ {
    /let D = \$0(),/a\
  // Hardcode theme and hasCompletedOnboarding to bypass welcome screen\
  D.theme = '\''dark'\'';\
  D.hasCompletedOnboarding = true;\
  // Save these values to config for persistence\
  f2({...D, theme: '\''dark'\'', hasCompletedOnboarding: true});
}' "$CLI_JS_PATH"

# Modification 2: Bypass trust folder check
echo "2. Applying trust folder bypass..."
sed -i '/function Lp0() {/,/return !1/ {
    /function Lp0() {/a\
  // Always trust - bypass the trust dialog prompt\
  return !0
}' "$CLI_JS_PATH"

echo "Modifications applied successfully!"
echo ""
echo "To verify:"
echo "1. Run: grep -n 'Hardcode theme' $CLI_JS_PATH"
echo "2. Run: grep -n 'Always trust' $CLI_JS_PATH"
echo ""
echo "To test:"
echo "1. Run 'claude' in any directory"
echo "2. Should skip theme selection and trust prompts"