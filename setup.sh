#!/usr/bin/env bash
# Fedora + niri setup. Run from your normal user account (not with sudo):
#   ./setup.sh               auto: gaming tools only on real hardware
#   ./setup.sh --gaming      force gaming tools
#   ./setup.sh --no-gaming   skip gaming tools
#   --cursors=options|fun|all   also install extra cursor themes (scripts/cursors.sh);
#                               the default cursor is always installed
#   --notifications=swaync|mako notification daemon; asked when run in a terminal,
#                               swaync when unattended. The other one is removed.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)

args=("$@")
case " $* " in
    *" --notifications="*) ;;
    *)
        notif=swaync
        if [ -t 0 ]; then
            echo "Notification daemon:"
            echo "  1) swaync  pauses on hover, notification center with history (default)"
            echo "  2) mako    minimal and lighter; Super+Ctrl+N brings back the last one"
            read -rp "Choose [1/2]: " ans
            [ "$ans" = 2 ] && notif=mako
        fi
        args+=("--notifications=$notif") ;;
esac

sudo bash "$here/scripts/system.sh" "${args[@]}"
bash "$here/scripts/user.sh" "${args[@]}"

echo
echo "All done. Reboot (or log out and back in) to start the themed niri session."
