#!/usr/bin/env bash
# User part of the setup: dotfiles, fonts, cursor, wallpaper, theme settings,
# dev runtimes, editor and mpv extras. Run as your normal user. Safe to re-run;
# any existing config that differs is kept as <file>.bak-<timestamp>.
#   --cursors=options|fun|all   also install extra cursor themes (scripts/cursors.sh)
set -euo pipefail

[ "$(id -u)" -ne 0 ] || { echo "run as your normal user, not root" >&2; exit 1; }
here=$(cd "$(dirname "$0")/.." && pwd)
stamp=$(date +%Y%m%d-%H%M%S)
export PATH="$HOME/.local/bin:$PATH"
cursors=
for arg in "$@"; do
    case "$arg" in --cursors=*) cursors=${arg#--cursors=} ;; esac
done

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
    mode=644; [ -x "$src" ] && mode=755   # waybar scripts stay executable
    # Some configs (gtklock) need absolute paths: @HOME@ becomes your home dir.
    if grep -q '@HOME@' "$src"; then
        sed "s|@HOME@|$HOME|g" "$src" > "$render"
        src=$render
    fi
    install_file "$src" "$HOME/.config/${f#./}" "$mode"
done
for f in "$here"/dotfiles/local-bin/*; do
    install_file "$f" "$HOME/.local/bin/$(basename "$f")" 755
done
# ~/.local/share bits (Nemo right-click actions)
(cd "$here/dotfiles/local-share" && find . -type f) | while read -r f; do
    src=$here/dotfiles/local-share/$f
    if grep -q '@HOME@' "$src"; then
        sed "s|@HOME@|$HOME|g" "$src" > "$render"
        src=$render
    fi
    install_file "$src" "$HOME/.local/share/${f#./}"
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

step "Cursor: Layan-White-Umbra"
# The theme itself is installed system-wide by system.sh (/usr/share/icons); here it is
# only selected for this user (niri, GTK and XCURSOR_THEME name it as well).
mkdir -p ~/.icons/default
printf '[Icon Theme]\nInherits=Layan-White-Umbra\n' > ~/.icons/default/index.theme

if [ -n "$cursors" ]; then
    step "Extra cursors: $cursors"
    bash "$here/scripts/cursors.sh" "$cursors" || echo "  some extra cursors failed: re-run scripts/cursors.sh $cursors"
fi

step "Wallpaper: Umbra + awww + Waypaper"
# default: Umbra; second option: Fedora's own night wallpaper, converted below
install_file "$here/wallpapers/umbra-construction-v2.png" ~/Pictures/Wallpapers/umbra-construction-v2.png
fedora=$(rpm -E %fedora)
src=$(ls /usr/share/backgrounds/f"$fedora"/default/*night*.jxl 2>/dev/null | head -1 || true)
if [ -n "$src" ] && [ ! -f ~/Pictures/Wallpapers/fedora-"$fedora"-night.png ]; then
    djxl "$src" ~/Pictures/Wallpapers/fedora-"$fedora"-night.png >/dev/null || true
fi
# ".current" is what the lock screen shows; Waypaper re-points it on every change.
[ -e ~/Pictures/Wallpapers/.current ] || ln -s ~/Pictures/Wallpapers/umbra-construction-v2.png ~/Pictures/Wallpapers/.current
# awww (successor of swww) draws the wallpaper; not packaged, so build it.
if ! command -v awww-daemon >/dev/null; then
    tmp=$(mktemp -d)
    git clone -q --depth 1 https://codeberg.org/LGFae/awww.git "$tmp/awww"
    (cd "$tmp/awww" && cargo build --release --locked -q)
    install -m 755 "$tmp/awww/target/release/awww" "$tmp/awww/target/release/awww-daemon" ~/.local/bin/
    rm -rf "$tmp"
fi
# Waypaper: wallpaper picker GUI (Super+Shift+W), in its own venv.
if [ ! -x ~/.local/share/waypaper-venv/bin/waypaper ]; then
    python3 -m venv --system-site-packages ~/.local/share/waypaper-venv
    ~/.local/share/waypaper-venv/bin/pip install -q waypaper
fi
ln -sf ~/.local/share/waypaper-venv/bin/waypaper ~/.local/bin/waypaper

step "Icons: Papirus-Dark with violet folders"
# A user icon theme on top of Papirus-Dark that only recolours the folders.
bash "$here/scripts/papirus-umbra.sh" violet

step "GTK / GNOME app theme (dark, Papirus violet folders, Layan-White-Umbra cursor, Inter)"
if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ] && [ -S "/run/user/$(id -u)/bus" ]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
fi
gs() { gsettings set org.gnome.desktop.interface "$@"; }
gs color-scheme prefer-dark
gs gtk-theme adw-gtk3-dark
gs icon-theme Papirus-Dark-Umbra
gs cursor-theme Layan-White-Umbra
gs cursor-size 24
gs font-name 'Inter 11'
gs document-font-name 'Inter 11'
gs monospace-font-name 'JetBrainsMono Nerd Font 11'
gsettings set org.gnome.desktop.wm.preferences button-layout ':'

step "Flatpak apps: same theme (gtk.css, fontconfig, adw-gtk3 runtime)"
# Already forwarded by flatpak itself: icons and cursors (/run/host/{user-,}share/icons, so
# Papirus-Dark-Umbra and Layan-White-Umbra just work), host fonts, XCURSOR_*, and the
# gsettings theme/colour scheme via the settings portal. Missing: the Umbra gtk.css and the
# fontconfig aliases, so those two dirs are shared read-only.
# GTK_THEME is deliberately NOT set: it forces the theme on libadwaita (GTK4) apps too and
# breaks them; GTK3 apps get adw-gtk3-dark from the runtime extension below instead.
if command -v flatpak >/dev/null; then
    flatpak override --user --filesystem=xdg-config/gtk-3.0:ro --filesystem=xdg-config/gtk-4.0:ro \
        --filesystem=xdg-config/fontconfig:ro
    # Electron/Qt flatpaks ignore gtk.css; keep the cursor explicit for apps that skip the portal.
    flatpak override --user --env=XCURSOR_THEME=Layan-White-Umbra --env=XCURSOR_SIZE=24
    if ! flatpak info org.gtk.Gtk3theme.adw-gtk3-dark >/dev/null 2>&1; then
        flatpak install --user -y --noninteractive flathub org.gtk.Gtk3theme.adw-gtk3-dark//3.22 ||
            echo "  adw-gtk3 flatpak theme not installed (flathub missing/offline?): re-run user.sh"
    fi
else
    echo "  flatpak not installed: skipped"
fi

step "mise: tools from ~/.config/mise/config.toml (Node, Python, Go, Rust, starship, lazygit...)"
command -v mise >/dev/null || fetch https://mise.run | sh
mise install -y

step "btop: Umbra theme"
# btop rewrites btop.conf on exit, so only the theme line is ours.
if [ -f ~/.config/btop/btop.conf ]; then
    sed -i 's/^color_theme = .*/color_theme = "umbra"/' ~/.config/btop/btop.conf
else
    echo 'color_theme = "umbra"' > ~/.config/btop/btop.conf
fi

step "Firefox: userChrome.css, userContent.css, user.js"
# Goes into the default-release profile, which exists only after Firefox's first start.
# The Umbra theme comes from AMO through the system policy (scripts/system.sh).
ff_profile=
for ff_dir in ~/.config/mozilla/firefox ~/.mozilla/firefox; do
    [ -f "$ff_dir/profiles.ini" ] || continue
    rel=$(sed -n '/^\[Install/,/^$/s/^Default=//p' "$ff_dir/profiles.ini" | head -1)
    [ -n "$rel" ] || rel=$(sed -n 's/^Path=\(.*default-release\)$/\1/p' "$ff_dir/profiles.ini" | head -1)
    [ -n "$rel" ] && [ -d "$ff_dir/$rel" ] && { ff_profile=$ff_dir/$rel; break; }
done
if [ -n "$ff_profile" ]; then
    install_file "$here/dotfiles/firefox/user.js" "$ff_profile/user.js"
    install_file "$here/dotfiles/firefox/chrome/userChrome.css" "$ff_profile/chrome/userChrome.css"
    install_file "$here/dotfiles/firefox/chrome/userContent.css" "$ff_profile/chrome/userContent.css"
else
    echo "  no Firefox profile yet: open Firefox once, close it, and re-run scripts/user.sh"
fi

step "bat + delta: Umbra syntax theme"
# git settings, delta and aliases live in ~/.config/git/config (installed above);
# bat and delta only see themes/Umbra.tmTheme after the cache is rebuilt.
command -v bat >/dev/null && bat cache --build >/dev/null

step "mpv: uosc interface + thumbnails"
if [ ! -f ~/.config/mpv/scripts/uosc/main.lua ]; then
    tmp=$(mktemp -d)
    fetch -o "$tmp/uosc.zip" https://github.com/tomasklaen/uosc/releases/latest/download/uosc.zip
    unzip -oq "$tmp/uosc.zip" -d ~/.config/mpv
    rm -rf "$tmp"
fi
[ -f ~/.config/mpv/scripts/thumbfast.lua ] ||
    fetch -o ~/.config/mpv/scripts/thumbfast.lua https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.lua

step "Nemo as the default file manager"
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
# apps that ask D-Bus to "show this file in a folder" get Nemo too
mkdir -p ~/.local/share/dbus-1/services
printf '[D-BUS Service]\nName=org.freedesktop.FileManager1\nExec=/usr/bin/nemo --no-default-window\n' \
    > ~/.local/share/dbus-1/services/org.freedesktop.FileManager1.service
gsettings set org.cinnamon.desktop.default-applications.terminal exec ghostty 2>/dev/null || true
gsettings set org.cinnamon.desktop.default-applications.terminal exec-arg -e 2>/dev/null || true    # Nemo: "Open in Terminal", Terminal=true apps

step "GNOME Text Editor: Umbra colours, JetBrains Mono"
gsettings set org.gnome.TextEditor style-scheme umbra 2>/dev/null || true
gsettings set org.gnome.TextEditor use-system-font false 2>/dev/null || true
gsettings set org.gnome.TextEditor custom-font 'JetBrains Mono 11' 2>/dev/null || true

step "Launcher: hide helper apps from fuzzel"
mkdir -p ~/.local/share/applications
for app in htop kbd-layout-viewer5 gkbd-keyboard-display org.fcitx.Fcitx5 \
           fcitx5-wayland-launcher org.fcitx.fcitx5-qt6-gui-wrapper; do
    [ -f "/usr/share/applications/$app.desktop" ] || continue
    printf '[Desktop Entry]\nType=Application\nName=%s\nNoDisplay=true\n' "$app" \
        > ~/.local/share/applications/$app.desktop
done
fc-cache -f >/dev/null   # fontconfig aliases (sans = Inter, mono = JetBrainsMono)

step "herdr (terminal workspace manager for coding agents)"
if ! command -v herdr >/dev/null; then
    fetch -o ~/.local/bin/herdr "https://github.com/herdrdev/herdr/releases/latest/download/herdr-linux-$(uname -m)"
    chmod 755 ~/.local/bin/herdr
fi

# The "sistema" workspace can use the 3D spinning logo (--logo-type spin), new in fastfetch
# 2.69. Until Fedora ships that, use upstream's build in ~/.local (ahead of /usr/bin in PATH);
# once Fedora's is new enough, drop the local copy and use the official package again.
FASTFETCH_MIN=2.69
step "fastfetch >= $FASTFETCH_MIN"
sys_ff=$(rpm -q --qf '%{VERSION}' fastfetch 2>/dev/null || echo 0)
if [ "$(printf '%s\n' "$FASTFETCH_MIN" "$sys_ff" | sort -V | head -1)" = "$FASTFETCH_MIN" ]; then
    if [ -d ~/.local/opt/fastfetch ]; then
        echo "  Fedora's fastfetch $sys_ff is new enough: removing the upstream copy"
        rm -rf ~/.local/opt/fastfetch ~/.local/bin/fastfetch
    fi
elif ! ~/.local/bin/fastfetch --version 2>/dev/null | grep -q .; then
    echo "  Fedora has $sys_ff: installing upstream's latest release in ~/.local/opt/fastfetch"
    tmp_ff=$(mktemp -d)
    fetch "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-$( [ "$(uname -m)" = aarch64 ] && echo aarch64 || echo amd64).tar.gz" |
        tar -xz -C "$tmp_ff"
    rm -rf ~/.local/opt/fastfetch && mkdir -p ~/.local/opt
    mv "$tmp_ff"/fastfetch-linux-*/usr ~/.local/opt/fastfetch && rm -rf "$tmp_ff"
    ln -sf ~/.local/opt/fastfetch/bin/fastfetch ~/.local/bin/fastfetch
fi

step "satty (screenshot annotation, Shift+Print)"
# Not packaged by Fedora: upstream's release binary in ~/.local/bin. Re-run with
# SATTY_UPDATE=1 to fetch the latest release again.
if ! command -v satty >/dev/null || [ -n "${SATTY_UPDATE:-}" ]; then
    tmp=$(mktemp -d)
    fetch https://github.com/Satty-org/Satty/releases/latest/download/satty-x86_64-unknown-linux-gnu.tar.gz |
        tar -xz -C "$tmp"
    install -Dm755 "$tmp/satty" ~/.local/bin/satty
    install -Dm644 "$tmp/completions/satty.fish" ~/.config/fish/completions/satty.fish
    rm -rf "$tmp"
fi
mkdir -p ~/Videos/Recordings

step "Claude Code + Orca (stable checkout)"
command -v claude >/dev/null || fetch https://claude.ai/install.sh | bash
# Orca lives in its own "stable" checkout; orca-lc and the Claude hooks/skills
# link into it, so updating Orca is a git pull + install.sh there.
ORCA_DIR=${ORCA_DIR:-$HOME/.local/src/orca-stable}
if [ ! -d "$ORCA_DIR/.git" ]; then
    mkdir -p "$(dirname "$ORCA_DIR")"
    git clone -q https://github.com/Umbra-Productions-Development/Orca.git "$ORCA_DIR"
fi
(cd "$ORCA_DIR" && ./install.sh)

step "Session services (systemd --user)"
# waybar, mako, swayidle and cliphist start with the session and restart if they crash
# (units: Fedora's for waybar/mako, ours in dotfiles/config/systemd/user).
systemctl --user daemon-reload 2>/dev/null &&
    systemctl --user enable waybar.service mako.service swayidle.service cliphist.service ||
    echo "  no user session bus: run 'systemctl --user enable waybar mako swayidle cliphist' after login"

step "Check niri config"
niri validate

step "User part done"
echo "Weather in the bar defaults to Liberdade, São Paulo. To use your city, create"
echo "~/.config/waybar/weather.local (see the top of ~/.config/waybar/scripts/weather.sh)."
