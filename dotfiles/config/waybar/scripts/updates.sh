#!/bin/sh
# Waybar: number of pending dnf upgrades (uses cached metadata; hidden when zero).
n=$(dnf -q --cacheonly check-upgrade 2>/dev/null | grep -cE '^\S+\.\S+\s+\S+\s+\S+')
if [ "$n" -gt 0 ]; then
  printf '{"text":"󰏗 %s","tooltip":"%s atualizações do Fedora\\nClique: escolher o que atualizar\\nBotão direito: atualizar tudo","class":"pending"}\n' "$n" "$n"
else
  printf '{"text":"","class":"none"}\n'
fi
