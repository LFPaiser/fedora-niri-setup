#!/bin/sh
# Waybar custom module: mako do-not-disturb state. Click toggles.
if [ "$1" = toggle ]; then makoctl mode -t do-not-disturb >/dev/null; pkill -RTMIN+8 waybar; exit; fi
if makoctl mode | grep -qx do-not-disturb; then
  printf '{"text":"󰂛","class":"on","tooltip":"Não perturbe: ligado"}\n'
else
  printf '{"text":"󰂚","class":"off","tooltip":"Notificações: ligadas (clique = não perturbe)"}\n'
fi
