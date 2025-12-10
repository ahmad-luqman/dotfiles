# System Update Scripts - Quick Start

## ✅ Current Status
- **Cron Job**: Running every 6 hours (0, 6, 12, 18 = 12 AM, 6 AM, 12 PM, 6 PM)
- **Status**: Active and running
- **Last Run**: 2025-12-10 10:29:38 (3 packages updated)
- **Log Location**: `~/.update-logs/`

## 🚀 Quick Commands

### Run Updates Manually
```bash
~/bin/system-update.sh
```

### View Logs
```bash
# Latest updates
~/bin/view-update-logs.sh latest

# Statistics
~/bin/view-update-logs.sh stats

# Watch in real-time
~/bin/view-update-logs.sh watch

# Full detailed output
~/bin/view-update-logs.sh detailed
```

### Manage Cron
```bash
# View current cron job
crontab -l

# Edit cron schedule
crontab -e

# Change to daily updates
bash ~/bin/setup-update-cron.sh --daily

# Change to weekly
bash ~/bin/setup-update-cron.sh --weekly

# Custom schedule
bash ~/bin/setup-update-cron.sh --custom "0 */6 * * *"
```

## 📁 File Locations

```
~/bin/
├── system-update.sh              ← Main update script
├── setup-update-cron.sh         ← Cron configuration
├── view-update-logs.sh          ← Log viewer
├── update-aliases.sh            ← Shell aliases (optional)
├── UPDATE_SYSTEM_README.md      ← Full documentation
└── QUICK_START.md               ← This file

~/.update-logs/
├── updates.log                  ← Main log (summary)
├── updates-detailed.log         ← Detailed output
├── cron.log                     ← Cron execution log
└── weekly-summary.log           ← Weekly summary
```

## 🎯 Current Schedule

**Every 6 Hours** at:
- **12:00 AM** (midnight)
- **6:00 AM**
- **12:00 PM** (noon)
- **6:00 PM**

Since you mentioned your laptop closes at 2 AM, updates will run when it's on at other times.

## 📊 What Gets Updated

1. **Homebrew packages** - All outdated brew packages
2. **Homebrew cleanup** - Removes old versions
3. **NPM global packages** - Global npm packages
4. **Specific tools** - Claude, Codex, Gemini, Copilot (if installed)

## 📝 Recent Update Log

```
Total Update Runs: 2
Total Packages Updated: 3
Last Update: 2025-12-10 10:29:38

Packages Updated:
  - npm: corepack
  - npm: forgecode
  - npm: npm
```

## 🔧 Optional: Add Shell Aliases

To make commands shorter, add to your `~/.zshrc` or `~/.bashrc`:

```bash
source /Users/ahmadluqman/bin/update-aliases.sh
```

Then you can use:
```bash
update-system      # Run updates
update-logs        # View logs
update-help        # Show help
```

## 🐛 Troubleshooting

**Check if cron is running:**
```bash
crontab -l
```

**View latest logs:**
```bash
tail -f ~/.update-logs/updates.log
```

**Test manually:**
```bash
~/bin/system-update.sh
```

**For more help:**
```bash
cat ~/bin/UPDATE_SYSTEM_README.md
```

---

**Last Updated**: 2025-12-10
**Cron Status**: ✅ Active (every 6 hours)
