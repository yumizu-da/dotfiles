#!/bin/bash

INPUT=$(cat)

# Colors
ORANGE='\033[38;2;227;142;73m'
PURPLE='\033[38;2;187;154;247m'
CYAN='\033[36m'
WHITE='\033[37m'
BLUE='\033[38;2;122;162;247m'
GRAY='\033[90m'
DIM='\033[38;2;60;60;60m'
RESET='\033[0m'
SEP="${GRAY}|${RESET}"

# Session info
MODEL=$(echo "$INPUT" | jq -r '.model.display_name')
CWD=$(echo "$INPUT" | jq -r '.workspace.current_dir')
PCT=$(echo "$INPUT" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
DIR="${CWD/#$HOME/~}"

BRANCH=""
if [ -n "$CWD" ] && git -C "$CWD" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$CWD" symbolic-ref --short HEAD 2>/dev/null || git -C "$CWD" rev-parse --short HEAD 2>/dev/null)
fi

echo -ne "${WHITE}${DIR}${RESET} ${SEP} ${CYAN} ${BRANCH}${RESET} ${SEP} ${ORANGE}[${MODEL}]${RESET} ${SEP} ${PURPLE}Context: ${PCT}%${RESET}"

# Usage API (OAuth, cached 360s)
CACHE_FILE="/tmp/claude-usage-cache.json"
CACHE_TTL=360

# キャッシュ付きでUsage APIからデータ取得
get_usage() {
    local now=$(date +%s)

    if [ -f "$CACHE_FILE" ]; then
        local cached_at=$(jq -r '.cached_at // 0' "$CACHE_FILE" 2>/dev/null || echo "0")
        if (( now - cached_at < CACHE_TTL )); then
        jq -r 'del(.cached_at)' "$CACHE_FILE" 2>/dev/null
        return 0
        fi
    fi

    local token=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null || true)
    [ -z "$token" ] && return 1

    local access_token=$(echo "$token" | jq -r '.claudeAiOauth.accessToken // .accessToken // .access_token // empty' 2>/dev/null || true)
    [ -z "$access_token" ] && return 1

    local response=$(curl -sf --max-time 5 \
        -H "Authorization: Bearer ${access_token}" \
        -H "anthropic-beta: oauth-2025-04-20" \
        "https://api.anthropic.com/api/oauth/usage" 2>/dev/null) || return 1

    echo "$response" | jq --arg ts "$now" '. + {cached_at: ($ts | tonumber)}' > "$CACHE_FILE" 2>/dev/null
    echo "$response"
}

# ISO8601 -> "Reset 2026/03/08 00:00 (3d02h left)"
format_reset() {
    local stripped="${1%%.*}"
    local epoch=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$stripped" +%s 2>/dev/null) || return
    local reset_date=$(TZ="Asia/Tokyo" date -r "$epoch" +"%Y/%m/%d %H:%M" 2>/dev/null) || return
    local diff=$(( epoch - $(date +%s) ))
    (( diff < 0 )) && diff=0
    local days=$(( diff / 86400 ))
    local hours=$(( (diff % 86400) / 3600 ))
    if (( days > 0 )); then
        echo "Reset ${reset_date} (${days}d$(printf '%02d' $hours)h left)"
    else
        echo "Reset ${reset_date} (${hours}h left)"
    fi
}

# 20セグメントバー + % + リセット時刻
usage_line() {
    local label=$1 util=$2 reset=$3
    [ -z "$util" ] && return

    local pct=$(echo "$util" | cut -d. -f1)
    local filled=$((pct * 20 / 100))
    local empty=$((20 - filled))
    local bar=$(printf "%${filled}s" | tr ' ' '█')
    local empty_bar=$(printf "%${empty}s" | tr ' ' '█')
    local reset_str=""
    [ -n "$reset" ] && reset_str="  $(format_reset "$reset")"

    echo -e "\n${WHITE}- ${label}:${RESET} ${WHITE}${bar}${DIM}${empty_bar}${RESET}  ${WHITE}${pct}%${RESET}${reset_str}"
}

USAGE_JSON=$(get_usage 2>/dev/null || true)
if [ -n "$USAGE_JSON" ]; then
    FIVE_UTIL=$(echo "$USAGE_JSON" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
    FIVE_RESET=$(echo "$USAGE_JSON" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)
    SEVEN_UTIL=$(echo "$USAGE_JSON" | jq -r '.seven_day.utilization // empty' 2>/dev/null)
    SEVEN_RESET=$(echo "$USAGE_JSON" | jq -r '.seven_day.resets_at // empty' 2>/dev/null)

    usage_line "5h" "$FIVE_UTIL" "$FIVE_RESET"
    usage_line "7d" "$SEVEN_UTIL" "$SEVEN_RESET"
fi
