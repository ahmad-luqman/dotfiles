#!/bin/bash

# Setup script to add system-update.sh to crontab
# Usage: bash setup-update-cron.sh [--daily|--weekly|--custom CRON_SCHEDULE]

set -e

SCRIPT_PATH="/Users/ahmadluqman/scripts/system-update.sh"
CRON_SCHEDULE="$2"

# Default to weekly (Sunday 2 AM)
if [ -z "$1" ]; then
    CRON_SCHEDULE="0 2 * * 0"
    echo "Using default schedule: Weekly (Sunday 2 AM)"
elif [ "$1" == "--daily" ]; then
    CRON_SCHEDULE="0 2 * * *"
    echo "Using schedule: Daily (2 AM)"
elif [ "$1" == "--weekly" ]; then
    CRON_SCHEDULE="0 2 * * 0"
    echo "Using schedule: Weekly (Sunday 2 AM)"
elif [ "$1" == "--custom" ]; then
    if [ -z "$CRON_SCHEDULE" ]; then
        echo "Error: --custom requires a cron schedule expression"
        echo "Example: bash setup-update-cron.sh --custom '0 2 * * 0'"
        exit 1
    fi
    echo "Using custom schedule: $CRON_SCHEDULE"
else
    echo "Usage: bash setup-update-cron.sh [--daily|--weekly|--custom CRON_SCHEDULE]"
    echo ""
    echo "Examples:"
    echo "  bash setup-update-cron.sh --daily          # Run at 2 AM every day"
    echo "  bash setup-update-cron.sh --weekly         # Run at 2 AM on Sunday"
    echo "  bash setup-update-cron.sh --custom '0 3 * * 0'  # Custom cron expression"
    exit 1
fi

# Verify script exists
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Error: $SCRIPT_PATH not found"
    exit 1
fi

# Get current crontab (if exists)
CURRENT_CRON=$(crontab -l 2>/dev/null || echo "")

# Check if job already exists
if echo "$CURRENT_CRON" | grep -q "system-update.sh"; then
    echo "⚠ System update job already exists in crontab"
    echo ""
    echo "Current crontab entries with 'system-update':"
    crontab -l | grep "system-update" || echo "No entries found"
    echo ""
    read -p "Do you want to replace it? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 1
    fi
    # Remove existing entry
    CURRENT_CRON=$(echo "$CURRENT_CRON" | grep -v "system-update" || echo "")
fi

# Create new cron entry
NEW_CRON_ENTRY="$CRON_SCHEDULE $SCRIPT_PATH >> ~/.update-logs/cron.log 2>&1"

# Add to crontab
if [ -z "$CURRENT_CRON" ]; then
    echo "$NEW_CRON_ENTRY" | crontab -
else
    echo "$CURRENT_CRON" | {
        cat
        echo "$NEW_CRON_ENTRY"
    } | crontab -
fi

echo ""
echo "✓ Cron job added successfully!"
echo ""
echo "Schedule: $CRON_SCHEDULE"
echo "Command: $SCRIPT_PATH"
echo "Logs: ~/.update-logs/"
echo ""
echo "To view your crontab:"
echo "  crontab -l"
echo ""
echo "To edit your crontab:"
echo "  crontab -e"
echo ""
echo "To view logs:"
echo "  tail -f ~/.update-logs/updates.log"
echo "  tail -f ~/.update-logs/cron.log"

exit 0
