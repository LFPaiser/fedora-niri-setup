#!/bin/sh
# Wi-Fi menu in fuzzel (NetworkManager via nmcli). Opened by the waybar network icon.
menu() { fuzzel --dmenu --minimal-lines --width 46 --prompt "$1" ${2:+--placeholder "$2"}; }
note() { notify-send -a Rede -i network-wireless "$1" "$2"; }

wifi_on=$(nmcli radio wifi)
has_wifi=$(nmcli -t -f TYPE dev | grep -qx wifi && echo yes)

actions() {
    if [ -z "$has_wifi" ]; then
        echo "󰤮  Sem adaptador Wi-Fi"
    elif [ "$wifi_on" = enabled ]; then
        echo "󰤭  Desligar Wi-Fi"
        echo "󰑓  Procurar redes de novo"
    else
        echo "󰤨  Ligar Wi-Fi"
    fi
    nmcli -t -f DEVICE,STATE dev | grep -q ':connected$' && echo "󰅖  Desconectar"
    echo "󰒓  Editor avançado de conexões"
}

networks() {
    [ -n "$has_wifi" ] && [ "$wifi_on" = enabled ] || return
    # IN-USE:SIGNAL:SECURITY:SSID — SSID last so colons inside it survive the split.
    nmcli -t --escape no -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list --rescan "${1:-auto}" 2>/dev/null |
    awk -F: '{
        inuse=$1; sig=$2; sec=$3; ssid=substr($0, length($1)+length($2)+length($3)+4)
        if (ssid == "" || seen[ssid]++) next
        icon = sig>=80 ? "󰤨" : sig>=60 ? "󰤥" : sig>=40 ? "󰤢" : sig>=20 ? "󰤟" : "󰤯"
        lock = (sec == "" || sec == "--") ? "  " : "󰌾 "
        mark = inuse == "*" ? "  ✓" : ""
        printf "%s %s %s%s\n", icon, lock, ssid, mark
    }'
}

choice=$( { networks "$1"; actions; } | menu "󰤨  " "rede ou ação…") || exit 0

case "$choice" in
    *"Desligar Wi-Fi"*)   nmcli radio wifi off && note "Wi-Fi desligado" ;;
    *"Ligar Wi-Fi"*)      nmcli radio wifi on && note "Wi-Fi ligado" "Procurando redes…" && sleep 3 && exec "$0" yes ;;
    *"Procurar redes"*)   exec "$0" yes ;;
    *"Editor avançado"*)  exec nm-connection-editor ;;
    *"Sem adaptador"*)    exit 0 ;;
    *"Desconectar"*)
        dev=$(nmcli -t -f DEVICE,TYPE,STATE dev | awk -F: '$3=="connected" && ($2=="wifi"||$2=="ethernet"){print $1; exit}')
        nmcli dev disconnect "$dev" && note "Desconectado" "$dev" ;;
    *)
        # Strip "icon lock " prefix and the "  ✓" suffix to recover the SSID.
        ssid=$(printf '%s' "$choice" | sed -E 's/^[^ ]+ +(󰌾 )? *//; s/  ✓$//')
        case "$choice" in *"  ✓") note "Já conectado" "$ssid"; exit 0 ;; esac
        if nmcli -t -f NAME con show | grep -Fxq "$ssid"; then
            nmcli con up id "$ssid" >/dev/null 2>&1 && note "Conectado" "$ssid" && exit 0
        fi
        case "$choice" in
            *"󰌾"*) pw=$(fuzzel --dmenu --password --lines 0 --width 40 --prompt "󰌾  $ssid: ") || exit 0
                    out=$(nmcli dev wifi connect "$ssid" password "$pw" 2>&1) ;;
            *)      out=$(nmcli dev wifi connect "$ssid" 2>&1) ;;
        esac
        if [ $? -eq 0 ]; then note "Conectado" "$ssid"
        else note "Falha ao conectar em $ssid" "$out"; fi ;;
esac
