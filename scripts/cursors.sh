#!/usr/bin/env bash
# Optional cursor themes, on top of the default (Layan-White-Umbra, installed by user.sh).
# Run as your normal user, any time; safe to re-run (themes already there are skipped).
#
#   scripts/cursors.sh options    other everyday cursors (Catppuccin, Graphite, Bibata, ...)
#   scripts/cursors.sh fun        themed ones (Banana, Miku, NieR, PopCat, ...)
#   scripts/cursors.sh all        both
#   scripts/cursors.sh list       what each group has
#
# setup.sh passes --cursors=options|fun|all here. Themes go to ~/.local/share/icons;
# pick one in niri/config.kdl (xcursor-theme), gtk-3.0/settings.ini and gsettings.
set -euo pipefail

[ "$(id -u)" -ne 0 ] || { echo "run as your normal user, not root" >&2; exit 1; }
here=$(cd "$(dirname "$0")/.." && pwd)
icons=${ICONS_DIR:-$HOME/.local/share/icons}
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

OPTIONS=(
    Breeze Bluecurve Bibata-Modern-Classic XCursor-Pro-Dark Fuchsia-Pop Posy-Mono Future WhiteSur Qogir
    Catppuccin-Mocha-{Mauve,Peach,Yellow,Flamingo,Rosewater,Lavender,Teal,Dark,Light}
    Graphite-Dark Graphite-Dark-Nord Graphite-Light Graphite-Light-Nord Vimix Vimix-White
    Layan Layan-White Layan-Border Layan-Border-Umbra Layan-Border-Ambar Layan-Border-Lilas
    Notwaita-Black Notwaita-White Kanagawa-Wave Kanagawa-Lotus Breeze-Hacked-White Mocu-Black AOSP-Android
)
FUN=(Banana Miku NieR PopCat Retrosmart-8bit WarCraft3-Undead)

fetch() { curl -fsSL --retry 3 "$@"; }

