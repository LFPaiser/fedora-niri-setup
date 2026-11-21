# Fedora + niri setup

Everything needed to set up a themed niri desktop on Fedora, on real hardware
(e.g. a laptop with hybrid Intel + NVIDIA graphics) or in a VirtualBox VM for testing.

- **Desktop:** Fedora 44 + [niri](https://github.com/YaLTeR/niri), a scrollable-tiling Wayland compositor.
- **Look:** **Umbra**, a warm plum + amber palette taken from the bundled wallpaper
  (`wallpapers/umbra-construction-v2.png`), used everywhere: niri, a custom waybar, Ghostty, Kitty, fuzzel,
  swaync (or mako), GTK 4 / libadwaita apps, Firefox (the Umbra theme on AMO) and the lock screen. Login is a text greeter
  (greetd + tuigreet); the lock screen (gtklock) shows the darkened wallpaper, clock + date and a password field.
- **Uses:** development, gaming (on real hardware), browsing and video.

One command (`./setup.sh`) installs and configures everything. It is safe to
re-run. If a config file of yours differs from the repo's, the old one is kept
as `<file>.bak-<date>`.

```
setup.sh                  entry point (run as your user, asks for sudo once)
scripts/system.sh         repos, packages, drivers, services (root)
scripts/user.sh           dotfiles, fonts, cursor, wallpaper, theme, dev runtimes (user)
scripts/cursor-recolor.py recolours a cursor theme (builds the default Layan-White-Umbra)
scripts/cursors.sh        optional extra cursor themes (options / fun / all)
dotfiles/config/...       copied to ~/.config/... (@HOME@ is replaced with your home dir)
dotfiles/local-bin/...    copied to ~/.local/bin/ (osd, powermenu, sistema, fastfetch-umbra)
system-files/             Firefox policy (uBlock Origin, no telemetry), greetd login config
wallpapers/umbra-construction-v2.png  default wallpaper (the Umbra palette is derived from it;
                          Fedora's own night wallpaper is set up as the second option)
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
   dual-boot well. GNOME stays installed as a fallback session (pick it in the
   greeter with F3), but `setup.sh` replaces GDM with greetd + tuigreet.
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
5. Reboot. The GRUB menu offers both Fedora and Windows Boot Manager, but it is
   hidden by default: the default entry boots after 1 s, and pressing **Esc** repeatedly
   right after power-on shows it. When another OS is found, `setup.sh` asks instead:
   hidden or shown every boot (5 s), and whether to remember the last choice
   (`--boot-menu=hidden|show`, `--boot-remember=yes|no`; set up by `scripts/system.sh`).

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
- replaces GDM with **greetd + tuigreet** (a text login that starts niri) and makes fish your shell;
- sets the keyboard to **Brazilian ABNT2** (US as second layout) on the console, login and desktop;
- keeps the system language in **English** but uses **Brazilian formats** (dates, 24h clock, R$, A4,
  metric); numbers keep the decimal point, which shell scripts rely on;
- installs **fcitx5** (input method: ABNT2/US plus Japanese, Chinese, Korean) and makes **Nemo** the file manager;
- installs **herdr**, **Claude Code** and **Orca** (see §4);
- builds **awww** (the wallpaper daemon, successor of swww) and installs the **Waypaper** picker.

**Secure Boot + NVIDIA:** the script asks you to choose a one-time password.
On the next reboot a blue *MOK management* screen appears. Choose **Enroll MOK →
Continue → Yes**, type that password, then reboot. Without this step the
NVIDIA driver won't load while Secure Boot is on.

Wait ~5 minutes after the script finishes (the NVIDIA module builds in the
background), then **reboot**. Check with `nvidia-smi`, which should list your NVIDIA GPU.

Flags: `./setup.sh --no-gaming` skips the gaming tools; `--gaming` forces them in a VM. `--notifications=swaync` or `--notifications=mako` picks the notification daemon (asked when omitted in a terminal; swaync when unattended).
`--cursors=options`, `--cursors=fun` or `--cursors=all` also installs extra cursor themes
(see [Customizing](#7-customizing)); the default cursor is always installed.

## 4. After the first login

```bash
passwd                                    # if you used a temporary password
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
ssh-keygen -t ed25519                     # then:
gh auth login                             # uploads the key to GitHub
```

- **Orca (first launch):** update the stable checkout before the first session,
  then sign in to Claude Code:
  ```bash
  cd ~/.local/src/orca-stable && git pull && ./install.sh   # same command updates Orca later
  claude                                                     # log in once
  herdr                                                      # agent workspaces
  ```
  `install.sh` re-links `orca-lc`, the hooks, skills and agents into `~/.claude`.
  To keep Orca elsewhere, set `ORCA_DIR=/path` before running `setup.sh`.
- **Firefox:** sign in to sync. uBlock Origin and the Umbra theme install themselves on first
  start; then close Firefox and re-run `scripts/user.sh` to add userChrome.css/user.js to the profile.
- **VS Code:** turn on Settings Sync (Accounts menu) with the same account as your other machines;
  it brings themes, icons, extensions and profiles.
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
| Login | greetd + tuigreet (remembers the last user, shows the time) |
| Compositor | niri, rounded corners, thin shadows, gradient focus ring, overview with wallpaper backdrop |
| Bar | **waybar**, 4 interchangeable presets (default: *faixa*, a thin floating band). Workspaces, window title with app icon, clock + calendar (day and month in Portuguese), weather (5 sources with automatic fallback; expected rain in mm next to the temperature on rainy days), media, CPU/RAM/uptime, dnf updates (click to pick which), GitHub notifications, clipboard, input method, Wi-Fi menu, Bluetooth, battery, volume, notifications (bell + count; click: notification center, right-click: do-not-disturb, middle: clear all), stay-awake, power menu |
| Input method | **fcitx5**: ABNT2 + US layouts, plus Japanese (Mozc), Chinese (Pinyin) and Korean (Hangul). Candidate window in the Umbra theme (`dotfiles/local-share/fcitx5/themes/umbra`, same card as the notifications) |
| Terminal | **Ghostty**, one process for all windows (Kitty as fallback on Super+Alt+Enter, same image protocol and split keys; Foot for emergencies). Default for `Terminal=true` apps and Nemo via `xdg-terminal-exec`. Bar pop-ups (volume, network, weather, updates) open floating |
| Launcher / notifications / lock | fuzzel / **swaync** by default, or mako (`setup.sh --notifications=mako`; asked when run in a terminal). swaync pauses a notification while the mouse is over it and keeps a notification center; clicking a notification runs its default action, its × only closes it. Both play a sound through the Notifications volume group, silent in do-not-disturb and for low urgency / gtklock + swayidle (after 1 h idle the screen dims to 60% black with `idle-fade`, locks 1 min later, screens off 30 min after the lock) |
| Volume/brightness pop-up | wob, via `~/.local/bin/osd` |
| Volume groups | **Media**, **Notifications**, **System**, **Calls**: each its own volume in front of the master (PipeWire loopbacks + WirePlumber role routing; apps that set no role are Media). **wiremix** (middle-click the volume icon) adjusts groups and single apps |
| Screen recording / annotation | `~/.local/bin/record` (wf-recorder, H.264 + AAC, with the computer's sound) / satty |
| Mic and recorder icons | in the bar's audio group (volume, mic, recorder; brightness, do-not-disturb and stay-awake sit with the power button): mic muted (crossed out) / on / **in use** (red, apps in the tooltip); recorder idle (click: screen, right: area) / **recording** (red timer, click stops) |
| Clipboard | cliphist history (Super+Shift+V): last 200 items, password-manager copies skipped; Shift+Del deletes an item, Ctrl+Shift+Del clears all |
| Emoji / calculator | fuzzel pickers: emoji by English or Portuguese name, typed into the focused window with wtype (Super+Ctrl+Space); quick calculator on qalc (Super+Ctrl+=) |
| Theme | Umbra (custom), adw-gtk3-dark + an Umbra `gtk-4.0/gtk.css`, Papirus-Dark icons with violet folders (`scripts/papirus-umbra.sh`), Layan white cursor with an Umbra amber → lilac outline, Inter + JetBrainsMono Nerd Font; Qt apps via qt6ct; login screen and text console in Umbra colours |
| Wallpaper | awww + Waypaper (Super+Shift+W), optional slideshow |
| Files | **Nemo** (default for folders; Nautilus kept for GNOME dialogs). Right-click: "Abrir no terminal" (Ghostty), "Definir como wallpaper" (through Waypaper, the lock screen follows), "Copiar caminho", and compress/extract (`nemo-fileroller`). Actions live in `dotfiles/local-share/nemo/actions` |
| Text editor | **GNOME Text Editor** with the Umbra colour scheme (`dotfiles/local-share/gtksourceview-5/styles/umbra.xml`, Ghostty colours) and JetBrains Mono 11 |
| "sistema" workspace | Super+0 / Super+': fastfetch + live journal warnings + btop, opened at login. fastfetch has its own Umbra config (`fastfetch/config.jsonc`: Portuguese labels with icons, amber bars). The distro logo is animated in two Umbra colours (a random pair each time) |
| Agents | **herdr** (agent workspaces) + **Claude Code** + **Orca** (stable checkout in `~/.local/src/orca-stable`) |
| Shell | fish + Starship prompt (Umbra, two lines: blocks with folder · git · project language, slow-command time and clock on the right; `❯` turns red on failure), zoxide (`z`), fzf (Ctrl+R/Ctrl+T), fisher + the `done` plugin (desktop notification when a command over 10 s ends while another niri window has focus; interactive programs excluded), eza (`ls`/`ll`/`la`/`tree`, Umbra theme), file colours via vivid `LS_COLORS` (Umbra), bat (`cat`, Umbra theme), lazygit (`lg`, Umbra, diffs through delta; `|` toggles side by side), btop. Shortcuts are fish `abbr` (expand on Space: `ll`, `cat`, `lg`, git `g` `gs` `gd` `ga` `gc` `gp` `gl` `gsw`, `!!`), plus `mkcd` and `extract` functions and the direnv hook |
| Git | `~/.config/git/config`: delta as pager (Umbra syntax colours, line numbers, changed words highlighted; `n`/`N` jump between files), `git ds` for a side-by-side diff (`git dss` for a commit), zdiff3 conflicts, rerere, histogram diffs, push without `-u`; aliases `st` `sw` `co` `br` `ci` `amend` `unstage` `undo` `last` `lg` (graph log). Identity stays in `~/.gitconfig` |
| Dev | VS Code (themes, extensions and profiles via its Settings Sync), gcc/cmake, **mise** (Node LTS + Python 3.13; per project: `mise use node@22`), uv, gh, Podman + Toolbox + Distrobox, Docker (+ Compose, Buildx) |
| Video | full codecs (RPM Fusion ffmpeg), **mpv** with the uosc interface + thumbnails (Umbra colours, Inter font), yt-dlp (`mpv <youtube-url>` works) |
| Browser | Firefox + uBlock Origin |
| Gaming (real HW) | Steam + Proton, GameMode, MangoHud, gamescope, Heroic, ProtonUp-Qt |

## 6. Keyboard cheat sheet

`Super` is the Windows key. **Super+/** shows the full list on screen.

| Keys | Action |
|---|---|
| Super+Enter (or T) | Ghostty terminal |
| Super+Shift+Enter | Foot terminal (emergency: CPU-rendered, works when the GPU/Ghostty breaks) |
| Super+Alt+Enter | Kitty terminal (fallback) |
| Super+A (or Space) | app launcher |
| Super+B / Super+E | Firefox / Files (Nemo) |
| Super+; | VS Code |
| Super+Shift+W | wallpaper picker (Waypaper) |
| Super+Shift+V | clipboard history |
| Super+Ctrl+Space | emoji picker (search in English or Portuguese; copies and types it) |
| Super+Ctrl+= | calculator (qalc: `2+2`, `15% of 80`, `5 km to mi`; Enter on empty copies the result) |
| Super+N / Super+Shift+N | dismiss the notification / all of them (they stay in the history) · Super+Ctrl+N opens the notification center (mako: brings the last one back) |
| Super+Q | close window |
| Super+O | overview of all windows/workspaces |
| Super+' | toggle the "sistema" workspace (fastfetch + btop, opened at login) · Super+0 goes there |
| Super+←→↑↓ or H/J/K/L | move focus (↑↓ continue into the workspace above/below) |
| Super+Ctrl+arrows / HJKL | move the window/column (↑↓ also across workspaces) |
| Super+Shift+↑↓ | move the whole workspace up / down |
| Super+1…9 | go to workspace · Super+Ctrl+1…9 move window there (Super+0 is "sistema") |
| Super+U / Super+I | workspace down / up · Super+Tab previous workspace |
| Super+R | cycle column width (⅓, ½, ⅔, full) |
| Super+F / Super+Shift+F | maximize column / true fullscreen |
| Super+C | center column |
| Super+- / Super+= | narrower / wider |
| Super+V | float / tile window |
| Super+W | tabbed column |
| Super+[ / Super+] | merge window into neighbour column / split out |
| Print or Super+Shift+S | screenshot (select area; copied + saved to ~/Pictures/Screenshots) |
| Ctrl+Print / Alt+Print | screenshot of the whole screen / the focused window |
| Shift+Print | screenshot of an area, opened in **satty** to annotate (Enter: copy + save) |
| Super+Alt+R / Super+Alt+Shift+R | start/stop recording the screen / an area (red timer in the bar; ~/Videos/Recordings) |
| Super+Alt+L | lock (type the password, Enter to unlock) |
| Super+P or Ctrl+Alt+Delete | power menu (lock, log out, suspend, reboot, shut down) |
| Super+Shift+E | exit niri (asks for confirmation) |
| Super+Shift+P | turn the monitors off |
| Super+Esc | give shortcuts back to niri when an app (VM, game) grabs them |
| Super+Shift+Space | switch keyboard layout ABNT2 ↔ US (fcitx5) |
| Super+Alt+Space | toggle the Asian input method (Shift+Super+Alt+Space cycles Mozc/Pinyin/Hangul) |
| Media keys / Super+F9–F12 | play-pause / volume down, mute, up |
| Super+Shift+F10–F12 | Media group only: mute, down, up (scrolling on the playing track does the same) |

Ghostty: Ctrl+Shift+Enter splits; Ctrl+Shift+H/J/K/L moves between splits;
Ctrl+Shift+Alt+H/J/K/L resizes; Ctrl+Shift+Z zooms a split; Ctrl+Shift+= evens them out;
Ctrl+Shift+T opens a tab.

## 7. Customizing

What is still left to tune (problems to fix and ideas, by priority) is tracked in
[TODO.md](TODO.md).

- **Wallpaper:** put images in `~/Pictures/Wallpapers/` and press **Super+Shift+W**
  (Waypaper) to pick one; it applies immediately with a fade and is restored at
  login. Waypaper also points `~/Pictures/Wallpapers/.current` at it, which the lock
  screen uses. From a terminal: `awww img myimage.jpg`. A slideshow can be turned on in Waypaper.
- **niri:** `~/.config/niri/config.kdl` reloads live on save; run `niri validate`
  to check it.
- **Bar:** presets live in `~/.config/waybar/presets/` (*faixa*, *solida*,
  *refinada*, *minimal*). Try one with `~/.config/waybar/scripts/try refinada`
  and keep it with `try refinada --fixar`. Shared pieces: `modules.jsonc`
  (module settings), `colors.css` (palette), `common.css` (state colours) and
  `scripts/`. Ideas for more modules: `~/.config/waybar/CANDIDATOS.md`.
  Reload with `pkill -SIGUSR2 waybar`. Right-click on the Bluetooth icon turns
  Blueman's tray applet off at login (and back on).
- **Weather location:** defaults to Liberdade, São Paulo. Create
  `~/.config/waybar/weather.local` (not part of the repo) with your
  `WEATHER_NAME`, `WEATHER_LAT`, `WEATHER_LON` and `WEATHER_CPTEC_ID`; the
  format is at the top of `waybar/scripts/weather.sh`. Right-click the weather
  to cycle sources (Open-Meteo, INPE + Open-Meteo, CPTEC/INPE, MET Norway,
  wttr.in); if one is down, the next one is used automatically.
- **Different theme:** the Umbra colors live in `niri/config.kdl` (focus ring),
  `waybar/colors.css`, `fuzzel/fuzzel.ini`, `swaync/style.css`, `mako/config`,
  `kitty/kitty.conf`, `gtklock/style.css`, `gtk-4.0/gtk.css`,
  `ghostty/themes/Umbra` (switch with `theme = ...` in `ghostty/config.ghostty`; list the
  built-in options with `ghostty +list-themes`). The previous Catppuccin Mocha look is one
  `theme = Catppuccin Mocha` + palette swap away. Edit the files in this repo and
  re-run `./setup.sh` to keep them in sync.
- **"sistema" workspace logo:** `sistema logo umbra` (default: colour wave),
  `sistema logo spin` (fastfetch's 3D spinning logo) or `sistema logo fastfetch`
  (static). The choice is remembered. `spin` needs fastfetch 2.69+: until Fedora ships
  it, `user.sh` installs upstream's build in `~/.local/opt/fastfetch` and drops it once
  Fedora catches up. The colour pairs are at the top of `~/.local/bin/fastfetch-umbra`.
- **Cursor:** the default, Layan-White-Umbra, is built by `system.sh` into
  `/usr/share/icons` and set as the system default (Adwaita is its fallback): it downloads
  [Layan](https://github.com/vinceliuice/Layan-cursors) and recolours its outline with
  `scripts/cursor-recolor.py SRC DST NAME COLOUR [COLOUR2]` (one colour, or a diagonal
  gradient between two). The same script makes other colours of any Xcursor theme.
  More themes, optional: `scripts/cursors.sh options` (everyday ones: Catppuccin
  Mocha in 9 colours, Graphite, Vimix, Layan and its Umbra recolours, Bibata, Breeze,
  Bluecurve, Notwaita, Kanagawa, XCursor Pro, WhiteSur, Qogir, ...), `scripts/cursors.sh fun`
  (Banana, Miku, NieR, PopCat, Retrosmart 8-bit, WarCraft III) or `all`;
  `scripts/cursors.sh list` shows them all. Each is downloaded from its own project.
  To switch theme, change `xcursor-theme` in `niri/config.kdl`,
  `gtk-cursor-theme-name` in `gtk-3.0/settings.ini` and
  `gsettings set org.gnome.desktop.interface cursor-theme NAME`.
- **Lock screen:** `~/.config/gtklock/style.css` (look) and `layout.ui` (which
  widgets show; the Unlock button and "Password:" label are hidden). Test with `gtklock`.
- **A fancier bar/shell (real hardware only):** [Noctalia](https://github.com/noctalia-dev/noctalia-shell)
  and [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) are
  complete, animated niri shells. They replace waybar, the notification daemon and the OSD. They were
  not used here because they need a real GPU to feel smooth. To try one,
  install it, turn off the bar and notifications with
  `systemctl --user disable --now waybar swaync` (or `mako`) and remove the `osd` line from
  `spawn-at-startup`.
- **Caps Lock as Esc (tap) / Ctrl (hold):** install `keyd` from COPR
  (`dnf copr enable alternateved/keyd`) and map `capslock = overload(control, esc)`.
- **More apps (Flathub):** `flatpak install flathub com.discordapp.Discord com.spotify.Client com.obsproject.Studio`.
  `user.sh` themes Flatpak apps too: user-level overrides share `gtk-3.0`/`gtk-4.0`/`fontconfig` read-only (Umbra `gtk.css`, font aliases) and set the cursor, and it installs the `adw-gtk3-dark` Flatpak theme. Icons, cursor and fonts are forwarded by Flatpak itself; `GTK_THEME` is intentionally unset (it breaks libadwaita apps). Electron apps ignore `gtk.css`. Undo with `flatpak override --user --reset`.

## 8. Troubleshooting

| Problem | Fix |
|---|---|
| Black screen / no niri after login | In tuigreet press F3 to pick another session (e.g. GNOME), or switch to a TTY (Ctrl+Alt+F2). Then check `journalctl --user -b -u niri`. |
| Bar, notifications, idle lock or clipboard history gone | They are systemd user services and restart on their own after a crash. Check with `systemctl --user status waybar swaync swayidle cliphist` (or `mako`); restart one with `systemctl --user restart waybar`. |
| No wallpaper | Check `pgrep awww-daemon`; run `awww-daemon & waypaper --restore`. |
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
- The kickstart creates the user `user` (password `changeme`) with a Brazilian ABNT2 keyboard (US second),
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
- Clock off by a few seconds at boot (`chronyd: System clock wrong by N seconds`, then
  stepped): VirtualBox starts the guest clock from the Windows host clock, and Windows
  only syncs it now and then. Chrony corrects it a few seconds after boot. The guest
  additions are already installed (VM only). To shrink the offset, resync the host: admin
  `w32tm /resync`. Real hardware has its own RTC and doesn't need any of this.

**VM-only rule:** anything that exists only because of VirtualBox (guest additions,
software-rendered Ghostty, clock notes above) goes inside the `if [ "$virt" = oracle ]`
block of `scripts/system.sh` and is documented in this section. It must never run on
real hardware.
