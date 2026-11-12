# Sprig

Sprig is a Gleam styling library targeting Erlang/BEAM. Its renderer returns a
string; the caller decides where and when to print it.

Checkpoint 1 implements ANSI styling. Padding, borders, and layout are future
checkpoints. Sprig has no dependency on the Bonsai runtime.

## API

- `new()` creates a style with no colors and all attributes disabled.
- `foreground(style, color)` and `background(style, color)` set the colors.
- `bold(style)`, `italic(style)`, and `underline(style)` enable attributes.
- `render(style, text)` returns the styled string without printing anything.
- `hex(value)` parses six hex digits, with an optional leading `#`, returning
  `Result(Color, ColorError)`. Malformed input returns `Error(sprig.InvalidHex)`.

Named colors are `sprig.Black`, `sprig.Red`, `sprig.Green`, `sprig.Yellow`, `sprig.Blue`,
`sprig.Magenta`, `sprig.Cyan`, and `sprig.White`. They use basic ANSI codes, so their
appearance follows the terminal's palette.

Custom RGB colors use `sprig.Color(red: 136, green: 192, blue: 112)`. RGB and hex
colors use true-color codes. Direct RGB channels below `0` or above `255` are
clamped to that range when rendered. Hex parsing accepts uppercase and lowercase
digits; three-digit shorthand and alpha channels are not supported.

Pass a `Color` to `foreground` or `background`. For hex, first handle the
`Result` returned by `hex`; the example below asserts success for a fixed literal.
For user-provided strings, handle `Error(sprig.InvalidHex)` in the caller.

Setters return a new style, preserving its other fields, so they work in pipelines.

An unstyled render returns the original text unchanged. A styled render adds one
ANSI SGR sequence (attributes, foreground, then background) and a trailing
`ESC[0m` reset to prevent styling from leaking into subsequent output.

## Example

Run the included example from this checkout in a terminal:

```sh
gleam run -m sprig_example
```

The example prints styled text followed by a plain line to demonstrate the reset:

```gleam
import gleam/io
import sprig

pub fn main() -> Nil {
  sprig.new()
  |> sprig.foreground(sprig.Green)
  |> sprig.render("Sprig: named ANSI color")
  |> io.println

  let assert Ok(accent) = sprig.hex("#ff7b13")

  sprig.new()
  |> sprig.foreground(accent)
  |> sprig.background(sprig.Color(74, 89, 174))
  |> sprig.bold
  |> sprig.italic
  |> sprig.underline
  |> sprig.render("Sprig: styled text")
  |> io.println

  io.println("Plain text: the style above has been reset.")
}
```

## Limitations

- ANSI 256-color palette indices are not implemented.
- Exact RGB and hex colors require true-color terminal support. Sprig does not
  provide a fallback to basic or 256-color palettes.
- ANSI codes are always emitted for styled text. Their appearance depends on
  terminal support; Sprig does not detect terminal capabilities.
- Text is wrapped once and passed through unchanged. Embedded ANSI resets are
  not interpreted, and nested styles are not restored.
- Padding, borders, width measurement (including Unicode display width), and
  horizontal/vertical joining are not implemented yet.

## Development

```sh
gleam format --check src test
gleam check
gleam test
```
