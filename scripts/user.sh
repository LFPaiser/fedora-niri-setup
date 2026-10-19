#!/usr/bin/env bash
# User part of the setup: dotfiles, fonts, cursor, wallpaper, theme settings,
# dev runtimes, editor and mpv extras. Run as your normal user. Safe to re-run;
# any existing config that differs is kept as <file>.bak-<timestamp>.
set -euo pipefail

[ "$(id -u)" -ne 0 ] || { echo "run as your normal user, not root" >&2; exit 1; }
here=$(cd "$(dirname "$0")/.." && pwd)
stamp=$(date +%Y%m%d-%H%M%S)
export PATH="$HOME/.local/bin:$PATH"

step() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }

install_file() { # src dst [mode]
    local src=$1 dst=$2 mode=${3:-644}
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && ! cmp -s "$src" "$dst"; then
        mv "$dst" "$dst.bak-$stamp"
        echo "  backed up $dst"
    fi
    install -m "$mode" "$src" "$dst"
}

fetch() { curl -fsSL --retry 3 "$@"; }

step "Config files -> ~/.config"
render=$(mktemp); trap 'rm -f "$render"' EXIT
(cd "$here/dotfiles/config" && find . -type f) | while read -r f; do
    src=$here/dotfiles/config/$f
    # Some configs (gtklock) need absolute paths: @HOME@ becomes your home dir.
    if grep -q '@HOME@' "$src"; then
        sed "s|@HOME@|$HOME|g" "$src" > "$render"
        src=$render
    fi
    install_file "$src" "$HOME/.config/${f#./}"
done
for f in "$here"/dotfiles/local-bin/*; do
    install_file "$f" "$HOME/.local/bin/$(basename "$f")" 755
done
mkdir -p ~/Pictures/Screenshots ~/Pictures/Wallpapers

step "Font: JetBrainsMono Nerd Font"
font_dir=~/.local/share/fonts/JetBrainsMonoNerd
if [ ! -d "$font_dir" ]; then
    mkdir -p "$font_dir"
    fetch https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz |
        tar -xJ -C "$font_dir" --wildcards '*.ttf'
fi
fc-cache -f >/dev/null

step "Cursor: Bibata Modern Classic"
if [ ! -d ~/.local/share/icons/Bibata-Modern-Classic ]; then
    mkdir -p ~/.local/share/icons
    fetch https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.tar.xz |
        tar -xJ -C ~/.local/share/icons
fi
mkdir -p ~/.icons/default
printf '[Icon Theme]\nInherits=Bibata-Modern-Classic\n' > ~/.icons/default/index.theme

step "Wallpaper"
fedora=$(rpm -E %fedora)
src=$(ls /usr/share/backgrounds/f"$fedora"/default/*night*.jxl 2>/dev/null | head -1 || true)
if [ -n "$src" ] && [ ! -f ~/Pictures/Wallpapers/fedora-"$fedora"-night.png ]; then
    djxl "$src" ~/Pictures/Wallpapers/fedora-"$fedora"-night.png >/dev/null
fi
# "current" is what niri shows; point it at any image you like.
if [ ! -e ~/Pictures/Wallpapers/current ] && [ -f ~/Pictures/Wallpapers/fedora-"$fedora"-night.png ]; then
    ln -s fedora-"$fedora"-night.png ~/Pictures/Wallpapers/current
fi

step "GTK / GNOME app theme (dark, Papirus, Bibata, Inter)"
if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ] && [ -S "/run/user/$(id -u)/bus" ]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
fi
gs() { gsettings set org.gnome.desktop.interface "$@"; }
gs color-scheme prefer-dark
gs gtk-theme adw-gtk3-dark
gs icon-theme Papirus-Dark
gs cursor-theme Bibata-Modern-Classic
gs cursor-size 24
gs font-name 'Inter 11'
gs document-font-name 'Inter 11'
gs monospace-font-name 'JetBrainsMono Nerd Font 11'
gsettings set org.gnome.desktop.wm.preferences button-layout ':'

step "mise: Node LTS, Python, starship, lazygit"
command -v mise >/dev/null || fetch https://mise.run | sh
mise use -g -y node@lts python@3.13 starship lazygit

step "Git defaults"
git config --global init.defaultBranch main
git config --global pull.rebase true

if command -v code >/dev/null; then
    step "VS Code extensions"
    for ext in catppuccin.catppuccin-vsc catppuccin.catppuccin-vsc-icons \
               ms-python.python editorconfig.editorconfig \
               dbaeumer.vscode-eslint esbenp.prettier-vscode; do
        code --install-extension "$ext" --force >/dev/null 2>&1 || echo "  could not install $ext"
    done
fi

step "mpv: uosc interface + thumbnails"
if [ ! -f ~/.config/mpv/scripts/uosc/main.lua ]; then
    tmp=$(mktemp -d)
    fetch -o "$tmp/uosc.zip" https://github.com/tomasklaen/uosc/releases/latest/download/uosc.zip
    unzip -oq "$tmp/uosc.zip" -d ~/.config/mpv
    rm -rf "$tmp"
fi
[ -f ~/.config/mpv/scripts/thumbfast.lua ] ||
    fetch -o ~/.config/mpv/scripts/thumbfast.lua https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.lua

step "Check niri config"
niri validate

step "User part done"
