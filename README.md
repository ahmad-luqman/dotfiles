# dotfiles

Personal automation and utility scripts for macOS system maintenance and development environment management.

## 📦 Contents

### System Update Automation
Complete automation solution for managing **Homebrew** and **npm** package updates with comprehensive logging.

**Scripts:**
- `system-update.sh` - Main update script (Homebrew + npm packages)
- `setup-update-cron.sh` - Cron job configuration helper
- `view-update-logs.sh` - Log viewer and statistics

**Documentation:**
- `UPDATE_SYSTEM_README.md` - Complete guide with examples
- `QUICK_START.md` - Quick reference and setup instructions
- `update-aliases.sh` - Optional shell aliases

## 🚀 Quick Start

### 1. Setup
```bash
# Copy scripts to ~/bin
mkdir -p ~/bin
cp system-update.sh setup-update-cron.sh view-update-logs.sh ~/bin/
chmod +x ~/bin/*.sh

# Or add this repo to PATH
export PATH="$PATH:/path/to/dotfiles"
```

### 2. Run Initial Update
```bash
./system-update.sh
```

### 3. Configure Cron Job
```bash
# Weekly updates (Sunday 2 AM)
bash setup-update-cron.sh --weekly

# Daily updates
bash setup-update-cron.sh --daily

# Every 6 hours
bash setup-update-cron.sh --custom "0 */6 * * *"
```

### 4. View Logs
```bash
./view-update-logs.sh latest     # Show latest updates
./view-update-logs.sh stats      # Show statistics
./view-update-logs.sh watch      # Watch in real-time
```

## 📋 System Updates

### What Gets Updated
- ✅ Homebrew packages (all outdated packages)
- ✅ Homebrew cleanup (removes old versions)
- ✅ NPM global packages
- ✅ Specific tools (claude, codex, gemini, copilot)
- ✅ GitHub Actions runner logs (deletes logs older than 7 days)

### Example Output
```
[2025-12-10 10:29:38] === System Update Started ===
[2025-12-10 10:29:38] Checking Homebrew updates...
[2025-12-10 10:29:38] Upgrading Homebrew packages...
[2025-12-10 10:29:38] Running Homebrew cleanup...
[2025-12-10 10:29:38] Checking npm global packages...
[2025-12-10 10:29:38] ✓ Updated: npm: corepack
[2025-12-10 10:29:38] ✓ Updated: npm: npm
[2025-12-10 10:29:38] Checking GitHub Actions runner logs...
[2025-12-10 10:29:38] Cleaning GitHub Actions runner logs older than 7 days...
[2025-12-10 10:29:38] ✓ Deleted 127 GitHub Actions log file(s)
[2025-12-10 10:29:38] === System Update Completed ===
[2025-12-10 10:29:38] Summary: Updated 2 package(s)
```

## 📊 Log Files

Logs are stored in `~/.update-logs/`:

```
~/.update-logs/
├── updates.log              # Main log with summary
├── updates-detailed.log     # Full command output
├── cron.log                 # Cron execution log
└── weekly-summary.log       # Weekly statistics
```

## 🔧 Configuration

### Cron Schedules

**Default** - Every 6 hours:
```
0 */6 * * * /path/to/system-update.sh
```

**Daily** - 2 AM:
```
0 2 * * * /path/to/system-update.sh
```

**Weekly** - Sunday 2 AM:
```
0 2 * * 0 /path/to/system-update.sh
```

**Custom** - Modify time as needed:
```bash
bash setup-update-cron.sh --custom "0 3 * * 1"  # Monday 3 AM
```

### View/Edit Cron
```bash
# List all cron jobs
crontab -l

# Edit crontab
crontab -e

# Remove update job
crontab -l | grep -v "system-update" | crontab -
```

## 🐚 Shell Aliases (Optional)

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
source /path/to/dotfiles/update-aliases.sh
```

Then use:
```bash
update-system      # Run updates
update-logs latest # View latest logs
update-help        # Show help
```

## 📖 Documentation

- **QUICK_START.md** - Quick reference guide
- **UPDATE_SYSTEM_README.md** - Complete documentation with examples and troubleshooting

## 🐛 Troubleshooting

### Scripts not found
```bash
chmod +x ~/bin/system-update.sh ~/bin/setup-update-cron.sh ~/bin/view-update-logs.sh
```

### Cron not running
```bash
# Check if script is executable
ls -l ~/bin/system-update.sh

# Test manually
~/bin/system-update.sh

# Check cron logs
log stream --predicate 'process == "cron"' --level debug
```

### Logs not created
```bash
# Create log directory
mkdir -p ~/.update-logs

# Test script
~/bin/system-update.sh

# Verify logs
ls -lh ~/.update-logs/
```

## 📁 File Structure

```
dotfiles/
├── system-update.sh                # Main update script
├── setup-update-cron.sh           # Cron configuration
├── view-update-logs.sh            # Log viewer
├── update-aliases.sh              # Shell aliases
├── UPDATE_SYSTEM_README.md        # Complete documentation
├── QUICK_START.md                 # Quick reference
├── README.md                      # This file
└── .gitignore
```

## 🔐 Security

- All scripts run with user permissions (no `sudo` required)
- No sensitive data is logged
- Logs include only package names and timestamps
- All scripts are portable across macOS systems

## 📝 License

Personal use scripts.

## 🤝 Contributing

These are personal dotfiles, but feel free to fork and customize for your own use.

---

**Created**: 2025-12-10
**Last Updated**: 2025-12-10 (Added GitHub Actions log cleanup)
