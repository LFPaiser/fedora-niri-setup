#!/bin/sh
# Waybar: unread GitHub notifications via gh.
json=$(gh api notifications 2>/dev/null) || { printf '{"text":"","class":"error","tooltip":"gh: sem acesso"}\n'; exit 0; }
printf '%s' "$json" | jq -c '
  def esc: gsub("&";"&amp;") | gsub("<";"&lt;") | gsub(">";"&gt;");
  length as $n
  | {
      text: (if $n > 0 then "󰊤 \($n)" else "󰊤" end),
      class: (if $n > 0 then "unread" else "none" end),
      tooltip: (if $n == 0 then "GitHub: nada novo"
                else "<b>GitHub — \($n) não lidas</b>\n" + ([.[:8][] | "\(.repository.name): \(.subject.title)" | esc] | join("\n")) end)
    }'
