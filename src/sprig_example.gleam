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
  |> sprig.background(sprig.Color(12, 89, 174))
  |> sprig.bold
  |> sprig.italic
  |> sprig.underline
  |> sprig.render("Sprig: styled text")
  |> io.println

  io.println("Plain text: the style above has been reset.")
}
