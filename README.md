# Fedora + niri setup

Everything needed to set up a themed niri desktop on Fedora, on real hardware
(e.g. a laptop with hybrid Intel + NVIDIA graphics) or in a VirtualBox VM for testing.

- **Desktop:** Fedora 44 + [niri](https://github.com/YaLTeR/niri), a scrollable-tiling Wayland compositor.
- **Look:** Catppuccin Mocha everywhere: niri, a custom waybar, Ghostty, fuzzel, mako, GTK, VS Code and fzf.
  The lock screen (gtklock) looks like GDM's: darkened wallpaper, clock + date, password field only.
- **Uses:** development, gaming (on real hardware), browsing and video.

One command (`./setup.sh`) installs and configures everything. It is safe to
re-run. If a config file of yours differs from the repo's, the old one is kept
as `<file>.bak-<date>`.

```
setup.sh                  entry point (run as your user, asks for sudo once)
scripts/system.sh         repos, packages, drivers, services (root)
scripts/user.sh           dotfiles, fonts, cursor, wallpaper, theme, dev runtimes (user)
dotfiles/config/...       copied to ~/.config/... (@HOME@ is replaced with your home dir)
dotfiles/local-bin/...    copied to ~/.local/bin/ (osd, powermenu)
system-files/             Firefox policy (uBlock Origin, no telemetry)
ks/ks.cfg, oemdrv-ks.iso  VM only: unattended install (wipes the disk!)
vm_ed25519                VM only (optional, not committed): SSH key for the test VM
```

---

## 1. Before installing (on Windows)

These steps assume dual-boot with Windows. Check that the storage controller
is in AHCI mode (not Intel RST/RAID) in the BIOS/UEFI setup; otherwise the
Fedora installer may not see the drives.

1. **Back up** anything important on the drive you will shrink.
2. **Make room.** Recommended: in *Disk Management* (`diskmgmt.msc`), right-click
   a partition with enough free space → *Shrink Volume* → about **100 GB**. Leave
   the space *unallocated*.
   - Alternative: if the PC has a second drive, give Linux the whole drive after
     moving its data. This is the cleanest option, since Windows and Linux never
     share a disk.
3. **Turn off Fast Startup:** Control Panel → Power Options → *Choose what the
   power buttons do* → untick *Turn on fast startup*. With it on, Windows keeps
   its disks "half-mounted" and the clock can go wrong.
4. **BitLocker:** if `C:` is encrypted, save its recovery key first
   (`manage-bde -protectors -get C:` in an admin terminal). Changing boot
   entries can make Windows ask for it once.
5. **Secure Boot can stay on.** The script signs the NVIDIA driver for you (see §3).
6. **Create the USB stick** with [Fedora Media Writer](https://fedoraproject.org/workstation/download):
   choose **Fedora Workstation 44**. It has a graphical installer that handles
   dual-boot well, and GNOME stays installed as a fallback session.
7. **Get this folder onto the PC.** Copy it to a second USB stick, or
   `git clone` this repository after installing.
   Leave out the `vm_ed25519` key, if you made one; it only belongs to the test VM.

## 2. Install Fedora

1. Reboot with the USB plugged in and press the boot-menu key at the vendor logo
   (often **F12**, F11, F8 or Esc). If nothing happens, enable the boot menu in
   the BIOS/UEFI setup (often F2 or Del).
2. Choose *Start Fedora Workstation Live* → *Install Fedora*.
3. **Installation destination:** pick the disk with the free space. Choose
   *Automatic* storage and **do not** tick "reclaim space" or delete anything.
   Fedora will use only the unallocated space (btrfs).
4. Create your user, tick *Make this user administrator*, and finish.
5. Reboot. The GRUB menu now offers both Fedora and Windows Boot Manager.

## 3. Run the setup

Connect to the internet, open a terminal in GNOME and run:

```bash
cd ~/fedora-niri-setup        # wherever you put the folder
chmod +x setup.sh scripts/*.sh
./setup.sh
```

On real hardware it automatically:

- adds RPM Fusion, the Ghostty COPR, the VS Code repo and Flathub, then updates everything;
- installs niri and the whole desktop (see §5), themes, fonts, CLI tools, dev tools and full codecs;
- installs **GPU drivers** for the GPUs it finds:
  - Intel: `intel-media-driver` (hardware video decoding);
  - AMD: the RPM Fusion "freeworld" Mesa VA-API/VDPAU drivers;
  - NVIDIA: `akmod-nvidia` plus CUDA, VA-API and suspend support, with the GPU powering off when idle to save battery;
- installs **gaming** tools: Steam, GameMode, MangoHud, gamescope, Heroic (Epic/GOG) and ProtonUp-Qt;
- makes niri the default login session and fish your shell.

**Secure Boot + NVIDIA:** the script asks you to choose a one-time password.
On the next reboot a blue *MOK management* screen appears. Choose **Enroll MOK →
Continue → Yes**, type that password, then reboot. Without this step the
NVIDIA driver won't load while Secure Boot is on.

Wait ~5 minutes after the script finishes (the NVIDIA module builds in the
background), then **reboot**. Check with `nvidia-smi`, which should list your NVIDIA GPU.

Flags: `./setup.sh --no-gaming` skips the gaming tools; `--gaming` forces them in a VM.

## 4. After the first login

```bash
passwd                                    # if you used a temporary password
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
ssh-keygen -t ed25519                     # then:
gh auth login                             # uploads the key to GitHub
```

- **Firefox:** sign in to sync. uBlock Origin installs itself on first start.
- **Steam:** Settings → Compatibility → *Enable Steam Play for all titles*
  (Proton). Use ProtonUp-Qt to add GE-Proton for problem games.
- **Run games on the NVIDIA GPU.** The desktop itself runs on the Intel GPU,
  which is good for battery. In Steam → game → Properties → Launch options:
  ```
  __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia gamemoderun mangohud %command%
  ```
  For other apps: `switcherooctl launch <app>`. Check which GPU a game uses
  in the MangoHud overlay (Right Shift+F12 toggles it).
- **Monitors:** run `niri msg outputs`, then set mode/scale in
  `~/.config/niri/config.kdl` (there is a commented `output` example). On many
  hybrid-graphics laptops the HDMI port is wired to the NVIDIA GPU, so an
  external screen needs the NVIDIA driver working.

## 5. What you get

| Area | Choice |
|---|---|
| Compositor | niri, rounded corners, shadows, gradient focus ring, overview with wallpaper backdrop |
| Bar | custom **waybar**: floating Catppuccin "pills"; launcher, workspaces, window title, clock with calendar, media, CPU/RAM, volume, network, battery, keyboard layout, idle-inhibit, tray, power menu |
| Terminal | **Ghostty** (Alacritty kept as fallback) |
| Launcher / notifications / lock | fuzzel / mako / gtklock + swayidle (locks after 1 h, screen off after 3 h) |
| Volume/brightness pop-up | wob, via `~/.local/bin/osd` |
| Clipboard | cliphist history (Super+Shift+V) |
| Theme | Catppuccin Mocha, adw-gtk3-dark, Papirus-Dark icons, Bibata cursor, Inter + JetBrainsMono Nerd Font |
| Shell | fish + starship prompt, zoxide (`z`), fzf (Ctrl+R/Ctrl+T), eza (`ls`/`ll`/`tree`), bat (`cat`), lazygit (`lg`), btop |
| Dev | VS Code (Catppuccin, Python, ESLint, Prettier), gcc/cmake, **mise** (Node LTS + Python 3.13; per project: `mise use node@22`), uv, gh, Podman + Toolbox + Distrobox, Docker (+ Compose, Buildx) |
| Video | full codecs (RPM Fusion ffmpeg), **mpv** with the uosc interface + thumbnails, yt-dlp (`mpv <youtube-url>` works) |
| Browser | Firefox + uBlock Origin |
| Gaming (real HW) | Steam + Proton, GameMode, MangoHud, gamescope, Heroic, ProtonUp-Qt |

## 6. Keyboard cheat sheet

`Super` is the Windows key. **Super+Shift+/** shows the full list on screen.

| Keys | Action |
|---|---|
| Super+Enter (or T) | Ghostty terminal |
| Super+Space (or D) | app launcher |
| Super+B / Super+E | Firefox / Files |
| Super+Shift+V | clipboard history |
| Super+Q | close window |
| Super+O | overview of all windows/workspaces |
| Super+←→↑↓ or H/J/K/L | move focus |
| Super+Ctrl+arrows / HJKL | move the window/column |
| Super+1…9 | go to workspace · Super+Ctrl+1…9 move window there |
| Super+U / Super+I | workspace down / up · Super+Tab previous workspace |
| Super+R | cycle column width (⅓, ½, ⅔, full) |
| Super+F / Super+Shift+F | maximize column / true fullscreen |
| Super+C | center column |
| Super+- / Super+= | narrower / wider |
| Super+V | float / tile window |
| Super+W | tabbed column |
| Super+[ / Super+] | merge window into neighbour column / split out |
| Print or Super+Shift+S | screenshot (select area; copied + saved to ~/Pictures/Screenshots) |
| Super+Alt+L | lock (type the password, Enter to unlock) |
| Super+Shift+Esc | power menu (lock, log out, suspend, reboot, shut down) |
| Alt+Shift | switch keyboard layout (when more than one is set in `niri/config.kdl`) |
| Media keys / Super+F9–F12 | play-pause / volume down, mute, up |

Ghostty: Ctrl+Shift+Enter splits; Ctrl+Shift+H/J/K/L moves between splits;
Ctrl+Shift+T opens a tab.

## 7. Customizing

- **Wallpaper:** put any image in `~/Pictures/Wallpapers/` and run
  `ln -sf myimage.jpg ~/Pictures/Wallpapers/current`. It applies at next login,
  or immediately with `pkill swaybg; swaybg -m fill -i ~/Pictures/Wallpapers/current &`.
  The lock screen uses the same image.
- **niri:** `~/.config/niri/config.kdl` reloads live on save; run `niri validate`
  to check it.
- **Bar:** `~/.config/waybar/config.jsonc` and `style.css` (the colors are at the
  top). Reload with `pkill -SIGUSR2 waybar`.
- **Different theme:** the colors live in `niri/config.kdl` (focus ring),
  `waybar/style.css`, `fuzzel/fuzzel.ini`, `mako/config`,
  `wob/wob.ini`, `ghostty/config` (`theme = ...`; list the options with
  `ghostty +list-themes`) and VS Code. Edit the files in this repo and
  re-run `./setup.sh` to keep them in sync.
- **Lock screen:** `~/.config/gtklock/style.css` (look) and `layout.ui` (which
  widgets show; the Unlock button and "Password:" label are hidden). Test with `gtklock`.
- **A fancier bar/shell (real hardware only):** [Noctalia](https://github.com/noctalia-dev/noctalia-shell)
  and [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) are
  complete, animated niri shells. They replace waybar, mako and the OSD. They were
  not used here because they need a real GPU to feel smooth. To try one,
  install it and remove the `waybar`/`mako`/`osd` lines from `spawn-at-startup`.
- **Caps Lock as Esc (tap) / Ctrl (hold):** install `keyd` from COPR
  (`dnf copr enable alternateved/keyd`) and map `capslock = overload(control, esc)`.
- **More apps (Flathub):** `flatpak install flathub com.discordapp.Discord com.spotify.Client com.obsproject.Studio`.

## 8. Troubleshooting

| Problem | Fix |
|---|---|
| Black screen / no niri after login | At the GDM login, click ⚙ (bottom right) → pick *GNOME*. Then check `journalctl --user -b -u niri`. |
| `nvidia-smi` fails after reboot | Wait for `akmods` to finish (`sudo akmods --force`), or Secure Boot key not enrolled: `mokutil --import /etc/pki/akmods/certs/public_key.der` and reboot. |
| Game runs on Intel GPU | Use the launch options in §4; `switcherooctl list` shows the GPUs. |
| Bar/terminal icons are boxes | `fc-cache -f` and check `fc-list | grep JetBrainsMono`. |
| Windows missing from GRUB | `sudo grub2-mkconfig -o /boot/grub2/grub.cfg` |
| Clock wrong in Windows after using Linux | In Linux: `timedatectl set-local-rtc 1` (or make Windows use UTC). |
| Laptop fans / keyboard RGB | Often not handled by stock Linux on gaming laptops. Look for community projects for your model, such as `nbfc-linux` (fan control). |

## 9. The test VM (VirtualBox on Windows)

- Attach `oemdrv-ks.iso` to the VM next to the Fedora install ISO. The unattended
  installer reads `ks/ks.cfg` from it (volume label `OEMDRV`). It **wipes the VM disk**;
  never boot that ISO on real hardware.
- The kickstart creates the user `user` (password `changeme`) with a US keyboard,
  `en_US.UTF-8` and UTC. Edit `ks/ks.cfg` to change them (the user name appears
  twice: the `user` line and `KS_USER` in `%post`), then rebuild the ISO, e.g.
  `xorriso -as mkisofs -V OEMDRV -J -r -o oemdrv-ks.iso ks/ks.cfg`.
- SSH (with a NAT port forward 2222 → 22): `ssh -p 2222 user@127.0.0.1`. For
  key login, create `vm_ed25519` with `ssh-keygen -t ed25519 -f vm_ed25519`, put
  the public key in the `sshkey` line of `ks/ks.cfg`, and use `ssh -i vm_ed25519 ...`.
- The Windows hypervisor is off (`bcdedit /set hypervisorlaunchtype off`) so
  VirtualBox uses VT-x. With it on, VirtualBox falls back to a slow mode and the
  guest freezes. Re-enable for WSL2: admin `bcdedit /set hypervisorlaunchtype auto`, reboot.
- The VM has no real GPU (no Vulkan), so gaming was not testable there and
  `setup.sh` skips it automatically. Copy/paste with Windows doesn't work under niri.
- The VM's virtual GPU only offers OpenGL 4.1 and Ghostty needs 4.3, so in a VM
  `setup.sh` adds `/usr/local/bin/ghostty`, which runs it with software rendering.
  Real hardware doesn't need this.
