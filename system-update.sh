#!/bin/bash

# System Update Script with Logging
# Updates Homebrew packages and global npm packages
# Logs all updates with timestamps

# Setup PATH for cron environment
# Cron runs with minimal environment, so we need to set up PATH explicitly
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Add Homebrew to PATH (supports both Apple Silicon and Intel)
if [ -d "/opt/homebrew/bin" ]; then
    # Apple Silicon Mac
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
elif [ -d "/usr/local/bin" ]; then
    # Intel Mac or Linux
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
fi

# Setup nvm for npm access (if available)
# This is needed because npm is installed via nvm, not system-wide
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    export NVM_DIR="$HOME/.nvm"
    \. "$NVM_DIR/nvm.sh"
    # Load default node version
    nvm use default 2>/dev/null || nvm use node 2>/dev/null || true
fi

# Configuration
LOG_DIR="${HOME}/.update-logs"
LOG_FILE="${LOG_DIR}/updates.log"
DETAILED_LOG="${LOG_DIR}/updates-detailed.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
DATE_SLUG=$(date '+%Y-%m-%d')

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log messages
log_message() {
    local message="$1"
    echo "[${TIMESTAMP}] ${message}" | tee -a "$LOG_FILE"
}

# Function to log detailed output
log_detailed() {
    local message="$1"
    echo "[${TIMESTAMP}] ${message}" >> "$DETAILED_LOG"
}

# Start logging
log_message "=== System Update Started ==="
log_detailed "=== System Update Started ==="

# Track what was updated
UPDATED_PACKAGES=()

# Update Homebrew
log_message "Checking Homebrew updates..."
log_detailed "--- Homebrew Update ---"

brew update >> "$DETAILED_LOG" 2>&1

# Get outdated packages before upgrade
OUTDATED=$(brew outdated --json=v2 2>/dev/null || echo "{}")

# Upgrade all packages
log_message "Upgrading Homebrew packages..."
BREW_OUTPUT=$(brew upgrade 2>&1 || true)
echo "$BREW_OUTPUT" >> "$DETAILED_LOG"

# Parse upgraded packages
while IFS= read -r line; do
    if [[ $line =~ "==> Upgrading" ]]; then
        PACKAGE=$(echo "$line" | sed 's/==> Upgrading //' | sed 's/ *$//')
        if [ -n "$PACKAGE" ]; then
            UPDATED_PACKAGES+=("$PACKAGE")
            log_message "✓ Updated: $PACKAGE"
        fi
    fi
done <<< "$BREW_OUTPUT"

# Cleanup
log_message "Running Homebrew cleanup..."
brew cleanup >> "$DETAILED_LOG" 2>&1

# Update npm global packages
log_message "Checking npm global packages..."
log_detailed "--- NPM Global Updates ---"

# Check if npm is available
if command -v npm &> /dev/null; then
    # Get list of outdated global packages
    NPM_OUTDATED=$(npm outdated -g --json 2>/dev/null || echo "{}")

    if [ -n "$NPM_OUTDATED" ] && [ "$NPM_OUTDATED" != "{}" ]; then
        echo "$NPM_OUTDATED" >> "$DETAILED_LOG"
        log_message "Updating npm global packages..."
        npm update -g >> "$DETAILED_LOG" 2>&1 || log_message "⚠ npm update completed with warnings"

        # Try to extract updated packages
        if command -v jq &> /dev/null; then
            while IFS= read -r package; do
                if [ -n "$package" ]; then
                    UPDATED_PACKAGES+=("npm: $package")
                    log_message "✓ Updated: npm: $package"
                fi
            done < <(echo "$NPM_OUTDATED" | jq -r 'keys[]' 2>/dev/null || true)
        fi
    else
        log_message "No npm global package updates available"
    fi
else
    log_message "npm not found, skipping npm global updates"
fi

# Cleanup GitHub Actions runner diagnostic logs
log_message "Checking GitHub Actions runner logs..."
log_detailed "--- GitHub Actions Log Cleanup ---"

if [ -d "$HOME/actions-runner/_diag" ]; then
    log_message "Cleaning GitHub Actions runner logs older than 7 days..."
    DELETED_COUNT=$(find "$HOME/actions-runner/_diag" -type f -mtime +7 -delete -print 2>/dev/null | wc -l)
    log_message "✓ Deleted $DELETED_COUNT GitHub Actions log file(s)"
    log_detailed "GitHub Actions cleanup deleted $DELETED_COUNT files"
else
    log_message "GitHub Actions runner directory not found, skipping cleanup"
fi

# Update specific tools if they exist
TOOLS=("claude" "codex" "gemini" "copilot")
log_detailed "--- Specific Tool Updates ---"

for tool in "${TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null; then
        log_message "Checking $tool..."
        BEFORE_VERSION=$($tool --version 2>/dev/null || $tool -v 2>/dev/null || $tool -V 2>/dev/null || echo "unknown")
        log_detailed "$tool version before: $BEFORE_VERSION"
    fi
done

# Summary
log_message "=== System Update Completed ==="
log_detailed "=== System Update Completed ==="

# Write summary to main log
PACKAGE_COUNT=${#UPDATED_PACKAGES[@]}
if [ $PACKAGE_COUNT -gt 0 ]; then
    log_message "Summary: Updated $PACKAGE_COUNT package(s)"
    log_message "Updated packages:"
    for package in "${UPDATED_PACKAGES[@]}"; do
        log_message "  - $package"
    done
else
    log_message "Summary: No packages updated"
fi

log_message "Logs saved to:"
log_message "  Main log: $LOG_FILE"
log_message "  Detailed log: $DETAILED_LOG"
log_message ""

# Also write to a weekly summary file
WEEKLY_LOG="${LOG_DIR}/weekly-summary.log"
echo "" >> "$WEEKLY_LOG"
echo "=== $TIMESTAMP ===" >> "$WEEKLY_LOG"
echo "Updated $PACKAGE_COUNT package(s)" >> "$WEEKLY_LOG"
for package in "${UPDATED_PACKAGES[@]}"; do
    echo "  - $package" >> "$WEEKLY_LOG"
done

exit 0
