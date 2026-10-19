#!/usr/bin/env bash
# Fedora + niri setup. Run from your normal user account (not with sudo):
#   ./setup.sh               auto: gaming tools only on real hardware
#   ./setup.sh --gaming      force gaming tools
#   ./setup.sh --no-gaming   skip gaming tools
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)

sudo bash "$here/scripts/system.sh" "$@"
bash "$here/scripts/user.sh"

echo
echo "All done. Reboot (or log out and back in) to start the themed niri session."
