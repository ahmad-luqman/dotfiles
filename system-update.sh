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
LOG_MAX_SIZE_KB=512  # Rotate logs when they exceed this size
LOG_KEEP_ROTATED=2   # Number of rotated files to keep (.1, .2)

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Rotate a log file if it exceeds LOG_MAX_SIZE_KB
rotate_log() {
    local file="$1"
    [ ! -f "$file" ] && return
    local size_kb=$(du -k "$file" | cut -f1)
    if [ "$size_kb" -gt "$LOG_MAX_SIZE_KB" ]; then
        # Shift old rotations
        for i in $(seq $((LOG_KEEP_ROTATED - 1)) -1 1); do
            [ -f "${file}.${i}" ] && mv "${file}.${i}" "${file}.$((i + 1))"
        done
        mv "$file" "${file}.1"
        touch "$file"
    fi
}

# Rotate all log files at start
rotate_log "$LOG_FILE"
rotate_log "$DETAILED_LOG"
rotate_log "${LOG_DIR}/cron.log"
rotate_log "${LOG_DIR}/weekly-summary.log"

# Function to log messages
log_message() {
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    local message="$1"
    echo "[${ts}] ${message}" | tee -a "$LOG_FILE"
}

# Function to log detailed output
log_detailed() {
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    local message="$1"
    echo "[${ts}] ${message}" >> "$DETAILED_LOG"
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

# Cleanup all GitHub Actions runners
log_message "Checking GitHub Actions runners..."
log_detailed "--- GitHub Actions Runner Cleanup ---"

RUNNER_DIRS_FOUND=0
FREED_GRAND_TOTAL=0

for ACTIONS_DIR in "$HOME"/actions-runner*; do
    [ ! -d "$ACTIONS_DIR" ] && continue
    RUNNER_NAME=$(basename "$ACTIONS_DIR")
    RUNNER_DIRS_FOUND=$((RUNNER_DIRS_FOUND + 1))
    FREED_TOTAL=0

    log_message "Cleaning $RUNNER_NAME..."

    # 1. Clean diagnostic logs older than 7 days
    if [ -d "$ACTIONS_DIR/_diag" ]; then
        DELETED_COUNT=$(find "$ACTIONS_DIR/_diag" -type f -mtime +7 -delete -print 2>/dev/null | wc -l | tr -d ' ')
        [ "$DELETED_COUNT" -gt 0 ] && log_message "  ✓ Deleted $DELETED_COUNT diagnostic log file(s)"
    fi

    # 2. Clean old runner version directories (bin.* and externals.*)
    CURRENT_VERSION=$("$ACTIONS_DIR/config.sh" --version 2>/dev/null || echo "")
    if [ -n "$CURRENT_VERSION" ]; then
        for old_dir in "$ACTIONS_DIR"/bin.* "$ACTIONS_DIR"/externals.*; do
            [ ! -d "$old_dir" ] && continue
            dir_version=$(basename "$old_dir" | sed 's/^[^.]*\.//')
            if [ "$dir_version" != "$CURRENT_VERSION" ]; then
                old_size=$(du -sm "$old_dir" 2>/dev/null | cut -f1)
                rm -rf "$old_dir"
                FREED_TOTAL=$((FREED_TOTAL + old_size))
                log_message "  ✓ Removed stale $(basename "$old_dir") (${old_size}MB)"
            fi
        done
    fi

    # 3. Clean stale _work/_update directory (leftover from runner self-updates)
    if [ -d "$ACTIONS_DIR/_work/_update" ]; then
        update_size=$(du -sm "$ACTIONS_DIR/_work/_update" 2>/dev/null | cut -f1)
        rm -rf "$ACTIONS_DIR/_work/_update"
        FREED_TOTAL=$((FREED_TOTAL + update_size))
        log_message "  ✓ Removed stale _work/_update (${update_size}MB)"
    fi

    # 4. Clean _work/_temp (temporary job files older than 3 days)
    if [ -d "$ACTIONS_DIR/_work/_temp" ]; then
        find "$ACTIONS_DIR/_work/_temp" -type f -mtime +3 -delete 2>/dev/null
    fi

    # 5. Remove leftover runner tar.gz installer archives
    for tarball in "$ACTIONS_DIR"/actions-runner-*.tar.gz; do
        [ ! -f "$tarball" ] && continue
        tar_size=$(du -sm "$tarball" 2>/dev/null | cut -f1)
        rm -f "$tarball"
        FREED_TOTAL=$((FREED_TOTAL + tar_size))
        log_message "  ✓ Removed installer archive $(basename "$tarball") (${tar_size}MB)"
    done

    # 6. Clean hostedtoolcache (cached tool versions, safe to remove)
    if [ -d "$ACTIONS_DIR/hostedtoolcache" ]; then
        cache_size=$(du -sm "$ACTIONS_DIR/hostedtoolcache" 2>/dev/null | cut -f1)
        if [ "$cache_size" -gt 0 ] 2>/dev/null; then
            rm -rf "$ACTIONS_DIR/hostedtoolcache"
            mkdir -p "$ACTIONS_DIR/hostedtoolcache"
            FREED_TOTAL=$((FREED_TOTAL + cache_size))
            log_message "  ✓ Cleared hostedtoolcache (${cache_size}MB)"
        fi
    fi

    if [ "$FREED_TOTAL" -gt 0 ]; then
        log_message "  $RUNNER_NAME: freed ~${FREED_TOTAL}MB"
    else
        log_message "  $RUNNER_NAME: clean"
    fi
    FREED_GRAND_TOTAL=$((FREED_GRAND_TOTAL + FREED_TOTAL))
done

if [ "$RUNNER_DIRS_FOUND" -eq 0 ]; then
    log_message "No GitHub Actions runner directories found, skipping cleanup"
elif [ "$FREED_GRAND_TOTAL" -gt 0 ]; then
    log_message "Total runner cleanup freed ~${FREED_GRAND_TOTAL}MB across $RUNNER_DIRS_FOUND runner(s)"
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

# Also write to summary file
WEEKLY_LOG="${LOG_DIR}/weekly-summary.log"
echo "" >> "$WEEKLY_LOG"
echo "=== $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$WEEKLY_LOG"
echo "Updated $PACKAGE_COUNT package(s)" >> "$WEEKLY_LOG"
for package in "${UPDATED_PACKAGES[@]}"; do
    echo "  - $package" >> "$WEEKLY_LOG"
done

exit 0
