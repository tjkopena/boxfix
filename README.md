# BoxFix 📦

BoxFix is an elisp function for Emacs that takes as (interactive)
input a buffer region, scans it for ASCII-style box art (though it
actually works over Unicode), and fixes up the line corners,
intersections, and transitions between single, heavy, and double
styles as supported by the Unicode box drawing block.  The intended
use case is making and updating simple box and tree diagrams in plain
text READMEs and other documentation using regular trivially
keyboard-accessible characters `-|+#=<>^vV` but making them pretty by
transforming the diagrams to Unicode drawing characters.

![Screenshot from a terminal](terminal-screenshot.png)


## Simple Examples

_**N.B.:** If the transformed diagrams below do not line up properly
it's almost certainly a font issue._
* _If columns are misaligned following an arrow, your font has given
  them a different width than the other characters.  Per Unicode
  standards they do not have prescribed widths, leaving them free for
  font designers to vary.  Font designers inexplicably do so often,
  even in ostensibly fixed-width/monospace fonts.  There's no good way
  to resolve this across all fonts and viewers short of bludgeoning
  font designers into order.  The arrow codepoints used have been
  chosen to look good in a number of common terminal fonts but are
  known to have issues in some common web browser & site styles._
* _If there are gaps between rows your viewer is applying a line
  height greater than the font itself.  Again this holds in some
  common web browser & site styles but is a rare issue for terminals._

**BoxFix**
```
                    ----------          ┌────────┐
                    | BoxFix |  ->  ─▶  │ BoxFix │
                    ----------          └────────┘
```

**TCP/IP**
```
           +-----------------+          ┌─────────────────┐
           |   Application   |          │   Application   │
           -------------------          ├─────────────────┤
           | [ TCP ] [ UDP ] |          │ [ TCP ] [ UDP ] │
           |        IP       |  ->  ─▶  │        IP       │
           -------------------          ├─────────────────┤
           |  Device Driver  |          │  Device Driver  │
           +-----------------+          └─────────────────┘
```

**Tower**
```
                          +                ╷
                         +-+              ┌┴┐
                         | |              │ │
                       |-----|          ┌─┴─┴─┐
                       |     |          │     │
                       |  +  |          │  ◻  │
                       |     |  ->  ─▶  │     │
                       | + + |          │ ◻ ◻ │
                       |     |          │     │
                       | +-+ |          │ ┌─┐ │
                       | | | |          │ │ │ │
                       -------          └─┴─┴─┘
```

**Left/Right-Most**
```
  ------------+ -------------+          ┌───────────┐ ┌────────────┐
  | Left-Most |-| Right-Most |  ->  ─▶  │ Left-Most ├─┤ Right-Most │
  +------------ +-------------          └───────────┘ └────────────┘
```

**Twirling, Twirling Toward Freedom**
```
                  Freedom                  Freedom
                     ^                        ▲
                     |                        │
                  +--+ Twirling  ->  ─▶    ┌──┘ Twirling
                  |                        │
                  V                        ▼
                Always                   Always
```

*8Fancy BoxFix 1**
```
            ==================          ╒════════════════╕
            | Fancy BoxFix 1 |  ->  ─▶  │ Fancy BoxFix 1 │
            ##################          ┕━━━━━━━━━━━━━━━━┙
```

**Fancy BoxFix 2**
```
            ==================          ╒════════════════╕
            | Fancy BoxFix 2 |  ->  ─▶  │ Fancy BoxFix 2 │
            |################|          ┕━━━━━━━━━━━━━━━━┙
```

**Fancy BoxFix 3**
```
                    ---====---          ┌──════──┐
                    | BoxFix |  ->  ─▶  │ BoxFix │
                    --##--##--          └─━━──━━─┘
```

**BoxFix Evolution**
```
    ----------      ┌────────┐      ┌──####──┐        ┌──━━━━──┐
    | BoxFix |  ─▶  │ BoxFix │  ->  │ BoxFix ├-+  ╶▶  │ BoxFix ├─┐
    ----------      └────────┘      └────────┘ |      └──────┬─┘ │
                                           |   =             │   ║
                                           ---==             └──═╝
```

## Usage

Load the file in Emacs:

    M-x load-file RET /path/to/boxfix.el

Or add it to your init file:

    (load "/path/to/boxfix.el")

To use, select a region containing ASCII-style box art and run:

    M-x boxfix

