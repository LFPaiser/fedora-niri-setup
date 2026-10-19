fish_add_path ~/.local/bin

if status is-interactive
    set -g fish_greeting

    command -q mise; and mise activate fish | source
    command -q starship; and starship init fish | source
    command -q zoxide; and zoxide init fish | source
    command -q fzf; and fzf --fish | source

    # Catppuccin Mocha for fzf; bat follows the terminal colors
    set -gx FZF_DEFAULT_OPTS "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 --border=rounded"
    set -gx BAT_THEME ansi

    alias ls 'eza --icons --group-directories-first'
    alias ll 'eza -l --icons --git --group-directories-first'
    alias la 'eza -la --icons --git --group-directories-first'
    alias tree 'eza --tree --icons'
    alias cat 'bat --paging=never'
    alias lg lazygit
end
