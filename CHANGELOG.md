# Changelog

## 0.3.0

- `ExBanner.showcase/2` prints a text in every bundled font, page by page, to help choose one. Filters with `:fonts` and `:match`; pauses every `:page_size` fonts.
- Fonts read by `showcase/2` are not kept in the font cache, so a showcase does not leave all 333 fonts in memory.

## 0.2.0

- 333 bundled fonts: every font from the FIGlet 2.2.5 distribution and the FIGlet community collections, including Crazy, Doom, Epic and ANSI Shadow. Each font is credited to its author in `CREDITS.md`, and any font is removed on request of its author.
- TOIlet fonts (`.tlf`) are supported, bundled and in `:font_paths`.
- Fonts whose header uses a Latin-1 hardblank are now read.
- Control characters inside font glyphs are replaced by spaces instead of removed, so glyph widths are kept.

## 0.1.0

- Startup banner from `priv/banner.txt` with `$placeholder` values and `$[color]` styles.
- FIGlet renderer with full width, fitting and horizontal smushing, matching `figlet` 2.2.5 output.
- 26 bundled fonts: the FIGlet 2.2.5 distribution and 8 MIT fonts.
- `ExBanner.render/2`, `ExBanner.render!/2`, `ExBanner.print/2`, `ExBanner.show/0` and `ExBanner.fonts/0`, documented with examples checked as doctests.
