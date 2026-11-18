#!/bin/sh
# Pick which Fedora updates to install (fzf multi-select). Opened by the waybar 󰏗 module.
list=$(dnf -q --cacheonly check-upgrade 2>/dev/null | grep -E '^\S+\.\S+\s+\S+\s+\S+' | awk '{printf "%-50s %-32s %s\n", $1, $2, $3}')
if [ -z "$list" ]; then echo "Nenhuma atualização pendente."; read -r _; exit; fi

sel=$(printf '%s\n' "$list" | fzf --multi --reverse --no-sort \
  --prompt='atualizar › ' \
  --header='Tab marca · Ctrl-A marca tudo · Ctrl-D desmarca · Enter instala · Esc sai' \
  --bind='ctrl-a:select-all,ctrl-d:deselect-all' \
  --preview='dnf -q --cacheonly info --upgrades {1} 2>/dev/null | grep -E "^(Name|Version|Release|Repository|Size|Summary|Description)" ' \
  --preview-window='down,40%,wrap') || exit 0

pkgs=$(printf '%s\n' "$sel" | awk '{print $1}')
n=$(printf '%s\n' "$pkgs" | wc -l)
printf '\nAtualizando %s pacote(s):\n%s\n\n' "$n" "$pkgs"
# shellcheck disable=SC2086
sudo dnf upgrade $pkgs
pkill -RTMIN+9 waybar
printf '\nEnter para fechar'; read -r _
