#!/bin/bash
cd "$(dirname "$0")"

# シンボリックリンクを作成
mkdir -p "$HOME/.claude"
ln -sf $(pwd)/.zshrc $HOME/.zshrc
ln -snf "$(pwd)/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -snf "$(pwd)/.claude/settings.json" "$HOME/.claude/settings.json"
ln -snf "$(pwd)/.claude/statusline.sh" "$HOME/.claude/statusline.sh"
ln -snf "$(pwd)/.claude/rules" "$HOME/.claude/rules"
ln -snf "$(pwd)/.claude/skills" "$HOME/.claude/skills"
ln -snf "$(pwd)/.config/starship.toml" "$HOME/.config/starship.toml"

# MCPサーバー設定を ~/.claude.json にマージ
CLAUDE_JSON="$HOME/.claude.json"
MCP_SERVERS="$(pwd)/.claude/mcp-servers.json"
if [ -f "$CLAUDE_JSON" ]; then
    jq --slurpfile mcp "$MCP_SERVERS" '.mcpServers = $mcp[0]' "$CLAUDE_JSON" > "${CLAUDE_JSON}.tmp" \
    && mv "${CLAUDE_JSON}.tmp" "$CLAUDE_JSON"
else
    echo "{\"mcpServers\": $(cat "$MCP_SERVERS")}" > "$CLAUDE_JSON"
fi
