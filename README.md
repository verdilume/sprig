# Sprig

Sprig provides progress bars and spinners for Gleam on Erlang/BEAM. Its renderers
return strings for callers to print. Use Moss for standalone ANSI styling.

## Progress bars

The `progressbar` module renders a fixed-width bar using `█` for filled cells and
`░` for the empty track. `progressbar.new()` creates a 20-cell bar with a green
gradient from RGB `(0, 64, 8)` to `(0, 229, 29)`. The empty track is unstyled by
default.

- `progressbar.width(bar, cells)` sets the width; negative widths become zero.
- `progressbar.gradient(bar, start, end)` accepts RGB or hex-created `moss.Color`
  values, returning `Result(ProgressBar, GradientError)`. Named ANSI colors return
  `Error(progressbar.RgbRequired)` because their RGB values depend on the terminal
  palette. RGB channels are clamped to `0–255`.
- `progressbar.filled_style(bar, style)` replaces the gradient with any solid
  Moss style; use `moss.new()` for an uncolored fill.
- `progressbar.empty_style(bar, style)` styles the empty track.
- `progressbar.render(bar, progress)` returns a string, clamping progress to
  `0.0–1.0` and rounding partial cells down. A zero-width bar returns `""`.

```gleam
import progressbar

let bar = progressbar.new() |> progressbar.width(30)
let frame = progressbar.render(bar, 0.6)
```

Gradient colors stay anchored across the full bar width as progress changes.
A one-cell bar uses the gradient's start color. Width assumes `█` and `░` each
occupy one terminal column; a terminal font with block glyphs is required.
Custom glyphs and general Unicode display-width measurement are not implemented.

Run the animated showcase for the default green gradient, a custom purple-to-blue
gradient, and a solid cyan fill with a styled track:

```sh
gleam run -m progressbar_example
```

Each bar fills from 0% to 100% on one line; the example finishes in about eight
seconds. Press Ctrl+C to stop early. Timing, percentage labels, and terminal
redraws are handled in the example; the component itself only renders strings.

## Spinners

The `spinner` module provides seven looping presets, with no emoji:

| Preset | Motion | Interval |
| --- | --- | --- |
| `Dot` (default) | Rotating braille dots | 80 ms |
| `Line` | Rotating ASCII stroke | 120 ms |
| `MiniDot` | A small bouncing braille dot | 100 ms |
| `Jump` | A tumbling braille stroke | 100 ms |
| `Pulse` | Shading from `░` to `█` and back | 120 ms |
| `Points` | A highlighted dot moving across three points | 160 ms |
| `Bounce` | A dot bouncing across five columns | 80 ms |

- `spinner.new()` starts a `Dot` at its first frame in RGB `(0, 229, 29)`
  (`#00E51D`).
- `spinner.variant(value, preset)` selects a preset and resets its frame,
  preserving its style.
- `spinner.style(value, style)` applies any Moss style without changing the frame.
  It replaces the default green; use `moss.new()` for unstyled frames.
- `spinner.render(value)` returns the current frame without advancing it.
- `spinner.tick(value)` returns the next frame's state, wrapping after the last.
- `spinner.interval_ms(value)` returns the preset's recommended tick delay.

```gleam
import spinner

let loading =
  spinner.new()
  |> spinner.variant(spinner.Points)

let frame = "  " <> spinner.render(loading) <> "   Loading..."
// On the next timer event:
let loading = spinner.tick(loading)
```

The caller owns the timer, redraws, and stopping. Use `interval_ms` to schedule
ticks; rendering alone does not animate. Each preset keeps its own frame width
stable. Preserve trailing spaces, and clear the previous line when switching
between presets of different widths. `Line` uses only ASCII; the other presets
need a terminal font with braille, block, and dot glyphs.

Run the animated showcase to see every preset with the default green spinner,
a light-gray loading label, and padding around each line:

```sh
gleam run -m spinner_example
```

It cycles through all seven presets in about 18 seconds and exits. Press Ctrl+C
to stop early. Timers and terminal control codes are confined to this example.

## Example

Run the included example from this checkout in a terminal:

```sh
gleam run -m sprig_example
```

The example prints styled text followed by a plain line to demonstrate the reset:

```gleam
import gleam/io
import moss

pub fn main() -> Nil {
  moss.new()
  |> moss.foreground(moss.Green)
  |> moss.render("Sprig: named ANSI color")
  |> io.println

  let assert Ok(accent) = moss.hex("#ff7b13")

  moss.new()
  |> moss.foreground(accent)
  |> moss.background(moss.Color(12, 89, 174))
  |> moss.bold
  |> moss.italic
  |> moss.underline
  |> moss.render("Sprig: styled text")
  |> io.println

  io.println("Plain text: the style above has been reset.")
}
```

## Limitations

- Padding, borders, width measurement (including Unicode display width), and
  horizontal/vertical joining are not implemented yet.

## Development

Keep the Moss checkout at `../moss` so Gleam can resolve the local dependency.
GitHub Actions checks out Moss beside Sprig from `<owner>/moss` by default.
Set the `MOSS_REPOSITORY` Actions variable to `owner/repo` if Moss is hosted in
a different public repository.

```sh
gleam format --check src test
gleam check
gleam test
```
