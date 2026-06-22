#!/bin/bash
# Claude Code Status Line Setup
# Run this script to install the custom status line configuration

set -e

STATUSLINE_SCRIPT_DIR="$HOME/.claude"
STATUSLINE_SCRIPT="$STATUSLINE_SCRIPT_DIR/statusline-command.sh"

echo "Installing Claude Code custom status line..."

# Create .claude directory if it doesn't exist
mkdir -p "$STATUSLINE_SCRIPT_DIR"

# Copy the status line script
cat > "$STATUSLINE_SCRIPT" << 'SCRIPT_EOF'
#!/bin/sh
# Claude Code status line - styled after Powerlevel10k Pure theme

input=$(cat)

# Account display name (same name shown in the "Welcome back ..." greeting)
display_name=""
for cfg in "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.claude.json" "$HOME/.claude.json"; do
  if [ -f "$cfg" ]; then
    display_name=$(jq -r '.oauthAccount.displayName // empty' "$cfg" 2>/dev/null)
    [ -n "$display_name" ] && break
  fi
done
dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // ""')
effort=$(echo "$input" | jq -r '.effort.level // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
in_tok=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')
out_tok=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // empty')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // empty')
rate_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rate_5h_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
rate_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Shorten home directory to ~
home="$HOME"
short_dir=$(echo "$dir" | sed "s|^$home|~|")

# Git branch (skip optional lock files)
git_branch=""
if git -C "$dir" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$dir" -c core.fsmonitor=false symbolic-ref --short HEAD 2>/dev/null || git -C "$dir" -c core.fsmonitor=false rev-parse --short HEAD 2>/dev/null)
fi

# Build output with ANSI colors matching Pure/Snazzy palette
grey="\033[38;5;242m"
blue="\033[38;2;87;199;255m"
magenta="\033[38;2;255;106;193m"
cyan="\033[38;2;154;237;254m"
yellow="\033[38;2;243;249;157m"
green="\033[38;2;90;247;142m"
reset="\033[0m"

# directory
printf "${blue}%s${reset}" "$short_dir"

# git branch
if [ -n "$git_branch" ]; then
  printf "  ${magenta}%s${reset}" "$git_branch"
fi

# separator
printf "  ${grey}|${reset}"

# account display name (same name shown in the "Welcome back ..." greeting)
if [ -n "$display_name" ]; then
  printf "  ${green}%s${reset}" "$display_name"
fi

# model
if [ -n "$model" ]; then
  printf "  ${cyan}%s${reset}" "$model"
fi

# reasoning effort level (only present when the model supports it)
if [ -n "$effort" ]; then
  printf "  ${yellow}effort:${reset}${cyan}%s${reset}" "$effort"
fi

# weekly / session rate limit usage
if [ -n "$rate_7d" ]; then
  printf "  ${yellow}week:${reset}${cyan}$(printf '%.0f' "$rate_7d")%%${reset}"
fi

if [ -n "$rate_5h" ]; then
  session_str="$(printf '%.0f' "$rate_5h")%"
  if [ -n "$rate_5h_reset" ]; then
    now=$(date +%s)
    secs_left=$(( rate_5h_reset - now ))
    if [ "$secs_left" -gt 0 ] 2>/dev/null; then
      hrs=$(( secs_left / 3600 ))
      mins=$(( (secs_left % 3600) / 60 ))
      if [ "$hrs" -gt 0 ]; then
        reset_str="${hrs}h$(printf '%02d' $mins)m"
      else
        reset_str="${mins}m"
      fi
      session_str="${session_str} reset ${reset_str}"
    fi
  fi
  printf "  ${yellow}session:${reset}${cyan}%s${reset}" "$session_str"
fi

# context usage percentage
if [ -n "$used" ]; then
  printf "  ${yellow}ctx:$(printf '%.0f' "$used")%%${reset}"
fi

# token counts from last API call
if [ -n "$in_tok" ] && [ -n "$out_tok" ]; then
  # Format large numbers compactly: 1000 -> 1k
  fmt_tok() {
    val=$1
    if [ "$val" -ge 1000 ] 2>/dev/null; then
      printf "%.1fk" "$(echo "scale=1; $val / 1000" | bc)"
    else
      printf "%s" "$val"
    fi
  }
  in_fmt=$(fmt_tok "$in_tok")
  out_fmt=$(fmt_tok "$out_tok")
  printf "  ${grey}in:${reset}${cyan}%s${reset} ${grey}out:${reset}${cyan}%s${reset}" "$in_fmt" "$out_fmt"
  if [ -n "$cache_read" ] && [ "$cache_read" -gt 0 ] 2>/dev/null; then
    cache_fmt=$(fmt_tok "$cache_read")
    printf " ${grey}cache:${reset}${cyan}%s${reset}" "$cache_fmt"
  fi
fi

# time
printf "  ${grey}%s${reset}" "$(date +%H:%M)"

printf "\n"
SCRIPT_EOF

chmod +x "$STATUSLINE_SCRIPT"

echo "✓ Status line script installed to: $STATUSLINE_SCRIPT"
echo ""
echo "Next step: Configure Claude Code to use this script"
echo "=================================================="
echo ""
echo "Run this command in Claude Code:"
echo "  /config"
echo ""
echo "Then navigate to: Settings → Status Line Command"
echo "And set the path to:"
echo "  ~/.claude/statusline-command.sh"
echo ""
echo "Done! Your status line will now show:"
echo "  • Directory"
echo "  • Account display name (same as the 'Welcome back ...' greeting)"
echo "  • Current model"
echo "  • Reasoning effort level (e.g., 'effort:high') when supported"
echo "  • Session usage % with reset timer (e.g., '9% reset 2h34m')"
echo "  • Weekly usage % (e.g., 'week: 43%')"
echo "  • Context window % (e.g., 'ctx: 8%')"
echo "  • Token counts: in/out/cache from last API call"
echo "  • Current time"
