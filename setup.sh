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
