#!/bin/bash
cd "$(dirname "$0")"

# .claude/以下のシンボリックリンクを作成
mkdir -p "$HOME/.claude"
ln -snf "$(pwd)/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -snf "$(pwd)/.claude/settings.json" "$HOME/.claude/settings.json"
ln -snf "$(pwd)/.claude/rules" "$HOME/.claude/rules"
ln -snf "$(pwd)/.claude/skills" "$HOME/.claude/skills"
