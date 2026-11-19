# Settings for the `done` fisher plugin (see fish_plugins): a desktop notification when a
# long command ends and the niri window focused at its start is no longer focused.
# Named to sort before the plugin's own conf.d/done.fish, which only sets defaults
# (`set -q`), so these values win.
if status is-interactive
    set -g __done_min_cmd_duration 10000
    set -g __done_notification_command '__done_notify_send $exit_status $cmd_duration "$wd" "$argv[1]"'
    set -g __done_exclude '^git (?!push|pull|fetch)' '^(sudo )?(btop|htop|top|nvim|vim|vi|hx|helix|lazygit|lg|yazi|ranger|nnn|man|less|more|ssh|mosh|tmux|screen|zellij|watch|fzf|nmtui|alsamixer|claude|herdr)\b'
end
