#!env python3

import re
import csv
import sys
from itertools import product

STYLES = {'light', 'heavy', 'double', 'single'}
DIRECTIONS = {'up', 'down', 'left', 'right', 'horizontal', 'vertical'}

def expand_dirs(dirs):
    """Expand 'horizontal' and 'vertical' into individual directions."""
    result = []
    for d in dirs:
        if d == 'horizontal':
            result += ['left', 'right']
        elif d == 'vertical':
            result += ['up', 'down']
        else:
            result.append(d)
    return result

def normalize_style(s):
    return 'light' if s == 'single' else s

def parse_description(desc):
    """Parse a box drawing description into {direction: style} mapping."""
    desc = desc.removeprefix('box drawings ')
    parts = desc.split(' and ')
    result = {}
    last_style = None
    for part in parts:
        tokens = part.split()
        dirs = [t for t in tokens if t in DIRECTIONS]
        styles = [t for t in tokens if t in STYLES]
        style = normalize_style(styles[0]) if styles else last_style
        for d in expand_dirs(dirs):
            result[d] = style
        if style:
            last_style = style
    return result

WIDTH = max(len(s) for s in STYLES - {'single'})+1

def pad(value):
    return value.rjust(WIDTH)

# Build lookup table from Unicode characters list
lookup = {}
with open('box_drawings-unicode.txt') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        m = re.match(r'^(U\+[0-9A-Fa-f]+)\s+(\S)\s+(.+)$', line)
        if m:
            codepoint, char, description = m.groups()
            dirs = parse_description(description)
            key = (dirs.get('up', ''), dirs.get('right', ''), dirs.get('down', ''), dirs.get('left', ''))
            lookup[key] = (codepoint, char, description)

def base_style(combo):
    """Determine the base style from non-null directions of a combo."""
    styles = [s for s in combo if s]
    if not styles:
        return None
    from collections import Counter
    counts = Counter(styles)
    # Strict majority
    for style, count in counts.most_common(1):
        if count > len(styles) / 2:
            return style
    # First of light, heavy, double present
    for s in ('light', 'heavy', 'double'):
        if s in counts:
            return s
    return None

# Output lookup table as palette CSV
with open('box_drawings-palette.csv', 'w', newline='') as pf:
    pw = csv.writer(pf)
    pw.writerow([pad('up'), pad('right'), pad('down'), pad('left'), '  code', ' char', ' description', pad('base')])
    for key, (codepoint, char, description) in lookup.items():
        bs = base_style(key) or ''
        pw.writerow([
            pad(key[0]),
            pad(key[1]),
            pad(key[2]),
            pad(key[3]),
            ' ' + codepoint,
            f"{char:>5}",
            ' ' + description,
            pad(bs),
        ])

# Output all combinations
combo_styles = ['', 'light', 'heavy', 'double']
outfile = open('box_drawings-mapping.csv', 'w', newline='')
writer = csv.writer(outfile)
writer.writerow([pad('up'), pad('right'), pad('down'), pad('left'), '  code', ' char', ' description'])

def fallback(combo):
    """Fallback for unmatched combos."""
    non_empty = [(i, s) for i, s in enumerate(combo) if s]
    if not non_empty:
        return ('', '', '')
    # Tier 1: single-direction → use full vertical/horizontal
    if len(non_empty) == 1:
        idx, style = non_empty[0]
        if idx in (0, 2):
            key = (style, '', style, '')
        else:
            key = ('', style, '', style)
        result = lookup.get(key, None)
        if result:
            return result
    # Tier 2: base style fallback
    bs = base_style(combo)
    if bs:
        key = tuple(bs if s else '' for s in combo)
        return lookup.get(key, ('', '', ''))
    return ('', '', '')

for combo in product(combo_styles, repeat=4):
    codepoint, char, description = lookup.get(combo, None) or fallback(combo)
    writer.writerow([
        pad(combo[0]),
        pad(combo[1]),
        pad(combo[2]),
        pad(combo[3]),
        ' ' + (codepoint if codepoint else '      '),
        f"{char:>5}" if char else '     ',
        ' '+description,
    ])
