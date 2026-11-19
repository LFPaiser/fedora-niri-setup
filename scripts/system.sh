#!/usr/bin/env bash
# System part of the setup: repos, packages, drivers, services. Run as root
# (setup.sh does this with sudo). Safe to re-run.
#
#   --gaming      install Steam & co. even inside a VM
#   --no-gaming   skip them even on real hardware
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "run as root (use ./setup.sh)" >&2; exit 1; }
TARGET_USER=${SUDO_USER:-${TARGET_USER:-}}
[ -n "$TARGET_USER" ] && [ "$TARGET_USER" != root ] || { echo "run through sudo from your user account" >&2; exit 1; }

here=$(cd "$(dirname "$0")/.." && pwd)
fedora=$(rpm -E %fedora)
virt=$(systemd-detect-virt || true)
is_vm=false; [ "$virt" != none ] && is_vm=true

gaming=auto
for arg in "$@"; do
    case "$arg" in
        --gaming) gaming=yes ;;
        --no-gaming) gaming=no ;;
    esac
done
[ "$gaming" = auto ] && { $is_vm && gaming=no || gaming=yes; }

step() { printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }
dnf_install() { dnf -y install --skip-unavailable "$@"; }

step "Fedora $fedora | virtualization: $virt | gaming: $gaming | user: $TARGET_USER"

step "dnf: parallel downloads"
grep -q '^max_parallel_downloads' /etc/dnf/dnf.conf || echo 'max_parallel_downloads=10' >> /etc/dnf/dnf.conf

step "Repositories: RPM Fusion, Ghostty COPR, VS Code, Flathub"
dnf_install dnf5-plugins pciutils
rpm -q rpmfusion-free-release >/dev/null || dnf -y install \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedora.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$fedora.noarch.rpm"
dnf -y copr enable scottames/ghostty
if [ ! -f /etc/yum.repos.d/vscode.repo ]; then
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    cat > /etc/yum.repos.d/vscode.repo <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
fi
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

step "System update"
dnf -y upgrade --refresh

step "Desktop: niri + bar, launcher, notifications, lock, portals"
dnf_install niri xwayland-satellite greetd tuigreet \
    waybar fuzzel mako gtklock swayidle wob libnotify \
    xdg-desktop-portal-gnome xdg-desktop-portal-gtk gnome-keyring mate-polkit \
    pipewire pipewire-pulseaudio wireplumber pavucontrol wiremix wf-recorder xdg-terminal-exec \
    NetworkManager-tui network-manager-applet blueman \
    wl-clipboard cliphist grim slurp brightnessctl playerctl \
    ghostty alacritty foot nemo nemo-fileroller nautilus file-roller loupe gnome-text-editor tuned-ppd \
    f"$fedora"-backgrounds-base libjxl-utils \
    cargo lz4-devel wayland-devel wayland-protocols-devel python3-gobject gtk3  # awww + Waypaper

step "Qt apps follow the Umbra palette (qt6ct)"
dnf_install qt6ct

step "Input method: fcitx5 (br/us layouts, dead keys, emoji; Japanese, Chinese, Korean)"
dnf_install fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool fcitx5-lua \
    fcitx5-mozc fcitx5-chinese-addons fcitx5-hangul

step "Look & feel: themes, icons, fonts"
dnf_install adw-gtk3-theme papirus-icon-theme rsms-inter-fonts \
    google-noto-sans-fonts google-noto-emoji-fonts google-noto-sans-cjk-fonts \
    fontawesome-fonts-all jetbrains-mono-fonts-all

step "Cursor: Layan-White-Umbra for the whole system"
# Layan's white variant with its outline recoloured to an Umbra amber -> lilac gradient
# (scripts/cursor-recolor.py). Installed system-wide and made the default theme, so
# root apps (pkexec, sudo), other users and the login screen get it too. Adwaita
# stays as Layan's fallback (Inherits=Adwaita), for any name Layan does not draw.
if [ ! -d /usr/share/icons/Layan-White-Umbra ]; then
    tmp=$(mktemp -d)
    curl -fsSL --retry 3 https://github.com/vinceliuice/Layan-cursors/archive/refs/heads/master.tar.gz | tar -xz -C "$tmp"
    python3 -I "$here/scripts/cursor-recolor.py" "$tmp"/Layan-cursors-*/dist-white \
        /usr/share/icons/Layan-White-Umbra Layan-White-Umbra d08a30 a560c0
    chmod -R a+rX /usr/share/icons/Layan-White-Umbra
    rm -rf "$tmp"
fi
printf '[Icon Theme]\nInherits=Layan-White-Umbra\n' > /usr/share/icons/default/index.theme

step "Terminal tools"
dnf_install fish direnv eza zoxide fzf bat ripgrep fd-find btop fastfetch tealdeer jq \
    git gh curl wget unzip 7zip cpio vim-enhanced htop

step "Development: compilers, containers, Docker, VS Code"
dnf -y group install --skip-unavailable development-tools c-development
dnf_install gcc-c++ cmake pkgconf openssl-devel zlib-devel \
    podman podman-compose toolbox distrobox uv code
