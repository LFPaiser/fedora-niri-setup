#!/usr/bin/env python3
"""Make a recoloured copy of an Xcursor theme.

    cursor-recolor.py SRC_DIR DST_DIR NAME COLOUR [COLOUR2]

Every coloured (saturated) pixel takes COLOUR, keeping its relative brightness; white,
grey and black pixels (borders, shadows) stay as they are. With COLOUR2 the colour is a
diagonal gradient across each cursor's drawn shape: COLOUR at the top-left (the arrow's
tip), COLOUR2 at the bottom-right. Colours are hex, without '#'.

user.sh uses it to build the default cursor, Layan-White-Umbra: Layan's white variant
(github.com/vinceliuice/Layan-cursors, GPL-3.0) with its outline in Umbra amber → lilac.
"""
import colorsys
import os
import shutil
import struct
import sys

IMAGE = 0xfffd0002   # Xcursor chunk type of an image
MIN_SAT = 0.25       # below this a pixel counts as white/grey/black and is left alone
SRC_VALUE = 0.85     # typical brightness of Layan's colour: maps to the target's own


def rgb(h):
    return tuple(int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))


def saturation(b, g, r, a):
    # pixels are premultiplied ARGB, stored as little-endian B G R A
    return colorsys.rgb_to_hsv(min(r / a, 1), min(g / a, 1), min(b / a, 1))[1]


def recolor(data, c1, c2):
    d = bytearray(data)
    count = struct.unpack('<I', d[12:16])[0]
    for i in range(count):
        kind, _, pos = struct.unpack('<III', d[16 + i * 12:28 + i * 12])
        if kind != IMAGE:
            continue
        w, h = struct.unpack('<II', d[pos + 16:pos + 24])
        px = pos + 36
        # extent of the coloured pixels, so the gradient spans the drawn shape
        xs, ys = [], []
        for k in range(w * h):
            b, g, r, a = d[px + k * 4:px + k * 4 + 4]
            if a and saturation(b, g, r, a) >= MIN_SAT:
                xs.append(k % w)
                ys.append(k // w)
        if not xs:
            continue
        x0, y0 = min(xs), min(ys)
        span = max(1, (max(xs) - x0) + (max(ys) - y0))
        for k in range(w * h):
            o = px + k * 4
            b, g, r, a = d[o:o + 4]
            if not a:
                continue
            _, s, v = colorsys.rgb_to_hsv(min(r / a, 1), min(g / a, 1), min(b / a, 1))
            if s < MIN_SAT:
                continue
            f = min(1, max(0, ((k % w - x0) + (k // w - y0)) / span))
            th, ts, tv = colorsys.rgb_to_hsv(*(c1[j] + (c2[j] - c1[j]) * f for j in range(3)))
            nr, ng, nb = colorsys.hsv_to_rgb(th, ts * min(1, s / 0.6), min(1, tv * v / SRC_VALUE))
            d[o:o + 3] = bytes(round(c * a) for c in (nb, ng, nr))
    return bytes(d)


def main():
    if len(sys.argv) not in (5, 6):
        sys.exit(__doc__)
    src, dst, name, col1 = sys.argv[1:5]
    c1 = rgb(col1)
    c2 = rgb(sys.argv[5]) if len(sys.argv) == 6 else c1
    shutil.rmtree(dst, ignore_errors=True)
    shutil.copytree(src, dst, symlinks=True)   # the aliases are symlinks: keep them
    cursors = os.path.join(dst, 'cursors')
    for f in os.listdir(cursors):
        p = os.path.join(cursors, f)
        if os.path.islink(p) or not os.path.isfile(p):
            continue
        with open(p, 'rb') as fh:
            data = fh.read()
        if data[:4] == b'Xcur':
            with open(p, 'wb') as fh:
                fh.write(recolor(data, c1, c2))
    # Names Layan does not ship but draws under another name: link them, so these
    # cursors (resize ↕/↔ above all) keep Layan's look instead of falling to Adwaita.
    aliases = {
        'ns-resize': 'size_ver', 'ew-resize': 'size_hor', 'all-resize': 'size_all',
        'bd_double_arrow': 'nwse-resize', 'fd_double_arrow': 'nesw-resize',
        'cross_reverse': 'crosshair', 'diamond_cross': 'crosshair', 'tcross': 'crosshair',
        'dnd-ask': 'context-menu', 'top_left_arrow': 'default', 'X_cursor': 'x-cursor',
    }
    for alias, target in aliases.items():
        p = os.path.join(cursors, alias)
        if not os.path.lexists(p) and os.path.exists(os.path.join(cursors, target)):
            os.symlink(target, p)
    # Adwaita as fallback for any cursor name the theme does not draw
    with open(os.path.join(dst, 'index.theme'), 'w') as fh:
        fh.write(f'[Icon Theme]\nName={name}\nComment={name} cursor theme\nInherits=Adwaita\n')
    cursor_theme = os.path.join(dst, 'cursor.theme')
    if os.path.exists(cursor_theme):
        os.remove(cursor_theme)


if __name__ == '__main__':
    main()
