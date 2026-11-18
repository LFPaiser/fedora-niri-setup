#!/usr/bin/env bash
# Microphone state for waybar, updated on every PipeWire change (pactl subscribe):
#   muted   crossed-out mic, dim
#   on      mic, normal colour
#   live    mic in red: some app is capturing it (tooltip names the apps)
# Capture of the output's monitor (screen recording) and peak meters (wiremix,
# pavucontrol) do not count as using the mic.
#   mic.sh          stream JSON lines (waybar "exec")
#   mic.sh toggle   mute / unmute the default mic
if [ "${1:-}" = toggle ]; then
    exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
fi

state() {
    local muted apps
    if ! pactl get-default-source >/dev/null 2>&1 || [ "$(pactl get-default-source)" = "@DEFAULT_SOURCE@" ]; then
        echo '{"text":"󰍭","class":"none","tooltip":"Sem microfone"}'; return
    fi
    muted=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')
    apps=$(jq -rn --argjson so "$(pactl -f json list source-outputs)" \
                  --argjson src "$(pactl -f json list sources)" '
        [$src[] | select(.monitor_source == "") | .index] as $mics
        | [$so[] | select(.source as $s | $mics | index($s))
                 | .properties["application.name"] // .properties["node.name"] // "?"
                 | select(test("wiremix|pavucontrol|PulseAudio Volume Control"; "i") | not)]
        | unique | join(", ")')
    if [ "$muted" = yes ]; then
        printf '{"text":"󰍭","class":"muted","tooltip":"Microfone desligado%s\\nclique: ligar"}\n' \
            "${apps:+ (aberto por: $apps)}"
    elif [ -n "$apps" ]; then
        printf '{"text":"󰍬","class":"live","tooltip":"Microfone em uso: %s\\nclique: desligar"}\n' "$apps"
    else
        echo '{"text":"󰍬","class":"on","tooltip":"Microfone ligado\nclique: desligar · direito: entradas"}'
    fi
}

state
pactl subscribe 2>/dev/null | while read -r line; do
    case "$line" in
        *source*|*server*) state ;;
    esac
done
