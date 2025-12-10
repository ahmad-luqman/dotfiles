#!/bin/bash

# Log viewer script for system updates
# Usage: view-update-logs.sh [command]

LOG_DIR="${HOME}/.update-logs"
LOG_FILE="${LOG_DIR}/updates.log"
DETAILED_LOG="${LOG_DIR}/updates-detailed.log"
CRON_LOG="${LOG_DIR}/cron.log"
WEEKLY_SUMMARY="${LOG_DIR}/weekly-summary.log"

# Color codes
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if log directory exists
if [ ! -d "$LOG_DIR" ]; then
    echo "Log directory not found: $LOG_DIR"
    echo "Run the update script first to generate logs."
    exit 1
fi

# Functions
show_latest() {
    if [ ! -f "$LOG_FILE" ]; then
        echo "No logs found yet"
        return
    fi

    echo -e "${BLUE}=== Latest Updates ===${NC}"
    tail -20 "$LOG_FILE"
}

show_full() {
    if [ ! -f "$LOG_FILE" ]; then
        echo "No logs found"
        return
    fi

    echo -e "${BLUE}=== Full Update Log ===${NC}"
    cat "$LOG_FILE"
}

show_detailed() {
    if [ ! -f "$DETAILED_LOG" ]; then
        echo "No detailed logs found"
        return
    fi

    echo -e "${BLUE}=== Detailed Log ===${NC}"
    cat "$DETAILED_LOG"
}

show_cron() {
    if [ ! -f "$CRON_LOG" ]; then
        echo "No cron logs found yet"
        return
    fi

    echo -e "${BLUE}=== Cron Execution Log ===${NC}"
    tail -30 "$CRON_LOG"
}

show_summary() {
    if [ ! -f "$WEEKLY_SUMMARY" ]; then
        echo "No summary logs found"
        return
    fi

    echo -e "${BLUE}=== Weekly Summary ===${NC}"
    cat "$WEEKLY_SUMMARY"
}

show_stats() {
    echo -e "${BLUE}=== Update Statistics ===${NC}"
    echo ""

    if [ -f "$LOG_FILE" ]; then
        TOTAL_RUNS=$(grep -c "System Update Started" "$LOG_FILE" || echo "0")
        echo -e "${GREEN}Total Update Runs:${NC} $TOTAL_RUNS"

        TOTAL_PACKAGES=$(grep -c "✓ Updated:" "$LOG_FILE" || echo "0")
        echo -e "${GREEN}Total Packages Updated:${NC} $TOTAL_PACKAGES"

        LAST_UPDATE=$(grep "System Update Started" "$LOG_FILE" | tail -1)
        echo -e "${GREEN}Last Update:${NC} $LAST_UPDATE"
    else
        echo "No statistics available yet"
    fi

    echo ""
    echo -e "${BLUE}=== Log Files ===${NC}"
    ls -lh "$LOG_DIR" 2>/dev/null | tail -n +2 | awk '{print $9, "(" $5 ")"}'
}

show_watch() {
    echo -e "${BLUE}=== Watching Update Log (press Ctrl+C to stop) ===${NC}"
    tail -f "$LOG_FILE"
}

show_help() {
    echo -e "${BLUE}=== System Update Log Viewer ===${NC}"
    echo ""
    echo "Usage: view-update-logs.sh [command]"
    echo ""
    echo "Commands:"
    echo -e "  ${GREEN}latest${NC}    - Show latest 20 updates (default)"
    echo -e "  ${GREEN}full${NC}      - Show all update logs"
    echo -e "  ${GREEN}detailed${NC}  - Show detailed logs"
    echo -e "  ${GREEN}cron${NC}      - Show cron execution logs"
    echo -e "  ${GREEN}summary${NC}   - Show weekly summary"
    echo -e "  ${GREEN}stats${NC}     - Show update statistics"
    echo -e "  ${GREEN}watch${NC}     - Watch logs in real-time"
    echo -e "  ${GREEN}help${NC}      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  view-update-logs.sh latest"
    echo "  view-update-logs.sh watch"
    echo "  view-update-logs.sh stats"
}

# Main
case "${1:-latest}" in
    latest)
        show_latest
        ;;
    full)
        show_full
        ;;
    detailed)
        show_detailed
        ;;
    cron)
        show_cron
        ;;
    summary)
        show_summary
        ;;
    stats)
        show_stats
        ;;
    watch)
        show_watch
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac

exit 0
