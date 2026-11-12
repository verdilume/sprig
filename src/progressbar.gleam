import gleam/float
import gleam/int
import gleam/list
import gleam/string
import moss

pub opaque type ProgressBar {
  ProgressBar(width: Int, fill: Fill, empty_style: moss.Style)
}

type Fill {
  Gradient(start: #(Int, Int, Int), end: #(Int, Int, Int))
  Solid(moss.Style)
}

pub type GradientError {
  RgbRequired
}

/// Create a 20-cell bar with a dark-to-light green fill and unstyled empty cells.
pub fn new() -> ProgressBar {
  ProgressBar(20, Gradient(#(0, 64, 8), #(0, 229, 29)), moss.new())
}

/// Set the width in terminal cells. Negative widths become zero.
pub fn width(bar: ProgressBar, value: Int) -> ProgressBar {
  ProgressBar(..bar, width: int.max(value, 0))
}

/// Set RGB gradient endpoints. Hex-created colors also work.
/// Named ANSI colors return `Error(RgbRequired)` because their RGB values vary
/// with the terminal palette. RGB channels are clamped to 0–255.
pub fn gradient(
  bar: ProgressBar,
  start: moss.Color,
  end: moss.Color,
) -> Result(ProgressBar, GradientError) {
  case start, end {
    moss.Color(r0, g0, b0), moss.Color(r1, g1, b1) -> {
      let start = #(
        int.clamp(r0, 0, 255),
        int.clamp(g0, 0, 255),
        int.clamp(b0, 0, 255),
      )
      let end = #(
        int.clamp(r1, 0, 255),
        int.clamp(g1, 0, 255),
        int.clamp(b1, 0, 255),
      )
      Ok(ProgressBar(..bar, fill: Gradient(start, end)))
    }
    _, _ -> Error(RgbRequired)
  }
}

/// Replace the gradient with a solid fill using any Moss style.
pub fn filled_style(bar: ProgressBar, style: moss.Style) -> ProgressBar {
  ProgressBar(..bar, fill: Solid(style))
}

/// Set the style of the empty cells.
pub fn empty_style(bar: ProgressBar, style: moss.Style) -> ProgressBar {
  ProgressBar(..bar, empty_style: style)
}

/// Render a fraction from 0.0 to 1.0, clamping values outside that range.
/// Partial cells are rounded down. A zero-width bar returns an empty string.
/// Gradient colors stay anchored to positions across the full bar width.
pub fn render(bar: ProgressBar, progress: Float) -> String {
  case bar.width {
    0 -> ""
    width -> {
      let progress = float.clamp(progress, 0.0, 1.0)
      let filled_cells = float.truncate(progress *. int.to_float(width))
      let empty_cells = width - filled_cells
      let filled = render_fill(bar.fill, filled_cells, width)
      let empty = case empty_cells {
        0 -> ""
        _ -> moss.render(bar.empty_style, string.repeat("░", empty_cells))
      }
      filled <> empty
    }
  }
}

fn render_fill(fill: Fill, cells: Int, width: Int) -> String {
  // shortcut: assumes █ and ░ are one column each; measure width before adding custom glyphs.
  case fill, cells {
    _, 0 -> ""
    Solid(style), _ -> moss.render(style, string.repeat("█", cells))
    Gradient(start, end), _ ->
      list.repeat("█", cells)
      |> list.index_map(fn(cell, index) {
        let position = case width {
          1 -> 0.0
          _ -> int.to_float(index) /. int.to_float(width - 1)
        }
        let color =
          moss.Color(
            interpolate(start.0, end.0, position),
            interpolate(start.1, end.1, position),
            interpolate(start.2, end.2, position),
          )
        moss.new()
        |> moss.foreground(color)
        |> moss.render(cell)
      })
      |> string.join("")
  }
}

fn interpolate(start: Int, end: Int, position: Float) -> Int {
  float.round(int.to_float(start) +. int.to_float(end - start) *. position)
}
