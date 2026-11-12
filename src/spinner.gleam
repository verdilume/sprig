import gleam/list
import moss

pub type Variant {
  Dot
  Line
  MiniDot
  Jump
  Pulse
  Points
  Bounce
}

pub opaque type Spinner {
  Spinner(variant: Variant, frame: Int, style: moss.Style)
}

/// Create a braille-dot spinner at its first frame in RGB (0, 229, 29).
pub fn new() -> Spinner {
  Spinner(Dot, 0, moss.new() |> moss.foreground(moss.Color(0, 229, 29)))
}

/// Select a preset and reset to its first frame, preserving the style.
pub fn variant(spinner: Spinner, value: Variant) -> Spinner {
  Spinner(..spinner, variant: value, frame: 0)
}

/// Style the frames using any Moss style, preserving the current frame.
pub fn style(spinner: Spinner, value: moss.Style) -> Spinner {
  Spinner(..spinner, style: value)
}

/// Recommended delay between ticks in milliseconds. The caller owns the timer.
pub fn interval_ms(spinner: Spinner) -> Int {
  let #(_, interval) = preset(spinner.variant)
  interval
}

/// Advance one frame, looping back to the first after the last.
pub fn tick(spinner: Spinner) -> Spinner {
  let #(frames, _) = preset(spinner.variant)
  let next = case spinner.frame + 1 == list.length(frames) {
    True -> 0
    False -> spinner.frame + 1
  }
  Spinner(..spinner, frame: next)
}

/// Render the current frame without advancing, printing, or scheduling a tick.
/// Frames within each preset have a fixed width, including any trailing spaces.
pub fn render(spinner: Spinner) -> String {
  let #(frames, _) = preset(spinner.variant)
  let assert [frame, ..] = list.drop(frames, spinner.frame)
  moss.render(spinner.style, frame)
}

fn preset(variant: Variant) -> #(List(String), Int) {
  case variant {
    Dot -> #(["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"], 80)
    Line -> #(["|", "/", "-", "\\"], 120)
    MiniDot -> #(["⠁", "⠂", "⠄", "⠂"], 100)
    Jump -> #(["⢄", "⢂", "⢁", "⡁", "⡈", "⡐", "⡠"], 100)
    Pulse -> #(["░", "▒", "▓", "█", "▓", "▒"], 120)
    Points -> #(["●··", "·●·", "··●"], 160)
    Bounce -> #(
      ["●    ", " ●   ", "  ●  ", "   ● ", "    ●", "   ● ", "  ●  ", " ●   "],
      80,
    )
  }
}
