# Suggested apps

Candidates to add to the setup. None of them is installed by `setup.sh` yet. Each row says how it is packaged:
`dnf` (Fedora or RPM Fusion), `copr`, `flatpak` (Flathub) or `binary` (upstream release / mise).
Apps already planned in [TODO.md](../TODO.md) are marked *(TODO)*.
Adopting one goes through a GitHub issue, like any other change.

## Archives

| App | Channel | Role | Why |
|---|---|---|---|
| unar | dnf | alternative to unrar for extract | Free, in Fedora main repos, handles rar/zip/7z/many legacy formats with one command |
| unrar | dnf | adds RAR support for extract | Fedora's 7zip has no RAR codec; RPM Fusion nonfree is already enabled |

## Audio

| App | Channel | Role | Why |
|---|---|---|---|
| Easy Effects *(TODO)* | dnf | adds | Equalizer/compressor for PipeWire (TODO item, real hardware) |
| qpwgraph | dnf | adds | PipeWire patchbay to see/repair the volume-group loopbacks graphically |

## Cli

| App | Channel | Role | Why |
|---|---|---|---|
| trash-cli | dnf | adds | rm-to-trash from the shell (trash-put, trash-list, trash-restore), same trash as Nemo |

## Clipboard

| App | Channel | Role | Why |
|---|---|---|---|
| wl-clip-persist | copr | adds | Keeps clipboard content alive after the source app closes (Wayland drops it); complements cliphist without picking from history. |

## Communication

| App | Channel | Role | Why |
|---|---|---|---|
| Geary | dnf | adds | Lightweight GTK mail client to own mailto: (currently unhandled); optional if webmail via Firefox is preferred |
| Vesktop | flatpak | adds | Discord client with working Wayland screen share + audio via portal (relates to the screen-share TODO) |

## Connectivity

| App | Channel | Role | Why |
|---|---|---|---|
| KDE Connect | dnf | adds | Phone integration: notifications, clipboard, file send, media control; works outside KDE |
| LocalSend | flatpak | adds | AirDrop-like LAN file sharing with phones/Windows, no account (org.localsend.localsend_app) |
| Packet | flatpak | adds | Quick Share (Android Nearby Share) client for Linux (io.github.nozwock.Packet) |
| Syncthing | dnf | adds | Continuous folder sync between machines (dotfiles-free way to share projects with the Windows host) |
| Warp | flatpak | adds | Send files over the internet with a short code (magic-wormhole), app.drey.Warp |

## Development

| App | Channel | Role | Why |
|---|---|---|---|
| DistroShelf | flatpak | adds | GUI for distrobox containers (com.ranfdev.DistroShelf) |
| Pods | flatpak | adds | GTK4 GUI for Podman containers/images (com.github.marhkb.Pods) |
| lazydocker | binary | adds | TUI for Docker/compose (logs, restart, prune) next to lazygit; install via mise (aqua) or GitHub binary |

## Disk

| App | Channel | Role | Why |
|---|---|---|---|
| Baobab (Disk Usage Analyzer) | dnf | adds | Visual disk usage to find what fills / or ~/.cache |
| Btrfs Assistant | dnf | adds | GUI for btrfs subvolumes, balance/scrub and Snapper snapshots (pairs with the snapper TODO) |
| Czkawka / Krokiet | flatpak | adds | Find duplicate files, big files, broken symlinks; useful for ~/Pictures and Downloads cleanup |
| GNOME Disks (gnome-disk-utility) | dnf | adds | Format USB sticks, write images, SMART data, mount options in a GUI |
| Impression | flatpak | adds | Simple libadwaita USB image writer (io.gitlab.adhami3310.Impression) |
| gdu | dnf | adds | Fast TUI disk usage analyzer (SSD-parallel), fits the terminal-first workflow |

## File-manager

| App | Channel | Role | Why |
|---|---|---|---|
| f3d | dnf | adds | Fast 3D model viewer + thumbnailer (STL/OBJ/glTF) if you work with 3D files |
| ffmpegthumbnailer | dnf | adds | Video thumbnails in Nemo (not installed today) |
| libheif-tools + glycin-loaders | dnf | adds | HEIC/AVIF/JXL thumbnails and previews in Nemo/Gwenview/GTK pickers |

## Flatpak

| App | Channel | Role | Why |
|---|---|---|---|
| Bazaar | flatpak | adds | Modern Flathub store (io.github.kolunmi.Bazaar); no GNOME Software/PackageKit needed |
| Flatseal | dnf | adds | Review and edit Flatpak permissions (Bitwarden etc.) instead of flatpak override by hand |
| Warehouse | flatpak | adds | Manage Flatpak apps, leftover data and unused runtimes from a GUI (io.github.flattool.Warehouse) |

## Git

| App | Channel | Role | Why |
|---|---|---|---|
| git-delta (Fedora package) | dnf | replaces mise-installed delta | git's core.pager should not depend on mise being on PATH; dnf keeps it updated |
| lazygit (Fedora package) | dnf | replaces mise-installed lazygit | Packaged in Fedora 44 updates (0.66.3), newer than the mise copy |

## Media

