#!/usr/bin/env bash
# Fedora + niri setup. Run from your normal user account (not with sudo):
#   ./setup.sh               auto: gaming tools only on real hardware
#   ./setup.sh --gaming      force gaming tools
#   ./setup.sh --no-gaming   skip gaming tools
#   --cursors=options|fun|all   also install extra cursor themes (scripts/cursors.sh);
#                               the default cursor is always installed
#   --notifications=swaync|mako notification daemon; asked when run in a terminal,
#                               swaync when unattended. The other one is removed.
#   --boot-menu=hidden|show     GRUB menu: hidden (boots after 1 s, Esc shows it) or shown
#                               every boot (5 s); asked only when another OS is installed
#   --boot-remember=yes|no      boot the last chosen entry (e.g. Windows) next time;
#                               asked together with --boot-menu
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

# Another OS next to Fedora (UEFI entry outside \EFI\fedora, or os-prober finds one)?
other_os() {
    efibootmgr -v 2>/dev/null | grep -oiE '\\EFI\\[^\\]+\\' | grep -viqE '\\EFI\\(fedora|BOOT)\\' && return
    command -v os-prober >/dev/null && [ -n "$(sudo os-prober 2>/dev/null)" ]
}
case " $* " in
    *" --boot-menu="*) ;;
    *)
        if [ -t 0 ] && other_os; then
            echo "Another operating system was found. GRUB boot menu:"
            echo "  1) hidden  boots Fedora after 1 s; press Esc right after power-on for the menu (default)"
            echo "  2) show    the menu appears every boot, 5 s to choose"
            read -rp "Choose [1/2]: " ans
            [ "$ans" = 2 ] && args+=(--boot-menu=show) || args+=(--boot-menu=hidden)
            case " $* " in *" --boot-remember="*) ;; *)
                echo "Remember the last choice? (if you booted Windows, it boots by default next time)"
                read -rp "  [y/N]: " ans
                case $ans in [yYsS]*) args+=(--boot-remember=yes) ;; *) args+=(--boot-remember=no) ;; esac
            esac
        fi ;;
esac

sudo bash "$here/scripts/system.sh" "${args[@]}"
bash "$here/scripts/user.sh" "${args[@]}"

echo
echo "All done. Reboot (or log out and back in) to start the themed niri session."
