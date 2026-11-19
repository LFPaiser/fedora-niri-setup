#!/usr/bin/env python3
"""Regenerate dotfiles/local-share/emoji/emoji.txt (one emoji per line: "<emoji> <english name> · <portuguese name> · <portuguese keywords>").

Needs the unicode-emoji and cldr-emoji-annotation packages (or their files):
  gen-emoji.py [/usr/share/unicode] > dotfiles/local-share/emoji/emoji.txt
Skin-tone variants are left out to keep the list small.
"""
import re
import sys
import xml.etree.ElementTree as ET

base = sys.argv[1] if len(sys.argv) > 1 else "/usr/share/unicode"
tones = re.compile("[\U0001F3FB-\U0001F3FF]")


def load(name):
    out = {}
    for d in ("annotations", "annotationsDerived"):
        try:
            root = ET.parse(f"{base}/cldr/common/{d}/{name}.xml").getroot()
        except FileNotFoundError:
            continue
        for a in root.iter("annotation"):
            kind = "tts" if a.get("type") == "tts" else "kw"
            out.setdefault(a.get("cp"), {})[kind] = a.text or ""
    return out


pt = load("pt")
for line in open(f"{base}/emoji/emoji-test.txt", encoding="utf-8"):
    m = re.match(r"^[0-9A-F ]+;\s*fully-qualified\s*#\s*(\S+)\s+E[\d.]+\s+(.*)$", line)
    if not m or tones.search(m.group(1)):
        continue
    emoji, name = m.groups()
    p = pt.get(emoji) or pt.get(emoji.replace("️", "")) or {}
    kw = " ".join(k.strip() for k in p.get("kw", "").split("|"))
    parts = [name, p.get("tts", ""), kw]
    print(emoji, " · ".join(x for x in parts if x))
