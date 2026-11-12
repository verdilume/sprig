import gleeunit/should
import moss
import progressbar

pub fn default_width_test() {
  progressbar.new()
  |> progressbar.render(0.0)
  |> should.equal("░░░░░░░░░░░░░░░░░░░░")
}

pub fn default_gradient_test() {
  progressbar.new()
  |> progressbar.width(3)
  |> progressbar.render(1.0)
  |> should.equal(
    "\u{001b}[38;2;0;64;8m█\u{001b}[0m"
    <> "\u{001b}[38;2;0;147;19m█\u{001b}[0m"
    <> "\u{001b}[38;2;0;229;29m█\u{001b}[0m",
  )
}

pub fn gradient_positions_stay_fixed_test() {
  progressbar.new()
  |> progressbar.width(3)
  |> progressbar.render(0.75)
  |> should.equal(
    "\u{001b}[38;2;0;64;8m█\u{001b}[0m"
    <> "\u{001b}[38;2;0;147;19m█\u{001b}[0m░",
  )
}

pub fn progress_bounds_test() {
  let bar =
    progressbar.new()
    |> progressbar.width(4)
    |> progressbar.filled_style(moss.new())

  progressbar.render(bar, 0.0) |> should.equal("░░░░")
  progressbar.render(bar, -0.5) |> should.equal("░░░░")
  progressbar.render(bar, 1.0) |> should.equal("████")
  progressbar.render(bar, 1.5) |> should.equal("████")
}

pub fn partial_cells_round_down_test() {
  progressbar.new()
  |> progressbar.width(5)
  |> progressbar.filled_style(moss.new())
  |> progressbar.render(0.5)
  |> should.equal("██░░░")
}

pub fn nonpositive_width_test() {
  progressbar.new()
  |> progressbar.width(0)
  |> progressbar.render(1.0)
  |> should.equal("")

  progressbar.new()
  |> progressbar.width(-5)
  |> progressbar.render(0.5)
  |> should.equal("")
}

pub fn one_cell_gradient_test() {
  progressbar.new()
  |> progressbar.width(1)
  |> progressbar.render(1.0)
  |> should.equal("\u{001b}[38;2;0;64;8m█\u{001b}[0m")
}

pub fn custom_gradient_test() {
  let assert Ok(start) = moss.hex("#00c8ff")
  let assert Ok(end) = moss.hex("#ff000a")
  let assert Ok(bar) =
    progressbar.new()
    |> progressbar.width(3)
    |> progressbar.gradient(start, end)

  progressbar.render(bar, 1.0)
  |> should.equal(
    "\u{001b}[38;2;0;200;255m█\u{001b}[0m"
    <> "\u{001b}[38;2;128;100;133m█\u{001b}[0m"
    <> "\u{001b}[38;2;255;0;10m█\u{001b}[0m",
  )
}

pub fn gradient_channel_bounds_test() {
  let assert Ok(bar) =
    progressbar.new()
    |> progressbar.width(2)
    |> progressbar.gradient(moss.Color(-1, 256, 10), moss.Color(999, -5, 20))

  progressbar.render(bar, 1.0)
  |> should.equal(
    "\u{001b}[38;2;0;255;10m█\u{001b}[0m"
    <> "\u{001b}[38;2;255;0;20m█\u{001b}[0m",
  )
}

pub fn gradient_requires_rgb_test() {
  let bar = progressbar.new()
  let rgb = moss.Color(0, 229, 29)

  progressbar.gradient(bar, moss.Green, rgb)
  |> should.equal(Error(progressbar.RgbRequired))

  progressbar.gradient(bar, rgb, moss.Green)
  |> should.equal(Error(progressbar.RgbRequired))
}

pub fn styled_sections_test() {
  let filled = moss.new() |> moss.foreground(moss.Red) |> moss.bold
  let empty = moss.new() |> moss.foreground(moss.White)
  let bar =
    progressbar.new()
    |> progressbar.width(4)
    |> progressbar.filled_style(filled)
    |> progressbar.empty_style(empty)

  progressbar.render(bar, 0.5)
  |> should.equal("\u{001b}[1;31m██\u{001b}[0m\u{001b}[37m░░\u{001b}[0m")

  progressbar.render(bar, 0.0)
  |> should.equal("\u{001b}[37m░░░░\u{001b}[0m")

  progressbar.render(bar, 1.0)
  |> should.equal("\u{001b}[1;31m████\u{001b}[0m")
}

pub fn gradient_can_replace_solid_style_test() {
  let assert Ok(bar) =
    progressbar.new()
    |> progressbar.width(2)
    |> progressbar.filled_style(moss.new() |> moss.foreground(moss.Red))
    |> progressbar.gradient(moss.Color(0, 0, 0), moss.Color(255, 255, 255))

  progressbar.render(bar, 1.0)
  |> should.equal(
    "\u{001b}[38;2;0;0;0m█\u{001b}[0m"
    <> "\u{001b}[38;2;255;255;255m█\u{001b}[0m",
  )
}
