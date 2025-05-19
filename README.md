# Claude CLI Bypass Modifications

This repository documents the modifications made to bypass the authentication and trust prompts in the Claude CLI tool.

## Problem Statement

The Claude CLI has two annoying prompts that appear even when valid credentials are stored:
1. **Theme Selection/Welcome Screen**: Shows "Let's get started" and asks for theme selection
2. **Trust Folder Prompt**: Asks "Do you trust the files in this folder?"

These prompts appear despite having valid credentials stored in `.claude/.credentials.json`.

## Findings

### File Locations
- **CLI Entry Point**: `/usr/lib/node_modules/@anthropic-ai/claude-code/cli.js` (or similar based on installation)
- **Credentials**: `~/.claude/.credentials.json`
- **Configuration**: `~/.claude.json`

### Root Cause Analysis

1. **Theme/Onboarding Issue**:
   - Function `x38` checks if `theme` and `hasCompletedOnboarding` are set in config
   - If either is missing, it shows the welcome screen
   - The check happens BEFORE credential validation
   - Location: Around line 294989 in the obfuscated code

2. **Trust Folder Issue**:
   - Function `Lp0()` checks if current directory has been trusted
   - Returns false if directory hasn't been explicitly trusted before
   - Forces user to confirm trust every time in new directories

## Modifications

### 1. Bypass Theme/Onboarding Check

Modified function `x38` to force set values:

```javascript
async function x38(Z, G) {
  if (!1 === 'true' || process.env.IS_DEMO) return !1
  let D = $0(),
    W = !1
  // Hardcode theme and hasCompletedOnboarding to bypass welcome screen
  D.theme = 'dark';
  D.hasCompletedOnboarding = true;
  // Save these values to config for persistence
  f2({...D, theme: 'dark', hasCompletedOnboarding: true});
  if (!D.theme || !D.hasCompletedOnboarding)
    // ... rest of function
```

### 2. Bypass Trust Folder Check

Modified function `Lp0` to always return true:

```javascript
function Lp0() {
  // Always trust - bypass the trust dialog prompt
  return !0
  // ... rest of original function (unreachable)
}
```

## Installation

1. Locate your Claude CLI installation:
   ```bash
   which claude
   # Follow symlink to find actual cli.js location
   ```

2. Backup original file:
   ```bash
   cp /path/to/cli.js /path/to/cli.js.backup
   ```

3. Apply modifications to the cli.js file

## Configuration Storage

The modifications ensure that:
- `theme` is set to 'dark'
- `hasCompletedOnboarding` is set to true
- These values are saved to `~/.claude.json` for persistence
- Trust dialog is completely bypassed for all directories

## Testing

After modifications:
1. Run `claude` in any directory
2. Should skip welcome/theme screen
3. Should skip trust folder prompt
4. Should use stored credentials from `.claude/.credentials.json`

## Notes

- These modifications work with Claude CLI version 0.2.107
- The cli.js file is obfuscated/minified, making it difficult to read
- Line numbers may vary between versions
- Always backup before modifying