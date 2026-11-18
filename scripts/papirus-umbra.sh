#!/usr/bin/env bash
# Papirus-Dark with folders in another colour (default: violet), as a small user
# icon theme that inherits Papirus-Dark and only overrides the folder icons. No root,
# Papirus itself untouched, so package updates neither need nor undo anything.
#
#   scripts/papirus-umbra.sh [colour]     # colour = any Papirus folder colour
#
# Papirus' generic folder names (folder.svg, folder-documents.svg, user-home.svg, ...)
# are symlinks to the blue set; here the same names point to the chosen colour.
set -euo pipefail

colour=${1:-violet}
src=/usr/share/icons/Papirus
dst=~/.local/share/icons/Papirus-Dark-Umbra
[ -f "$src/48x48/places/folder-$colour.svg" ] || { echo "no Papirus folder colour '$colour'" >&2; exit 1; }

rm -rf "$dst"
mkdir -p "$dst"
for dir in "$src"/*/places; do
    [ -L "$(dirname "$dir")" ] && continue          # 48x48@2x etc. are links to 48x48
    size=$(basename "$(dirname "$dir")")
    for link in "$dir"/*.svg; do
        [ -L "$link" ] || continue
        target=$(readlink "$link")
        case "$target" in *-blue-*|*-blue.svg) ;; *) continue ;; esac
        new=${target/-blue/-$colour}
        [ -e "$dir/$new" ] || continue
        mkdir -p "$dst/$size/places"
        ln -s "$dir/$new" "$dst/$size/places/$(basename "$link")"
    done
done
# Scaled (@2x) directories reuse the 1x icons, as in Papirus.
for d in "$dst"/*; do
    [ -d "$d" ] && ln -s "$(basename "$d")" "$d@2x"
done

sed -e 's/^Name=.*/Name=Papirus-Dark-Umbra/' \
    -e "s/^Comment=.*/Comment=Papirus-Dark with $colour folders/" \
    -e 's/^Inherits=.*/Inherits=Papirus-Dark,breeze-dark,hicolor/' \
    /usr/share/icons/Papirus-Dark/index.theme > "$dst/index.theme"
gtk-update-icon-cache -qf "$dst" 2>/dev/null || true
echo "Papirus-Dark-Umbra: $(find "$dst" -type l -name '*.svg' | wc -l) folder icons in $colour"
