#!/bin/sh
# Waybar: time since boot.
s=$(cut -d. -f1 /proc/uptime)
d=$((s/86400)); h=$((s%86400/3600)); m=$((s%3600/60))
if [ $d -gt 0 ]; then t="${d}d ${h}h"; elif [ $h -gt 0 ]; then t="${h}h ${m}m"; else t="${m}m"; fi
since=$(uptime -s)
printf '{"text":"󰔟 %s","tooltip":"Ligado desde %s"}\n' "$t" "$since"