| App | Channel | Role | Why |
|---|---|---|---|
| Amberol | flatpak | adds | Minimal music player for local files, libadwaita, MPRIS works with playerctl/waybar |
| Showtime | dnf | adds | GNOME's new video player for people who prefer a GUI over mpv; mpv stays default |

## Multimedia

| App | Channel | Role | Why |
|---|---|---|---|
| mpv-mpris | dnf | adds | MPRIS bridge so waybar player module, playerctl and media keys control mpv |

## Network

| App | Channel | Role | Why |
|---|---|---|---|
| Fragments | flatpak | adds | GTK4/libadwaita torrent client to own the currently unhandled magnet: scheme; follows the GTK Umbra theme |

## Osd

| App | Channel | Role | Why |
|---|---|---|---|
| SwayOSD | copr | replaces wob | OSD with icons for volume/brightness/caps-lock/mic mute, server/client design, CSS-themable to Umbra; avoids the FIFO plumbing. |

## Packages

| App | Channel | Role | Why |
|---|---|---|---|
| Gear Lever | flatpak | adds | Integrate AppImages into the launcher with icons and updates (it.mijorus.gearlever) |

## Performance

| App | Channel | Role | Why |
|---|---|---|---|
| btrfsmaintenance | dnf | adds | Timers for btrfs scrub/balance |
| scx-scheds | copr | adds | sched_ext schedulers (scx_lavd/bpfland) for lower latency under load, opt-in on real hardware; COPR bieszczaders/kernel-cachyos-addons |
| uresourced | dnf | adds | Gives the active desktop session CPU/IO priority (Fedora Workstation default) |

## Power

| App | Channel | Role | Why |
|---|---|---|---|
| powertop | dnf | adds | Find wakeups and power drains on laptops; --auto-tune as a diagnostic (real hardware) |

## Productivity

| App | Channel | Role | Why |
|---|---|---|---|
| Dialect | dnf | adds | Translator (pt/en) with several backends, libadwaita |
| Errands | flatpak | adds | Simple todo/task app with CalDAV sync (io.github.mrvladus.List) |
| Foliate | dnf | adds | EPUB/ebook reader with dark theme support |
| Newsflash | flatpak | adds | RSS reader with sync services, GTK4 (io.gitlab.news_flash.NewsFlash) |
| Papers *(TODO)* | dnf | replaces Firefox as PDF viewer | GNOME's new document viewer (TODO item lists Papers or zathura); available in Fedora updates |

## Recording

| App | Channel | Role | Why |
|---|---|---|---|
| gpu-screen-recorder *(TODO)* | copr | replaces wf-recorder on real hardware | Already noted in TODO; NVENC/VAAPI, replay buffer (save last N seconds). |
| wl-screenrec | binary | replaces wf-recorder (option) | Hardware-encoded (VAAPI) screen recorder for wlroots-protocol compositors with very low CPU; good fit for real hardware. |

## Screenshot

| App | Channel | Role | Why |
|---|---|---|---|
| tesseract | dnf | adds | OCR of a selected screen area (grim+slurp / tesseract / wl-copy) as another fuzzel/keybind tool. |

## Security

| App | Channel | Role | Why |
|---|---|---|---|
| Authenticator | flatpak | adds | TOTP 2FA codes on the desktop (com.belmoussaoui.Authenticator) |

## Shell

| App | Channel | Role | Why |
|---|---|---|---|
| carapace | binary | adds completions for tools without fish completions | Covers hundreds of CLIs (mise, herdr-like tools) in fish with one init line |

## System

| App | Channel | Role | Why |
|---|---|---|---|
| GNOME Firmware | dnf | adds | GUI front-end for fwupd to see/update device firmware (complements the firmware TODO) |
| isd (interactive systemd) | binary | adds | TUI to browse/start/stop/inspect system and user units and their journals; install with uv tool install isd-tui |

## System-monitor

| App | Channel | Role | Why |
|---|---|---|---|
| Mission Center | flatpak | adds | GTK4 task manager with per-app CPU/GPU/disk/net graphs; nicer than btop for a quick look, follows dark theme |
| Resources | flatpak | adds | Lightweight libadwaita system monitor (net.nokyan.Resources) with per-app usage and process kill |
| nvtop | dnf | adds | GPU usage/VRAM TUI for NVIDIA/AMD/Intel (real hardware) |

## Theming

| App | Channel | Role | Why |
|---|---|---|---|
| qt5ct | dnf | adds | Themes Qt5 tools (fcitx5-mozc config/dictionary) with the same Umbra palette as qt6ct |

## Tooling

| App | Channel | Role | Why |
|---|---|---|---|
| gum | dnf | adds | Pretty prompts for shell scripts; would power the first-run setup wizard |

## Wayland

| App | Channel | Role | Why |
|---|---|---|---|
| niriswitcher | binary | adds | Alt-Tab window switcher with previews made for niri |
| wl-mirror | dnf | adds | Mirror one output onto another for presentations/projectors; works on niri (wlr-screencopy) |
| wlsunset *(TODO)* | dnf | adds | Night light for wlroots-style compositors; niri supports gamma control (already a TODO item, listed for packaging) |
