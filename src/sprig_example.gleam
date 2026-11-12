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