You can also bind the `boxfix` function to a key:

    (global-set-key (kbd "C-c b") #'boxfix)

If no region is selected when boxfix is run you will be prompted to
select one.

BoxFix respects `rectangle-mark-mode` (C-x SPC). E.g., the examples
above were made by rectangle-marking the original, copying it, pasting
to the right, rectangle-marking the copy, and applying `boxfix`.

To run the test suite:

    emacs --batch -l boxfix-test.el


## Specification

BoxFix works as specified in this section.

## Character Collections

Several named collections of Unicode codepoints are defined.

All of the Unicode codepoints listed in
[box_drawings-palette.csv](box_drawings-palette.csv) are considered
_drawing characters_.  Each codepoint in that file is additionally
associated with the named collections _light_, _heavy_, and _double_
as indicated by the `base` column.

The following Unicode codepoints are collectively referred to as
_box characters_:
* U+25FB ◻ white medium square
* U+25FC ◼ black medium square
* U+25A3 ▣ white square containing black small square

In addition, U+25FB is considered _light_, U+25FC is considered
_heavy_, and U+25A3 is considered _double_.

The following Unicode codepoints are collectively referred to as
_arrow characters_:
* U+25B6 ▶ (black right-pointing triangle)
* U+25C0 ◀ (black left-pointing triangle)
* U+25B2 ▲ (black up-pointing triangle)
* U+25BC ▼ (black down-pointing triangle)

## Processing

Using those definitions, this process is applied to the input---

### Stage 1

Direct conversions to Unicode drawing characters are first applied to
each character in the region:
* Any bar ('|') is converted to U+2502 │
* Any dash ('-') is converted to U+2500 ─ provided neither of the
  characters immediately to the left or right are alphanumerical
* Any hash mark ('#') is converted to U+2501 ━ provided neither of the
  characters immediately to the left or right are alphanumerical
* Any equals ('=') is converted to U+2550 ═ provided neither of the
  characters immediately to the left or right are alphanumerical
* Any plus ('+') is converted to U+25FB ◻ provided neither of the
  characters immediately to the left or right are alphanumerical
* Any less-than ('<') is converted to U+25C0 ◀
* Any greater-than ('>') is converted to U+25B6 ▶
* Any caret ('^') is converted to U+25B2 ▲
* Any vee ('V' or 'v') is converted to U+25BC ▼ provided neither of
  the characters immediately to the left or right are alphanumerical
* Any other characters are left alone.

### Stage 2

All Unicode _drawing_ and _box characters_ in the region are then
adjusted.  Replacements are computed and applied in two-step rounds
until no further changes occur.

Step I. Iterate _cursor_ over each character in the region:
   1. If _cursor_ is not a _drawing_ or _box character_, skip the
      following points and continue to the next character.

   2. The base style of _cursor_ is whichever of the sets _light_,
      _heavy_, or _double_ to which its character belongs.

   3. Generate a lookup key tuple for _cursor_ based on the characters
      immediately to its up, right, down, and left:

      a. If not a _drawing_, _box_, or _arrow character_ then its
         associated tuple component is nil.

      b. If an _arrow character_ then the associated tuple component
         is taken to be the base style of _cursor_.

      c. Otherwise the tuple component is taken as the tuple component
         of the adjacent character in the opposite direction as in
         [box_drawings-palette.csv](box_drawings-palette.csv). E.g.,
         for a _cursor_ with a U+252a ┪ box drawings up light and left
         down heavy adjacent upward, the lookup key's up component for
         _cursor_ would be _heavy_, the down component for the U+252a
         ┪.  If a U+252a ┪ were adjacent downward, the lookup key down
         component would be _light_, the up component for U+252a ┪.

         If the adjacent character has a nil component in
         the direction of _cursor_ then the lookup component for
         _cursor_ is taken as the adjacent character's base style.
         The latter is considered a _fallback_.

   4. Generate a replacement for _cursor_:

      a. If the generated key is (nil, nil, nil, nil) then the
         replacement is the _box character_ matching its base style.

      b. Otherwise the replacement is the character matching the
         lookup key in the table defined by
         [box_drawings-mapping.csv](box_drawings-mapping.csv).

         If there is no such entry in the table, set all of the non-nil
         components of the lookup key to the base style of _cursor_ and
         take the matching character in the table as the replacement.

   5. If the replacement differs from _cursor_, it is classified as
      either a non-fallback replacement (no fallback was used in step
      3c) or a fallback replacement (at least one tuple component
      required a fallback).

Step II. Apply replacements as follows:
   1. If any non-fallback replacements were found, apply only the
      non-fallback replacements.

   2. Otherwise only fallback replacements were found and are applied.

Steps I and II are repeated until a round produces no replacements.


## License

<img alt="CC0"
     src="https://mirrors.creativecommons.org/presskit/icons/zero.svg"
     align="right" />
<img alt="Creative Commons"
     src="https://mirrors.creativecommons.org/presskit/icons/cc.svg"
     align="right" />

[BoxFix](https://github.com/tjkopena/boxfix.git) by
[tjkopena](https://tjkopena.com) is marked [CC0
1.0](https://creativecommons.org/publicdomain/zero/1.0/), dedicating
it to the public domain.  To view a copy of this mark, visit
https://creativecommons.org/publicdomain/zero/1.0/