# download + unpack into a fresh directory, print that directory
unpack() { # url
    local d; d=$(mktemp -d -p "$tmp")
    fetch -o "$d/.archive" "$1"
    case $1 in
        *.zip) unzip -qo "$d/.archive" -d "$d" ;;
        *.7z)  7z x -y -o"$d" "$d/.archive" >/dev/null ;;
        *)     tar -xf "$d/.archive" -C "$d" ;;
    esac
    rm -f "$d/.archive"; echo "$d"
}
# a GitHub repository's current source, downloaded once per run
repo() { # owner/name → directory of its checkout
    local k=$tmp/repo-${1//\//_} d
    if [ ! -d "$k" ]; then
        d=$(unpack "https://github.com/$1/archive/HEAD.tar.gz")
        mv "$d"/*/ "$k"
    fi
    echo "$k"
}
# a file from a GitHub repository's latest release, picked by a regex on its name
release() { # owner/name regex → directory it unpacked to
    local url
    url=$(fetch "https://api.github.com/repos/$1/releases/latest" |
        jq -r --arg re "$2" '[.assets[] | select(.name | test($re))][0].browser_download_url // empty')
    [ -n "$url" ] || { echo "  no release file matching $2 in $1" >&2; return 1; }
    unpack "$url"
}
# files of a Fedora package, without installing it (no root needed)
rpm_files() { # package → directory
    local d; d=$(mktemp -d -p "$tmp")
    (cd "$d" && dnf download -q "$1" >/dev/null && rpm2cpio ./*.rpm | cpio -idm --quiet)
    echo "$d"
}

# copy a theme directory (the one holding cursors/) as NAME
put() { # src name
    [ -d "$1/cursors" ] || { echo "  $2: no cursors/ in the download" >&2; return 1; }
    rm -rf "${icons:?}/$2"; cp -a "$1" "$icons/$2"
    rm -f "$icons/$2/cursor.theme"
    printf '[Icon Theme]\nName=%s\nComment=%s cursor theme\nInherits=Adwaita\n' "$2" "$2" > "$icons/$2/index.theme"
}
recolor() { # src name colour [colour2]
    python3 -I "$here/scripts/cursor-recolor.py" "$1" "$icons/$2" "$2" "${@:3}"
}

get() { # name
    local n=$1 d
    case $n in
        Breeze)                 put "$(rpm_files breeze-cursor-theme)/usr/share/icons/breeze_cursors" "$n" ;;
        Bluecurve)              put "$(rpm_files bluecurve-cursor-theme)/usr/share/icons/Bluecurve" "$n" ;;
        Bibata-Modern-Classic)  put "$(release ful1e5/Bibata_Cursor '^Bibata-Modern-Classic\.tar\.xz$')/$n" "$n" ;;
        XCursor-Pro-Dark)       put "$(release ful1e5/XCursor-pro '^XCursor-Pro-Dark\.tar\.xz$')/$n" "$n" ;;
        Fuchsia-Pop)            put "$(release ful1e5/fuchsia-cursor '^Fuchsia-Pop\.tar\.xz$')/$n" "$n" ;;
        Notwaita-*)             put "$(release ful1e5/notwaita-cursor "^$n\\.tar\\.xz\$")/$n" "$n" ;;
        Posy-Mono)              put "$(repo simtrami/posy-improved-cursor-linux)/Posy_Cursor_Mono" "$n" ;;
        Future)                 put "$(repo yeyushengfan258/Future-cursors)/dist" "$n" ;;
        WhiteSur)               put "$(repo vinceliuice/WhiteSur-cursors)/dist" "$n" ;;
        Qogir)                  put "$(repo vinceliuice/Qogir-icon-theme)/src/cursors/dist" "$n" ;;
        Catppuccin-Mocha-*)
            local c=${n#Catppuccin-Mocha-}; c=${c,,}
            put "$(release catppuccin/cursors "^catppuccin-mocha-$c-cursors\\.zip\$")/catppuccin-mocha-$c-cursors" "$n" ;;
        Graphite-*)
            local v=${n#Graphite-}; v=${v,,}
            put "$(repo vinceliuice/Graphite-cursors)/dist-$v" "$n" ;;
        Vimix)                  put "$(repo vinceliuice/Vimix-cursors)/dist" "$n" ;;
        Vimix-White)            put "$(repo vinceliuice/Vimix-cursors)/dist-white" "$n" ;;
        Layan)                  put "$(repo vinceliuice/Layan-cursors)/dist" "$n" ;;
        Layan-White)            put "$(repo vinceliuice/Layan-cursors)/dist-white" "$n" ;;
        Layan-Border)           put "$(repo vinceliuice/Layan-cursors)/dist-border" "$n" ;;
        # Layan's border variant in Umbra colours (scripts/cursor-recolor.py)
        Layan-Border-Umbra)     recolor "$(repo vinceliuice/Layan-cursors)/dist-border" "$n" e0a050 c58bd6 ;;
        Layan-Border-Ambar)     recolor "$(repo vinceliuice/Layan-cursors)/dist-border" "$n" e0a050 ;;
        Layan-Border-Lilas)     recolor "$(repo vinceliuice/Layan-cursors)/dist-border" "$n" c58bd6 ;;
        Kanagawa-*)             put "$(repo kanagawa-community/cursors)/themes/$n" "$n" ;;
        Breeze-Hacked-White)    put "$(release mustaqimM/Breeze-Hacked-White '\.zip$')/Breeze_Hacked_White" "$n" ;;
        Mocu-Black)             put "$(release sevmeyer/mocu-xcursor '\.zip$')/Mocu-Black-Right" "$n" ;;
        AOSP-Android)           put "$(release Tech-Tac/aosp-cursors '^aosp-cursors-linux-.*\.tar\.xz$')/aosp-cursors" "$n" ;;
        Banana)                 put "$(release ful1e5/banana-cursor '^Banana\.tar\.xz$')/Banana" "$n" ;;
        Miku)                   put "$(release supermariofps/hatsune-miku-windows-linux-cursors '^miku-cursor-linux\.tar\.xz$')/miku-cursor-linux" "$n" ;;
        NieR)                   put "$(release Beinsezii/NieR-Cursors '\.tar\.xz$')/nier_cursors" "$n" ;;
        PopCat)                 put "$(release nguyenngochan1506/PopCat_Cursor '\.tar\.xz$')/PopCat" "$n" ;;
        Retrosmart-8bit)        put "$(release useless-anvil/retrosmart-cursor '^retrosmart-cursor-classic-.*-linux\.tar\.gz$')/retrosmart-xcursor-win-ish-classic-shadow" "$n" ;;
        WarCraft3-Undead)       put "$(release chelovechishko/WarCraft_III_cursors '\.7z$')/WarCraftIII" "$n" ;;
        *) echo "  unknown theme $n" >&2; return 1 ;;
    esac
}

case ${1:-} in
    options) list=("${OPTIONS[@]}") ;;
    fun)     list=("${FUN[@]}") ;;
    all)     list=("${OPTIONS[@]}" "${FUN[@]}") ;;
    list)    echo "options: ${OPTIONS[*]}"; echo; echo "fun: ${FUN[*]}"; exit ;;
    *)       sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac

mkdir -p "$icons"
failed=()
for n in "${list[@]}"; do
    if [ -d "$icons/$n/cursors" ]; then echo "  $n: already installed"; continue; fi
    if (get "$n"); then echo "  $n"; else failed+=("$n"); fi
done
[ ${#failed[@]} -eq 0 ] || { echo "could not install: ${failed[*]}" >&2; exit 1; }
