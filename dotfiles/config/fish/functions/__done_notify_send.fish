# Notification for the `done` plugin (config.fish sets it as __done_notification_command).
# Arguments: exit status, duration in ms, working directory, command line.
# Plain notify-send: swaync shows it. Urgency stays normal, also for failures.
function __done_notify_send -a exit_status -a duration_ms -a where -a what
    set -l dur (__done_humanize_duration $duration_ms)
    set -l title "Terminou em $dur"
    test "$exit_status" -eq 0 || set title "Falhou (código $exit_status) após $dur"
    notify-send --app-name=fish --urgency=normal --icon=utilities-terminal "$title" "$where
$what"
end
