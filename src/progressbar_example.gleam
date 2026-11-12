import gleam/dynamic.{type Dynamic}
import gleam/int
import gleam/io
import moss
import progressbar

@external(erlang, "timer", "sleep")
fn sleep(milliseconds: Int) -> Dynamic

pub fn main() -> Nil {
  let bar = progressbar.new() |> progressbar.width(30)
  io.println("Default green gradient")
  animate(bar)

  let assert Ok(start) = moss.hex("#5B2C90")
  let assert Ok(end) = moss.hex("#55D9FF")
  let assert Ok(custom) =
    progressbar.new()
    |> progressbar.width(30)
    |> progressbar.gradient(start, end)

  io.println("\nCustom purple-to-blue gradient")
  animate(custom)

  let solid =
    progressbar.new()
    |> progressbar.width(30)
    |> progressbar.filled_style(
      moss.new() |> moss.foreground(moss.Cyan) |> moss.bold,
    )
    |> progressbar.empty_style(
      moss.new() |> moss.foreground(moss.Color(96, 96, 96)),
    )

  io.println("\nSolid cyan with a styled empty track")
  animate(solid)

  io.println("Plain text: the progress bar styles have been reset.")
}

fn animate(bar: progressbar.ProgressBar) -> Nil {
  int.range(0, 101, Nil, fn(_, percent) {
    let progress = int.to_float(percent) /. 100.0
    io.print(
      "\r\u{001b}[2K  "
      <> progressbar.render(bar, progress)
      <> " "
      <> int.to_string(percent)
      <> "%",
    )
    let _ = sleep(25)
    Nil
  })
  io.println("")
}