dnf_install moby-engine docker-compose docker-buildx
systemctl enable docker
usermod -aG docker "$TARGET_USER"

step "Multimedia: full codecs (RPM Fusion), mpv, yt-dlp"
dnf -y swap ffmpeg-free ffmpeg --allowerasing || true
dnf_install gstreamer1-plugins-bad-freeworld gstreamer1-plugins-ugly \
    gstreamer1-plugin-libav gstreamer1-plugin-openh264 mpv yt-dlp

step "Firefox: uBlock Origin, Umbra theme, no telemetry (system policy)"
install -Dm644 "$here/system-files/firefox-policies.json" /etc/firefox/policies/policies.json
dnf_install firefox

gpus=$(lspci -nn | grep -Ei 'vga|3d|display' || true)
if ! $is_vm; then
    step "GPU drivers"
    echo "$gpus"
    if grep -qi intel <<<"$gpus"; then
        dnf_install intel-media-driver libva-utils
    fi
    if grep -Eqi 'amd|ati ' <<<"$gpus"; then
        dnf -y swap mesa-va-drivers mesa-va-drivers-freeworld --allowerasing || true
        dnf -y swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld --allowerasing || true
    fi
    if grep -qi nvidia <<<"$gpus"; then
        dnf_install akmod-nvidia xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-power \
            nvidia-vaapi-driver libva-utils switcheroo-control
        systemctl enable --now switcheroo-control
        systemctl enable nvidia-suspend nvidia-resume nvidia-hibernate || true
        # Let the GPU power off when idle (laptop battery). Needed explicitly on
        # Turing cards (GTX 16xx, RTX 20xx); newer cards do it by default.
        echo 'options nvidia NVreg_DynamicPowerManagement=0x02' > /etc/modprobe.d/nvidia-power.conf
        if mokutil --sb-state 2>/dev/null | grep -q enabled; then
            dnf_install akmods mokutil openssl
            [ -f /etc/pki/akmods/certs/public_key.der ] || kmodgenca -a
            if ! mokutil --test-key /etc/pki/akmods/certs/public_key.der 2>/dev/null | grep -q 'already enrolled'; then
                echo
                echo ">>> Secure Boot is on: enrolling the key that signs the NVIDIA driver."
                echo ">>> Choose a one-time password now. On the next boot pick"
                echo ">>> 'Enroll MOK' -> Continue -> Yes, and type that password."
                mokutil --import /etc/pki/akmods/certs/public_key.der
            fi
        fi
        echo "Building the NVIDIA kernel module (a few minutes)..."
        akmods --force || true
    fi
fi

if [ "$gaming" = yes ]; then
    step "Gaming: Steam, GameMode, MangoHud, gamescope, Heroic, ProtonUp-Qt"
    dnf_install steam gamemode mangohud gamescope
    flatpak install -y --noninteractive flathub com.heroicgameslauncher.hgl net.davidotek.pupgui2
fi

if [ "$virt" = oracle ]; then
    step "VirtualBox guest additions"
    dnf_install virtualbox-guest-additions
    # The virtual GPU only offers OpenGL 4.1; Ghostty needs 4.3, so render it in software.
    printf '#!/bin/sh\nLIBGL_ALWAYS_SOFTWARE=1 exec /usr/bin/ghostty "$@"\n' > /usr/local/bin/ghostty
    chmod 755 /usr/local/bin/ghostty
fi

step "Keyboard: Brazilian ABNT2 on the console and login screen"
localectl set-keymap br-abnt2 || true
localectl set-x11-keymap br,us abnt2, || true

step "Locale: English messages, Brazilian formats"
# Programs speak English (errors and docs are easier to search); dates (dd/mm/aaaa, 24h),
# currency (R$), paper (A4), units and addresses are Brazilian. LC_NUMERIC stays en_US:
# with pt_BR's decimal comma, shell scripts break (bash's printf rejects "3.5").
dnf_install glibc-langpack-pt
localectl set-locale LANG=en_US.UTF-8 LC_TIME=pt_BR.UTF-8 LC_MONETARY=pt_BR.UTF-8 \
    LC_PAPER=pt_BR.UTF-8 LC_MEASUREMENT=pt_BR.UTF-8 LC_ADDRESS=pt_BR.UTF-8 \
    LC_TELEPHONE=pt_BR.UTF-8 LC_NAME=pt_BR.UTF-8 || true

step "Login: greetd + tuigreet (text greeter) starting niri, fish as shell"
install -Dm644 "$here/system-files/greetd-config.toml" /etc/greetd/config.toml
install -Dm644 "$here/system-files/vtrgb" /etc/vtrgb    # Umbra console palette
install -Dm644 "$here/system-files/umbra-vtrgb.service" /etc/systemd/system/umbra-vtrgb.service
systemctl enable umbra-vtrgb.service
echo niri-session > /etc/greetd/environments
install -d -o greetd -g greetd /var/cache/tuigreet   # lets --remember work
systemctl disable gdm sddm lightdm 2>/dev/null || true
systemctl enable greetd
systemctl set-default graphical.target
usermod -s /usr/bin/fish "$TARGET_USER"
usermod -aG video,input "$TARGET_USER"

step "System part done"
