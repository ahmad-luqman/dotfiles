#!/bin/bash

# Shell aliases and functions for update scripts
# Add this to your ~/.zshrc or ~/.bashrc:
#   source /Users/ahmadluqman/bin/update-aliases.sh

# Aliases for convenient access
alias update-system='/Users/ahmadluqman/bin/system-update.sh'
alias update-logs='/Users/ahmadluqman/bin/view-update-logs.sh'
alias update-cron='bash /Users/ahmadluqman/bin/setup-update-cron.sh'

# Functions for more convenient usage
update-help() {
    cat << 'EOF'
System Update Commands:

  update-system           Run system updates (Homebrew + npm)
  update-logs [cmd]       View update logs
  update-cron [schedule]  Setup cron job

Log Viewing:
  update-logs latest      Show latest 20 updates
  update-logs full        Show all updates
  update-logs detailed    Show detailed output
  update-logs stats       Show statistics
  update-logs watch       Watch logs in real-time

Cron Setup:
  update-cron --daily          Run daily at 2 AM
  update-cron --weekly         Run weekly (Sunday 2 AM)
  update-cron --custom "0 */6 * * *"  Custom cron expression

Examples:
  update-system              # Run updates now
  update-logs stats          # View statistics
  update-logs watch          # Monitor in real-time
EOF
}

# Export functions
export -f update-help
