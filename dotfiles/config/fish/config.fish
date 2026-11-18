fish_add_path ~/.local/bin

if status is-interactive
    set -g fish_greeting

    command -q mise; and mise activate fish | source
    command -q starship; and starship init fish | source
    command -q zoxide; and zoxide init fish | source
    command -q fzf; and fzf --fish | source

    # Umbra colours for fzf (bat: theme in ~/.config/bat/config)
    set -gx FZF_DEFAULT_OPTS "--color=bg+:#3a1544,bg:#26082f,spinner:#e0a050,hl:#e0a050,fg:#e6d6c6,header:#c58bd6,info:#8f6a90,pointer:#e0a050,marker:#f2cf8a,fg+:#fdf0dc,prompt:#e0a050,hl+:#f2cf8a,border:#57235a --border=rounded"
    # File colours for ls/eza/fd/tree from the vivid theme ~/.config/vivid/themes/umbra.yml
    command -q vivid; and set -gx LS_COLORS (vivid generate umbra)

    alias ls 'eza --icons --group-directories-first'
    alias ll 'eza -l --icons --git --group-directories-first'
    alias la 'eza -la --icons --git --group-directories-first'
    alias tree 'eza --tree --icons'
    alias cat 'bat --paging=never'
    alias lg lazygit
end
