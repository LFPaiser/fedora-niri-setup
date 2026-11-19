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

    command -q direnv; and direnv hook fish | source

    # Abbreviations instead of aliases: they expand when you hit Space/Enter, so the
    # real command shows on screen and lands in the history as typed.
    abbr -a ls   'eza --icons --group-directories-first'
    abbr -a ll   'eza -l --icons --git --group-directories-first'
    abbr -a la   'eza -la --icons --git --group-directories-first'
    abbr -a tree 'eza --tree --icons'
    abbr -a cat  'bat --paging=never'
    abbr -a lg   lazygit
    # git
    abbr -a g    git
    abbr -a gs   'git status -sb'
    abbr -a gd   'git diff'
    abbr -a ga   'git add'
    abbr -a gc   'git commit'
    abbr -a gp   'git push'
    abbr -a gl   'git log --oneline --graph -20'
    abbr -a gsw  'git switch'
    # `!!` → the previous command (e.g. `sudo !!`)
    function _last_cmd; echo $history[1]; end
    abbr -a !! --position anywhere --function _last_cmd
end
