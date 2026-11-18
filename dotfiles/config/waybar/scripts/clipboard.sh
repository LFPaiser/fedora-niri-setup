#!/bin/sh
# Waybar: clipboard history (cliphist). Click opens the picker.
if [ "$1" = pick ]; then
  cliphist list | fuzzel --dmenu --prompt '󰅌  ' | cliphist decode | wl-copy
  exit
fi
n=$(cliphist list 2>/dev/null | wc -l)
printf '{"text":"󰅌","tooltip":"Clipboard: %s itens\\nClique abre o histórico (Super+Shift+V)"}\n' "$n"
