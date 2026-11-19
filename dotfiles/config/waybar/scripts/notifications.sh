#!/bin/sh
# Waybar custom module: bell + notification count (no number at zero); slashed
# bell in amber when do-not-disturb is on. Works with swaync or mako.
# Output classes follow swaync: notification | none | dnd-notification | dnd-none.
fmt='(.text | tonumber? // 0) as $n
  | (.alt | startswith("dnd")) as $dnd
  | .text = (if $n > 0 then " \($n)" else "" end)
  | .tooltip = ((if $dnd then "Não perturbe: ligado" else "Notificações" end)
      + (if $n > 0 then " · \($n)" else "" end)
      + "\nClique: \($hist) · Direito: não perturbe · Meio: limpar tudo")'

if [ "$(~/.local/bin/notifications daemon)" = swaync ]; then
    # swaync pushes a line on every change
    exec swaync-client -swb | jq --unbuffered -c --arg hist central "$fmt"
fi
# mako has no change events: poll
while :; do
    n=$(makoctl list -j 2>/dev/null | jq length 2>/dev/null || echo 0)
    if makoctl mode 2>/dev/null | grep -qx do-not-disturb; then s=dnd-; else s=; fi
    [ "$n" -gt 0 ] && s=${s}notification || s=${s}none
    printf '{"text":"%s","alt":"%s","class":"%s"}\n' "$n" "$s" "$s"
    sleep 2
done | jq --unbuffered -c --arg hist "reabrir a última" "$fmt"
