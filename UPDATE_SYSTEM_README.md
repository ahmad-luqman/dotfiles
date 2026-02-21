# System Update Scripts

Complete automation solution for managing Homebrew and npm package updates with comprehensive logging.

## Scripts Overview

### 1. `system-update.sh` - Main Update Script
Performs all system updates and logs results.

**What it does:**
- Updates Homebrew
- Upgrades all outdated Homebrew packages
- Runs Homebrew cleanup
- Updates global npm packages
- Logs all changes with timestamps
- Tracks updates in multiple log files

**Usage:**
```bash
/Users/ahmadluqman/bin/system-update.sh

# Or run directly
~/scripts/system-update.sh
```

### 2. `setup-update-cron.sh` - Cron Configuration Helper
Sets up automated scheduling for the update script.

**Available Schedules:**

```bash
# Weekly updates (Sunday 2 AM) - DEFAULT
bash ~/scripts/setup-update-cron.sh --weekly

# Daily updates (2 AM every day)
bash ~/scripts/setup-update-cron.sh --daily

# Custom schedule (using cron expression)
bash ~/scripts/setup-update-cron.sh --custom "0 3 * * 0"
```

**Cron Expression Format:** `minute hour day month weekday`
- `0 2 * * 0` = Sunday at 2:00 AM
- `0 2 * * *` = Every day at 2:00 AM
- `30 3 * * 1` = Monday at 3:30 AM

### 3. `view-update-logs.sh` - Log Viewer
Inspect and analyze update logs.

**Commands:**

```bash
# Show latest 20 updates (default)
view-update-logs.sh
view-update-logs.sh latest

# Show all update logs
view-update-logs.sh full

# Show detailed system output
view-update-logs.sh detailed

# Show cron execution logs
view-update-logs.sh cron

# Show weekly summary
view-update-logs.sh summary

# Show statistics
view-update-logs.sh stats

# Watch logs in real-time
view-update-logs.sh watch

# Help
view-update-logs.sh help
```

## Quick Start

### Step 1: Run Initial Update
```bash
~/scripts/system-update.sh
```

### Step 2: Set Up Cron Job
```bash
# For weekly updates (recommended)
bash ~/scripts/setup-update-cron.sh --weekly

# Or daily updates
bash ~/scripts/setup-update-cron.sh --daily
```

### Step 3: Verify Installation
```bash
# Check crontab
crontab -l

# View latest updates
view-update-logs.sh latest
```

## Log Files

All logs are stored in `~/.update-logs/`:

| File | Purpose |
|------|---------|
| `updates.log` | Main update log with timestamps and summary |
| `updates-detailed.log` | Full command output from updates |
| `cron.log` | Cron execution log |
| `weekly-summary.log` | Weekly summary of all updates |

**View logs:**
```bash
# Latest updates
tail -f ~/.update-logs/updates.log

# All logs
ls -lh ~/.update-logs/

# Watch in real-time
view-update-logs.sh watch
```

## Examples

### Example 1: Daily Updates
```bash
# Set up daily updates at 2 AM
bash ~/scripts/setup-update-cron.sh --daily

# Verify
crontab -l | grep system-update

# Check today's results
view-update-logs.sh latest
```

### Example 2: Weekly Updates on Mondays
```bash
# Set up custom schedule for Mondays at 3 AM
bash ~/scripts/setup-update-cron.sh --custom "0 3 * * 1"

# Verify
crontab -l

# View weekly summary
view-update-logs.sh summary
```

### Example 3: Manual Update with Logging
```bash
# Run update manually
~/scripts/system-update.sh

# Check what was updated
view-update-logs.sh latest

# View detailed output
view-update-logs.sh detailed
```

### Example 4: Monitor Updates Over Time
```bash
# View statistics
view-update-logs.sh stats

# Export logs for analysis
cat ~/.update-logs/updates.log > ~/Desktop/update-log-backup.txt
```

## Managing Cron Jobs

### View All Cron Jobs
```bash
crontab -l
```

### Edit Crontab
```bash
crontab -e
```

### Remove Update Cron Job
```bash
# Edit crontab and delete the line with system-update.sh
crontab -e

# Or use a one-liner
crontab -l | grep -v "system-update" | crontab -
```

### Temporarily Disable Cron Job
Edit crontab and add `#` at the start of the line:
```bash
# 0 2 * * 0 /Users/ahmadluqman/bin/system-update.sh >> ~/.update-logs/cron.log 2>&1
```

## Troubleshooting

### Cron Job Not Running
1. Check if cron is enabled: `launchctl list | grep cron`
2. Verify script is executable: `ls -l ~/scripts/system-update.sh`
3. Check log: `view-update-logs.sh cron`
4. Ensure `HOMEBREW_NO_INSTALL_CLEANUP=1` is not set

### Permission Denied Error
```bash
# Make scripts executable
chmod +x ~/scripts/system-update.sh
chmod +x ~/scripts/setup-update-cron.sh
chmod +x ~/scripts/view-update-logs.sh
```

### Logs Not Being Created
```bash
# Create log directory manually
mkdir -p ~/.update-logs

# Test script
~/scripts/system-update.sh

# Check if logs were created
ls -lh ~/.update-logs/
```

### Cron Email Notifications (Optional)
To receive email on errors:
```bash
# Edit crontab
crontab -e

# Add MAILTO at the top
MAILTO=your-email@example.com
0 2 * * 0 /Users/ahmadluqman/bin/system-update.sh
```

## Security Notes

- Scripts check for Homebrew and npm availability before running
- No sensitive data is logged
- Logs include only package names and timestamps
- All scripts run with user permissions (no sudo required)

## Advanced Usage

### Custom Update Frequency
```bash
# Every 6 hours
bash ~/scripts/setup-update-cron.sh --custom "0 0,6,12,18 * * *"

# Twice daily (2 AM and 2 PM)
bash ~/scripts/setup-update-cron.sh --custom "0 2,14 * * *"

# First day of month
bash ~/scripts/setup-update-cron.sh --custom "0 2 1 * *"
```

### Log Rotation
For long-term storage, archive logs monthly:
```bash
# Add to crontab
0 0 1 * * gzip -c ~/.update-logs/updates.log > ~/.update-logs/updates-$(date +\%Y-\%m).log.gz && rm ~/.update-logs/updates.log
```

### Integration with Other Tools
```bash
# Get update count
grep -c "✓ Updated:" ~/.update-logs/updates.log

# Export to JSON (requires jq)
# Can be extended to create JSON output

# Slack notification
# Add to system-update.sh to send webhook to Slack
```

## File Locations

```
~/scripts/
├── system-update.sh          # Main update script
├── setup-update-cron.sh      # Cron setup helper
├── view-update-logs.sh       # Log viewer
└── UPDATE_SYSTEM_README.md   # This file

~/.update-logs/
├── updates.log              # Main log
├── updates-detailed.log     # Detailed log
├── cron.log                 # Cron execution log
└── weekly-summary.log       # Weekly summary
```

## Support

For issues or questions:
1. Check logs: `view-update-logs.sh latest`
2. Review detailed output: `view-update-logs.sh detailed`
3. Verify cron setup: `crontab -l`
4. Test manually: `~/scripts/system-update.sh`

---

Last updated: 2025-12-10
