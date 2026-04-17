# PATH
export PATH="$HOME/.local/bin:$PATH"

# Starship
eval "$(starship init zsh)"

# atuin(terminal history)
eval "$(atuin init zsh)"

# ailas
alias ls="eza -T"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
