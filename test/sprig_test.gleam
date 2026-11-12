import gleam/list
import gleeunit
import gleeunit/should
import sprig

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn unstyled_render_test() {
  sprig.new()
  |> sprig.render("plain\ntext")
  |> should.equal("plain\ntext")

  sprig.new()
  |> sprig.render("")
  |> should.equal("")
}

pub fn foreground_test() {
  list.each(
    [
      #(sprig.Black, "\u{001b}[30mcolor\u{001b}[0m"),
      #(sprig.Red, "\u{001b}[31mcolor\u{001b}[0m"),
      #(sprig.Green, "\u{001b}[32mcolor\u{001b}[0m"),
      #(sprig.Yellow, "\u{001b}[33mcolor\u{001b}[0m"),
      #(sprig.Blue, "\u{001b}[34mcolor\u{001b}[0m"),
      #(sprig.Magenta, "\u{001b}[35mcolor\u{001b}[0m"),
      #(sprig.Cyan, "\u{001b}[36mcolor\u{001b}[0m"),
      #(sprig.White, "\u{001b}[37mcolor\u{001b}[0m"),
    ],
    fn(example) {
      let #(color, expected) = example
      sprig.new()
      |> sprig.foreground(color)
      |> sprig.render("color")
      |> should.equal(expected)
    },
  )
}

pub fn background_test() {
  list.each(
    [
      #(sprig.Black, "\u{001b}[40mcolor\u{001b}[0m"),
      #(sprig.Red, "\u{001b}[41mcolor\u{001b}[0m"),
      #(sprig.Green, "\u{001b}[42mcolor\u{001b}[0m"),
      #(sprig.Yellow, "\u{001b}[43mcolor\u{001b}[0m"),
      #(sprig.Blue, "\u{001b}[44mcolor\u{001b}[0m"),
      #(sprig.Magenta, "\u{001b}[45mcolor\u{001b}[0m"),
      #(sprig.Cyan, "\u{001b}[46mcolor\u{001b}[0m"),
      #(sprig.White, "\u{001b}[47mcolor\u{001b}[0m"),
    ],
    fn(example) {
      let #(color, expected) = example
      sprig.new()
      |> sprig.background(color)
      |> sprig.render("color")
      |> should.equal(expected)
    },
  )
}

pub fn bold_test() {
  sprig.new()
  |> sprig.bold
  |> sprig.render("bold")
  |> should.equal("\u{001b}[1mbold\u{001b}[0m")
}

pub fn italic_test() {
  sprig.new()
  |> sprig.italic
  |> sprig.render("italic")
  |> should.equal("\u{001b}[3mitalic\u{001b}[0m")
}

pub fn underline_test() {
  sprig.new()
  |> sprig.underline
  |> sprig.render("underline")
  |> should.equal("\u{001b}[4munderline\u{001b}[0m")
}

pub fn combined_style_test() {
  sprig.new()
  |> sprig.foreground(sprig.Green)
  |> sprig.background(sprig.Blue)
  |> sprig.bold
  |> sprig.italic
  |> sprig.underline
  |> sprig.render("Sprig")
  |> should.equal("\u{001b}[1;3;4;32;44mSprig\u{001b}[0m")
}

pub fn trailing_reset_test() {
  let styled =
    sprig.new()
    |> sprig.foreground(sprig.Red)
    |> sprig.render("styled")

  should.equal(styled <> " plain", "\u{001b}[31mstyled\u{001b}[0m plain")
}

pub fn rgb_foreground_test() {
  sprig.new()
  |> sprig.foreground(sprig.Color(255, 123, 19))
  |> sprig.render("custom")
  |> should.equal("\u{001b}[38;2;255;123;19mcustom\u{001b}[0m")
}

pub fn rgb_background_test() {
  sprig.new()
  |> sprig.background(sprig.Color(74, 89, 174))
  |> sprig.render("custom")
  |> should.equal("\u{001b}[48;2;74;89;174mcustom\u{001b}[0m")
}

pub fn rgb_channel_bounds_test() {
  sprig.new()
  |> sprig.foreground(sprig.Color(-1, 256, 128))
  |> sprig.background(sprig.Color(999, -20, 300))
  |> sprig.render("clamped")
  |> should.equal("\u{001b}[38;2;0;255;128;48;2;255;0;255mclamped\u{001b}[0m")
}

pub fn hex_test() {
  sprig.hex("#88C070")
  |> should.equal(Ok(sprig.Color(136, 192, 112)))

  sprig.hex("88c070")
  |> should.equal(Ok(sprig.Color(136, 192, 112)))

  sprig.hex("#000000")
  |> should.equal(Ok(sprig.Color(0, 0, 0)))

  sprig.hex("#ffffff")
  |> should.equal(Ok(sprig.Color(255, 255, 255)))
}

pub fn invalid_hex_test() {
  list.each(
    ["", "#", "#fff", "#1234567", "#gg0000", "0x1234", "##123456", " 123456"],
    fn(value) {
      sprig.hex(value)
      |> should.equal(Error(sprig.InvalidHex))
    },
  )
}

pub fn hex_with_named_color_test() {
  let assert Ok(accent) = sprig.hex("#88C070")

  sprig.new()
  |> sprig.foreground(accent)
  |> sprig.background(sprig.Blue)
  |> sprig.bold
  |> sprig.render("Sprig")
  |> should.equal("\u{001b}[1;38;2;136;192;112;44mSprig\u{001b}[0m")
}
