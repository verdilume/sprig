import gleam/io
import gleam/list
import spinner
import sprig

@external(erlang, "timer", "sleep")
fn sleep(milliseconds: Int) -> Nil

pub fn main() -> Nil {
  let text_style = sprig.new() |> sprig.foreground(sprig.Color(220, 220, 220))
  io.println("")
  list.each(
    [
      #(spinner.Dot, "Dot"),
      #(spinner.Line, "Line"),
      #(spinner.MiniDot, "MiniDot"),
      #(spinner.Jump, "Jump"),
      #(spinner.Pulse, "Pulse"),
      #(spinner.Points, "Points"),
      #(spinner.Bounce, "Bounce"),
    ],
    fn(preset) {
      let value = spinner.new() |> spinner.variant(preset.0)
      let label = sprig.render(text_style, "Loading... (" <> preset.1 <> ")")
      animate(value, label, 24)
      io.println("\n")
    },
  )
}

fn animate(value: spinner.Spinner, label: String, frames_left: Int) -> Nil {
  case frames_left {
    0 -> Nil
    _ -> {
      io.print("\r\u{001b}[2K  " <> spinner.render(value) <> "   " <> label)
      sleep(spinner.interval_ms(value))
      animate(spinner.tick(value), label, frames_left - 1)
    }
  }
}
