# Claude Code Custom Status Line

A beautiful status line for Claude Code that shows **real-time usage limits**, **token consumption**, and **session reset timers**.

## What it shows

```
sourav@MacBook  ~/Documents  main  |  Sourav  Claude Haiku  session: 9% reset 2h34m  week: 43%  ctx: 8%  in: 12.3k out: 847  14:22
```

| Field | Meaning |
|-------|---------|
| `sourav@MacBook` | Your username and machine |
| `~/Documents` | Current working directory |
| `main` | Git branch (if in a repo) |
| `Sourav` | Your account display name (same name shown in the "Welcome back …" greeting) |
| `Claude Haiku` | Current Claude model |
| `session: 9% reset 2h34m` | **Current session usage** with countdown to reset |
| `week: 43%` | **Weekly usage** (7-day rolling window) |
| `ctx: 8%` | Context window fullness percentage |
| `in: 12.3k` | Input tokens from last API call |
| `out: 847` | Output tokens from last API call |
| `cache: 9.8k` | Cached input tokens (shown when > 0) |
| `14:22` | Current time |

## Installation

### Option 1: Automated Setup (Easiest)

```bash
bash ~/Documents/claude-statusline-setup.sh
```

This script will:
1. Create `~/.claude/` directory if needed
2. Install `statusline-command.sh`
3. Show you next steps

### Option 2: Manual Setup

1. Copy `statusline-command.sh` to `~/.claude/statusline-command.sh`
2. Make it executable:
   ```bash
   chmod +x ~/.claude/statusline-command.sh
   ```
3. In Claude Code, open settings with `/config`
4. Go to **Settings → Status Line Command**
5. Set the path to: `~/.claude/statusline-command.sh`

## Configuration

The status line is **read-only** — it pulls data from Claude Code's internal state and displays it.

To customize colors or fields, edit the script at `~/.claude/statusline-command.sh`.

### Color reference
- **Grey** (`242m`) — labels
- **Blue** — directory
- **Magenta** — git branch
- **Green** — account display name
- **Cyan** — values
- **Yellow** — labels (usage/context)

## Understanding the limits

### Session limit (5-hour rolling window)
- Resets every 5 hours
- Shows `session: X% reset Xh Xm`
- When you hit 100%, new API calls are blocked until the window rolls

### Weekly limit (7-day rolling window)
- Resets every 7 days (Tuesday 8:30 PM PT)
- Shows `week: X%`
- Your pro plan covers usage up to this limit

## Troubleshooting

**Status line not showing?**
- Usage data only appears after the first API call in a session
- Check that the path in `/config` → Settings → Status Line Command is correct

**Reset timer not showing?**
- First API call of the session hasn't happened yet
- Or your Claude Code version doesn't have rate limit data (update to latest)

**Colors look wrong?**
- Terminal doesn't support 24-bit RGB colors
- Try a modern terminal (iTerm2, Kitty, WezTerm, etc.)

## Sharing with your team

1. Share `statusline-command.sh` and this README
2. Team members run the setup script or follow manual setup
3. Everyone gets the same status line view

## System requirements

- macOS, Linux, or WSL2
- `jq` installed (usually comes with Claude Code)
- `bash` or `sh`
- A terminal that supports ANSI colors (most modern terminals do)

---

**Made for:** Sourav Das and team  
**Status line script:** Embedded in setup script above
